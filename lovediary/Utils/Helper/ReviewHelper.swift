//
//  ReviewHelper.swift
//  lovediary
//
//  Created by vu dao on 03/04/2021.
//

import UIKit
import Combine
import Configuration
import StoreKit

struct ReviewHelper {
    
    private static let appUrl = "https://apps.apple.com/app/id\(AppConfigs.appId)?mt=8"
    
    static func checkAndRequestReview() {
        guard Utilities.usedAppHours() >= AppConfigs.timeReview else { return }
        let numberLaunchedAppCount = Settings.numberLaunchedAppCount.value
        let listReviewCount = AppConfigs.launchedAppToRequestReviewCounts
        if let index = listReviewCount.firstIndex(of: numberLaunchedAppCount) {
            if !Settings.requestReviewFlags.value[index] {
                Settings.requestReviewFlags.value[index] = true
                requestAppReview()
            }
        }
    }
    
    static func updateNumberLaunchedAppCountIfNeeded() {
        if Utilities.usedAppHours() >= AppConfigs.timeReview {
            Settings.numberLaunchedAppCount.value += 1
        }
    }
    
    static func requestAppReview() {
        SKStoreReviewController.requestReview()
    }
    
    static func reviewInStore() {
        guard let url = URL(string: ReviewHelper.appUrl) else { return }
        SettingsHelper.go(to: url)
    }
    
    static func shareAppToFriend() -> CustomActivityViewController? {
        if let topViewController = UIApplication.topViewController() {
           return recommendAppToFriend(viewController: topViewController)
        }
        return nil
    }
    
    private static func recommendAppToFriend(viewController: UIViewController) -> CustomActivityViewController? {
        let shareText = LocalizedString.shareAppName + "\n"
        guard let shareWebsite = NSURL(string: ReviewHelper.appUrl) else { return nil }
        let shareItems = [shareText, shareWebsite] as [Any]
        let activityViewController = CustomActivityViewController(viewController, activityItems: shareItems, applicationActivities: nil)
        return activityViewController
    }
}
