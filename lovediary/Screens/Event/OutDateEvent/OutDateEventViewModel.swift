//
//  OutDateEventViewModel.swift
//  lovediary
//
//  Created by daovu on 08/04/2021.
//

import Foundation
import Combine

class OutDateEventViewModel: ViewModelType {
    private let dependecy: Dependency
    private let navigator: OutDateEventNavigatorType
    
    init(navigator: OutDateEventNavigatorType, dependecy: Dependency) {
        self.navigator = navigator
        self.dependecy = dependecy
    }
    
    struct Dependency {
        let eventManager: EventManagerType
    }
    
    struct Input {
        let loadData: AnyPublisher<Void, Never>
        let delete: AnyPublisher<EventModel, Never>
        let toEventDetail: AnyPublisher<EventModel, Never>
    }
    
    struct Output {
        let events: AnyPublisher<[EventModel], Never>
        let actionVoid: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input) -> Output {
        
        let shouldReload = PassthroughSubject<Void, Never>()
        
        let events = Publishers.Merge(shouldReload, input.loadData)
            .flatMap {[weak self] _  ->  AnyPublisher<[EventModel], Never> in
                guard let self = self else { return .empty() }
                return self.dependecy.eventManager.getOutDateEvent()
            }.eraseToAnyPublisher()
        
        let deleteAction = input.delete
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .flatMap { [weak self] event -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return self.dependecy.eventManager.deleteEvent(event: event)
                    .receive(on: DispatchQueue.main)
                    .delay(for: .milliseconds(50), scheduler: DispatchQueue.main)
                    .receiveOutput { _ in
                        shouldReload.send()
                    }
            }
        
        let toEventDetail = input.toEventDetail
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receiveOutput(outPut: {[weak self] in
                guard let self = self else { return }
                self.navigator.toEventDetail(event: $0) { shouldReload.send() }
            }).eraseToVoidAnyPublisher()
        
        return .init(events: events,
                     actionVoid: Publishers.Merge(deleteAction, toEventDetail)
                        .eraseToAnyPublisher())
    }
}
