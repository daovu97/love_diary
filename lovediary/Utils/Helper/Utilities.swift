//
//  Utilities.swift
//  lovediary
//
//  Created by daovu on 30/03/2021.
//

import Foundation
import UIKit

struct Utilities {
    static func isAdsRemoved() -> Bool {
        return Settings.isRemoveAds.value
    }
    
    static func usedAppHours() -> Int {
        if let dateStartApp = Settings.dateStartApp.value {
            return DateHelper.hourBetweenDates(start: dateStartApp, end: Date())
        }
        return 0
    }
    
    static func usedAppDays() -> Int {
        if let dateStartApp = Settings.dateStartApp.value {
            return DateHelper.dayBetweenDates(start: dateStartApp, end: Date())
        }
        return 0
    }
    
    static var isAttRequestNeeded: Bool {
        if #available(iOS 14.5, *) {
            return true
        } else {
            return false
        }
    }
    
    static var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var appState: UIApplication.State {
        return UIApplication.shared.applicationState
    }
}
