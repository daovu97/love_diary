//
//  CustomActivityViewController.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import UIKit
import Photos
import Combine

typealias CustomCompletionHandler = (Bool) -> Void

class CustomActivityViewController: UIActivityViewController {
  
    private var anyCancelables = Set<AnyCancellable>()
    
    private func applyTheme() {
        UINavigationBar.appearance().tintColor = UINavigationBar().tintColor
        UINavigationBar.appearance().barTintColor = UINavigationBar().barTintColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UINavigationBar().tintColor ?? .systemBlue]
    }
    
    var viewController: UIViewController?
    var customCompletionHandler: CustomCompletionHandler?
    
    deinit {
        print("Deinit \(self.className)")
        Themes.current.apply()
    }
    
    init(_ viewController: UIViewController, activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
        setupViewController(viewController)
    }
    
    private func setupViewController(_ viewController: UIViewController) {
        self.viewController = viewController
        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popoverPresentationController?.sourceView = viewController.view
        popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
        
        applyTheme()
        
        completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if !completed {
                if let activity = activityType {
                    switch activity {
                    case .saveToCameraRoll:
                        self.checkPermission(of: self)
                    default:
                        return
                    }
                }
            }
            self.customCompletionHandler?(completed)
        }
    }
    
    private func checkPermission(of activityViewController: UIActivityViewController) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied, .restricted, .notDetermined:
            activityViewController.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.gotoSettingApp()
            }
        default:
            return
        }
    }
    
    private func gotoSettingApp() {
        AlertManager.shared.showConfirmMessage(message: LocalizedString.askToSavePhotoPermision,
                                                  confirm: LocalizedString.openSettingApp,
                                                  cancel: LocalizedString.cancel)
            .sink{ selectedCase in
                if selectedCase == .confirm {
                    SettingsHelper.go(to: URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    return
                }
            }.store(in: &anyCancelables)
    }
    
    func show() {
        viewController?.present(self, animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self, let viewController = self.viewController else { return }
            self.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
        }, completion: nil)
    }

}

