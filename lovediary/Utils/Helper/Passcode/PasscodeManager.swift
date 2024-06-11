//
//  PasscodeManager.swift
//  PasscodeManager
//
//  Created by daovu on 23/03/2021.
//

import UIKit
import LocalAuthentication

class PascodeManager {
    static var shared: PascodeManager = PascodeManager()
    private lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    private static var isShowPasscode = false
    
    var isLocked: Bool {
        let isLock = try? !AppLocker.valet.string(forKey: ALConstants.kPincode).isEmpty
        return isLock ?? false
    }
    
    func validate(from viewController: UIViewController?,
                  withSensor: Bool = Settings.isUsingSensor.value,
                  isInSetting: Bool = false,
                  onWillSuccessDismiss: OnWillSuccessDismissCallback? = nil) {
        if let passcode = try? AppLocker.valet.string(forKey: ALConstants.kPincode), !passcode.isEmpty {
            guard !PascodeManager.isShowPasscode else { return }
            PascodeManager.isShowPasscode = true
            var config = ALOptions()
            config.title = LocalizedString.enterPasscode
            config.titleColor = Colors.toneColor
            config.isSensorsEnabled = withSensor
            config.wilDismiss = onWillSuccessDismiss
            config.onSuccessfulDismiss = {
                PascodeManager.isShowPasscode = false
                if $0 == .validate {
                    ReviewHelper.checkAndRequestReview()
                }
            }
            AppLocker.present(with: isInSetting ? .validateInSetting : .validate, and: config, over: viewController)
        }
    }
    
    func create(from viewController: UIViewController?, onWillSuccessDismiss: OnWillSuccessDismissCallback? = nil) {
        guard !PascodeManager.isShowPasscode else { return }
        PascodeManager.isShowPasscode = true
        var config = ALOptions()
        config.title = LocalizedString.setPasscode
        config.titleColor = Colors.toneColor
        config.isSensorsEnabled = false
        config.wilDismiss = onWillSuccessDismiss
        config.onSuccessfulDismiss = { _ in
            PascodeManager.isShowPasscode = false
        }
        AppLocker.present(with: .create, and: config, over: viewController)
    }
    
    func changePasscode(from viewController: UIViewController?) {
        guard !PascodeManager.isShowPasscode else { return }
        PascodeManager.isShowPasscode = true
        var config = ALOptions()
        config.title = LocalizedString.setPasscode
        config.titleColor = Colors.toneColor
        config.isSensorsEnabled = false
        config.onSuccessfulDismiss = { _ in
            PascodeManager.isShowPasscode = false
        }
        AppLocker.present(with: .change, and: config, over: viewController)
    }
    
    func deactive(from viewController: UIViewController?, onWillSuccessDismiss: OnSuccessfulDismissCallback? = nil) {
        guard !PascodeManager.isShowPasscode else { return }
        PascodeManager.isShowPasscode = true
        var config = ALOptions()
        config.title = LocalizedString.setPasscode
        config.titleColor = Colors.toneColor
        config.isSensorsEnabled = false
        config.onSuccessfulDismiss = {
            PascodeManager.isShowPasscode = false
            onWillSuccessDismiss?($0)
        }
        AppLocker.present(with: .deactive, and: config, over: viewController)
    }
    
    func removeFirstLaunch() {
        
    }
    
    func removePasscode() {
        try? AppLocker.valet.removeObject(forKey: ALConstants.kPincode)
    }
    
    
    func shouldShowBlurView(from window: UIWindow?) {
        guard isLocked, let window = window else { return }
        blurView.removeFromSuperview()
        self.blurView.alpha = 0
        self.blurView.frame = window.bounds
        window.addSubview(self.blurView)
        window.bringSubviewToFront(self.blurView)
        UIView.animate(withDuration: 0.1) {[weak self] in
            guard let self = self else { return }
            self.blurView.alpha = 1
        }
    }
    
    func reMoveBlurView() {
        self.blurView.alpha = 1
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.blurView.alpha = 0
        }) { [weak self] _ in
            self?.blurView.removeFromSuperview()
        }
    }
    
    let biometricType: LAContext.BiometricType = LAContext().biometricType
    
    var isUsingSensor: Bool {
        return Settings.isUsingSensor.value
    }
    
    func setUsingSensor(isUsing: Bool) {
        Settings.isUsingSensor.value = isUsing
    }
    
    func setLockImmediately(isImmediate: Bool) {
        Settings.isLockImmediately.value = isImmediate
    }
    
    var isLockImmediately: Bool {
        return Settings.isLockImmediately.value
    }
}

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
        
        var title: String {
            switch self {
            case .touchID:
                return "TouchID"
            case .faceID:
                return "FaceID"
            default:
                return ""
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .touchID:
                return Images.Icon.touchId
            case .faceID:
                return Images.Icon.faceId
            default:
                return nil
            }
        }
    }
    
    var biometricType: BiometricType {
        var error: NSError?
        
        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                #warning("Handle new Biometric type")
            }
        }
        
        return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
}
