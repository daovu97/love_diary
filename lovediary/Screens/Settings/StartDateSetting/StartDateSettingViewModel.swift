//
//  StartDateSettingViewModel.swift
//  lovediary
//
//  Created by daovu on 24/03/2021.
//

import Foundation
import Combine

class StartDateSettingViewModel: ViewModelType {
    
    private let dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    struct Dependency {
        let userManager: UserManagermentType
        let eventManager: EventManagerType
    }
    
    struct Input {
        var loadData: AnyPublisher<Void, Never>
        var dateChange: AnyPublisher<Date, Never>
    }
    struct Output {
        var date: AnyPublisher<Date, Never>
    }
    
    func transform(_ input: Input) -> Output {
        let timeInfo = input.loadData.flatMap {_ -> AnyPublisher<Date, Never> in
            return .just(AnnivesaryTime.time)
        }.eraseToAnyPublisher()
        
        let dateChange = input.dateChange.removeDuplicates()
            .flatMap {date -> AnyPublisher<Date, Never> in
                AnnivesaryTime.setTime(time: date)
                return self.dependency.eventManager.updateDefaultEvent()
                    .map { return date }
                    .receiveOutput(outPut: {[weak self] date in
                        self?.dependency.eventManager.updateReminderStatus()
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        return Output(date: Publishers.Merge(timeInfo, dateChange).eraseToAnyPublisher())
    }
}
