//
//  ThemeCommonColorLabel.swift
//  lovediary
//
//  Created by daovu on 01/04/2021.
//

import UIKit
import Combine

class ThemeCommonColorLabel: IncreaseHeightLabel, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        textColor = Colors.textColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addThemeObserver()
    }
    
    deinit {
        removeThemeObserver()
    }
}
