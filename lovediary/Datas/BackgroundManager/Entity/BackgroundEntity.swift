//
//  BackgroundEntity.swift
//  BackgroundManager
//
//  Created by daovu on 12/03/2021.
//
import Foundation
import RealmSwift

enum BackgroundEntityField: String {
    case id = "id"
    case nameUrl = "nameUrl"
    case date = "date"
}

class BackgroundEntity: RealmSwift.Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var nameUrl: String = ""
    @objc dynamic var date: Date = Date()

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension BackgroundEntity {
    func mapToModel() -> BackgroundModel {
        return BackgroundModel(id: id, nameUrl: nameUrl)
    }
}
