//
//  DiariesViewModel.swift
//  lovediary
//
//  Created by daovu on 17/03/2021.
//

import Combine
import Foundation

enum LoadAction {
    case today
    case custome(date: Date)
    case reload
    case next
    case previous
}

class DiariesViewModel: ViewModelType {
    
    private var dependency: Dependency
    private var navigator: DiariesNavigatorType
    
    private var currentDate = Date()
   
    init(dependency: Dependency, navigator: DiariesNavigatorType) {
        self.dependency = dependency
        self.navigator = navigator
    }
    
    struct Dependency {
        var repo: DiaryManagerType
    }
    
    struct Input {
        var loadDiarysTrigger: AnyPublisher<LoadAction, Never>
        var toDiaryDetail: AnyPublisher<DiaryModel?, Never>
        var deleteTrigger: AnyPublisher<DiaryModel, Never>
        var toSearchDiary: AnyPublisher<Void, Never>
        var viewWillAppear: AnyPublisher<Void, Never>
        var loadCalendarDataTrigger: AnyPublisher<Date, Never>
    }
    
    struct Output {
        var actionVoid: AnyPublisher<Void, Never>
        var diarys: AnyPublisher<[DiaryModel], Never>
        var currentDate: AnyPublisher<Date, Never>
        var calendarDateEvents: AnyPublisher<Set<Date>, Never>
    }
    
    func transform(_ input: Input) -> Output {
        var currentMonthLoad = Date()
        
        let didToDiaryDetail = input.toDiaryDetail
            .receiveOutput {[weak self] in
                self?.navigator.toDiaryDetail(diaryModel: $0,
                                              createDate: self?.currentDate)  }
            .eraseToVoidAnyPublisher()
    
        let reloadAtDate = NotificationCenter.default.publisher(for: .shouldReloadDiaryNotification)
            .compactMap { notification -> Date? in
                return notification.userInfo?[Notification.Name.shouldReloadDiaryNotification] as? Date
            }.share()
        
        let observerChange = reloadAtDate
            .filter {[weak self] in
                guard let self = self else { return false }
                return $0.isInSameDay(as: self.currentDate) }
            .eraseToVoidAnyPublisher()
            
        
        let shouldReload = Publishers.CombineLatest(input.viewWillAppear, observerChange).map { _ in return LoadAction.reload }
            .eraseToAnyPublisher()
        
        let dateChange = Publishers.Merge(shouldReload, input.loadDiarysTrigger)
            .flatMap {[weak self] action -> AnyPublisher<Date, Never> in
            guard let self = self else { return .empty() }
            switch action {
            case .today:
                self.currentDate = Date()
                return .just(self.currentDate)
            case .custome(let date):
                if date.isInSameDay(as: self.currentDate) {
                    return .empty()
                } else {
                    self.currentDate = date
                }
                return .just(self.currentDate)
            case .reload:
                return .just(self.currentDate)
            case .next:
                return self.dependency.repo.getEventDateNext(from: self.currentDate)
                    .receiveOutput {  self.currentDate = $0 }
            case .previous:
                return self.dependency.repo.getEventDatePrevious(from: self.currentDate)
                    .receiveOutput {  self.currentDate = $0 }
            }
           
        }.eraseToAnyPublisher()
        .share()
        
        let diaries = dateChange.flatMap { [weak self] action -> AnyPublisher<[DiaryModel], Never> in
            guard let self = self else { return .empty() }
            return self.dependency.repo
                .getAllDiary(startDate: self.currentDate.midnight, toDate: self.currentDate.endOfDay)
        }
        
        let displayDate = Publishers.Merge(Just(currentDate), dateChange)
        
        let delete = input.deleteTrigger.flatMap({[weak self] diaryModel -> AnyPublisher<Void, Never> in
            guard let self = self else { return .empty() }
            return self.dependency.repo.deleteDiary(diaryModel: diaryModel)
        }).eraseToVoidAnyPublisher()
        
        let toSearchTrigger = input.toSearchDiary.receiveOutput { [weak self] in
            self?.navigator.toSearchDiary()
        }.eraseToVoidAnyPublisher()
        
        let reloadCalendar = reloadAtDate.flatMap { date -> AnyPublisher<Date, Never> in
            if date.isEqualMonthInYear(with: currentMonthLoad) {
                return .just(date)
            }
            
            return .empty()
        }.eraseToAnyPublisher()
        
        let loadAllDateDiary = Publishers.Merge(input.loadCalendarDataTrigger, reloadCalendar)
            .flatMap {[weak self] date -> AnyPublisher<Set<Date>, Never> in
            guard let self = self else { return .empty() }
            currentMonthLoad = date
            return self.dependency.repo.getDiaryByDateCalendar(from: date.startOfMonth, to: date.endOfMonth)
        }.eraseToAnyPublisher()
        
        return Output(actionVoid: Publishers.Merge3(didToDiaryDetail,
                                                    delete,
                                                    toSearchTrigger).eraseToVoidAnyPublisher(),
                      diarys: diaries.eraseToAnyPublisher(),
                      currentDate: displayDate.eraseToAnyPublisher(),
                      calendarDateEvents: loadAllDateDiary)
    }
}
