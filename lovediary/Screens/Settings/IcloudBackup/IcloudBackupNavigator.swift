//
//  IcloudBackupNavigator.swift
//  lovediary
//
//  Created by daovu on 23/04/2021.
//

import UIKit

protocol IcloudBackupNavigatorType: NavigatorType {
    func toDataManage()
}

class IcloudBackupNavigator: IcloudBackupNavigatorType {
    func toDataManage() {
        
    }
    
    weak var viewController: UIViewController?
    private var dependency: ApplicationDependency
    init(dependency: ApplicationDependency) {
        self.dependency = dependency
    }
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
}
