//
//  BackgroundManager.swift
//  BackgroundManager
//
//  Created by daovu on 12/03/2021.
//

import UIKit
import Combine
import RealmSwift

protocol BackgroundManagerType {
    var didChange: PassthroughSubject<Void, Never> { get }
    func getAllBackground() -> AnyPublisher<[BackgroundModel], Never>
    func getSelectedBackgroundID() -> String
    func getSelectedBackground() -> AnyPublisher<BackgroundModel, Never>
    func setSelectedBackground(backgroundID: String)
    func addBackground(background: UIImage) -> AnyPublisher<BackgroundModel, Never>
    var defautlBackgrounds: [BackgroundModel] { get }
}

class BackgroundManager: BackgroundManagerType {
    lazy var didChange = PassthroughSubject<Void, Never>()
    var defautlBackgrounds: [BackgroundModel] = StockBackgrounds.stockBackgrounds
    
    private var dao: BackgroundDAOType
    
    init() {
        self.dao = BackgroundDAO()
    }
    
    func getAllBackground() -> AnyPublisher<[BackgroundModel], Never> {
        return dao.querryAll().map {[weak self] backgrounds -> [BackgroundModel] in
            guard let self = self else { return [] }
            var result = [BackgroundModel]()
            result.append(contentsOf: backgrounds)
            result.append(contentsOf: self.defautlBackgrounds)
            return result
        }.eraseToAnyPublisher()
    }
    
    func getSelectedBackgroundID() -> String {
        return Settings.getMainBackgroundID()
    }
    
    func setSelectedBackground(backgroundID: String) {
        Settings.setMainBackgroundID(id: backgroundID)
        didChange.send()
    }
    
    func getSelectedBackground() -> AnyPublisher<BackgroundModel, Never> {
        return getAllBackground().map { backgrounds -> BackgroundModel in
            return (backgrounds.filter { $0.id == Settings.getMainBackgroundID() }
                        .first ?? StockBackgrounds.defaultStock)
        }.eraseToAnyPublisher()
    }
    
    func addBackground(background: UIImage) -> AnyPublisher<BackgroundModel, Never> {
        return BackgroundLocalHelper.save(image: background)
            .catch({ _ in Empty(completeImmediately: false).eraseToAnyPublisher()})
            .flatMap {[weak self] name -> AnyPublisher<BackgroundModel, Never> in
                guard let self = self else { return .empty() }
                let backgroundModel = BackgroundModel(id: UUID().uuidString, nameUrl: name)
                return self.dao.save(model: backgroundModel)
                    .catch {_ -> AnyPublisher<BackgroundModel, Never> in return .empty()  }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

struct StockBackgrounds {
    static let stockBackgrounds = [
        BackgroundModel(id: "1", defaultImage: UIImage(named: "background1")),
        BackgroundModel(id: "2", defaultImage: UIImage(named: "background2")),
        BackgroundModel(id: "3", defaultImage: UIImage(named: "background3")),
        BackgroundModel(id: "4", defaultImage: UIImage(named: "background4")),
        BackgroundModel(id: "5", defaultImage: UIImage(named: "background5")),
        BackgroundModel(id: "6", defaultImage: UIImage(named: "background6")),
        BackgroundModel(id: "7", defaultImage: UIImage(named: "background7")),
        BackgroundModel(id: "8", defaultImage: UIImage(named: "background8"))
    ]
    static let defaultStock = BackgroundModel(id: UUID().uuidString, defaultImage: UIImage(named: "background1"))
}

