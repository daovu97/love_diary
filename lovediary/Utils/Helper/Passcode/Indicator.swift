//
//  Indicator.swift
//  PasscodeManager
//
//  Created by daovu on 23/03/2021.
//

import UIKit

class Indicator: UIView {
    var isNeedClear = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 1
        layer.borderColor = Colors.toneColor.withAlphaComponent(0.6).cgColor
        clipsToBounds = true
    }
}
