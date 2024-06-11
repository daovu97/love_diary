//
//  MailHelper.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import UIKit
import MessageUI
import DeviceKit
import Combine
import Configuration

class MailHelper: NSObject {
    static let shared = MailHelper()
    var mailComposeViewController: MFMailComposeViewController?
    private static var subscription: AnyCancellable?
    private override init() {}
    
    static func sendFeedback(from viewController: UIViewController) {
        let osVersionName = UIDevice.current.systemVersion
        let deviceName = Device.current
        let dictionary = Bundle.main.infoDictionary!
        var versionOfApplication = ""
        if let version = dictionary["CFBundleShortVersionString"] as? String, let build = dictionary["CFBundleVersion"] as? String {
            versionOfApplication = String("\(version) - \(build)")
        }
        let signature = String("[iOS: \(osVersionName), \(deviceName): \(versionOfApplication)]")
        let messageBody = String("\n\n\n\n\n\(signature)")
        let mailAddressForFeedbackAndQuestion = AppConfigs.mailFeedback
        let subjectForFeedbackAndQuestion = "\(LocalizedString.subjectForFeedbackAndQuestion)"
        MailHelper.sendEmail(from: viewController, mailAddress: [mailAddressForFeedbackAndQuestion], subject: subjectForFeedbackAndQuestion, messageBody: messageBody)
    }
    
    static func sendEmail(from viewController: UIViewController, mailAddress: [String], subject: String, messageBody: String, attachmentData: Data? = nil, fileName: String? = nil) {
        if MFMailComposeViewController.canSendMail() {
            if shared.mailComposeViewController == nil {
                shared.mailComposeViewController = MFMailComposeViewController()
            }
            guard let mailComposeViewController = shared.mailComposeViewController else {
                return
            }
            mailComposeViewController.mailComposeDelegate = shared
            mailComposeViewController.setToRecipients(mailAddress)
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.setMessageBody(messageBody, isHTML: false)
            if let attachmentData = attachmentData, let fileName = fileName {
                mailComposeViewController.addAttachmentData(attachmentData, mimeType: "text/csv", fileName: fileName)
            }
            viewController.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            subscription = AlertManager.shared
                .showConfirmMessage(message: LocalizedString.setupEmailMessage,
                                    confirm: LocalizedString.setupEmailConfirm,
                                    cancel: LocalizedString.cancel)
                .sink { selectCase in
                    if selectCase == .confirm {
                        let mailUrl = URL(string: "message://")!
                        SettingsHelper.go(to: mailUrl)
                    }
                    subscription?.cancel()
                }
        }
    }
}

extension MailHelper: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        controller.dismiss(animated: true, completion: nil)
        MailHelper.shared.mailComposeViewController = nil
    }
}

