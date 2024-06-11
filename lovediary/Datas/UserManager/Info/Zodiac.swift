//
//  zodiac.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation

enum Zodiac: Int, CaseIterable {
    
    static var defaultValue = Zodiac.aries
    
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricon
    case aqarius
    case pisces
    
    init(value: Int) {
        if let value = Zodiac(rawValue: value) {
            self = value
        } else {
            self = Zodiac.defaultValue
        }
    }
}
