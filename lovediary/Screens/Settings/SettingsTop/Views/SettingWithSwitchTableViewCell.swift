//
//  SettingWithSwitchTableViewCell.swift
//  NotepadWidget
//
//  Created by daovu on 23/12/2020.
//

import UIKit
import Combine

class SettingWithSwitchTableViewCell: SettingTableViewCell, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    override func setupView() {
        super.setupView()
        addThemeObserver()
    }
    
    deinit {
        removeThemeObserver()
    }
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: SettingTableViewLabel!
    @IBOutlet weak var switchButton: UISwitch!
    
    var didValueChange: ((Bool) -> Void)?
    
    func bind(icon: UIImage?, title: String, isOn: Bool) {
        iconImage.image = icon
        titleLabel.text = title
        switchButton.isOn = isOn
        switchButton.addTarget(self, action: #selector(didSwitchChange), for: .valueChanged)
        titleLabel.applyTheme()
    }
    
    @objc private func didSwitchChange(switchButton: UISwitch) {
        didValueChange?(switchButton.isOn)
    }
}
