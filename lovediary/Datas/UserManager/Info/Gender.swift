//
//  Gender.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation

enum Gender: Int, CaseIterable {
    static var defaultValue = Gender.preferNotToSay
    
    case male
    case female
    case preferNotToSay
    
    init(value: Int?) {
        if let value = value,
           let gender = Gender(rawValue: value) {
            self = gender
        } else {
            self = Gender.defaultValue
        }
    }
    
    var name: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .preferNotToSay:
            return "Prefer Not To Say"
        }
    }
    
    static var names: [String] {
        return Gender.allCases.map { $0.name }
    }
}
