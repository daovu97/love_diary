//
//  SettingsDataConfig.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import UIKit.UIImage

extension SettingViewModel {
    enum CellType {
        case normal(icon: UIImage?, title: String, isDisable: Bool = false)
        case withSwitch(icon: UIImage?, title: String, isOn: Bool = false)
        case delete(icon: UIImage?, title: String)
    }
    
    struct CellInfo {
        let type: CellType
    }
    
    struct SectionInfo {
        var title: String = ""
        var footer: String = ""
        var cells: [Cell]
    }
    
    enum Cell {
        case icloudBackup
        //
        case startDate
        case backgroundImage
        case font
        //
        case removeAds
        //
        case theme
        case passcode
        case languages
        case dataExport
        //
        
        case deleteAllData
        
        case help
        case aboutApp
        
        var info: CellInfo {
            switch self {
            case .icloudBackup:
                return .init(type: .normal(icon: Images.Icon.icloud, title: LocalizedString.icloudSettingTitle))
            case .backgroundImage:
                return .init(type: .normal(icon: Images.Icon.photo, title: LocalizedString.backgroundImageSettingTitle))
            case .font:
                return .init(type: .normal(icon: Images.Icon.textformat, title: LocalizedString.diaryFontSettingTitle))
            case .removeAds:
                return .init(type: .normal(icon: Images.Icon.sparkle, title: LocalizedString.purchaseButtonTitle,
                                           isDisable: Settings.isRemoveAds.value))
            case .theme:
                return .init(type: .normal(icon: Images.Icon.flame, title: LocalizedString.themeSettingTitle))
            case .passcode:
                return .init(type: .normal(icon: Images.Icon.lock, title: LocalizedString.passcodeSettingTitle))
            case .languages:
                return .init(type: .normal(icon: Images.Icon.globe, title: LocalizedString.languageSettingTitle))
            case .dataExport:
                return .init(type: .normal(icon: Images.Icon.arrowDownDoc, title: LocalizedString.dataExportSettingTitle))
            case .help:
                return .init(type: .normal(icon: Images.Icon.questionmarkCircle, title: LocalizedString.helpSettingTitle))
            case .aboutApp:
                return .init(type: .normal(icon: Images.Icon.infoCircle, title: LocalizedString.aboutAppSettingTitle))
            case .deleteAllData:
                return .init(type: .delete(icon: Images.Icon.xmarkBin, title: LocalizedString.deleteAllSettingTitle))
            case .startDate:
                return .init(type: .normal(icon: Images.Icon.heart, title: LocalizedString.startDateSettingTitle))
            }
        }
        
        // swiftlint:disable cyclomatic_complexity
        func transition(navigator: SettingsNavigatorType) {
            switch self {
            case .icloudBackup:
                navigator.toIcloudBackup()
            case .backgroundImage:
                navigator.toBackgroundImage()
            case .font:
                navigator.toDiaryFont()
            // restoreIAP
            case .theme:
                navigator.toTheme()
            case .passcode:
                navigator.toPasscode()
            case .dataExport:
                navigator.toDataExport()
            case .help:
                //send email feedback
                navigator.toHelp()
            case .aboutApp:
                navigator.toaboutApp()
            case .startDate:
                navigator.toStartDateSetting()
            case .removeAds:
                navigator.toPremium()
            default: break
            }
        }
        // swiftlint:enable cyclomatic_complexity
    }
    
    enum SettingData: Int, CaseIterable {
        case adsSection
        case icloudSection
        case anniversary
        case apperanceSection
        case generalSection
        case aboutSection
        //        case deleteAllSection
        
        var info: SectionInfo {
            switch self {
            case .icloudSection:
                return .init(cells: [Cell.icloudBackup])
            case .anniversary:
                return SectionInfo(title: LocalizedString.anniversaryHeaderSettingTitle,
                                   cells: [Cell.startDate ,
                                           Cell.backgroundImage])
            case .apperanceSection:
                return SectionInfo(title: LocalizedString.apperanceSettingTitle,
                                   cells: [Cell.theme,
                                           Cell.font])
            case .adsSection:
                return .init(cells: [Cell.removeAds])
            case .generalSection:
                return .init(cells: [Cell.passcode,
                                     Cell.languages])
            //                                     Cell.dataExport])
            case .aboutSection:
                return .init( footer: LocalizedString.feedbackDetailMessage,
                              cells: [Cell.aboutApp,
                                     Cell.help])
            //            case .deleteAllSection:
            //                return .init(cells: [Cell.deleteAllData])
            }
        }
        
        static func generateData() -> [SectionInfo] {
            return Self.allCases.map {$0.info}
        }
        
    }
}
