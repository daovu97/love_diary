//
//  BackgroundModel.swift
//  BackgroundManager
//
//  Created by daovu on 12/03/2021.
//

import Foundation
import UIKit.UIImage

struct BackgroundModel {
    
    var id: String = UUID().uuidString
    var nameUrl: String = ""
    var date: Date
    var defaultImage: UIImage?
    
    
    init(id: String, nameUrl: String) {
        self.id = id
        self.nameUrl = nameUrl
        self.date = Date()
        self.defaultImage = nil
    }
    
    init(id: String, defaultImage: UIImage?) {
        self.id = id
        self.nameUrl = ""
        self.date = Date()
        self.defaultImage = defaultImage
    }
    
    func getImage() -> UIImage? {
        if !nameUrl.isEmpty, let path = BackgroundLocalHelper.load(fileName: nameUrl) {
            return UIImage(contentsOfFile: path.path)
        } else {
            return defaultImage
        }
    }
}

extension BackgroundModel {
    func mapToEntity() -> BackgroundEntity {
        let entity = BackgroundEntity()
        entity.id = id
        entity.nameUrl = nameUrl
        entity.date = date
        return entity
    }
}
