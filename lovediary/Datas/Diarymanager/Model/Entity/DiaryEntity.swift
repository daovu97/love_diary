//
//  DiaryEntity.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import Foundation
import RealmSwift

enum DiaryEntityField: String {
    case id = "id"
    case text = "text"
    case displayDate = "displayDate"
    case createdDate = "createdDate"
    case updatedDate = "updatedDate"
}

class DiaryEntity: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var text: String = ""
    @objc dynamic var displayDate: Date = Date()
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var updatedDate: Date = Date()
    
    override class func primaryKey() -> String? {
        return DiaryEntityField.id.rawValue
    }
}
