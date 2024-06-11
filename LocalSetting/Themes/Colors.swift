//
//  Colors.swift
//  LocalSettings
//
//  Created by daovu on 24/03/2021.
//

import UIKit

struct Colors {
    // Common
    static var textColor: UIColor { return Themes.current.commonColor.textColor }
    static var toneColor: UIColor { return Themes.current.pencilButtonColor.background }
    static var backgroundColor: UIColor { return Themes.current.diaryTableViewColor.background }
    static var navigationItemColor: UIColor { return Themes.current.navigationColor.tint }
    static var navigationBackgroundColor: UIColor { return Themes.current.navigationColor.background }
    static var settingTableViewBackgroundColor: UIColor { return Themes.current.settingTableViewColor.background }
    static var settingTableViewCellBackgroundColor: UIColor { return Themes.current.settingTableViewColor.cellBackground }
    static var settingTableViewTextColor: UIColor { return Themes.current.settingTableViewColor.text }
    
}
