//
//  ThemeImageIcon.swift
//  lovediary
//
//  Created by vu dao on 24/03/2021.
//

import UIKit
import Combine

class ThemeImageIcon: UIImageView, ThemeNotification {
    var subscription: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        applyTheme()
        addThemeObserver()
    }
    
    private func applyTheme() {
        self.tintColor = Colors.toneColor
    }
    
    func themeChange() {
        applyTheme()
    }
    
    deinit {
        removeThemeObserver()
    }
}

