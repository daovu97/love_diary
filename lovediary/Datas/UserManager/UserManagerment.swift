//
//  UserManagerment.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation
import Combine

private let userKeyDefault = "$123"
//private let APPGROUPNAME = "group.someGroup"

protocol UserManagermentType {
    var didUserChange: PassthroughSubject<Void, Never> { get }
    func getUser(by type: UserType) -> UserInfoModel?
    func saveUser(_ user: UserInfoModel) -> UserInfoModel
}

class UserManagerment: UserManagermentType {
    
    //    static var userDefaults = UserDefaults(suiteName: T##String?)
    private var userDefaults: UserDefaults
    
    lazy var didUserChange = PassthroughSubject<Void, Never>()
    
    init(defaults: UserDefaults) {
        self.userDefaults = defaults
    }
    
    func getUser(by type: UserType) -> UserInfoModel? {
        return UserInfoModel.get(with: type, defaults: userDefaults)
    }
    
    func saveUser(_ user: UserInfoModel) -> UserInfoModel {
        user.save(with: userDefaults)
        didUserChange.send()
        return user
    }
}

private extension UserInfoModel {
    func save(with defaults: UserDefaults) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            let key = "\(userKeyDefault)-\(self.userType)"
            defaults.set(encoded, forKey: key)
        }
    }
    
    static func get(with type: UserType, defaults: UserDefaults) -> UserInfoModel? {
        let key = "\(userKeyDefault)-\(type.rawValue)"
        if let savedPerson = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(UserInfoModel.self, from: savedPerson)
        }
        return nil
    }
}
