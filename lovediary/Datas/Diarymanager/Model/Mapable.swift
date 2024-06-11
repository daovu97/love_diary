//
//  Mapable.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import Foundation

private struct DiaryMapper {
    static func toModel(from entity: DiaryEntity, attachment: [ImageAttachmentEntity]) -> DiaryModel {
        return DiaryModel(id: entity.id, text: entity.text,
                          attachments: attachment.map { ImageAttachmentMapper.toModel(from: $0) },
                          displayDate: entity.displayDate, createdDate: entity.createdDate,
                          updatedDate: entity.updatedDate)
    }
    
    static func toEntity(from model: DiaryModel) -> DiaryEntity {
        let entity = DiaryEntity()
        entity.id = model.id
        entity.text = model.text
        entity.displayDate = model.displayDate
        entity.createdDate = model.createdDate
        entity.updatedDate = model.updatedDate
        return entity
    }
}

private struct ImageAttachmentMapper {
    static func toModel(from entity: ImageAttachmentEntity) -> ImageAttachment {
        return ImageAttachment(id: entity.id, nameUrl: entity.nameUrl,
                               position: entity.position, length: entity.length, width: entity.width,
                               height: entity.height, diaryId: entity.diaryId, createDate: entity.createDate)
    }
    
    static func toEntity(from model: ImageAttachment) -> ImageAttachmentEntity {
        let entity = ImageAttachmentEntity()
        entity.id = model.id
        entity.nameUrl = model.nameUrl
        entity.position = model.position
        entity.width = model.width
        entity.height = model.height
        entity.diaryId = model.diaryId
        entity.length = model.length
        entity.createDate = model.createDate
        return entity
    }
}

extension DiaryModel {
    func toEntity() -> DiaryEntity {
        DiaryMapper.toEntity(from: self)
    }
}

extension ImageAttachment {
    func toEntity() -> ImageAttachmentEntity {
        ImageAttachmentMapper.toEntity(from: self)
    }
}

extension DiaryEntity {
    func toModel(attachment: [ImageAttachmentEntity]) -> DiaryModel {
        DiaryMapper.toModel(from: self, attachment: attachment)
    }
}

extension ImageAttachmentEntity {
    func toModel() -> ImageAttachment {
        ImageAttachmentMapper.toModel(from: self)
    }
}
