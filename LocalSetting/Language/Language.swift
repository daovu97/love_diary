//
//  LanguageCode.swift
//  LocalSettings
//
//  Created by vu dao on 10/03/2021.
//

import Foundation

enum Language: String, CaseIterable {
    case english = "en_US"
    case english_gb = "en_GB"
    case english_au = "en_AU"
    case japanese = "ja"
    case vietnamese = "vi"
    case korean = "ko"
    case simplifiedChinese = "zh-hans"
    case traditionalChinese = "zh-hant"
    
    static func getLanguageCode(from index: Int) -> Language {
        return allCases.indices.contains(index) ? allCases[index] : .english_gb
    }
    
    static let preferredLanguages = NSLocale.preferredLanguages
    
    static var languageCodeDevice: String {
        guard let currentLanguage = preferredLanguages.first,
              let deviceLanguageCode =  Language
                .allCases
                .last(where: { currentLanguage.lowercased().contains($0.rawValue.lowercased()) })
        else {
            return Language.english_gb.rawValue
        }
        return deviceLanguageCode.rawValue
    }
    
    static let currentLanguage: Language = Self.allCases.first { $0.rawValue == languageCodeDevice } ?? Language.english
    
    var datePattern: DatePattern {
        switch self {
        case .english:
            return USDatePattern()
        case .japanese:
            return JADatePattern()
        case .vietnamese:
            return VIDatePattern()
        case .english_gb:
            return GBDatePattern()
        case .english_au:
            return AUDatePattern()
        case .korean:
            return KODatePattern()
        case .simplifiedChinese:
            return ZHSDatePattern()
        case .traditionalChinese:
            return ZHTDatePattern()
        }
    }
    
    static let currentDatePattern: DatePattern = currentLanguage.datePattern
}

enum DatePatterns {
    case fullDate
    case fullDateTime
    case timeShort
    case year
    case date
    case dayShotDate
    case monthYear
    
    var patern: String {
        switch self {
        case .fullDate:
           return Language.currentDatePattern.fullDate
        case .fullDateTime:
            return Language.currentDatePattern.fullDateTime
        case .timeShort:
            return Language.currentDatePattern.timeShort
        case .year:
            return Language.currentDatePattern.year
        case .date:
            return Language.currentDatePattern.date
        case .dayShotDate:
            return Language.currentDatePattern.dayShotDate
        case .monthYear:
            return Language.currentDatePattern.monthYear
        }
    }
}

protocol DatePattern {
    var fullDate: String { get }
    var fullDateTime: String { get }
    var timeShort: String { get }
    var year: String { get }
    var date : String { get }
    var dayShotDate: String { get }
    var monthYear: String { get }
}

struct USDatePattern: DatePattern {
    var fullDate: String = "MM-dd-yyyy"
    var fullDateTime: String = "MM-dd-yyyy hh:mm a"
    var timeShort: String = "hh:mm a"
    var year: String = "yyyy"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

struct GBDatePattern: DatePattern {
    var fullDate: String = "MM-dd-yyyy"
    var fullDateTime: String = "MM-dd-yyyy HH:mm"
    var timeShort: String = "HH:mm"
    var year: String = "yyyy"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

struct AUDatePattern: DatePattern {
    var fullDate: String = "MM-dd-yyyy"
    var fullDateTime: String = "MM-dd-yyyy HH:mm"
    var timeShort: String = "HH:mm"
    var year: String = "yyyy"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

struct VIDatePattern: DatePattern {
    var fullDate: String = "dd/MM/yyyy"
    var fullDateTime: String = "dd/MM/yyyy HH:mm"
    var timeShort: String = "HH:mm"
    var year: String = "yyyy"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

struct JADatePattern: DatePattern {
    var fullDate: String = "yyyy年MM月dd日"
    var fullDateTime: String = "yyyy年MM月dd日 HH:mm"
    var timeShort: String = "HH:mm"
    var year: String = "yyyy年"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

struct ZHSDatePattern: DatePattern {
    var fullDate: String = "yyyy年M月d日"
    var fullDateTime: String = "yyyy年M月d日 hh:mm a"
    var timeShort: String = "hh:mm a"
    var year: String = "yyyy年"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

struct ZHTDatePattern: DatePattern {
    var fullDate: String = "yyyy年M月d日"
    var fullDateTime: String = "yyyy年M月d日 hh:mm a"
    var timeShort: String = "hh:mm a"
    var year: String = "yyyy年"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

struct KODatePattern: DatePattern {
    var fullDate: String = "yyyy년mm월dd일"
    var fullDateTime: String = "yyyy년mm월dd일 hh:mm a"
    var timeShort: String = "hh:mm a"
    var year: String = "yyyy년"
    var date: String = "E"
    var dayShotDate: String = "EEEE MMMM dd.yyyy"
    var monthYear = "MMMM yyyy"
}

