//
//  AppDelegate.swift
//  lovediary
//
//  Created by vu dao on 25/03/2021.
//

import UIKit
import GoogleMobileAds
import Configuration
import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let appDependency = ApplicationDependency()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        updateNumberLaunchedAppAccountIfNeeded()
        setupRootView()
        setupWhenFirstTimeInstall()
        IAPHelper.shared.configure()
        AdsHelper.shared.configure()
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(AppConfigs.firebaseEnable)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(AppConfigs.firebaseEnable)
        UIApplication.showPasscodeIfNeed()
        saveLocalVersionNumber()
        return true
    }
    
    private func saveLocalVersionNumber() {
        Settings.appVersion.value = SettingsHelper.getVersion()
    }
    
    private func setupRootView() {
        window = UIWindow()
        Themes.current.initialize()
        appDependency.eventManager.updateDefaultEvent().sink {}.cancel()
        window?.rootViewController = MainTabBarController(dependency: appDependency)
        window?.makeKeyAndVisible()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.removeBlurView()
        checkPermissionOnAppActive()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shouldShowBlurView()
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if PascodeManager.shared.isLockImmediately {
            UIApplication.showPasscodeIfNeed()
        }
        
        if let topViewController = UIApplication.topViewController() as? AnniversaryViewController {
            topViewController.replayAnimationView()
        }
    }
    
    private func setupWhenFirstTimeInstall() {
        if Settings.dateStartApp.value == nil {
            // remove passcode
            PascodeManager.shared.removePasscode()
            Settings.dateStartApp.value = Date()
        }
    }
    
    private func updateNumberLaunchedAppAccountIfNeeded() {
        ReviewHelper.updateNumberLaunchedAppCountIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        updateBadget()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    private func checkPermissionOnAppActive() {
        if !NotificationPermissionStatus.isNotRegister {
            BadgeHelper.checkNotificationAuthorization { isAuthorization in
                if isAuthorization {
                    DispatchQueue.main.async {
                        Settings.isAllowNotificationPermission.value = isAuthorization ? NotificationPermissionStatus.allow.rawValue : NotificationPermissionStatus.decline.rawValue
                        if  !(UIApplication.topViewController() is EventViewController) || NotificationPermissionStatus.needUpdateTodoReminderTime {
                            self.appDependency.eventManager.updateReminderStatus()
                        }
                        self.updateBadget()
                    }
                }
            }
        } else {
            NotificationHelper.requestAuthorization(error: {_ in }, completion: {_ in })
        }
    }
    
    private func updateBadget() {
        appDependency.eventManager.updateBadget()
    }
}

extension UIApplication {
    
    static func showPasscodeIfNeed() {
        PascodeManager.shared.validate(from: self.topViewController())
    }
    
    static func shouldShowBlurView() {
        PascodeManager.shared.shouldShowBlurView(from: window)
    }
    
    static func removeBlurView() {
        PascodeManager.shared.reMoveBlurView()
    }
}

class BadgeHelper {
    
    class func checkNotificationAuthorization(completion: @escaping (_ isAuthorization: Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { setting in
            completion(setting.authorizationStatus == .authorized)
        }
    }
    
    class func checkNotificationAuthorization() -> AnyPublisher<Bool, Never> {
        return Deferred {
            Future { promise in
                let center = UNUserNotificationCenter.current()
                center.getNotificationSettings { setting in
                    promise(.success(setting.authorizationStatus == .authorized))
                }
            }}.eraseToAnyPublisher()
    }
}

