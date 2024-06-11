//
//  UINavigationController+Extension.swift
//  lovediary
//
//  Created by vu dao on 18/03/2021.
//

import UIKit

extension UINavigationController {
    func pushAndHideTabbar(_ viewController: UIViewController, animated: Bool = true) {
        viewController.hidesBottomBarWhenPushed = true
        pushViewController(viewController, animated: animated)
    }
}
