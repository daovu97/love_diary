//
//  SettingNormalTableViewCell.swift
//  NotepadWidget
//
//  Created by daovu on 23/12/2020.
//

import UIKit
import Combine

class SettingNormalTableViewCell: SettingTableViewCell , ThemeNotification {
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
    
    func bind(icon: UIImage?, title: String) {
        iconImage.image = icon
        titleLabel.text = title
        titleLabel.applyTheme()
    }
    
    func setDisable(isDisable: Bool) {
        iconImage.alpha = isDisable ? 0.5 : 1
        titleLabel.alpha = isDisable ? 0.5 : 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDisable(isDisable: false)
    }
}
