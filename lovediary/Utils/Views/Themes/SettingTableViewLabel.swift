//
//  SettingTableViewLabel.swift
//  lovediary
//
//  Created by vu dao on 31/03/2021.
//

import UIKit

class SettingTableViewLabel: IncreaseHeightLabel {
    
    func applyTheme() {
        textColor = Themes.current.settingTableViewColor.text
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
        applyTheme()
    }
}

class SettingTableViewDetailLabel: IncreaseHeightLabel {
    
    func applyTheme() {
        textColor = Themes.current.settingTableViewColor.text.withAlphaComponent(0.6)
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
        applyTheme()
    }
}
