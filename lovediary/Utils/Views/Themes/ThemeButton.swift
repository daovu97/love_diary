//
//  ThemeButton.swift
//  lovediary
//
//  Created by vu dao on 24/03/2021.
//

import UIKit
import Combine

class ThemeButton: UIButton, ThemeNotification {
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
        let inset = bounds.width / 5
        imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
        applyTheme()
        addThemeObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    private func applyTheme() {
        self.tintColor = Themes.current.pencilButtonColor.tint
        self.backgroundColor = Colors.toneColor
    }
    
    func themeChange() {
        applyTheme()
    }
    
    deinit {
        removeThemeObserver()
    }
}


