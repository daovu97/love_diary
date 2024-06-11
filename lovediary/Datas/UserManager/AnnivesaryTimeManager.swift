//
//  AnnivesaryTimeManager.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation

struct AnnivesaryTime {
    
    private static let timeKey = "AnnivesaryTime"
    
    static var time: Date {
        let value = UserDefaults.standard.double(forKey: timeKey)
        if value == 0 {
            return Date()
        } else {
            return Date(timeIntervalSince1970: value)
        }
    }
    
    static func setTime(time: Date) {
        UserDefaults.standard.setValue(time.timeIntervalSince1970, forKey: timeKey)
    }
}
