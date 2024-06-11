//
//  ThemeUserInfoCell.swift
//  lovediary
//
//  Created by daovu on 01/04/2021.
//

import Foundation

import UIKit
import Combine

class ThemeUserInfoCell: UIView {
    
    func applyTheme() {
        backgroundColor = Themes.current.settingTableViewColor.cellBackground
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

