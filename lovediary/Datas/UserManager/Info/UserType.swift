//
//  UserType.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation

enum UserType: Int {
    
    static var defaultValue = UserType.me
    
    case me = 0
    case partner
    
    init(value: Int) {
        if let value = UserType(rawValue: value) {
            self = value
        } else {
            self = UserType.defaultValue
        }
    }
}
