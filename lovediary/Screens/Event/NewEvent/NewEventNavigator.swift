//
//  NewEventNavigator.swift
//  lovediary
//
//  Created by daovu on 06/04/2021.
//

import UIKit
import Combine

protocol NewEventNavigatorType: NavigatorType {
    func dismiss()
    func showDismissAlert()
    func showReminderSetting(isTime: Bool, currentReminderType: ReminderType, didSelectComplete: ((ReminderType) -> Void)?)
}

class NewEventNavigator: NewEventNavigatorType {
    
    weak var viewController: UIViewController?
    private var dependency: ApplicationDependency
    
    init(dependency: ApplicationDependency) {
        self.dependency = dependency
    }
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func showDismissAlert() {
        let discastAction = UIAlertAction(title: LocalizedString.discartChangeLabel, style: .destructive) {[weak self] _ in
            self?.viewController?.isModalInPresentation = false
            self?.dismiss()
        }
        
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel) {[weak self] _ in
            self?.viewController?.isModalInPresentation = true
        }
        
        AlertManager.shared.showActionSheet(actions: [discastAction, cancelAction])
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func showReminderSetting(isTime: Bool,
                             currentReminderType: ReminderType,
                             didSelectComplete: ((ReminderType) -> Void)?) {
        let reminders = !isTime ? ReminderType.reminderDay : ReminderType.allCases
        let datas = reminders.map { return SelectTableModel(title: $0.title) }
        let selectedPosition = reminders.firstIndex(of: currentReminderType) ?? 0
        let selectViewController = ReminderTypeViewController.show(datas: datas,
                                                                   selectedPosition: [selectedPosition],
                                                                   numberOfSelection: 1) { selectVC in
            selectVC.navigationTitle = LocalizedString.reminderTypeTitle
            selectVC.didSelectComplete = { position in
                if let select = position.first {
                    didSelectComplete?(reminders[select])
                }
            }
        }
        selectViewController.isModalInPresentation = true
        self.viewController?.present(selectViewController, animated: true, completion: nil)
    }
}

