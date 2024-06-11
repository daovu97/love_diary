//
//  Themes.swift
//  LocalSettings
//
//  Created by vu dao on 10/03/2021.
//

import UIKit

struct NavigationColor {
    var barStyle: UIBarStyle
    var background: UIColor
    var title: UIColor
    var tint: UIColor
}

struct TabBarColor {
    var background: UIColor
    var selectedItem: UIColor
    var item: UIColor
}

struct DiaryTableViewColor {
    var background: UIColor
    var cellBackground: UIColor
    var cellDateTimeText: UIColor
    var cellDiaryText: UIColor
    var calendarColor: CalendarColor
}

struct PencilButtonColor {
    var background: UIColor
    var tint: UIColor
}

struct SettingTableViewColor {
    var background: UIColor
    var cellBackground: UIColor
    var text: UIColor
}

struct CommonColor {
    var textColor: UIColor
    var background: UIColor
}

struct EventTableViewColor {
    var background: UIColor
    var cellBackground: UIColor
    var cellEventTimeText: UIColor
    var cellEventText: UIColor
}

struct CalendarColor {
    var background: UIColor
    var weekdayTitleColor: UIColor
    var titleDefaultColor: UIColor
    var eventDefaultColor: UIColor
    var todayColor: UIColor
    var selectionColor: UIColor
    var titleTodayColor: UIColor
    var titlePlaceholderColor: UIColor
    var titleWeekendColor: UIColor
    var titleSelectionColor: UIColor
}

protocol Theme {
    var userInterfaceStyle: UIUserInterfaceStyle { get }
    var navigationColor: NavigationColor { get }
    var tabBarColor: TabBarColor { get }
    var diaryTableViewColor: DiaryTableViewColor { get }
    var pencilButtonColor: PencilButtonColor { get }
    var settingTableViewColor: SettingTableViewColor { get }
    var commonColor: CommonColor { get }
    var eventTableViewColor: EventTableViewColor { get }
}

extension Theme {
    func initialize() {
        applyGeneralControls()
    }
    
    func applyNavigation(with navi: UINavigationBar?, transparent: Bool = false,
                         hidenShadow: Bool = false, backgroundColor: UIColor = Themes.current.navigationColor.background) {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.backgroundColor = transparent ? .clear : backgroundColor
        navAppearance.backgroundImage = transparent ? UIImage() : UINavigationBarAppearance().backgroundImage
        navAppearance.backgroundEffect = transparent ? nil : UINavigationBarAppearance().backgroundEffect
        navAppearance.titleTextAttributes = [.foregroundColor: navigationColor.title]
        navAppearance.shadowImage = hidenShadow ? UIImage() : UINavigationBarAppearance().shadowImage
        navAppearance.shadowColor = hidenShadow ? .clear : UINavigationBarAppearance().shadowColor
        UINavigationBar.appearance().tintColor = navigationColor.tint
        navi?.scrollEdgeAppearance = navAppearance
        navi?.standardAppearance = navAppearance
        navi?.isTranslucent = true
    }
    
    func applyNavigationBarColor(with navi: UINavigationBar?) {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.backgroundColor = navigationColor.background
        navAppearance.titleTextAttributes = [.foregroundColor: navigationColor.title]
        navi?.scrollEdgeAppearance = navAppearance
        navi?.standardAppearance = navAppearance
        navi?.isTranslucent = true
        navi?.tintColor = navigationColor.tint
    }
    
    func applyGeneralControls() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.backgroundColor = navigationColor.background
        navAppearance.titleTextAttributes = [.foregroundColor: navigationColor.title]
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = navigationColor.tint
        
        // Tab Bar
        UITabBar.appearance().barTintColor = tabBarColor.background
        UITabBar.appearance().tintColor = tabBarColor.selectedItem
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().unselectedItemTintColor = tabBarColor.item
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: tabBarColor.item], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: tabBarColor.selectedItem], for: .selected)
        
        if #available(iOS 14.0, *) {
            UIDatePicker.appearance().tintColor = Colors.toneColor
        }
        // Switch
        UISwitch.appearance().onTintColor = Colors.toneColor
        UISwitch.appearance().tintColor = Colors.toneColor
        
        // Slider
        UISlider.appearance().minimumTrackTintColor = Colors.toneColor
        //        ToolbarHelper.applyTheme()
        UIToolbar.appearance().barTintColor = navigationColor.background
        UIToolbar.appearance().tintColor = navigationColor.tint
        
        UISegmentedControl.appearance().backgroundColor = Colors.backgroundColor
        UISegmentedControl.appearance().tintColor = Colors.toneColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.toneColor], for: .normal)
        applyUserInterfaceStyle()
    }
    
    func applyUserInterfaceStyle() {
        if let window = UIApplication.shared.windows.first {
            if window.overrideUserInterfaceStyle != userInterfaceStyle {
                UIView.animate(withDuration: 0.2) {
                    window.overrideUserInterfaceStyle = userInterfaceStyle
                }
            }
        }
    }
    
    func apply() {
        applyGeneralControls()
        NotificationCenter.default.post(name: .themeChangeNotification, object: nil)
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        return Themes.current.userInterfaceStyle == .light ? .light : .dark
    }
}

