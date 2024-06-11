//
//  ImageAttachmentDao.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import Foundation
import Combine
import RealmSwift

protocol ImageAttachmentDaoType {
    func getAll() -> AnyPublisher<[ImageAttachmentEntity], Never>
    func get(by diaryId: String) -> [ImageAttachmentEntity]
    func get(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[ImageAttachmentEntity], Never>
    func delete(by id: String) -> AnyPublisher<Void, Never>
    func delete(with predicates: [NSPredicate]) -> AnyPublisher<Void, Never>
    func add(entities: [ImageAttachmentEntity]) -> AnyPublisher<[ImageAttachmentEntity], Never>
    func addError(entities: [ImageAttachmentEntity]) -> AnyPublisher<[ImageAttachmentEntity], Error>
    func deleteAll() -> AnyPublisher<Void, Error>
    func delete(ids: [String]) -> AnyPublisher<Void, Never>
}

class ImageAttachmentDao: ImageAttachmentDaoType {
    func addError(entities: [ImageAttachmentEntity]) -> AnyPublisher<[ImageAttachmentEntity], Error> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                do {
                    try realm.write {
                        entities.forEach { entity in
                            if let object = realm.object(ofType: ImageAttachmentEntity.self, forPrimaryKey: entity.id) {
                                object.position = entity.position
                                object.length = entity.length
                                object.createDate = entity.createDate
                            } else {
                                realm.add(entity)
                            }
                        }
                    }
                    promise(.success(entities))
                } catch {
                    promise(.failure(error))
                    debugPrint(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    
    func delete(ids: [String]) -> AnyPublisher<Void, Never> {
        guard !ids.isEmpty else { return .just(()) } 
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                let object = ids
                    .compactMap { return realm.object(ofType: ImageAttachmentEntity.self, forPrimaryKey: $0) }
                do {
                    try realm.write {
                        realm.delete(object)
                    }
                    promise(.success(()))
                } catch {
                    debugPrint(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getAll() -> AnyPublisher<[ImageAttachmentEntity], Never> {
        guard let realm = try? Realm() else { return .empty() }
        let objects = realm.objects(ImageAttachmentEntity.self)
        return .just(Array(objects))
    }
    
    func get(by diaryId: String) -> [ImageAttachmentEntity] {
        guard let realm = try? Realm() else { return [] }
        let objects = realm.objects(ImageAttachmentEntity.self)
            .filter { $0.diaryId == diaryId }
            .sorted { (lhs, rhs) -> Bool in
               return lhs.position < rhs.position
            }
        return Array(objects)
    }
    
    func get(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[ImageAttachmentEntity], Never> {
        guard let realm = try? Realm() else { return .empty() }
        var objects = realm.objects(ImageAttachmentEntity.self)
        predicates.forEach {  objects = objects.filter($0) }
        objects = objects.sorted(by: sortDescriptors
                                    .map { SortDescriptor(keyPath: $0.key ?? "", ascending: $0.ascending) })
        return .just(Array(objects))
    }
    
    func delete(by id: String) -> AnyPublisher<Void, Never> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                if let deleteEntity = realm.object(ofType: ImageAttachmentEntity.self, forPrimaryKey: id) {
                    do {
                        try realm.write {
                            realm.delete(deleteEntity)
                        }
                        promise(.success(()))
                    } catch {
                        debugPrint(error)
                        promise(.success(()))
                    }
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func delete(with predicates: [NSPredicate]) -> AnyPublisher<Void, Never> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                var objects = realm.objects(ImageAttachmentEntity.self)
                predicates.forEach {  objects = objects.filter($0) }
                do {
                    try realm.write {
                        realm.delete(objects)
                    }
                    promise(.success(()))
                } catch {
                    debugPrint(error)
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func add(entities: [ImageAttachmentEntity]) -> AnyPublisher<[ImageAttachmentEntity], Never> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                do {
                    try realm.write {
                        entities.forEach { entity in
                            if let object = realm.object(ofType: ImageAttachmentEntity.self, forPrimaryKey: entity.id) {
                                object.position = entity.position
                                object.length = entity.length
                                object.createDate = entity.createDate
                            } else {
                                realm.add(entity)
                            }
                        }
                    }
                    promise(.success(entities))
                } catch {
                    debugPrint(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteAll() -> AnyPublisher<Void, Error> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                let object = realm.objects(ImageAttachmentEntity.self)
                do {
                    try realm.write {
                        realm.delete(object)
                    }
                    promise(.success(()))
                } catch {
                    debugPrint(error)
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
}
