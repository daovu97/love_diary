//
//  EventReminderHelper.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation

import UIKit
import Combine
import Configuration

class EventReminderHelper {
    
    private var anycanCelables = Set<AnyCancellable>()
    private weak var eventManager: EventManagerType?
    
    init(eventManager: EventManagerType) {
        self.eventManager = eventManager
    }
    
    func canCreateTodoReminder() -> Bool {
        guard let eventmanager = eventManager else { return false }
        let numberOfWaitPushTodo = eventmanager.findAllWaitPushNotification().count
        return numberOfWaitPushTodo < AppConfigs.maximumTodoPendingNotifications
    }
    
    func updateReminderStatus() {
        // Remove all expired reminder
        if let allTodoExpired = eventManager?.findAllExprisePushNotification() {
            let isTodoHasNotifyDate = allTodoExpired.filter { $0.hasNotifyDate() }.count > 0
            if isTodoHasNotifyDate {
                let allExpiredTodoId = allTodoExpired.map { "\($0.id)" }
                NotificationHelper.removePendingNotificationByIdentifier(withIdentifiers: allExpiredTodoId)
                allTodoExpired.forEach { todo in
                    eventManager?.update(with: todo, .pushed).sink{ }.store(in: &anycanCelables)
                }
            }
            
        }
        // register new reminder
        if let allWaitToRegister = eventManager?.findAllWaitRegisterNotification() {
            if allWaitToRegister.count > 0 {
                createTodoReminders(with: allWaitToRegister)
            }
        }
    }
    
    func updateTodoReminder(with newTodo: EventModel) {
        // Because it may doesnt have notify date
        if newTodo.hasNotifyDate() {
            NotificationHelper.removePendingNotificationByIdentifier(withIdentifiers: ["\(newTodo.id)"])
            eventManager?.update(with: newTodo, .waitingRegister).sink{ }.store(in: &anycanCelables)
            createTodoReminders(with: [newTodo])
        }
    }
    
    func removePendingTodoReminder(with identifiers: [String]) {
        // Remove pending todo
        NotificationHelper.removePendingNotificationByIdentifier(withIdentifiers: identifiers)
        
        // register new reminder
        if let allWaitToRegister = eventManager?.findAllWaitPushNotification() {
            if allWaitToRegister.count > 0 {
                createTodoReminders(with: allWaitToRegister)
            }
        }
    }
    
    //swiftlint:disable superfluous_disable_command
    func createTodoReminders(with events: [EventModel]) {
        let isTodoHasNotifyDate = events.filter { $0.hasNotifyDate() }.count > 0
        if isTodoHasNotifyDate {
            NotificationHelper.removeAllDeliveredNotifications()
            NotificationHelper.requestAuthorization(error: { error in
                print(error.localizedDescription)
            }, completion: { [weak self] granted in
                guard let self = self else { return }
                if NotificationPermissionStatus.canCreateNotification {
                    self.handlerGrantedStatus(granted, events: events)
                }
            })
        }
    }
    //swiftlint:enable superfluous_disable_command
    
    private func handlerGrantedStatus(_ granted: Bool, events: [EventModel]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if granted {
                for event in events {
                    if self.canCreateTodoReminder() {
                        NotificationHelper.removePendingNotificationByIdentifier(withIdentifiers: ["\(event.id)"])
                        self.createTodoReminder(with: event)
                    } else {
                        break
                    }
                }
            }
            Settings.isAllowNotificationPermission.value = granted ? NotificationPermissionStatus.allow.rawValue : NotificationPermissionStatus.decline.rawValue
        }
    }
    
    private func createTodoReminder(with event: EventModel) {
        NotificationHelper.createNotificationRequests(event: event)
            .flatMap {[weak self] _ -> AnyPublisher<Void, Never> in
                guard let eventManager = self?.eventManager else { return .empty() }
                print("daovu + createNotificationRequests")
                return eventManager.update(with: event, .waitingPush)
            }.sink {}.store(in: &anycanCelables)
    }
    
    deinit {
        anycanCelables.cancel()
    }
}

extension Set where Element == AnyCancellable {
    mutating func cancel() {
        self.forEach { $0.cancel() }
        self.removeAll()
    }
}
