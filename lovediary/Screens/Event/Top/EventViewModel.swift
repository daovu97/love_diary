//
//  EventViewModel.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation
import Combine

class EventViewModel: ViewModelType {
    
    private let navigator: EventNavigatorType
    private let dependecy: Dependency
    
    init(navigator: EventNavigatorType, dependecy: Dependency) {
        self.navigator = navigator
        self.dependecy = dependecy
    }
    
    struct Dependency {
        let eventManager: EventManagerType
    }
    
    struct Input {
        let loadData: AnyPublisher<String, Never>
        let action: AnyPublisher<(EventModel, EventTVAction), Never>
        let toEventDetail: AnyPublisher<EventModel?, Never>
        let searchText: AnyPublisher<String, Never>
        let toOutDateEvent: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let events: AnyPublisher<[EventModel], Never>
        let actionVoid: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input) -> Output {
        let shouldReload = PassthroughSubject<String, Never>()
        var keySearch = ""
        
        let searchTrigger = input.searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
        
        let loadData = Publishers.Merge3(shouldReload, input.loadData, searchTrigger)
            .flatMap {[weak self] searchText -> AnyPublisher<[EventModel], Never> in
                guard let self = self else { return .empty() }
                keySearch = searchText
                return self.dependecy.eventManager.searchEvent(searchText: searchText)
            }
            .eraseToAnyPublisher()
        
        let action = input.action
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .share()
        
        let deleteAction = action.filter {return $0.1 == .delete }
            .flatMap{ event, _ -> AnyPublisher<EventModel, Never> in
               return AlertManager.shared.showConfirmMessage(message: LocalizedString.deleteDiaryConfirm,
                                                       confirm: LocalizedString.delete, cancel: LocalizedString.cancel,
                                                       isDelete: true)
                    .flatMap { select -> AnyPublisher<EventModel?, Never>  in
                        return .just(select == .confirm ? event : nil)
                    }.compactMap { $0 }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .flatMap { [weak self] event -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return self.dependecy.eventManager.deleteEvent(event: event)
                    .receive(on: DispatchQueue.main)
                    .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)
                    .receiveOutput { _ in
                        shouldReload.send(keySearch)
                    }
            }
        
        let pinAction = action.filter {return $0.1 == .pin || $0.1 == .unpin }
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .flatMap { [weak self] event, _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                var eventTemp = event
                eventTemp.pinned = !eventTemp.pinned
                return self.dependecy.eventManager.updatePin(event: eventTemp)
                    .receive(on: DispatchQueue.main)
                    .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)
                    .receiveOutput { _ in
                        shouldReload.send(keySearch)
                    }
            }
        
        let toEventDetail = input.toEventDetail
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receiveOutput(outPut: {[weak self] in
                guard let self = self else { return }
                self.navigator.toEventDetail(event: $0) { shouldReload.send(keySearch) }
            }).eraseToVoidAnyPublisher()
        
        let toOutDateEvent = input.toOutDateEvent.receiveOutput {[weak self] _ in
            self?.navigator.toOutDateEvent()
        }
        
        return .init(events: loadData.eraseToAnyPublisher(),
                     actionVoid: Publishers.Merge4(deleteAction, toEventDetail, pinAction, toOutDateEvent).eraseToVoidAnyPublisher())
    }
}
