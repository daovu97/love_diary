//
//  BackgroundSelectViewModel.swift
//  lovediary
//
//  Created by daovu on 12/03/2021.
//

import Combine
import UIKit

class BackgroundSelectViewModel: ViewModelType {
    
    private let dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    struct Input {
        var selectedItemTrigger: AnyPublisher<Int, Never>
        var addBackgroundTrigger: AnyPublisher<UIImage, Never>
        var doneTrigger: AnyPublisher<String, Never>
    }
    
    struct Output {
        var listBackground: AnyPublisher<[BackgroundPresentModel], Never>
        var selectedBackground: AnyPublisher<Int, Never>
        var actionVoid: AnyPublisher<Void, Never>
        var addBackgroundComplete: AnyPublisher<BackgroundPresentModel, Never>
        var doneAction: AnyPublisher<Void, Never>
    }
    
    struct Dependency {
        var backgroundManager: BackgroundManagerType
    }
    
    func transform(_ input: Input) -> Output {
        let getSelected = CurrentValueSubject<Int, Never>(0)
        
        let selectBackground = Publishers.Merge(getSelected, input.selectedItemTrigger.map { $0 - 1 })
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        let backgrounds = self.dependency.backgroundManager.getAllBackground()
            .flatMap { customBackground -> AnyPublisher<[BackgroundPresentModel], Never> in
                var backgrounds = [BackgroundPresentModel]()
                backgrounds.append(contentsOf: customBackground
                                    .map { return BackgroundPresentModel(id: $0.id, image: $0.getImage()) })
                return .just(backgrounds)
            }.receiveOutput { backgrounds in
                let selectID = self.dependency.backgroundManager.getSelectedBackgroundID()
                if let selectModel = backgrounds.filter({ model -> Bool in
                    return model.id == selectID
                }).first, let index = backgrounds.firstIndex(of: selectModel) {
                    getSelected.send(index)
                } else {
                    getSelected.send(0)
                }
            }
        
        let didAddBackground = input
            .addBackgroundTrigger
            .flatMap {[weak self] image -> AnyPublisher<BackgroundPresentModel, Never> in
                guard let self = self else { return .empty() }
                return self.dependency.backgroundManager.addBackground(background: image)
                    .map { return BackgroundPresentModel(id: $0.id, image: $0.getImage()) }
                    .eraseToAnyPublisher()
            }
        
        let doneAction = input.doneTrigger.receiveOutput {[weak self] in
            self?.dependency.backgroundManager.setSelectedBackground(backgroundID: $0)
        }
        
        return Output(listBackground: backgrounds.eraseToAnyPublisher(),
                      selectedBackground: selectBackground,
                      actionVoid: .empty(),
                      addBackgroundComplete: didAddBackground.eraseToAnyPublisher(),
                      doneAction: doneAction.eraseToVoidAnyPublisher())
    }
}
