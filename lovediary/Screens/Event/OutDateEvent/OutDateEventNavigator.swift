//
//  OutDateEventnavigator.swift
//  lovediary
//
//  Created by daovu on 08/04/2021.
//

import Foundation
import UIKit
import Combine

protocol OutDateEventNavigatorType: NavigatorType {
    func toEventDetail(event: EventModel?, completion: (() -> Void)?)
}

class OutDateEventNavigator: OutDateEventNavigatorType {
    
    weak var viewController: UIViewController?
    private var dependency: ApplicationDependency
    
    init(dependency: ApplicationDependency) {
        self.dependency = dependency
    }
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func toEventDetail(event: EventModel?, completion: (() -> Void)?) {
        let toViewController = NewEventViewController.instantiate {[weak self] in
            guard let self = self else { return nil }
            let navigator = NewEventNavigator(dependency: self.dependency)
            let viewModel = NewEventViewModel(dependecy: .init(eventManager: self.dependency.eventManager),
                                              navigator: navigator, event: event, isOudate: true)
            let vc = NewEventViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: vc)
            return vc
        }
        
        let nav = BaseNavigationController(rootViewController: toViewController)
        toViewController.saveCompletion = completion
        nav.modalPresentationStyle = .automatic
        self.viewController?.present(nav, animated: true, completion: nil)
    }
}

