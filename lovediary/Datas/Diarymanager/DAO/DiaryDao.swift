//
//  DiaryDao.swift
//  DiaryManager
//
//  Created by daovu on 17/03/2021.
//

import Foundation
import Combine
import RealmSwift

protocol DiaryDaoType {
    func getAll() -> AnyPublisher<[DiaryEntity], Never>
    func find(predicates: [NSPredicate]) -> AnyPublisher<[DiaryEntity], Never>
    func delete(by id: String) -> AnyPublisher<Void, Never>
    func deleteAll() -> AnyPublisher<Void, Error>
    func add(entity: DiaryEntity) -> AnyPublisher<DiaryEntity, Never>
    func add(entities: [DiaryEntity]) -> AnyPublisher<Void, Error>
    func get(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[DiaryEntity], Never>
    
    func getError(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[DiaryEntity], Error>
    
    func get(by id: String) -> AnyPublisher<DiaryEntity?, Never>
    func updateDate(entity: DiaryEntity) -> AnyPublisher<DiaryEntity, Never>
}

class DiaryDao: DiaryDaoType {
    func add(entities: [DiaryEntity]) -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                do {
                    try realm?.write {
                        entities.forEach { entity in
                            if let object = realm?.object(ofType: DiaryEntity.self, forPrimaryKey: entity.id) {
                                object.id = entity.id
                                object.text = entity.text
                                object.displayDate = entity.displayDate
                                object.createdDate = entity.createdDate
                                object.updatedDate = entity.updatedDate
                            } else {
                                realm?.add(entity)
                            }
                        }
                    }
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                    debugPrint(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getAll() -> AnyPublisher<[DiaryEntity], Never> {
        let realm = try? Realm()
        if let value = realm?.objects(DiaryEntity.self) {
            return .just(Array(value))
        } else {
            return .just([])
        }
    }
    
    func find(predicates: [NSPredicate]) -> AnyPublisher<[DiaryEntity], Never> {
        guard let realm = try? Realm() else { return .empty() }
        var objects = realm.objects(DiaryEntity.self)
        predicates.forEach {  objects = objects.filter($0) }
        return .just(Array(objects))
    }
    
    func get(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[DiaryEntity], Never> {
        guard let realm = try? Realm() else { return .empty() }
        var objects = realm.objects(DiaryEntity.self)
        predicates.forEach {  objects = objects.filter($0) }
        objects = objects.sorted(by: sortDescriptors
                                    .map { SortDescriptor(keyPath: $0.key ?? "", ascending: $0.ascending) })
        return .just(Array(objects))
    }
    
    func getError(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[DiaryEntity], Error> {
        guard let realm = try? Realm() else { return .empty() }
        var objects = realm.objects(DiaryEntity.self)
        predicates.forEach {  objects = objects.filter($0) }
        objects = objects.sorted(by: sortDescriptors
                                    .map { SortDescriptor(keyPath: $0.key ?? "", ascending: $0.ascending) })
        return .just(Array(objects))
    }
    
    func delete(by id: String) -> AnyPublisher<Void, Never> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                if let deleteEntity = realm.object(ofType: DiaryEntity.self, forPrimaryKey: id) {
                    do {
                        try realm.write {
                            realm.delete(deleteEntity)
                        }
                        promise(.success(()))
                    } catch {
                        debugPrint(error)
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteAll() -> AnyPublisher<Void, Error> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                let object = realm.objects(DiaryEntity.self)
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
    
    func add(entity: DiaryEntity) -> AnyPublisher<DiaryEntity, Never> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                do {
                    try realm?.write {
                        realm?.add(entity, update: .modified)
                    }
                    promise(.success(entity))
                } catch {
                    debugPrint(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func get(by id: String) -> AnyPublisher<DiaryEntity?, Never> {
        guard let realm = try? Realm() else { return .empty() }
        return .just(realm.object(ofType: DiaryEntity.self, forPrimaryKey: id))
    }
    
    func updateDate(entity: DiaryEntity) -> AnyPublisher<DiaryEntity, Never> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                if let diaryEntity = realm?.object(ofType: DiaryEntity.self, forPrimaryKey: entity.id) {
                    do {
                        try realm?.write {
                            diaryEntity.displayDate = entity.displayDate
                            diaryEntity.updatedDate = entity.updatedDate
                        }
                        promise(.success(entity))
                    } catch {
                        debugPrint(error)
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
