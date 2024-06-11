//
//  NotificationName.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import Foundation

extension NSNotification.Name {
    static let IAPHelperPurchaseNotification = NSNotification.Name("IAPHelperPurchaseNotification")
    static let languageChangeObserver = NSNotification.Name(rawValue: "LanguageChangedObserver")
    static let themeChangeNotification = NSNotification.Name(rawValue: "ThemeChangeNotification")
    static let didDeleteDiaryNotification = NSNotification.Name(rawValue: "DeleteDiaryNotification")
    static let shouldReloadDiaryNotification = NSNotification.Name(rawValue: "ShouldReloadDiaryNotification")
    static let bannerViewLoadedNotification = NSNotification.Name(rawValue: "bannerViewLoadedNotification")
}

