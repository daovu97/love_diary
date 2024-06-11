//
//  AppALConstants.swift
//  AppLocker
//
//  Created by Oleg Ryasnoy on 07.07.17.
//  Copyright © 2017 Oleg Ryasnoy. All rights reserved.
//

import UIKit
import AudioToolbox
import LocalAuthentication
import Valet
import Configuration

public enum ALConstants {
    public static let nibName = "AppLocker"
    public static let kPincode = "com.vudx65.passcode" // Key for saving pincode to keychain
    public static var kLocalizedReason = String(format: LocalizedString.usingSensorTitle, "\(PascodeManager.shared.biometricType.title)")
    public static let duration = 0.1 // Duration of indicator filling
    public static let maxPinLength = 4
    
    enum Button: Int {
        case delete = 1000
        case cancel = 1001
    }
}

public typealias OnSuccessfulDismissCallback = (_ mode: ALMode?) -> () // Cancel dismiss will send mode as nil
public typealias OnWillSuccessDismissCallback = (_ mode: ALMode?) -> ()
public typealias OnFailedAttemptCallback = (_ mode: ALMode) -> ()

public struct ALOptions { // The structure used to display the controller
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    public var color: UIColor? = UIColor.systemBackground
    public var titleColor: UIColor?
    public var isSensorsEnabled: Bool?
    public var onSuccessfulDismiss: OnSuccessfulDismissCallback?
    public var onFailedAttempt: OnFailedAttemptCallback?
    public var wilDismiss: OnWillSuccessDismissCallback?
    public init() {}
}

public enum ALMode { // Modes for AppLocker
    case validate
    case change
    case deactive
    case create
    case validateInSetting
}

public class AppLocker: UIViewController {
    
    // MARK: - Top view
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var submessageLabel: UILabel!
    @IBOutlet var pinIndicators: [Indicator]!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    public static let valet = Valet.valet(with: Identifier(nonEmpty: AppConfigs.keychainPrivateKey)!, accessibility: .whenUnlockedThisDeviceOnly)
    // MARK: - Pincode
    private var onSuccessfulDismiss: OnSuccessfulDismissCallback?
    private var onFailedAttempt: OnFailedAttemptCallback?
    private var wilDismiss: OnWillSuccessDismissCallback?
    private let context = LAContext()
    private var pin = "" // Entered pincode
    private var reservedPin = "" // Reserve pincode for confirm
    private var isFirstCreationStep = true
    private var savedPin: String? {
        get {
            return try? AppLocker.valet.string(forKey: ALConstants.kPincode)
        }
        set {
            guard let newValue = newValue else { return }
            try? AppLocker.valet.setString(newValue, forKey: ALConstants.kPincode)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        deleteButton.setTitle(LocalizedString.delete, for: .normal)
        cancelButton.setTitle(LocalizedString.cancel, for: .normal)
    }
    
    fileprivate var mode: ALMode = .validate {
        didSet {
            switch mode {
            case .create:
                submessageLabel.text = LocalizedString.createPasscodeTitle
            case .change:
                submessageLabel.text =  LocalizedString.enterYourPasscodeTitle
            case .deactive:
                submessageLabel.text = LocalizedString.enterYourPasscodeTitle
            case .validate:
                submessageLabel.text = LocalizedString.enterYourPasscodeTitle
                cancelButton.isHidden = true
                isFirstCreationStep = false
            case .validateInSetting:
                submessageLabel.text = LocalizedString.enterYourPasscodeTitle
                isFirstCreationStep = false
            }
        }
    }
    
    private func precreateSettings () { // Precreate settings for change mode
        mode = .create
        clearView()
    }
    
    private func drawing(isNeedClear: Bool, tag: Int? = nil) { // Fill or cancel fill for indicators
        let results = pinIndicators.filter { $0.isNeedClear == isNeedClear }
        let pinView = isNeedClear ? results.last : results.first
        pinView?.isNeedClear = !isNeedClear
        
        UIView.animate(withDuration: ALConstants.duration, animations: {
            pinView?.backgroundColor = isNeedClear ? .clear : Colors.toneColor
        }) { _ in
            isNeedClear ? self.pin = String(self.pin.dropLast()) : self.pincodeChecker(tag ?? 0)
        }
    }
    
    private func pincodeChecker(_ pinNumber: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + ALConstants.duration) {
            if self.pin.count < ALConstants.maxPinLength {
                self.pin.append("\(pinNumber)")
                if self.pin.count == ALConstants.maxPinLength {
                    switch self.mode {
                    case .create:
                        self.createModeAction()
                    case .change:
                        self.changeModeAction()
                    case .deactive:
                        self.deactiveModeAction()
                    case .validate:
                        self.validateModeAction()
                    case .validateInSetting:
                        self.validateModeAction()
                    }
                }
            }
        }
    }
    
