//
//  UserInforViewModel.swift
//  lovediary
//
//  Created by vu dao on 10/03/2021.
//

import Combine
import Foundation
import UIKit

class UserInforViewModel: ViewModelType {
    private let dependency: Dependency
    private var userType: UserType
    
    private var currentUser: UserInfoModel?
    
    var didUserChange: ((UserInfoModel) -> Void)?
    
    init(dependency: Dependency, userType: UserType) {
        self.dependency = dependency
        self.userType = userType
    }
    
    struct Input {
        let selectGenderTrigger: AnyPublisher<Gender, Never>
        let nameTextChange: AnyPublisher<String, Never>
        let birthDayChange: AnyPublisher<Date, Never>
        let selectProfileImageTrigger: AnyPublisher<UIImage, Never>
    }
    struct Output {
        let userData: AnyPublisher<UserInfoModel, Never>
        let voidAction: AnyPublisher<Void, Never>
    }
    
    struct Dependency {
        let userManager: UserManagermentType
    }
    
    func transform(_ input: Input) -> Output {
        let nameChange = input.nameTextChange
            .removeDuplicates()
            .flatMap {[weak self] name -> AnyPublisher<UserInfoModel, Never> in
                guard let self = self,
                      var currentUser = self.currentUser else {
                    return .empty()
                }
                currentUser.name = name
                self.currentUser = currentUser
                return .just(self.dependency.userManager.saveUser(currentUser))
            }
            .eraseToVoidAnyPublisher()
        
        let genderChange = input.selectGenderTrigger
            .removeDuplicates()
            .flatMap {[weak self] gender -> AnyPublisher<UserInfoModel, Never> in
                guard let self = self, var currentUser = self.currentUser,
                      gender.rawValue != currentUser.gender  else {
                    return .empty()
                }
                currentUser.gender = gender.rawValue
                return .just(self.dependency.userManager.saveUser(currentUser))
            }
            .eraseToAnyPublisher()
        
        let dateChange = input.birthDayChange.removeDuplicates()
            .flatMap {[weak self] date -> AnyPublisher<UserInfoModel, Never> in
                guard let self = self,
                      var currentUser = self.currentUser, date != currentUser.birthDay else {
                    return .empty()
                }
                currentUser.birthDay = date
                return .just(self.dependency.userManager.saveUser(currentUser))
            }
            .eraseToAnyPublisher()
        
        let saveProfileImage = input
            .selectProfileImageTrigger
            .removeDuplicates()
            .flatMap({ [weak self] image -> AnyPublisher<String, Never> in
                guard let self = self else {
                    return .empty()
                }
                return ProfileImageManager
                    .saveProfile(image: image, of: self.userType)
                    .catch { _ -> AnyPublisher<String, Never> in
                        return .empty()
                    }.eraseToAnyPublisher()
            })
            .receiveOutput(outPut: {[weak self] _ in self?.dependency.userManager.didUserChange.send() })
            .eraseToVoidAnyPublisher()
        
        let user = self.dependency.userManager.getUser(by: self.userType) ?? .init(userType: self.userType.rawValue)
        
        DispatchQueue.main.async {
            ProfileImageManager.didChange.send(self.userType)
        }
        
        let userInfor = Publishers.Merge3(Just(user), genderChange, dateChange)
            .receiveOutput(outPut: {[weak self]  in
                self?.currentUser = $0
            })
            .eraseToAnyPublisher()
        
        return Output(userData: userInfor,
                      voidAction: Publishers.Merge(saveProfileImage, nameChange).eraseToAnyPublisher())
    }
}
