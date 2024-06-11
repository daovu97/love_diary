//
//  UserInfoModel.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import UIKit

struct UserInfoModel: Codable {
    var userType: Int
    var name: String = ""
    var birthDay: Date?
    var gender: Int = Gender.preferNotToSay.rawValue
    var detail: String = ""
    
    func getUserType() -> UserType {
        return UserType(value: userType)
    }
}

struct DefaultInfo {
    static let mProfileImage = UIImage(named: "male_avatar")
    static let pProfileImage = UIImage(named: "female_avatar")
    static let name = LocalizedString.name
}