struct Theme0: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .light
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .default,
                                                           background: UIColor(hexString: "FFFFFF"),
                                                           title: UIColor(hexString: "FF4B77"),
                                                           tint: UIColor(hexString: "FF4B77"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "FFFFFF"),
                                               selectedItem: UIColor(hexString: "FF4B77"),
                                               item: UIColor(hexString: "FF4B77").withAlphaComponent(0.4))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       cellDateTimeText: UIColor(hexString: "FF4B77"),
                                                                       cellDiaryText: UIColor(hexString: "767676"),
                                                                       calendarColor: .init(background: .white,
                                                                                            weekdayTitleColor: UIColor(hexString: "FF4B77"),
                                                                                            titleDefaultColor: UIColor(hexString: "767676"),
                                                                                            eventDefaultColor: UIColor(hexString: "FF4B77"),
                                                                                            todayColor: UIColor(hexString: "767676"),
                                                                                            selectionColor: UIColor(hexString: "FF4B77"),
                                                                                            titleTodayColor: .white,
                                                                                            titlePlaceholderColor: UIColor(hexString: "767676").withAlphaComponent(0.5),
                                                                                            titleWeekendColor: .red,
                                                                                            titleSelectionColor: .white))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "FF4B77"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: .systemGroupedBackground,
                                                                             cellBackground: UIColor(hexString: "FFFFFF"),
                                                                             text: UIColor(hexString: "5F5F5F"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "000000"), background: .white)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       cellEventTimeText: UIColor(hexString: "FF4B77"),
                                                                       cellEventText: UIColor(hexString: "767676"))
}

struct Theme1: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .light
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .default,
                                                           background: UIColor(hexString: "FFFFFF"),
                                                           title: UIColor(hexString: "FF98BE"),
                                                           tint: UIColor(hexString: "FF98BE"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "FFFFFF"),
                                               selectedItem: UIColor(hexString: "FF98BE"),
                                               item: UIColor(hexString: "FF98BE").withAlphaComponent(0.4))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       cellDateTimeText: UIColor(hexString: "FF98BE"),
                                                                       cellDiaryText: UIColor(hexString: "5F5F5F"),
                                                                       calendarColor: .init(background: .white,
                                                                                            weekdayTitleColor: UIColor(hexString: "FF98BE"),
                                                                                            titleDefaultColor: UIColor(hexString: "5F5F5F"),
                                                                                            eventDefaultColor: UIColor(hexString: "FF98BE"),
                                                                                            todayColor: UIColor(hexString: "5F5F5F"),
                                                                                            selectionColor: UIColor(hexString: "FF98BE"),
                                                                                            titleTodayColor: .white,
                                                                                            titlePlaceholderColor: UIColor(hexString: "5F5F5F").withAlphaComponent(0.5),
                                                                                            titleWeekendColor: .red,
                                                                                            titleSelectionColor: .white))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "FF98BE"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: .systemGroupedBackground,
                                                                             cellBackground: UIColor(hexString: "FFFFFF"),
                                                                             text: UIColor(hexString: "5F5F5F"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "000000"), background: .white)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       cellEventTimeText: UIColor(hexString: "FF98BE"),
                                                                       cellEventText: UIColor(hexString: "5F5F5F"))
}

struct Theme2: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .light
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .default,
                                                           background: UIColor(hexString: "FFFFFF"),
                                                           title: UIColor(hexString: "FF88AE"),
                                                           tint: UIColor(hexString: "FF88AE"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "FFFFFF"),
                                               selectedItem: UIColor(hexString: "FF88AE"),
                                               item: UIColor(hexString: "FF88AE").withAlphaComponent(0.4))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       cellDateTimeText: UIColor(hexString: "FF88AE"),
                                                                       cellDiaryText: UIColor(hexString: "5F5F5F"),
                                                                       calendarColor: .init(background: .white,
                                                                                            weekdayTitleColor: UIColor(hexString: "FF88AE"),
                                                                                            titleDefaultColor: UIColor(hexString: "5F5F5F"),
                                                                                            eventDefaultColor: UIColor(hexString: "FF88AE"),
                                                                                            todayColor: UIColor(hexString: "5F5F5F"),
                                                                                            selectionColor: UIColor(hexString: "FF88AE"),
                                                                                            titleTodayColor: .white,
                                                                                            titlePlaceholderColor: UIColor(hexString: "5F5F5F").withAlphaComponent(0.5),
                                                                                            titleWeekendColor: .red,
                                                                                            titleSelectionColor: .white))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "FF88AE"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: .systemGroupedBackground,
                                                                             cellBackground: UIColor(hexString: "FFFFFF"),
                                                                             text: UIColor(hexString: "5F5F5F"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "000000"), background: .white)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       
                                                                       cellEventTimeText: UIColor(hexString: "FF88AE"),
                                                                       cellEventText: UIColor(hexString: "5F5F5F"))
}

