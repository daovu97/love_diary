//
//  ThemeNavigationButton.swift
//  lovediary
//
//  Created by daovu on 24/03/2021.
//

import UIKit
import Combine

class ThemeNavigationButton: UIButton, ThemeNotification {
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
        self.tintColor = Colors.navigationItemColor
    }
    
    func themeChange() {
        applyTheme()
    }
    
    deinit {
        removeThemeObserver()
    }
}
