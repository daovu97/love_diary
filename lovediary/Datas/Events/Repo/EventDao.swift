//
//  EventDao.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation
import Combine
import RealmSwift

protocol EventDaoType {
    func getAllEvents() -> AnyPublisher<[EventEntity], Never>
    func get(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[EventEntity], Never>
    func getValue(with predicates: [NSPredicate],
             sortDescriptors: [NSSortDescriptor]) -> [EventEntity]
    func add(entity: EventEntity) -> AnyPublisher<EventEntity, Never>
    func add(entities: [EventEntity]) -> AnyPublisher<[EventEntity], Never>
    func addErr(entities: [EventEntity]) -> AnyPublisher<[EventEntity], Error>
    func get(by id: String) -> AnyPublisher<EventEntity?, Never>
    func delete(by id: String) -> AnyPublisher<Void, Never>
    func deleteAll() -> AnyPublisher<Void, Never>
    func updateDefault(entities: [EventEntity]) -> AnyPublisher<Void, Never>
    func updateDefaultErr(entities: [EventEntity]) -> AnyPublisher<Void, Error>
    func getAllEventsErr() -> AnyPublisher<[EventEntity], Error>
    func deleteAllErr() -> AnyPublisher<Void, Error>
}

class EventDao: EventDaoType {
    func deleteAllErr() -> AnyPublisher<Void, Error> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                let object = realm.objects(EventEntity.self)
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
    
    func getAllEventsErr() -> AnyPublisher<[EventEntity], Error> {
        let realm = try? Realm()
        if let value = realm?.objects(EventEntity.self) {
            return .just(Array(value))
        } else {
            return .just([])
        }
    }
    
    func getValue(with predicates: [NSPredicate], sortDescriptors: [NSSortDescriptor]) -> [EventEntity] {
        guard let realm = try? Realm() else { return [] }
        var objects = realm.objects(EventEntity.self)
        predicates.forEach {  objects = objects.filter($0) }
        objects = objects.sorted(by: sortDescriptors
                                    .map { SortDescriptor(keyPath: $0.key ?? "", ascending: $0.ascending) })
        return Array(objects)
    }
    
    func add(entities: [EventEntity]) -> AnyPublisher<[EventEntity], Never> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                do {
                    try realm?.write {
                        realm?.add(entities, update: .modified)
                    }
                    promise(.success(entities))
                } catch {
                    debugPrint(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func addErr(entities: [EventEntity]) -> AnyPublisher<[EventEntity], Error> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                do {
                    try realm?.write {
                        realm?.add(entities, update: .modified)
                    }
                    promise(.success(entities))
                } catch {
                    debugPrint(error)
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getAllEvents() -> AnyPublisher<[EventEntity], Never> {
        let realm = try? Realm()
        if let value = realm?.objects(EventEntity.self) {
            return .just(Array(value))
        } else {
            return .just([])
        }
    }
    
    func get(with predicates: [NSPredicate], sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[EventEntity], Never> {
        return .just(getValue(with: predicates, sortDescriptors: sortDescriptors))
    }
    
    func add(entity: EventEntity) -> AnyPublisher<EventEntity, Never> {
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
    
    func get(by id: String) -> AnyPublisher<EventEntity?, Never> {
        guard let realm = try? Realm() else { return .empty() }
        return .just(realm.object(ofType: EventEntity.self, forPrimaryKey: id))
    }
    
    func delete(by id: String) -> AnyPublisher<Void, Never> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                if let deleteEntity = realm.object(ofType: EventEntity.self, forPrimaryKey: id) {
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
    
    func deleteAll() -> AnyPublisher<Void, Never> {
        guard let realm = try? Realm() else { return .empty() }
        return Deferred {
            Future { promise in
                let object = realm.objects(EventEntity.self)
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
    
    func updateDefault(entities: [EventEntity]) -> AnyPublisher<Void, Never> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                do {
                    try realm?.write {
                        entities.forEach { entity in
                            if let updateEntity = realm?.object(ofType: EventEntity.self, forPrimaryKey: entity.id) {
                                updateEntity.title = entity.title
                                updateEntity.date = entity.date
                                updateEntity.isDefault = true
                                updateEntity.pushedStatus = entity.pushedStatus
                            } else {
                                realm?.add(entity)
                            }
                        } }
                    promise(.success(()))
                } catch {
                    debugPrint(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateDefaultErr(entities: [EventEntity]) -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                do {
                    try realm?.write {
                        entities.forEach { entity in
                            if let updateEntity = realm?.object(ofType: EventEntity.self, forPrimaryKey: entity.id) {
                                updateEntity.title = entity.title
                                updateEntity.date = entity.date
                                updateEntity.isDefault = true
                                updateEntity.pushedStatus = entity.pushedStatus
                            } else {
                                realm?.add(entity)
                            }
                        } }
                    promise(.success(()))
                } catch {
                    debugPrint(error)
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
