//
//  BaseNavigationController.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func transparent() {
        Themes.current.applyNavigation(with: self.navigationBar, transparent: true, hidenShadow: true)
    }
    
    func makeDefautl(hidenShadow: Bool = false, backgroundColor: UIColor = Themes.current.navigationColor.background) {
        Themes.current.applyNavigation(with: self.navigationBar, transparent: false,
                                       hidenShadow: hidenShadow, backgroundColor: backgroundColor)
    }
}
