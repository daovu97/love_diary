//
//  BackgroundDAO.swift
//  BackgroundManager
//
//  Created by daovu on 12/03/2021.
//

import Combine
import Foundation
import RealmSwift

protocol BackgroundDAOType {
    func querryAll() -> AnyPublisher<[BackgroundModel], Never>
    func save(model: BackgroundModel) -> AnyPublisher<BackgroundModel, Error>
    func find(id: String) -> AnyPublisher<BackgroundModel?, Never>
}

class BackgroundDAO: BackgroundDAOType {
    
    func querryAll() -> AnyPublisher<[BackgroundModel], Never> {
        let realm = try? Realm()
        if let results = realm?.objects(BackgroundEntity.self).sorted(byKeyPath: "date", ascending: false) {
            let value = Array(results)
            return Just(value.map { $0.mapToModel() }).eraseToAnyPublisher()
        } else {
            return .empty()
        }
    }
    
    func save(model: BackgroundModel) -> AnyPublisher<BackgroundModel, Error> {
        return Deferred {
            Future { promise in
                let realm = try? Realm()
                let entity = model.mapToEntity()
                do {
                    try realm?.write {
                        realm?.add(entity)
                    }
                    promise(.success(model))
                } catch let error {
                    promise(.failure(error))
                }
                
            }
        }.eraseToAnyPublisher()
    }
    
    func find(id: String) -> AnyPublisher<BackgroundModel?, Never> {
        let realm = try? Realm()
        let result = realm?.objects(BackgroundEntity.self)
            .filter(NSPredicate(format: "\(BackgroundEntityField.id.rawValue) == %@", id))
        return Just(result?.first?.mapToModel()).eraseToAnyPublisher()
    }
}
