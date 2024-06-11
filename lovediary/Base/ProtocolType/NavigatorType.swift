//
//  NavigatorType.swift
//  lovediary
//
//  Created by vu dao on 21/03/2021.
//

import UIKit

protocol NavigatorType {
    var viewController: UIViewController? { get set}
    
    func start(with viewController: UIViewController?)
}
