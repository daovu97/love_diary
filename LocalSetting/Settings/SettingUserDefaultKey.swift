//
//  SettingUserDefaultKey.swift
//  LocalSettings
//
//  Created by vu dao on 10/03/2021.
//

import UIKit

enum UserDefaultsKey: String {
    case theme
    case appInstallDate
    case tabbarLastTime
    case isFirstLaunch
    case isRemoveAds
    case isNotify
    case mainBackgroundID
    case isAllowAnalytic
    case lineSpacing
    case fontSize
    case isReversePhoto
    case dateStartApp
    case isUsingSensor
    case isLockImmediately
    case numberLaunchedAppCount
    case requestReviewFlags
    case isAllowNotificationPermission
    case isAdditionImageWithShareFB
    case sharedWithFBRequest
    case appVersion
    case galeryViewPosition
}

class WrappedUserDefault<T> {
    let key: String
    let defaultValue: T
    
    var value: T {
        get {
            let userDefaults = UserDefaults.standard
            if let value = userDefaults.object(forKey: key) as? T {
                return value
            } else {
                return defaultValue
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
            
            switch newValue {
            //appSetting
            case let isIAPed as Bool where key == UserDefaultsKey.isRemoveAds.rawValue:
                SettingsHelper.isRemoveAds.send(isIAPed)
            case let isNotify as Bool where key == UserDefaultsKey.isNotify.rawValue:
                SettingsHelper.isNotify.send(isNotify)
            default:
                break
            }
        }
    }
    
    init(key: UserDefaultsKey, defaultValue: T) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }
}