    // MARK: - Modes
    private func createModeAction() {
        if isFirstCreationStep {
            isFirstCreationStep = false
            reservedPin = pin
            clearView()
            submessageLabel.text = LocalizedString.confirmPincode
        } else {
            confirmPin()
        }
    }
    
    private func changeModeAction() {
        if pin == savedPin {
            DispatchQueue.main.asyncAfter(deadline: .now() + ALConstants.duration) {
                self.precreateSettings()
            }
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func deactiveModeAction() {
        if pin == savedPin {
            DispatchQueue.main.asyncAfter(deadline: .now() + ALConstants.duration) {
                self.removePin()
            }
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func validateModeAction() {
        if pin == savedPin {
            DispatchQueue.main.asyncAfter(deadline: .now() + ALConstants.duration) {
                self.wilDismiss?(self.mode)
                self.dismiss(animated: true) {
                    self.onSuccessfulDismiss?(self.mode)
                }
            }
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func removePin() {
       try? AppLocker.valet.removeObject(forKey: ALConstants.kPincode)
        self.wilDismiss?(self.mode)
        DispatchQueue.main.asyncAfter(deadline: .now() + ALConstants.duration) {
            self.dismiss(animated: true) {
                self.onSuccessfulDismiss?(self.mode)
            }
        }
    }
    
    private func confirmPin() {
        if pin == reservedPin {
            savedPin = pin
            DispatchQueue.main.asyncAfter(deadline: .now() + ALConstants.duration) {
                self.wilDismiss?(self.mode)
                self.dismiss(animated: true) {
                    self.onSuccessfulDismiss?(self.mode)
                }
            }
        } else {
            onFailedAttempt?(mode)
            incorrectPinAnimation()
        }
    }
    
    private func incorrectPinAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + ALConstants.duration) {
            self.pinIndicators.forEach { view in
                view.shake(delegate: self)
                view.backgroundColor = .clear
            }
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    fileprivate func clearView() {
        pin = ""
        pinIndicators.forEach { view in
            view.isNeedClear = false
            UIView.animate(withDuration: ALConstants.duration, animations: {
                view.backgroundColor = .clear
            })
        }
    }
    
    // MARK: - Touch ID / Face ID
    fileprivate func checkSensors() {
        if case .validate = mode {} else { return }
        var policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        policy = .deviceOwnerAuthentication
        var err: NSError?
        // Check if the user is able to use the policy we've selected previously
        guard context.canEvaluatePolicy(policy, error: &err) else { return }
        context.evaluatePolicy(policy, localizedReason: ALConstants.kLocalizedReason,
                               reply: {  success, error in
            if success {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.dismiss(animated: true) {
                        self.onSuccessfulDismiss?(self.mode)
                    }
                }
            }
        })
    }
    
    // MARK: - Keyboard
    @IBAction func keyboardPressed(_ sender: UIButton) {
        switch sender.tag {
        case ALConstants.Button.delete.rawValue:
            drawing(isNeedClear: true)
        case ALConstants.Button.cancel.rawValue:
            clearView()
            dismiss(animated: true) {
                self.onSuccessfulDismiss?(nil)
            }
        default:
            drawing(isNeedClear: false, tag: sender.tag)
        }
    }
    
}

// MARK: - CAAnimationDelegate
extension AppLocker: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        clearView()
    }
}

// MARK: - Present
extension AppLocker {
    // Present AppLocker
    class func present(with mode: ALMode, and config: ALOptions? = nil, over viewController: UIViewController? = nil) {
        guard let root = viewController,
            let locker = Bundle(for: self.classForCoder()).loadNibNamed(ALConstants.nibName, owner: self, options: nil)?.first as? AppLocker else {
                return
        }
        locker.messageLabel.text = config?.title ?? ""
        locker.submessageLabel.text = config?.subtitle ?? ""
        locker.view.backgroundColor = config?.color ?? .white
        locker.messageLabel.textColor = config?.titleColor
        locker.mode = mode
        locker.onSuccessfulDismiss = config?.onSuccessfulDismiss
        locker.onFailedAttempt = config?.onFailedAttempt
        locker.wilDismiss = config?.wilDismiss
        root.present(locker, animated: true, completion: {
            if config?.isSensorsEnabled ?? false {
                locker.checkSensors()
            }
        })
    }
}
