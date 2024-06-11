//
//  DiaryRepository.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import Foundation
import Combine
import RealmSwift

protocol DiaryRepositoryType {
    func getAllDiary() -> AnyPublisher<[DiaryModel], Error>
    func getDiary(from startDate: Date, to endDate: Date) -> AnyPublisher<[DiaryModel], Never>
    func getDiary(by id: String) -> AnyPublisher<DiaryModel?, Never>
    func addNewDiary(diary: DiaryModel) -> AnyPublisher<DiaryModel, Never>
    func addNewDiary(diaries: [DiaryModel]) -> AnyPublisher<Void, Error>
    func deleteDiary(diary: DiaryModel) -> AnyPublisher<Void, Never>
    func deleteAll() -> AnyPublisher<Void, Error>
    func deleteImage(ids: [String]) -> AnyPublisher<Void, Never>
    func getAllImage(reverse: Bool) -> AnyPublisher<[ImageAttachment], Never>
    
    func getDiaries(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[DiaryModel], Never>
    
    func updateDate(diary: DiaryModel) -> AnyPublisher<DiaryModel, Never>
    func getAllDiaryDate(with predicates: [NSPredicate], sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[Date], Never>
}

class DiaryRepository: DiaryRepositoryType {
    func addNewDiary(diaries: [DiaryModel]) -> AnyPublisher<Void, Error> {
        let saveDiary = diaryDao.add(entities: diaries.map { $0.toEntity() })
            .eraseToVoidAnyPublisher()
        
        var images = [ImageAttachmentEntity]()
        
        diaries.forEach { images.append(contentsOf: $0.attachments.map { $0.toEntity() }) }
        
        let saveImage = imageDao.addError(entities: images).eraseToVoidAnyPublisher()
          
        return Publishers.CombineLatest(saveDiary, saveImage).map {_ in return ()  }.eraseToAnyPublisher()
    }
    
    func getAllDiaryDate(with predicates: [NSPredicate], sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[Date], Never> {
        return diaryDao.get(with: predicates, sortDescriptors: sortDescriptors).map { entities -> [Date] in
            return entities.map { $0.displayDate }
        }.eraseToAnyPublisher()
    }
    
    private var diaryDao: DiaryDaoType
    private var imageDao: ImageAttachmentDaoType
    
    init(diaryDao: DiaryDaoType, imageDao: ImageAttachmentDaoType ) {
        self.diaryDao = diaryDao
        self.imageDao = imageDao
    }
    
    func getDiaries(with predicates: [NSPredicate], sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[DiaryModel], Never> {
        return diaryDao.get(with: predicates, sortDescriptors: sortDescriptors)
            .flatMap{ [weak self] entities -> AnyPublisher<[DiaryModel], Never> in
                let diaryModels = entities.map { entity in self?.map(entity: entity)}
                return .just(diaryModels.compactMap { $0 })
            }
            .eraseToAnyPublisher()
    }
    
    func getAllImage(reverse: Bool) -> AnyPublisher<[ImageAttachment], Never> {
        return imageDao.get(with: [], sortDescriptors: [.init(key: ImageAttachmentEntityField.createDate.rawValue, ascending: !reverse)]).map { entity -> [ImageAttachment] in
            return entity.map { $0.toModel() }
        }.eraseToAnyPublisher()
    }
    
    func deleteImage(ids: [String]) -> AnyPublisher<Void, Never> {
        guard !ids.isEmpty else { return .just(()) }
        return imageDao.delete(ids: ids)
    }
    
    func getAllDiary() -> AnyPublisher<[DiaryModel], Error> {
        return diaryDao.getError(with: [], sortDescriptors: [.init(key: DiaryEntityField.displayDate.rawValue, ascending: true)])
            .flatMap{ [weak self] entities -> AnyPublisher<[DiaryModel], Error> in
                let diaryModels = entities.map { entity in self?.map(entity: entity)}
                return .just(diaryModels.compactMap { $0 })
            }
            .eraseToAnyPublisher()
    }
    
    func map(entity: DiaryEntity) -> DiaryModel? {
        let attachment = imageDao.get(by: entity.id)
        return entity.toModel(attachment: attachment)
    }
    
    func queryDiary(predicate: NSPredicate) -> AnyPublisher<[DiaryModel], Never> {
        .empty()
    }
    
    func getDiary(from startDate: Date, to endDate: Date) -> AnyPublisher<[DiaryModel], Never> {
        let displayDateField = DiaryEntityField.displayDate.rawValue
        return diaryDao.get(with: [.init(format: "\(displayDateField) >= %@ && \(displayDateField) =< %@",
                                    argumentArray: [startDate, endDate])],
                       sortDescriptors: [.init(key: displayDateField, ascending: true)])
            .map { [weak self] in $0.map { entity in self?.map(entity: entity) }.compactMap { $0 } }
            .eraseToAnyPublisher()
    }
    
    func getDiary(by id: String) -> AnyPublisher<DiaryModel?, Never> {
        return diaryDao.get(by: id)
            .map { [weak self] in
                let attachment = self?.imageDao.get(by: id) ?? []
                return $0?.toModel(attachment: attachment)
            }
            .eraseToAnyPublisher()
    }
    
    func addNewDiary(diary: DiaryModel) -> AnyPublisher<DiaryModel, Never> {
        let saveDiary = diaryDao.add(entity: diary.toEntity())
            .eraseToVoidAnyPublisher()
            
        let saveImage = imageDao.add(entities: diary.attachments.map { $0.toEntity() })
            .eraseToVoidAnyPublisher()
          
        return Publishers.CombineLatest(saveDiary, saveImage).map { _ in return diary }
            .eraseToAnyPublisher()
    }
    
    func deleteDiary(diary: DiaryModel) -> AnyPublisher<Void, Never> {
        let deleteImage =  imageDao.delete(ids: diary.attachments.map { $0.id })
        let deleteDiary = diaryDao.delete(by: diary.id)
        return Publishers.CombineLatest(deleteImage, deleteDiary).eraseToVoidAnyPublisher()
    }
    
    func deleteAll() -> AnyPublisher<Void, Error> {
        let deleteImage =  imageDao.deleteAll()
        let deleteDiary = diaryDao.deleteAll()
        return Publishers.CombineLatest(deleteImage, deleteDiary).map{_ in return () }.eraseToAnyPublisher()
    }
    
    func updateDate(diary: DiaryModel) -> AnyPublisher<DiaryModel, Never> {
        return diaryDao.updateDate(entity: diary.toEntity()).map { _ in return diary }.eraseToAnyPublisher()
    }
}
