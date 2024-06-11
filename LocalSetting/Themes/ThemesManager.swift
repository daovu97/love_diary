//
//  ThemesManager.swift
//  LocalSettings
//
//  Created by vu dao on 23/03/2021.
//

import UIKit

enum Themes: Int, CaseIterable {
    case theme0
    case theme1
    case theme2
    case theme3
    case theme4
    case theme5
    case theme6
    case theme7
    
    static var current: Theme = getTheme(with: Settings.theme.value)
    
    var theme: Theme {
        switch self {
        case .theme0:
            return Theme0()
        case .theme1:
            return Theme1()
        case .theme2:
            return Theme2()
        case .theme3:
            return Theme3()
        case .theme4:
            return Theme4()
        case .theme5:
            return Theme5()
        case .theme6:
            return Theme6()
        case .theme7:
            return Theme22()
        }
    }
    
    var image: UIImage? {
        switch self {
        case .theme0:
            return UIImage(named: "theme1")
        case .theme1:
            return UIImage(named: "theme2")
        case .theme2:
            return UIImage(named: "theme3")
        case .theme3:
            return UIImage(named: "theme4")
        case .theme4:
            return UIImage(named: "theme5")
        case .theme5:
            return UIImage(named: "theme6")
        case .theme6:
            return UIImage(named: "theme7")
        case .theme7:
            return UIImage(named: "theme8")
        }
    }
    
    var name: String {
        switch self {
        case .theme0:
            return LocalizedString.themeName0
        case .theme1:
            return LocalizedString.themeName1
        case .theme2:
            return LocalizedString.themeName2
        case .theme3:
            return LocalizedString.themeName3
        case .theme4:
            return LocalizedString.themeName4
        case .theme5:
            return LocalizedString.themeName5
        case .theme6:
            return LocalizedString.themeName6
        case .theme7:
            return LocalizedString.themeName7
        }
    }
    
    var isDarkTheme: Bool {
        switch self {
        case .theme7:
            return true
        default: return false
        }
    }
    
    static func getCurrent() -> Themes {
        let currents = allCases.indices.contains(Settings.theme.value) ? allCases[Settings.theme.value] : Themes.theme0
        current = currents.theme
        return currents
    }
    
    static func getTheme(with id: Int) -> Theme {
        return allCases.indices.contains(id) ? allCases[id].theme : Themes.theme0.theme
    }
    
    static func getThemeName(with id: Int) -> String {
        return allCases.indices.contains(id) ? allCases[id].name : Themes.theme0.name
    }
    
    static func resetNavigationBarTheme() {
        UINavigationBar.appearance().barTintColor = nil
        UINavigationBar.appearance().tintColor = nil
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().titleTextAttributes = nil
    }
    
    static func applyNavigationBarTheme(to navigationController: UINavigationController? = nil) {
        let navigationBar = navigationController == nil ? UINavigationBar.appearance() : navigationController?.navigationBar
        navigationBar?.barTintColor = Themes.current.navigationColor.background
        navigationBar?.tintColor = Themes.current.navigationColor.tint
        navigationBar?.isTranslucent = false
        navigationBar?.titleTextAttributes = [.foregroundColor: Themes.current.navigationColor.title]
    }
    
    static func resetTableViewTheme() {
        UITableView.appearance().backgroundColor = Self.current.diaryTableViewColor.background
        UITableViewCell.appearance().backgroundColor = .white
    }
    
    static func applyTableViewTheme() {
        UITableView.appearance().backgroundColor =  Self.current.diaryTableViewColor.background
        UITableViewCell.appearance().backgroundColor =  Self.current.diaryTableViewColor.cellBackground
    }
}
