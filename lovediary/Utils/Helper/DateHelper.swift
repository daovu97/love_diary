//
//  DateHelper.swift
//  lovediary
//
//  Created by vu dao on 27/03/2021.
//

//
//  DateHelper.swift
//  NotepadWidget
//
//  Created by Thanh Luu on 12/22/20.
//

import Foundation

struct DateHelper {
    
    static func getReminderDate(from string: String) -> Date? {
        return string.toDate(pattern: "dd/MM/yyyy")
    }
    
    static func hourBetweenDates(start: Date, end: Date) -> Int {
        let components = Calendar.gregorian.dateComponents([.hour], from: start, to: end)
        return components.hour ?? 0
    }
    
    static func dayBetweenDates(start: Date, end: Date) -> Int {
        let components = Calendar.gregorian.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
    
    static func monthBetweenDates(start: Date, end: Date) -> Int {
        let components = Calendar.gregorian.dateComponents([.month], from: start, to: end)
        return components.month ?? 0
    }
    
    static func getDateWithTime(date: Date, hour: Int, minute: Int) -> Date? {
        var components = Calendar.gregorian.dateComponents([.day, .month, .year, .hour, .minute], from: date)
        components.hour = hour
        components.minute = minute
        return Calendar.gregorian.date(from: components)
    }
    
    static func getDate(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        return Calendar.gregorian.date(from: components)
    }
    
    static func getFormattedNoteDate(date: Date) -> Date {
        var dateComponent = Calendar.gregorian.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponent.second = 0
        return Calendar.gregorian.date(from: dateComponent) ?? Date()
    }
}
