//
//  AppConfigs.swift
//  QikNote
//
//  Created by daovu on 01/03/2021.
//

import Foundation

public struct AppConfigs {
    public static var appId: String = infoForKey("DV_APP_APP_ID")
    public static let maxNumberOfImages = Int(infoForKey("DV_APP_NUMBER_MAX_DIARY_IMAGE")) ?? 10
    public static let adsProductIdentifier = infoForKey("DV_APP_PRODUCT_IDENTIFY_ADS")
    public static let maxBackgroundInput = Int(infoForKey("DV_MAX_INPUT_BACKGROUND")) ?? 10
    public static let showAdsAfterDay = Int(infoForKey("DV_SHOW_ADS_AFTER_DAY")) ?? 2
    public static let adUnitID: String = infoForKey("DV_GAD_AD_UNIT")
    public static let keychainPrivateKey: String = infoForKey("DV_KEYCHAIN_PRIVATE_KEY")
    public static let mailFeedback: String = infoForKey("DV_MAIL_FEEDBACK")
    public static let appPrivacyUrl: String = infoForKey("DV_APP_PRIVACY_URL")
    public static let timeReview = 24
    public static let launchedAppToRequestReviewCounts = [3, 6, 10]
    
    public static let maximumTodoPendingNotifications = 64
    
    public static let firebaseEnable: Bool = (Int(infoForKey("DV_APP_FIREBASE_ENABLED")) ?? 0) == 1
}
