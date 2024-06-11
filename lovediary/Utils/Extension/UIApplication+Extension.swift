//
//  UIApplication+Extension.swift
//  QikNote
//
//  Created by daovu on 01/03/2021.
//

import UIKit

extension UIApplication {
    
    static var window: UIWindow? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        return delegate?.window
    }
    
    static var windowBound: CGRect {
        guard
            let windowBound = window?.bounds
        else {
            return .zero
        }
        
        return windowBound
    }
    
    static var width: CGFloat {
        return windowBound.width
    }
    
    static var height: CGFloat {
        return windowBound.height
    }
    
    class func topViewController(base: UIViewController? = UIApplication.window?.rootViewController) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }
        if let tabBarController = base as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        /// For case present 2 alert controller in 1 time
        if base is UIAlertController {
            return nil
        }
        
        return base
    }
}
