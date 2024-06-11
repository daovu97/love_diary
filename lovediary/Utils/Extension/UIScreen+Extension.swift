//
//  UIScreen+Extension.swift
//  lovediary
//
//  Created by daovu on 25/03/2021.
//

import UIKit

extension UIScreen {
    var ratio: CGSize {
        let bound = UIScreen.main.bounds
        return CGSize(width: bound.width, height: bound.height)
    }
}
