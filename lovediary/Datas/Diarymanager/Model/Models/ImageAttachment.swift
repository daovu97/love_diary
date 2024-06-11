//
//  ImageAttachment.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import Foundation
import UIKit

public struct ImageAttachment {
    public var id: String
    public var nameUrl: String
    public var position: Int
    public var width: Int
    public var height: Int
    public var diaryId: String
    public var length: Int
    public var createDate: Date
    public var image: UIImage?
    
    public init(nameUrl: String, position: Int, length: Int, width: Int,
                height: Int, diaryId: String) {
        self.id =  UUID().uuidString
        self.nameUrl = nameUrl
        self.position = position
        self.width = width
        self.height = height
        self.diaryId = diaryId
        self.length = length
        self.createDate = Date()
    }
    
    public init(image: UIImage) {
        self.id =  UUID().uuidString
        self.image = image
        self.nameUrl = ""
        self.position = 0
        self.width = 0
        self.height = 0
        self.diaryId = ""
        self.length = 0
        self.createDate = Date()
    }
    
    public init(id: String, nameUrl: String, position: Int, length: Int,
                width: Int, height: Int, diaryId: String, createDate: Date) {
        self.id =  id
        self.nameUrl = nameUrl
        self.position = position
        self.width = width
        self.height = height
        self.diaryId = diaryId
        self.length = length
        self.createDate = createDate
    }
    
    public func getImage() -> UIImage? {
        guard let imageUrl = getImageUrl() else { return image }
        return UIImage(contentsOfFile: imageUrl.path)
    }
    
    public func getImageUrl() -> URL? {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first, !nameUrl.isEmpty else { return nil }
        let folderURL = documentURL.appendingPathComponent(Constants.dataFolderName)
        return folderURL.appendingPathComponent("\(nameUrl).png")
    }
}

extension ImageAttachment: Hashable {
    public static func == (lhs: ImageAttachment, rhs: ImageAttachment) -> Bool {
        return lhs.id == rhs.id && lhs.diaryId == rhs.diaryId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
