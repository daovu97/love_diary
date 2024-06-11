//
//  SettingTableViewCell.swift
//  lovediary
//
//  Created by vu dao on 31/03/2021.
//

import UIKit
import Combine

class SettingTableViewCell: UITableViewCell {
    
    func applyTheme() {
        backgroundColor = Themes.current.settingTableViewColor.cellBackground
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    func setupView() {
        applyTheme()
    }
}
