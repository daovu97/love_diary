//
//  DiaryModel.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import UIKit

struct DiaryModel {
    var id: String = UUID().uuidString
    var text: String = ""
    var attachments: [ImageAttachment]
    var displayDate: Date
    var createdDate: Date
    var updatedDate: Date
    
    init(text: String = "", attachments: [ImageAttachment] = [], createdDate: Date = Date()) {
        self.text = text
        self.id =  UUID().uuidString
        self.attachments = attachments
        self.createdDate = createdDate
        self.displayDate = createdDate
        self.updatedDate = createdDate
    }
    
    init(id: String, text: String, attachments: [ImageAttachment],
         displayDate: Date, createdDate: Date, updatedDate: Date) {
        self.text = text
        self.id =  id
        self.attachments = attachments
        self.createdDate = createdDate
        self.displayDate = displayDate
        self.updatedDate = updatedDate
    }
    
    init() {
        self.text = ""
        self.id =  UUID().uuidString
        self.attachments = []
        self.createdDate = Date()
        self.displayDate = Date()
        self.updatedDate = Date()
    }
}

extension DiaryModel: Hashable {

}


extension DiaryModel {
    func getContent() -> NSAttributedString? {
        let newAttributedString = NSMutableAttributedString(string: text)
        for  metadata in attachments {
            let textAttachment = NSTextAttachment()
            let width = UIApplication.width - 15.0 * 2
            let height = CGFloat(metadata.height) * width / CGFloat(metadata.width)
            if let image = metadata.getImage() {
                textAttachment.image = image.scaleTo(size: CGSize(width: width, height: height))
                newAttributedString.replaceCharacters(in: NSRange(location: metadata.position, length: metadata.length), with: NSAttributedString(attachment: textAttachment))
            }
        }
        return newAttributedString
    }
}

