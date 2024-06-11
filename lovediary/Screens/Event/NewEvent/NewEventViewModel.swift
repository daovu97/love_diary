//
//  NewEventViewModel.swift
//  lovediary
//
//  Created by daovu on 05/04/2021.
//

import Combine
import Foundation

class NewEventViewModel: ViewModelType {
    
    private let dependecy: Dependency
    private let navigator: NewEventNavigatorType
    var currentEvent: EventModel?
    var isOudate: Bool
    init(dependecy: Dependency,
         navigator: NewEventNavigatorType,
         event: EventModel?, isOudate: Bool = false) {
        self.dependecy = dependecy
        self.navigator = navigator
        self.currentEvent = event
        self.isOudate = isOudate
    }
    
    struct Dependency {
        let eventManager: EventManagerType
    }
    
    struct Input {
        let eventTitle: AnyPublisher<String, Never>
        let eventDetail: AnyPublisher<String, Never>
        let isPin: AnyPublisher<Bool, Never>
        let eventDate: AnyPublisher<Date, Never>
        let usingTime: AnyPublisher<Bool, Never>
        let eventTime: AnyPublisher<Date, Never>
        let remiderSelect: AnyPublisher<Void, Never>
        let reminderTime: AnyPublisher<Date, Never>
        
        let saveTrigger: AnyPublisher<Void, Never>
        let dismissTrigger: AnyPublisher<Void, Never>
        let deleteEventTrigger: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let editComplete: AnyPublisher<Void, Never>
        let shouldDismiss: AnyPublisher<Bool, Never>
        let isUsingTime: AnyPublisher<Bool, Never>
        let reminderType: AnyPublisher<ReminderType, Never>
        let shouldSave: AnyPublisher<Bool, Never>
        let actionVoid: AnyPublisher<Void, Never>
        let event: AnyPublisher<EventModel, Never>
        let isEdit: AnyPublisher<(Bool, Bool), Never>
    }
    
    func transform(_ input: Input) -> Output {
        let current = Date()
        let title = currentEvent?.title ?? ""
        let isPinValue = currentEvent?.pinned ?? false
        let dateValue = currentEvent?.date ?? current
        var shouldDismiss = true
        
        let eventTitle = CurrentValueSubject<String, Never>(title)
        let eventDetail = CurrentValueSubject<String, Never>(currentEvent?.detail ?? "")
        let isPin = CurrentValueSubject<Bool, Never>(isPinValue)
        let eventDate = CurrentValueSubject<Date, Never>(currentEvent?.date ?? current)
        let usingTime = CurrentValueSubject<Bool, Never>(currentEvent?.time != nil)
        let eventTime = CurrentValueSubject<Date, Never>(currentEvent?.time ?? current)
        let remiderSelect = CurrentValueSubject<ReminderType, Never>(currentEvent?.reminderType ?? .none)
        let reminderTime = CurrentValueSubject<Date, Never>(currentEvent?.reminderTime ?? eventTime.value)
        
        let eventTitleChange = input.eventTitle.receiveOutput {  eventTitle.send($0) }.eraseToVoidAnyPublisher()
        let eventDetailChange = input.eventDetail.receiveOutput {  eventDetail.send($0) }.eraseToVoidAnyPublisher()
        let isPinChange = input.isPin.receiveOutput { isPin.send($0) }.eraseToVoidAnyPublisher()
        let eventDateChange = input.eventDate.receiveOutput {  eventDate.send($0) }.eraseToVoidAnyPublisher()
        let usingTimeChange = input.usingTime.receiveOutput {
            if remiderSelect.value.isRiminderTime && $0 == false { remiderSelect.send(.none) }
            usingTime.send($0) }.eraseToVoidAnyPublisher()
        let eventTimeChange = input.eventTime.receiveOutput {  eventTime.send($0) }.eraseToVoidAnyPublisher()
        let remiderSelectChange = input.remiderSelect.receiveOutput {[weak self] in
            self?.navigator.showReminderSetting(isTime: usingTime.value, currentReminderType: remiderSelect.value) {
                remiderSelect.send($0)
            }
        }.eraseToVoidAnyPublisher()
        let reminderTimeChange = input.reminderTime.receiveOutput {  reminderTime.send($0) }.eraseToVoidAnyPublisher()
        
        let shouldDismissed = Publishers.CombineLatest3(eventTitle, isPin, eventDate)
            .map { name, icon, color -> Bool in
                shouldDismiss = (name != title || icon != isPinValue || color != dateValue)
                return shouldDismiss
            }.eraseToAnyPublisher()
        
        let saveComplete = input.saveTrigger
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .flatMap {[weak self] eventModel -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                
                let time = usingTime.value ? eventTime.value : nil
                let date: Date = eventDate.value
                let reminderTimeValue = remiderSelect.value.isRiminderDay ? reminderTime.value : nil
                
                let event = EventModel(id: self.currentEvent?.id ?? UUID().uuidString,
                                       title: eventTitle.value,
                                       detail: eventDetail.value,
                                       reminderType: remiderSelect.value,
                                       reminderTime: reminderTimeValue,
                                       date: date,
                                       time: time,
                                       pinned: isPin.value,
                                       isDefault: self.currentEvent?.isDefault ?? false)
                if self.currentEvent == nil {
                    return self.dependecy.eventManager.addNewEvent(event: event).eraseToVoidAnyPublisher()
                } else {
                    return self.dependecy.eventManager.updateEvent(event: event).eraseToVoidAnyPublisher()
                }
            }.receive(on: DispatchQueue.main)
        
        let deleteComplete = input.deleteEventTrigger
            .compactMap{[weak self] in return self?.currentEvent }
            .flatMap { event -> AnyPublisher<EventModel, Never> in
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
                    .eraseToAnyPublisher()
            }
        
        let dismiss = input.dismissTrigger
            .receiveOutput(outPut: {[weak self] _ in
                if !shouldDismiss {
                    self?.navigator.dismiss()
                } else {
                    self?.navigator.showDismissAlert()
                }
            }).eraseToVoidAnyPublisher()
        
        return .init(editComplete: Publishers.Merge(saveComplete, deleteComplete).eraseToVoidAnyPublisher(),
                     shouldDismiss: shouldDismissed,
                     isUsingTime: usingTime.eraseToAnyPublisher(),
                     reminderType: remiderSelect.eraseToAnyPublisher(),
                     shouldSave: eventTitle.map { return !$0.isEmpty }.eraseToAnyPublisher(),
                     actionVoid: Publishers.MergeMany(
                        [eventTitleChange, eventDetailChange, isPinChange,
                         eventDateChange, eventDateChange, usingTimeChange,
                         eventTimeChange, remiderSelectChange,
                         dismiss,
                         reminderTimeChange]).eraseToVoidAnyPublisher(),
                     event: Just(currentEvent).compactMap { $0 }.eraseToAnyPublisher(),
                     isEdit: .just((currentEvent != nil, currentEvent?.isDefault == true)))
    }
}
