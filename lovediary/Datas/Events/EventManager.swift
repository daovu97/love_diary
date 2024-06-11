//
//  EventManager.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation
import Combine
import UIKit

private var defaultReminderTime = "12:00".toDate(pattern: "HH:mm")

protocol EventManagerType: class {
    func getEvent() ->  AnyPublisher<[EventModel], Never>
    func getAllEvent() ->  AnyPublisher<[EventModel], Error>
    func getOutDateEvent() ->  AnyPublisher<[EventModel], Never>
    func searchEvent(searchText: String) ->  AnyPublisher<[EventModel], Never>
    func addNewEvent(event: EventModel) -> AnyPublisher<EventModel, Never>
    func addNewEventErr(events: [EventModel]) -> AnyPublisher<Void, Error>
    func updateEvent(event: EventModel) -> AnyPublisher<Void, Never>
    func updatePin(event: EventModel) -> AnyPublisher<Void, Never>
    func addEvent(events: [EventModel]) -> AnyPublisher<[EventModel], Never>
    func updateDefaultEvent() -> AnyPublisher<Void, Never>
    func updateDefaultEventErr() -> AnyPublisher<Void, Error>
    func deleteEvent(event: EventModel) -> AnyPublisher<Void, Never>
    func update(with event: EventModel,_ pushedStatus: PushStatus) -> AnyPublisher<Void, Never>
    func findAllWaitPushNotification() -> [EventModel]
    func findAllExprisePushNotification() -> [EventModel]
    func findAllWaitRegisterNotification() -> [EventModel]
    func updateReminderStatus()
    func updateBadget()
    func deleteAll() -> AnyPublisher<Void, Error>
}

class EventManager: EventManagerType {
    func deleteAll() -> AnyPublisher<Void, Error> {
        return eventDao.deleteAllErr()
    }
    
    func getAllEvent() -> AnyPublisher<[EventModel], Error> {
        return eventDao.getAllEventsErr().map {
            $0.map { $0.toModel() }
        }.eraseToAnyPublisher()
    }
    
    func getOutDateEvent() -> AnyPublisher<[EventModel], Never> {
        let filter = NSPredicate(format: "date < %@", argumentArray: [Date().midnight])
        let sort = NSSortDescriptor(key: "date", ascending: false)
        return eventDao.get(with: [filter], sortDescriptors: [sort]).map { entities -> [EventModel] in
            return entities.map { $0.toModel() }
        }.eraseToAnyPublisher()
    }
    
    
    private lazy var reminderHelper = EventReminderHelper(eventManager: self)
    
    private lazy var eventDao: EventDaoType = EventDao()
    
    func findAllWaitPushNotification() -> [EventModel] {
        let filter = NSPredicate(format: "reminderDateTime > %@ && pushedStatus == %@", argumentArray: [Date(), PushStatus.waitingPush.rawValue])
        return eventDao.getValue(with: [filter], sortDescriptors: []).map { $0.toModel() }
    }
    
