//
//  SettingViewModel.swift
//  lovediary
//
//  Created by vu dao on 21/03/2021.
//

import Combine
import UIKit

class SettingViewModel: ViewModelType {
    
    private var dependency: Dependency
    private var navigator: SettingsNavigatorType
    
    init(dependency: Dependency, navigator: SettingsNavigatorType) {
        self.dependency = dependency
        self.navigator = navigator
    }
    
    struct Dependency {}
    
    struct Input {
        let didSelectRowTrigger: AnyPublisher<Cell, Never>
    }
    struct Output {
        let actionVoid: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input) -> Output {
        let didSelectCell = input.didSelectRowTrigger
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
            .share()
        
        let navigator = didSelectCell
            .filter { return !( $0 == Cell.deleteAllData) }
            .receiveOutput {[weak self] cell in
                guard let self = self else { return }
                cell.transition(navigator: self.navigator)
            }.eraseToVoidAnyPublisher()
        
        let toLanguageSetting = didSelectCell
            .filter { return $0 == Cell.languages }
            .flatMap {[weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return self.toLanguageSetting()
            }.eraseToAnyPublisher()
        
        let deleteAll = didSelectCell
            .filter { return $0 == .deleteAllData }
            .flatMap {[weak self] cell -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return self.deleteAllData()
            }
        
        return Output(actionVoid: Publishers.Merge3(toLanguageSetting,
                                                    navigator,
                                                    deleteAll).eraseToAnyPublisher())
    }
    
    private func toLanguageSetting() -> AnyPublisher<Void, Never> {
       return AlertManager.shared.showConfirmMessage(title: LocalizedString.languageChangeConfirmTitle,
                                               message: LocalizedString.languageChangeConfirmMessage,
                                               confirm: LocalizedString.continueLabel, cancel: LocalizedString.cancel)
        .flatMap { select -> AnyPublisher<Void, Never> in
            if select == .confirm {
                SettingsHelper.goToSettingApp()
            }
            return .just(())
        }.eraseToVoidAnyPublisher()
    }
    
    private func deleteAllData() -> AnyPublisher<Void, Never> {
        return .empty()
//        return AlertController.shared
//            .showConfirmMessage(message: LocalizedStrings.nss01DeleteAllData,
//                                confirm: LocalizedStrings.nss01DeleteButtonTitle,
//                                cancel: LocalizedStrings.nss01CancelButtonTitle, isDelete: true)
//            .asDriverOnErrorJustComplete()
//            .flatMapLatest {[weak self] selectCase -> Driver<Void> in
//                guard let self = self, selectCase == .confirm else { return Driver.empty() }
//                return AlertController.shared
//                    .showConfirmMessage(message: LocalizedStrings.nss01DeleteAllDataAgain,
//                                        confirm: LocalizedStrings.nss01DeleteButtonTitle,
//                                        cancel: LocalizedStrings.nss01CancelButtonTitle,
//                                        isDelete: true)
//                    .asDriverOnErrorJustComplete()
//                    .flatMapLatest {[weak self] selectCase -> Driver<Void> in
//                        guard let self = self, selectCase == .confirm else { return Driver.empty() }
//                        return self.settingUseCase.eraseAllData().asDriverOnErrorJustComplete()
//                    }
//            }
    }
}