struct Theme3: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .light
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .default,
                                                           background: UIColor(hexString: "FFFFFF"),
                                                           title: UIColor(hexString: "48DCD2"),
                                                           tint: UIColor(hexString: "48DCD2"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "FFFFFF"),
                                               selectedItem: UIColor(hexString: "48DCD2"),
                                               item: UIColor(hexString: "48DCD2").withAlphaComponent(0.6))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       
                                                                       cellDateTimeText: UIColor(hexString: "48DCD2"),
                                                                       cellDiaryText: UIColor(hexString: "5F5F5F"),
                                                                       calendarColor: .init(background: .white,
                                                                                            weekdayTitleColor: UIColor(hexString: "48DCD2"),
                                                                                            titleDefaultColor: UIColor(hexString: "5F5F5F"),
                                                                                            eventDefaultColor: UIColor(hexString: "48DCD2"),
                                                                                            todayColor: UIColor(hexString: "5F5F5F"),
                                                                                            selectionColor: UIColor(hexString: "48DCD2"),
                                                                                            titleTodayColor: .white,
                                                                                            titlePlaceholderColor: UIColor(hexString: "5F5F5F").withAlphaComponent(0.5),
                                                                                            titleWeekendColor: .red,
                                                                                            titleSelectionColor: .white))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "48DCD2"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: .systemGroupedBackground,
                                                                             cellBackground: UIColor(hexString: "FFFFFF"),
                                                                             text: UIColor(hexString: "5F5F5F"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "000000"), background: .white)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFFFF"),
                                                                       
                                                                       cellEventTimeText: UIColor(hexString: "48DCD2"),
                                                                       cellEventText: UIColor(hexString: "5F5F5F"))
}

struct Theme4: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .light
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .default,
                                                           background: UIColor(hexString: "D1E191"),
                                                           title: UIColor(hexString: "FFFFFF"),
                                                           tint: UIColor(hexString: "FFFFFF"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "D1E191"),
                                               selectedItem: UIColor(hexString: "9AA987"),
                                               item: UIColor(hexString: "FFFFFF"))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "F5FAF4"),
                                                                       cellDateTimeText: UIColor(hexString: "9AA987"),
                                                                       cellDiaryText: UIColor(hexString: "767676"),
                                                                       calendarColor: .init(background: UIColor(hexString: "D1E191"),
                                                                                            weekdayTitleColor: UIColor(hexString: "FFFFFF"),
                                                                                            titleDefaultColor: UIColor(hexString: "FFFFFF"),
                                                                                            eventDefaultColor: UIColor(hexString: "FFFFFF"),
                                                                                            todayColor: UIColor(hexString: "9AA987"),
                                                                                            selectionColor: .white,
                                                                                            titleTodayColor: .black,
                                                                                            titlePlaceholderColor: .lightText,
                                                                                            titleWeekendColor: UIColor.red.withAlphaComponent(0.6),
                                                                                            titleSelectionColor: .black))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "9AA987"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: UIColor(hexString: "eff5ed"),
                                                                             cellBackground: UIColor(hexString: "FFFFFF"),
                                                                             text: UIColor(hexString: "767676"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "000000"), background: .white)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "F5FAF4"),
                                                                       
                                                                       cellEventTimeText: UIColor(hexString: "9AA987"),
                                                                       cellEventText: UIColor(hexString: "767676"))
}

struct Theme5: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .light
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .default,
                                                           background: UIColor(hexString: "7FCFFF"),
                                                           title: UIColor(hexString: "FFFFFF"),
                                                           tint: UIColor(hexString: "FFFFFF"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "7FCFFF"),
                                               selectedItem: UIColor(hexString: "FFFFFF"),
                                               item: UIColor(hexString: "B6EBFF"))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "F6FCFF"),
                                                                       cellDateTimeText: UIColor(hexString: "37C5E0"),
                                                                       cellDiaryText: UIColor(hexString: "767676"),
                                                                       calendarColor: .init(background: UIColor(hexString: "7FCFFF"),
                                                                                            weekdayTitleColor: .white,
                                                                                            titleDefaultColor: .white,
                                                                                            eventDefaultColor: .white,
                                                                                            todayColor: .systemOrange,
                                                                                            selectionColor: .white,
                                                                                            titleTodayColor: .black,
                                                                                            titlePlaceholderColor: UIColor(hexString: "FFFFFF").withAlphaComponent(0.6),
                                                                                            titleWeekendColor: .red,
                                                                                            titleSelectionColor: .black))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "37C5E0"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: UIColor(hexString: "e9eff2"),
                                                                             cellBackground: UIColor(hexString: "FFFFFF"),
                                                                             text: UIColor(hexString: "767676"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "000000"), background: .white)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "F6FCFF"),
                                                                       
                                                                       cellEventTimeText: UIColor(hexString: "37C5E0"),
                                                                       cellEventText: UIColor(hexString: "767676"))
}