    func updateBadget() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = self.getTodayReminder().count
        }
    }
    
    private func getTodayReminder() -> [EventModel] {
        let filter = NSPredicate(format: "date >= %@ && date =< %@", argumentArray: [Date().midnight, Date().endOfDay])
        return eventDao.getValue(with: [filter], sortDescriptors: []).map { $0.toModel() }
    }
    
    func updateReminderStatus() {
        reminderHelper.updateReminderStatus()
    }
    
    func findAllExprisePushNotification() -> [EventModel] {
        let filter = NSPredicate(format: "reminderDateTime < %@", argumentArray: [Date()])
        return eventDao.getValue(with: [filter], sortDescriptors: []).map { $0.toModel() }
    }
    
    func findAllWaitRegisterNotification() -> [EventModel] {
        let filter = NSPredicate(format: "reminderDateTime >= %@ && pushedStatus == %@", argumentArray: [Date(), PushStatus.waitingRegister.rawValue])
        return eventDao.getValue(with: [filter], sortDescriptors: []).map { $0.toModel() }
    }
    
    func update(with event: EventModel, _ pushedStatus: PushStatus) -> AnyPublisher<Void, Never> {
        var tempEvent = event
        tempEvent.pushedStatus = pushedStatus
        return eventDao.add(entity: tempEvent.toEntity()).eraseToVoidAnyPublisher()
    }
    
    func deleteEvent(event: EventModel) -> AnyPublisher<Void, Never> {
        reminderHelper.removePendingTodoReminder(with: [event.id])
        return eventDao.delete(by: event.id)
            .receiveOutput(outPut: {[weak self] _ in  self?.updateBadget() })
            .eraseToAnyPublisher()
    }
    
    func getEvent() -> AnyPublisher<[EventModel], Never> {
        let filter = NSPredicate(format: "date > %@", argumentArray: [Date().midnight])
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let isPinned = NSSortDescriptor(key: "pinned", ascending: false)
        return eventDao.get(with: [filter], sortDescriptors: [isPinned, sort]).map { entities -> [EventModel] in
            return entities.map { $0.toModel() }
        }.eraseToAnyPublisher()
    }
    
    func addEvent(events: [EventModel]) -> AnyPublisher<[EventModel], Never> {
        reminderHelper.createTodoReminders(with: events)
        return eventDao.add(entities: events.map { $0.toEntity() }).map {_ in return events }
            .receiveOutput(outPut: {[weak self] _ in  self?.updateBadget() })
            .eraseToAnyPublisher()
    }
    
    func addNewEventErr(events: [EventModel]) -> AnyPublisher<Void, Error> {
        reminderHelper.createTodoReminders(with: events)
        return eventDao.addErr(entities: events.map { $0.toEntity() }).map {_ in return () }
            .receiveOutput(outPut: {[weak self] _ in  self?.updateBadget() })
            .eraseToAnyPublisher()
    }
    
    func addNewEvent(event: EventModel) -> AnyPublisher<EventModel, Never> {
        reminderHelper.createTodoReminders(with: [event])
        return eventDao.add(entity: event.toEntity()).map { $0.toModel() }
            .receiveOutput(outPut: {[weak self] _ in  self?.updateBadget() })
            .eraseToAnyPublisher()
    }
    
    func updatePin(event: EventModel) -> AnyPublisher<Void, Never> {
        return eventDao.add(entity: event.toEntity())
            .receiveOutput(outPut: {[weak self] _ in  self?.updateBadget() })
            .eraseToVoidAnyPublisher()
    }
    
    func updateEvent(event: EventModel) -> AnyPublisher<Void, Never> {
        reminderHelper.updateTodoReminder(with: event)
        return eventDao.add(entity: event.toEntity())
            .receiveOutput(outPut: {[weak self] _ in  self?.updateBadget() })
            .eraseToVoidAnyPublisher()
    }
    
    private func defaultEvents() -> [EventModel] {
        return [
            .init(id: "1", title: LocalizedString.valentineDayTitle,
                  reminderType: .oneDayBefore,
                  reminderTime: defaultReminderTime,
                  date: Date.valentinday < Date() ? Date.valentinday.nextYear : Date.valentinday,
                  pinned: false, isDefault: true),
            .init(id: "2", title: LocalizedString.whiteDayTitle,
                  reminderType: .oneDayBefore,
                  reminderTime: defaultReminderTime,
                  date: Date.whiteDay < Date() ? Date.whiteDay.nextYear : Date.whiteDay,
                  pinned: false, isDefault: true),
            .init(id: "3", title: LocalizedString.oneYearAnniversaryTitle,
                  reminderType: .oneDayBefore,
                  reminderTime: defaultReminderTime,
                  date: AnnivesaryTime.time.nextYear, pinned: false,
                  isDefault: true),
            .init(id: "4", title: LocalizedString.twoYearAnniversaryTitle,
                  reminderType: .oneDayBefore,
                  reminderTime: defaultReminderTime,
                  date: AnnivesaryTime.time.add(years: 2),
                  pinned: false, isDefault: true),
            .init(id: "5", title: LocalizedString.threeYearAnniversaryTitle,
                  reminderType: .oneDayBefore,
                  reminderTime: defaultReminderTime,
                  date: AnnivesaryTime.time.add(years: 3),
                  pinned: false, isDefault: true)
        ]
    }
    
    func updateDefaultEvent() -> AnyPublisher<Void, Never> {
        return eventDao.updateDefault(entities: defaultEvents().map { $0.toEntity() })
    }
    
    func updateDefaultEventErr() -> AnyPublisher<Void, Error> {
        return eventDao.updateDefaultErr(entities: defaultEvents().map { $0.toEntity() })
    }
    
    func searchEvent(searchText: String) -> AnyPublisher<[EventModel], Never> {
        if searchText.isEmpty {
            return getEvent()
        }
        
        let sort = NSSortDescriptor(key: "date", ascending: true)
        return eventDao.get(with: [], sortDescriptors: [sort]).map { entities -> [EventModel] in
            let fillterd = entities.filter { event -> Bool in
                return event.title.lowercased().contains(searchText.lowercased()) || event.detail.lowercased().contains(searchText.lowercased())
            }
            return fillterd.map { $0.toModel() }
        }.eraseToAnyPublisher()
    }
}
