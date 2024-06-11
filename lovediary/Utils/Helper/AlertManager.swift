//
//  AlertManager.swift
//  AlertManager
//
//  Created by daovu on 18/03/2021.
//

import Foundation
import Combine
import UIKit

enum SelectCase {
    case confirm
    case maybe
    case cancel
}

class AlertManager: NSObject {
    public static let shared = AlertManager()
    var alertController: UIAlertController?
    
    private override init() {}
    
    func showErrorMessage(message: String) -> AnyPublisher<Void, Never> {
        return Deferred {
            Future { promise in
                if self.alertController != nil {
                    self.alertController?.dismiss(animated: false, completion: nil)
                    self.alertController = nil
                }
                
                self.alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.alertController?.view.tintColor = Colors.toneColor
                let okAction = UIAlertAction(title: LocalizedString.ok, style: .cancel, handler: { _ in
                    self.alertController = nil
                    promise(.success(()))
                })
                
                
                self.alertController?.addAction(okAction)
                DispatchQueue.main.async {
                    UIApplication.topViewController()?.present(self.alertController!, animated: true, completion: nil)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func showConfirmMessage(title: String? = nil, message: String, confirm: String, cancel: String, isDelete: Bool = false) -> AnyPublisher<SelectCase, Never> {
        return Deferred {
            Future { promise in
                if self.alertController != nil {
                    self.alertController?.dismiss(animated: false, completion: nil)
                    self.alertController = nil
                }
                self.alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let confirmStyle: UIAlertAction.Style = (isDelete ? .destructive : .default)
                let confirmAction = UIAlertAction(title: confirm, style: confirmStyle, handler: { _ in
                    self.alertController = nil
                    promise(.success(.confirm))
                    
                })
                
                self.alertController?.view.tintColor = Colors.toneColor
                
                let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: { _ in
                    self.alertController = nil
                    promise(.success(.cancel))
                })
                self.alertController?.addAction(cancelAction)
                self.alertController?.addAction(confirmAction)
                UIApplication.topViewController()?.present(self.alertController!, animated: true, completion: nil)
            }
        }.eraseToAnyPublisher()
    }
    
    func showConfirmMessage(message: String, confirm: String, maybe: String, cancel: String) -> AnyPublisher<SelectCase, Never> {
        return Deferred {
            Future { promise in
                if self.alertController != nil {
                    self.alertController?.dismiss(animated: false, completion: nil)
                    self.alertController = nil
                }
                self.alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: confirm, style: .default, handler: { _ in
                    self.alertController = nil
                    promise(.success(.confirm))
                })
                
                
                let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: { _ in
                    self.alertController = nil
                    promise(.success(.cancel))
                })
                self.alertController?.view.tintColor = Colors.toneColor
                self.alertController?.addAction(confirmAction)
                if !maybe.isEmpty {
                    let maybeActionAction = UIAlertAction(title: maybe, style: .default, handler: { _ in
                        self.alertController = nil
                        promise(.success(.maybe))
                    })
                    self.alertController?.addAction(maybeActionAction)
                }
               
                self.alertController?.addAction(cancelAction)
                
                UIApplication.topViewController()?.present(self.alertController!, animated: true, completion: nil)
            }
        }.eraseToAnyPublisher()
    }
    
    func showActionSheet(title: String? = nil, message: String? = nil, actions: [UIAlertAction]) {
        if self.alertController != nil {
            self.alertController?.dismiss(animated: false, completion: nil)
            self.alertController = nil
        }
        
        var preferredStyle = UIAlertController.Style.actionSheet
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            preferredStyle = .alert
        }
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alertController?.view.tintColor = Colors.toneColor
        for action in actions {
            alertController?.addAction(action)
        }
        
        UIApplication.topViewController()?.present(alertController!, animated: true, completion: nil)
    }
}

extension UIViewController {
    func showErrorMessage(message: String) -> AnyPublisher<Void, Never> {
       return AlertManager.shared.showErrorMessage(message: message)
    }
}
