//
//  AnniversaryViewModel.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation
import Combine

// MARK: - INPUT
extension AnniversaryViewModel {
    struct Input {
        var refreshTrigger: AnyPublisher<Void, Never>
        var refreshTimeTrigger: AnyPublisher<Void, Never>
        var userInfoTrigger: AnyPublisher<UserType, Never>
        var toSelectBackgroundTrigger: AnyPublisher<Void, Never>
        var showSelectDate: AnyPublisher<Void, Never>
    }
}

// MARK: - OUTPUT
extension AnniversaryViewModel {
    struct Output {
        var userInfo: AnyPublisher<[UserInfoModel?], Never>
        var timeInfo: AnyPublisher<Date, Never>
        var actionVoid: AnyPublisher<Void, Never>
        var background: AnyPublisher<BackgroundModel, Never>
    }
}

// MARK: - TRANFORM
class AnniversaryViewModel: ViewModelType {
    
    private let dependency: Dependency
    private let navigator: AnniversaryNavigatorType
    
    init(dependency: Dependency, navigator: AnniversaryNavigatorType) {
        self.dependency = dependency
        self.navigator = navigator
    }
    
    struct Dependency {
        let userManager: UserManagermentType
        let backgroundManager: BackgroundManagerType
    }
    
    func transform(_ input: Input) -> Output {
        
        let userData = Publishers.Merge(dependency.userManager.didUserChange, input.refreshTrigger)
            .flatMap {[weak self] _ -> AnyPublisher<[UserInfoModel?], Never> in
                guard let self = self else { return .empty() }
            let meUser = self.dependency.userManager.getUser(by: .me)
            let partnerUser = self.dependency.userManager.getUser(by: .partner)
            return .just([meUser, partnerUser])
        }.eraseToAnyPublisher()
        
        let timeInfo = input.refreshTimeTrigger.flatMap { _ -> AnyPublisher<Date, Never> in
            return .just(AnnivesaryTime.time)
        }.eraseToAnyPublisher()
        
        let toUserInfo = input.userInfoTrigger.receiveOutput(outPut: { [weak self] in
            self?.navigator.toUserInfor(type: $0)
        }).eraseToVoidAnyPublisher()
        
        let background = Publishers.Merge(Just(()), dependency.backgroundManager.didChange)
            .flatMap {[weak self] _  -> AnyPublisher<BackgroundModel, Never> in
                guard let self = self else { return .empty() }
                return self.dependency.backgroundManager.getSelectedBackground()
            }
            .eraseToAnyPublisher()
        
        let toSelectbackground = input.toSelectBackgroundTrigger
            .receiveOutput {[weak self] _ in
               _ = self?.navigator.toBackgroundSelect()
            }
        
        let toSelectStartDate = input.showSelectDate.receiveOutput {[weak self] _ in
            guard Settings.isFirstLaunch.value else { return }
            Settings.isFirstLaunch.value = false
            self?.navigator.toStartDateSetting()
        }.eraseToVoidAnyPublisher()
        
        return Output(userInfo: userData,
                      timeInfo: timeInfo,
                      actionVoid: Publishers.Merge3(toUserInfo,
                                                    toSelectbackground,
                                                    toSelectStartDate).eraseToAnyPublisher(),
                      background: background)
    }
}
