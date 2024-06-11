//
//  ImageAttachmentEntity.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import Foundation
import RealmSwift

enum ImageAttachmentEntityField: String {
    case id = "id"
    case nameUrl = "nameUrl"
    case position = "position"
    case width = "width"
    case height = "height"
    case length = "length"
    case diaryId = "diaryId"
    case createDate = "createDate"
}

class ImageAttachmentEntity: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var nameUrl: String = ""
    @objc dynamic var position: Int = 0
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var length: Int = 0
    @objc dynamic var diaryId: String = ""
    @objc dynamic var createDate: Date = Date()
    
    override class func primaryKey() -> String? {
        return ImageAttachmentEntityField.id.rawValue
    }
}
