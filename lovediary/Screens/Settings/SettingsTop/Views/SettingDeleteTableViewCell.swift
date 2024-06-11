//
//  SettingDeleteTableViewCell.swift
//  NotepadWidget
//
//  Created by daovu on 23/12/2020.
//

import UIKit
import Combine

class SettingDeleteTableViewCell: SettingTableViewCell , ThemeNotification {
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
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(icon: UIImage?, title: String) {
        iconImage.image = icon
        titleLabel.text = title
        iconImage.tintColor = .red
        titleLabel.textColor = .red
        titleLabel.applyTheme()
    }
}
