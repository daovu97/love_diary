//
//  ReminderType.swift
//  lovediary
//
//  Created by daovu on 06/04/2021.
//

import Foundation

enum ReminderType: Int, CaseIterable {
    case none
    case atEventTime
    case fiveMinusBefore
    case tenMinusBefore
    case tweentyMinusBefore
    case thirtyMinusBefore
    case oneHourBefore
    case twoHourBefor
    case threeHourBefore
    
    case oneDayBefore
    case twoDayBefore
    case ThreeDayBefore
    case oneWeekBefore
    case twoWeekBefore
    case threeWeekBefore
    case oneMonthBefore
    case twoMonthBefore
    
    var title: String {
        switch self {
        case .none:
            return LocalizedString.none
        case .oneDayBefore:
            return LocalizedString.oneDayBefore
        case .twoDayBefore:
            return LocalizedString.twoDayBefore
        case .ThreeDayBefore:
            return LocalizedString.ThreeDayBefore
        case .oneWeekBefore:
            return LocalizedString.oneWeekBefore
        case .twoWeekBefore:
            return LocalizedString.twoWeekBefore
        case .threeWeekBefore:
            return LocalizedString.threeWeekBefore
        case .oneMonthBefore:
            return LocalizedString.oneMonthBefore
        case .twoMonthBefore:
            return LocalizedString.twoMonthBefore
        case .fiveMinusBefore:
            return LocalizedString.fiveMinusBefore
        case .tenMinusBefore:
            return LocalizedString.tenMinusBefore
        case .tweentyMinusBefore:
            return LocalizedString.tweentyMinusBefore
        case .thirtyMinusBefore:
            return LocalizedString.thirtyMinusBefore
        case .oneHourBefore:
            return LocalizedString.oneHourBefore
        case .twoHourBefor:
            return LocalizedString.oneHourBefore
        case .threeHourBefore:
            return LocalizedString.threeHourBefore
        case .atEventTime:
            return LocalizedString.atEventTime
        }
    }
    
    var isRiminderTime: Bool {
        switch self {
        case .atEventTime, .fiveMinusBefore, .tenMinusBefore, .tweentyMinusBefore, .thirtyMinusBefore,
             .oneHourBefore, .twoHourBefor, .threeHourBefore:
            return true
        default:
            return false
        }
    }
    
    static var reminderDay: [ReminderType] {
        return [.none, .oneDayBefore, .twoDayBefore, .ThreeDayBefore, .oneWeekBefore,
                .twoWeekBefore, .threeWeekBefore, .oneMonthBefore, .twoMonthBefore]
    }
    
    var isRiminderDay: Bool {
        return !(isRiminderTime || self == .none)
    }
    
    func convertDate(from date: Date) -> Date? {
        switch self {
        case .none:
            return nil
        case .fiveMinusBefore:
            return date.add(minutes: -5)
        case .tenMinusBefore:
            return date.add(minutes: -10)
        case .tweentyMinusBefore:
            return date.add(minutes: -20)
        case .thirtyMinusBefore:
            return date.add(minutes: -30)
        case .oneHourBefore:
            return date.add(hour: -1)
        case .twoHourBefor:
            return date.add(hour: -2)
        case .threeHourBefore:
            return date.add(hour: -3)
        case .oneDayBefore:
            return date.yesterday
        case .twoDayBefore:
            return date.add(days: -2)
        case .ThreeDayBefore:
            return date.add(days: -3)
        case .oneWeekBefore:
            return date.add(weeks: -1)
        case .twoWeekBefore:
            return date.add(weeks: -2)
        case .threeWeekBefore:
            return date.add(weeks: -3)
        case .oneMonthBefore:
            return date.previousMonth
        case .twoMonthBefore:
            return date.previousMonth.previousMonth
        case .atEventTime:
            return date
        }
    }
}
