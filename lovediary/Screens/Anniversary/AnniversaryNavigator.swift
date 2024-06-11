//
//  AnniversaryNavigator.swift
//  lovediary
//
//  Created by vu dao on 10/03/2021.
//

import UIKit
import Combine

protocol AnniversaryNavigatorType: NavigatorType {
    func toUserInfor(type: UserType)
    func toBackgroundSelect()
    func toStartDateSetting()
}

class AnniversaryNavigator: AnniversaryNavigatorType {
    
    weak var viewController: UIViewController?
    private var dependency: ApplicationDependency
    
    init(dependency: ApplicationDependency) {
        self.dependency = dependency
    }
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func toUserInfor(type: UserType) {
        let userInfoViewController = UserInforViewController.instantiate {[weak self] in
            guard let self = self else { return nil }
            let viewModel = UserInforViewModel(dependency: self.dependency.getUserInforDependency(), userType: type)
            return UserInforViewController(coder: $0, viewModel: viewModel)
        }
        
        viewController?.present(userInfoViewController, animated: true, completion: nil)
    }
    
    func toBackgroundSelect() {
        let toViewController = BackgroundSelectViewController.instantiate {[weak self] in
            guard let self = self else { return nil }
            let dependency = BackgroundSelectViewModel
                .Dependency(backgroundManager: self.dependency.backgroundManager)
            let viewModel = BackgroundSelectViewModel(dependency: dependency)
            return BackgroundSelectViewController(coder: $0, viewModel: viewModel)
        }
        
        let nav = BaseNavigationController(rootViewController: toViewController)
        toViewController.modalPresentationStyle = .fullScreen
        nav.modalPresentationStyle = .fullScreen
        self.viewController?.present(nav, animated: true, completion: nil)
    }
    
    func toStartDateSetting() {
        if let viewController = viewController as? AnniversaryViewController {
            let selectDate = StartDateSettingViewController.instantiate {[weak self] in
                guard let self = self else { return nil }
                return StartDateSettingViewController(coder: $0, viewModel: .init(dependency: self.dependency.getStartDateDependency()))
            }
            
            selectDate.presentationController?.delegate = viewController
            viewController.present(selectDate, animated: true, completion: nil)
        }
    }
}
