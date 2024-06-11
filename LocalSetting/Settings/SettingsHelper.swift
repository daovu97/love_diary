//
//  SettingsHelper.swift
//  LocalSettings
//
//  Created by vu dao on 10/03/2021.
//

import UIKit
import Combine
import Photos

public struct DefaultValue {
    public static let fontSize: Float = 15
    public static let lineSpacing: Float = 5
}

enum NotificationPermissionStatus: Int {
    case doenstRegister
    case allow
    case decline
    
    static var isNotRegister: Bool {
        return Settings.isAllowNotificationPermission.value == NotificationPermissionStatus.doenstRegister.rawValue
    }
    
    static var canCreateNotification: Bool {
        return Settings.isAllowNotificationPermission.value == NotificationPermissionStatus.doenstRegister.rawValue || Settings.isAllowNotificationPermission.value == NotificationPermissionStatus.allow.rawValue
    }
    
    static var needShowMessage: Bool {
        return Settings.isAllowNotificationPermission.value == NotificationPermissionStatus.decline.rawValue
    }
    
    static var needUpdateTodoReminderTime: Bool {
        return Settings.isAllowNotificationPermission.value == NotificationPermissionStatus.allow.rawValue
    }
}

public struct Settings {
    static let isFirstLaunch = WrappedUserDefault<Bool>(key: .isFirstLaunch, defaultValue: true)
    static let isRemoveAds = WrappedUserDefault<Bool>(key: .isRemoveAds, defaultValue: false)
    static let isNotify = WrappedUserDefault<Bool>(key: .isNotify, defaultValue: false)
    static let theme = WrappedUserDefault<Int>(key: .theme, defaultValue: Themes.theme0.rawValue)
    static let tabbarLastTime = WrappedUserDefault<Int>(key: .tabbarLastTime, defaultValue: 0)
    static let isAllowAnalytic = WrappedUserDefault<Bool>(key: .isAllowAnalytic, defaultValue: true)
    static let mainBackgroundID = WrappedUserDefault<String>(key: .mainBackgroundID, defaultValue: "")
    static let isReversePhoto = WrappedUserDefault<Bool>(key: .isReversePhoto, defaultValue: false)
    static let dateStartApp = WrappedUserDefault<Date?>(key: .dateStartApp, defaultValue: nil)
    
    static let numberLaunchedAppCount = WrappedUserDefault<Int>(key: .numberLaunchedAppCount, defaultValue: 0)
    static let requestReviewFlags = WrappedUserDefault<[Bool]>(key: .requestReviewFlags, defaultValue: [false, false, false])
    
    static let fontSize = WrappedUserDefault<Float>(key: .fontSize, defaultValue: DefaultValue.fontSize)
    static let lineSpacing = WrappedUserDefault<Float>(key: .lineSpacing, defaultValue: DefaultValue.fontSize)
    static let appVersion = WrappedUserDefault<String>(key: .appVersion, defaultValue: "1.0.0")
    static let galeryViewPosition = WrappedUserDefault<Int>(key: .galeryViewPosition, defaultValue: 2)
    
    static let isUsingSensor = WrappedUserDefault<Bool>(key: .isUsingSensor, defaultValue: false)
    static let isLockImmediately = WrappedUserDefault<Bool>(key: .isLockImmediately, defaultValue: true)
    static let isAllowNotificationPermission = WrappedUserDefault<Int>(key: .isAllowNotificationPermission, defaultValue: NotificationPermissionStatus.doenstRegister.rawValue)
    static let isAdditionImageWithShareFB = WrappedUserDefault<Bool>(key: .isAdditionImageWithShareFB, defaultValue: false)
    static let sharedWithFBRequest = WrappedUserDefault<Bool>(key: .sharedWithFBRequest, defaultValue: false)
    
    public static func setMainBackgroundID(id: String) {
        mainBackgroundID.value = id
    }
    
    public static func getMainBackgroundID() -> String {
        return mainBackgroundID.value
    }
}

struct SettingsHelper {
    static let isRemoveAds = CurrentValueSubject<Bool, Never>(Settings.isRemoveAds.value)
    static let isNotify = CurrentValueSubject<Bool, Never>(Settings.isNotify.value)
    
    @available(iOS 14.0, *)
    static func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        case .denied, .restricted, .limited:
            completion(false)
        default:
            completion(true)
        }
    }
    
    static func go(to url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    static func goToSettingApp() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            SettingsHelper.go(to:url)
        }
    }
    
    static let firstLineFontIncrement: CGFloat = 5
    
    static var textViewAttributes: [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CGFloat(Settings.lineSpacing.value)
        return [.font: regularFont, .foregroundColor: textColor, .paragraphStyle: style]
    }
    
    static var textViewLinkColor: UIColor {
        return .blue
    }

    static var textColor: UIColor {
        return Colors.toneColor
    }

    static var fontSize: CGFloat {
        return CGFloat(Settings.fontSize.value)
    }

    static var regularFont: UIFont {
        return Fonts.getHiraginoSansFont(fontSize: fontSize, fontWeight: .regular)
    }
    
    static var boldFont: UIFont {
        return Fonts.getHiraginoSansFont(fontSize: fontSize, fontWeight: .bold)
    }

    static var firstLineFont: UIFont {
        var fontSize = self.fontSize
            if true {
            fontSize += firstLineFontIncrement
        }
        return boldFont
    }
    
    static func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleShortVersionString"] as? String ?? "1"
    }
}
