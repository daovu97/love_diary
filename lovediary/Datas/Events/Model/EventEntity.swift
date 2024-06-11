//
//  EventEntity.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation
import RealmSwift

class EventEntity: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var detail: String = ""
    @objc dynamic var date: Date? = nil
    @objc dynamic var time: Date? = nil
    @objc dynamic var pinned: Bool = false
    @objc dynamic var reminderType: Int = 0
    @objc dynamic var reminderTime: Date?
    @objc dynamic var pushedStatus: Int = PushStatus.waitingRegister.rawValue
    @objc dynamic var isDefault = false
    @objc dynamic var reminderDateTime: Date?
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
