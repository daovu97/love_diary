//
//  ApplicationDependency.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation

class ApplicationDependency {
    private lazy var userDefaults = UserDefaults.standard
    private lazy var userManager: UserManagermentType = UserManagerment(defaults: userDefaults)
    lazy var backgroundManager: BackgroundManagerType = BackgroundManager()
    lazy var diaryDependency = DiariesDependency(appDependency: self)
    lazy var eventManager: EventManagerType = EventManager()
    
    func getAnniversaryDependency() -> AnniversaryViewModel.Dependency {
        return .init(userManager: userManager,
                     backgroundManager: backgroundManager)
    }
    
    func getUserInforDependency() -> UserInforViewModel.Dependency {
        return .init(userManager: userManager)
    }
    
    func getStartDateDependency() -> StartDateSettingViewModel.Dependency {
        return .init(userManager: userManager, eventManager: eventManager)
    }
    
    func getIcloudBackupManagerType() -> IcloudBackupManagerType {
        return IcloudBackupManager(cloudKitHelper: CloudKitHelper(),
                                   diaryManager: diaryDependency.diaryManager,
                                   userManager: userManager,
                                   eventManager: eventManager)
    }
}
