//
//  EventNavigator.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import UIKit
import Combine

protocol EventNavigatorType: NavigatorType {
    func toEventDetail(event: EventModel?, completion: (() -> Void)?)
    func toOutDateEvent()
}

class EventNavigator: EventNavigatorType {
    
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
                                              navigator: navigator, event: event)
            let vc = NewEventViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: vc)
            return vc
        }
        
        let nav = BaseNavigationController(rootViewController: toViewController)
        
        toViewController.saveCompletion = completion
        nav.modalPresentationStyle = .automatic
        
        self.viewController?.present(nav, animated: true, completion: nil)
    }
    
    func toOutDateEvent() {
        let outDateEvent = OutDateEventViewController.instantiate {
            let navigator = OutDateEventNavigator(dependency: self.dependency)
            let viewModel = OutDateEventViewModel(navigator: navigator,
                                                  dependecy: .init(eventManager: self.dependency.eventManager))
            let vc = OutDateEventViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: vc)
            return vc
        }
        self.viewController?.navigationController?.pushAndHideTabbar(outDateEvent)
    }
}