struct Theme6: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .light
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .default,
                                                           background: UIColor(hexString: "FFA936"),
                                                           title: UIColor(hexString: "FFFFFF"),
                                                           tint: UIColor(hexString: "FFFFFF"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "FFA936"),
                                               selectedItem: UIColor(hexString: "FFFFFF"),
                                               item: UIColor(hexString: "FFE8A0"))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFCEE"),
                                                                       cellDateTimeText: UIColor(hexString: "FFA936"),
                                                                       cellDiaryText: UIColor(hexString: "74715F"),
                                                                       calendarColor: .init(background: UIColor(hexString: "FFA936"),
                                                                                            weekdayTitleColor: .white,
                                                                                            titleDefaultColor: .white,
                                                                                            eventDefaultColor: .white,
                                                                                            todayColor: .systemGreen,
                                                                                            selectionColor: .white,
                                                                                            titleTodayColor: .black,
                                                                                            titlePlaceholderColor: UIColor.white.withAlphaComponent(0.6),
                                                                                            titleWeekendColor: .red,
                                                                                            titleSelectionColor: .black))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "FFA936"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: UIColor(hexString: "f7f4e6"),
                                                                             cellBackground: UIColor(hexString: "FFFFFF"),
                                                                             text: UIColor(hexString: "767676"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "000000"), background: .white)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: .systemGroupedBackground,
                                                                       cellBackground: UIColor(hexString: "FFFCEE"),
                                                                       cellEventTimeText: UIColor(hexString: "FFA936"),
                                                                       cellEventText: UIColor(hexString: "74715F"))
}

struct Theme22: Theme {
    var userInterfaceStyle: UIUserInterfaceStyle = .dark
    
    let navigationColor: NavigationColor = NavigationColor(barStyle: .black,
                                                           background: UIColor(hexString: "17191A"),
                                                           title: UIColor(hexString: "FFFFFF"),
                                                           tint: UIColor(hexString: "FFFFFF"))
    
    let tabBarColor: TabBarColor = TabBarColor(background: UIColor(hexString: "17191A"),
                                               selectedItem: UIColor(hexString: "FFFFFF"),
                                               item: UIColor(hexString: "8E8E93"))
    
    let diaryTableViewColor: DiaryTableViewColor = DiaryTableViewColor(background: UIColor(hexString: "000000"),
                                                                       cellBackground: UIColor(hexString: "17191A"),
                                                                       cellDateTimeText: UIColor(hexString: "AAAAAA"),
                                                                       cellDiaryText: UIColor(hexString: "FFFFFF"),
                                                                       calendarColor: .init(background: UIColor(hexString: "17191A"),
                                                                                            weekdayTitleColor: UIColor(hexString: "FFFFFF"),
                                                                                            titleDefaultColor: UIColor(hexString: "FFFFFF"),
                                                                                            eventDefaultColor: UIColor(hexString: "FFFFFF"),
                                                                                            todayColor: .systemBlue,
                                                                                            selectionColor: UIColor(hexString: "8E8E92"),
                                                                                            titleTodayColor: .white,
                                                                                            titlePlaceholderColor: UIColor(hexString: "8E8E92").withAlphaComponent(0.6),
                                                                                            titleWeekendColor: .red,
                                                                                            titleSelectionColor: .white))
    
    let pencilButtonColor: PencilButtonColor = PencilButtonColor(background: UIColor(hexString: "8E8E92"),
                                                                 tint: UIColor(hexString: "FFFFFF"))
    
    let settingTableViewColor: SettingTableViewColor = SettingTableViewColor(background: UIColor(hexString: "000000"),
                                                                             cellBackground: UIColor(hexString: "17191A"),
                                                                             text: UIColor(hexString: "FFFFFF"))
    
    let commonColor: CommonColor = CommonColor(textColor: UIColor(hexString: "FFFFFF"), background: .black)
    
    let eventTableViewColor: EventTableViewColor = EventTableViewColor(background: UIColor(hexString: "000000"),
                                                                       cellBackground: UIColor(hexString: "17191A"),
                                                                       cellEventTimeText: UIColor(hexString: "AAAAAA"),
                                                                       cellEventText: UIColor(hexString: "FFFFFF"))
}
