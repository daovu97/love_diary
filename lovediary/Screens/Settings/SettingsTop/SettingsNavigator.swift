//
//  SettingsNavigatorType.swift
//  lovediary
//
//  Created by vu dao on 21/03/2021.
//

import UIKit

protocol SettingsNavigatorType: NavigatorType {
    func toIcloudBackup()
    func toDiaryFont()
    func toTheme()
    func toPasscode()
    func toDataExport()
    func toaboutApp()
    func toBackgroundImage()
    func toHelp()
    func toStartDateSetting()
    func toPremium()
}

class SettingsNavigator: SettingsNavigatorType {
    
    weak var viewController: UIViewController?
    private var dependency: ApplicationDependency
    init(dependency: ApplicationDependency) {
        self.dependency = dependency
    }
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func toIcloudBackup() {
        let ibViewController = IcloudBackupViewController.get(dependency: dependency)
        viewController?.navigationController?.pushAndHideTabbar(ibViewController)
    }
    
    func toPremium() {
        PremiumViewController.show()
    }
    
    func toBackgroundImage() {
        let toViewController = BackgroundSelectViewController.instantiate {[weak self] in
            guard let self = self else { return nil }
            let dependency = BackgroundSelectViewModel
                .Dependency(backgroundManager: self.dependency.backgroundManager)
            let viewModel = BackgroundSelectViewModel(dependency: dependency)
            return BackgroundSelectViewController(coder: $0, viewModel: viewModel)
        }
        
        self.viewController?.navigationController?.pushAndHideTabbar(toViewController)
    }
    
    func toDiaryFont() {
        let settingViewController = DiaryFontSettingViewController.instantiate {
            let viewModel = DiaryFontSettingViewModel()
            let viewController = DiaryFontSettingViewController(coder: $0, viewModel: viewModel)
            return viewController
        }
        viewController?.navigationController?.pushAndHideTabbar(settingViewController)
    }
    
    func toTheme() {
        let aboutViewController = ThemeSettingViewController.instantiate {
            return ThemeSettingViewController(coder: $0, viewModel: ThemeSettingViewModel())
        }
        viewController?.navigationController?.pushAndHideTabbar(aboutViewController)
    }
    
    func toHelp() {
        if let topViewController = UIApplication.topViewController() {
            MailHelper.sendFeedback(from: topViewController)
        }
    }
    
    func toPasscode() {
        if !PascodeManager.shared.isLocked {
            PascodeManager.shared.create(from: UIApplication.topViewController(),
                                         onWillSuccessDismiss: { [weak self] in
                                            if $0 == .create {  self?.goToPasscode() }
                                         })
        } else {
            PascodeManager.shared.validate(from: UIApplication.topViewController(), withSensor: false,
                                           isInSetting: true,
                                           onWillSuccessDismiss: { [weak self] in
                                            if $0 == .validateInSetting {  self?.goToPasscode() }
                                           })
        }
    }
    
    private func goToPasscode() {
        let passcodeViewController = PasscodeSettingViewController.instantiate {
            return PasscodeSettingViewController(coder: $0, viewModel: .init())
        }
        viewController?.navigationController?.pushAndHideTabbar(passcodeViewController)
    }
    
    func toDataExport() {
        
    }
    
    func toaboutApp() {
        let aboutViewController = AboutAppViewController.instantiate {
            return AboutAppViewController(coder: $0, viewModel: BaseViewModel())
        }
        viewController?.navigationController?.pushAndHideTabbar(aboutViewController)
    }
    
    func toStartDateSetting() {
        let selectDate = StartDateSettingViewController.instantiate {[weak self] in
            guard let self = self else { return nil }
            return StartDateSettingViewController(coder: $0, viewModel: .init(dependency: self.dependency.getStartDateDependency()))
        }
        viewController?.present(selectDate, animated: true, completion: nil)
    }
}
