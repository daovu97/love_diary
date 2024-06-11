//
//  NotificationCenterHelper.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation
import UIKit
import Combine
import UserNotifications

enum NotificationError: Error {
    static let authorizationError = NSError(domain: "Notification permission error", code: 999, userInfo: nil)
    static let notifyDateNil = NSError(domain: "Notify Date Is Nil", code: 888, userInfo: nil)
    static let canNotGetReminderTimes = NSError(domain: "Can not get Reminder Times", code: 777, userInfo: nil)
}

struct NotificationHelper {
    static let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    static func requestAuthorization(error: @escaping (Error) -> Void, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options, completionHandler: { (granted, err) in
            if let err = err {
               error(err)
            }
            completion(granted)
        })
    }
    
    static func createNotificationRequests(event: EventModel) -> AnyPublisher<Void, Never> {
        return Deferred {
            Future { promise in
                if let notifyDate = event.reminderDateTime, notifyDate >= Date() {
                    let center = UNUserNotificationCenter.current()
                    let content = NotificationHelper.createUNNotificationContent(contentTitleKey: event.title, contentBodyKey: event.detail.isEmpty ? LocalizedString.openEventNotificationTitle : event.detail)
                    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notifyDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    let identifier = "\(event.id)"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    center.add(request) { (err: Error?) in
                        if let err = err {
                            print(err)
                        }
                        promise(.success(()))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    static func createUNNotificationContent(contentTitleKey: String, contentBodyKey: String, isReminder: Bool = false) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: contentTitleKey, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: contentBodyKey, arguments: nil)
        
        //update badget
        content.sound = UNNotificationSound.default
        return content
    }
    
    static func checkExistNotificationRequest(identifier: String, completion: @escaping (_ exist: Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            let filterRequests = requests.filter({ $0.identifier == identifier })
            if filterRequests.count > 0 {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func getPendingNotificationRequestCount(completion: @escaping (_ numberOfPendingNotification: Int) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            completion(requests.count)
        })
    }
    
    static func removeAllDeliveredNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
    }
    
    static func removeAllReminderPendingNotification() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            let allPendingReminderNotificationIdentifiers = requests.filter { return DateHelper.getReminderDate(from: $0.identifier) != nil }.map { $0.identifier }
            removePendingNotificationByIdentifier(withIdentifiers: allPendingReminderNotificationIdentifiers)
        })
    }
    
    static func removePendingNotificationByIdentifier(withIdentifiers identifiers: [String]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    static func redirectToSettingApp() {
        SettingsHelper.go(to: URL(string: UIApplication.openSettingsURLString)!)
    }
    
    static func handleRequestNotifications(_ granted: Bool, isOpenSetting: Bool = true) {
        let userdefault = UserDefaults.standard
        if let reminderisRequestedForRemoteNotifications = userdefault.value(forKey: "ReminderIsRequestedForRemoteNotifications") as? Bool {
            if reminderisRequestedForRemoteNotifications && !granted && isOpenSetting {
                SettingsHelper.go(to: URL(string: UIApplication.openSettingsURLString)!)
            }
        } else {
            userdefault.setValue(true, forKey: "ReminderIsRequestedForRemoteNotifications")
            userdefault.synchronize()
        }
    }
}

