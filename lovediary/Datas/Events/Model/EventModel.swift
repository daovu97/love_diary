//
//  EventModel.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation

enum PushStatus: Int {
    case waitingPush
    case pushed
    case waitingRegister
}

struct EventModel {
    var id: String
    var title: String = ""
    var detail: String = ""
    var date: Date
    var time: Date?
    var pinned: Bool = false
    var reminderType: ReminderType = .none
    var reminderTime: Date?
    var pushedStatus: PushStatus = .waitingRegister
    var reminderDateTime: Date?
    
    var isDefault = false
    
    init(id: String = UUID().uuidString,
         title: String, detail: String = "",
         isUsingTime: Bool = false,
         reminderType: ReminderType = .none,
         reminderTime: Date? = nil,
         date: Date = Date(),
         time: Date? = nil,
         pinned: Bool = false,
         isDefault: Bool = false,
         pushedStatus: PushStatus = .waitingRegister,
         reminderDateTime: Date? = nil ) {
        self.id =  id
        self.detail = detail
        self.date = date
        self.title = title
        self.pinned = pinned
        self.isDefault = isDefault
        self.reminderType = reminderType
        self.reminderTime = reminderTime
        self.time = time
        self.reminderDateTime = reminderDateTime
    }
    
    init(id: String = UUID().uuidString,
         title: String, detail: String = "",
         isUsingTime: Bool = false,
         reminderType: ReminderType = .none,
         reminderTime: Date? = nil,
         date: Date = Date(),
         time: Date? = nil,
         pinned: Bool = false,
         isDefault: Bool = false,
         pushedStatus: PushStatus = .waitingRegister) {
        self.id =  id
        self.detail = detail
        self.date = date
        self.title = title
        self.pinned = pinned
        self.isDefault = isDefault
        self.reminderType = reminderType
        self.reminderTime = reminderTime
        self.time = time
        self.reminderDateTime = EventModel.canculateReminderTime(reminderType: reminderType,
                                                                 eventDate: date,
                                                                 eventTime: time,
                                                                 reminderTime: reminderTime)
    }
    
    func hasNotifyDate() -> Bool {
        return reminderDateTime != nil
    }
    
    static func canculateReminderTime(reminderType: ReminderType,
                                      eventDate: Date,
                                      eventTime: Date?,
                                      reminderTime: Date?) -> Date? {
        let eventDateValue = eventDate.setTime(from: eventTime ?? .zeroTime) ?? Date()
        let tempDate = reminderType.convertDate(from: eventDateValue)
        if let reminderTime = reminderTime {
            return tempDate?.setTime(from: reminderTime)
        } else {
            return tempDate
        }
    }
}

extension EventModel: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.date == rhs.date && lhs.pinned == rhs.pinned
            && lhs.time == rhs.time && lhs.isDefault == rhs.isDefault
    }
}

extension EventModel {
    func toEntity() -> EventEntity {
        let entity = EventEntity()
        entity.id = id
        entity.title = title
        entity.date = date
        entity.isDefault = isDefault
        entity.pinned = pinned
        entity.pushedStatus = pushedStatus.rawValue
        entity.reminderType = reminderType.rawValue
        entity.reminderTime = reminderTime
        entity.detail = detail
        entity.time = time
        entity.reminderDateTime = reminderDateTime
        return entity
    }
}

extension EventEntity {
    func toModel() -> EventModel {
        return EventModel(id: id, title: title, detail: detail,
                          reminderType: ReminderType(rawValue: reminderType) ?? .none,
                          reminderTime: reminderTime,
                          date: date ?? Date(),
                          time: time,
                          pinned: pinned, isDefault: isDefault,
                          pushedStatus: PushStatus(rawValue: pushedStatus) ?? .waitingRegister,
                          reminderDateTime: reminderDateTime)
    }
}
