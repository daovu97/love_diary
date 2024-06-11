//
//  Date+Extension.swift
//  lovediary
//
//  Created by daovu on 11/03/2021.
//

import Foundation

extension Calendar {
    static var gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    
    static var valentinday: Date {
        return "14/02/\(Date().year)".toDate(pattern: "dd/MM/yyyy").startOfDay
    }
    
    static var whiteDay: Date {
        return "14/03/\(Date().year)".toDate(pattern: "dd/MM/yyyy").startOfDay
    }
    
    var year: Int {
        return Calendar.gregorian.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.gregorian.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.gregorian.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.gregorian.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.gregorian.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.gregorian.component(.second, from: self)
    }
    
    var previousYear: Date {
        return Calendar.gregorian.date(byAdding: .year, value: -1, to: self) ?? self
    }
    
    var nextYear: Date {
        return Calendar.gregorian.date(byAdding: .year, value: 1, to: self) ?? self
    }
    
    func add(years value: Int) -> Date {
        return Calendar.gregorian.date(byAdding: .year, value: value, to: self) ?? self
    }
    
    var previousMonth: Date {
        return Calendar.gregorian.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    var nextMonth: Date {
        return Calendar.gregorian.date(byAdding: .month, value: 1, to: self) ?? self
    }
    
    var noon: Date {
        return Calendar(identifier: .gregorian).date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? self
    }
    
    var nanoSecondRemoved: Date {
        return Calendar.gregorian.date(bySettingHour: self.hour, minute: self.minute,
                                       second: self.second, of: self) ?? self
    }
    
    var midnight: Date {
        return Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 0, second: 0, of: self) ?? Date()
    }
    
    var endOfDay: Date {
        return startOfDay.tomorrow.previousSecond
    }
    
    var yesterday: Date {
        return Calendar.gregorian.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    var tomorrow: Date {
        return Calendar.gregorian.date(byAdding: .day, value: 1, to: self) ?? self
    }
    
    var previousHour: Date {
        return Calendar.gregorian.date(byAdding: .hour, value: -1, to: self) ?? self
    }
    
    var nextHour: Date {
        return Calendar.gregorian.date(byAdding: .hour, value: 1, to: self) ?? self
    }
    
    var previousSecond: Date {
        return Calendar.gregorian.date(byAdding: .second, value: -1, to: self) ?? self
    }
    
    var startOfHour: Date {
        let components = Calendar.gregorian.dateComponents([.year, .month, .day, .hour], from: self)
        return Calendar.gregorian.date(from: components) ?? self
    }
    
    var startOfYear: Date {
        let components = Calendar.gregorian.dateComponents([.year], from: self)
        return Calendar.gregorian.date(from: components) ?? self
    }
    
    var endOfYear: Date {
        return startOfYear.nextYear.previousSecond
    }
    
    var startOfMonth: Date {
        let components = Calendar.gregorian.dateComponents([.year, .month], from: self)
        return Calendar.gregorian.date(from: components) ?? self
    }
    
    var endOfMonth: Date {
        return startOfMonth.nextMonth.previousSecond
    }
    
    var startOfDay: Date {
        let components = Calendar.gregorian.dateComponents([.year, .month, .day], from: self)
        return Calendar.gregorian.date(from: components) ?? self
    }
    
    var isLastDayOfMonth: Bool {
        return tomorrow.month != self.month
    }
    
    var weekday: Int {
        /* 1: Sun, 2: Mon, 3: Tue, 4: Wed, 5: Thu, 6: Fri, 7: Sat */
        return Calendar.gregorian.component(.weekday, from: self)
    }
    
    var isSunday: Bool {
        return Calendar.gregorian.component(.weekday, from: self) == 1
    }
    
    var isSaturday: Bool {
        return Calendar.gregorian.component(.weekday, from: self) == 7
    }
    
    var nextWeek: Date {
        return Calendar.gregorian.date(byAdding: .day, value: 7, to: self) ?? self
    }
    
    var startOfWeek: Date {
        let components = Calendar.gregorian.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        return Calendar.gregorian.date(from: components) ?? self
    }
    
    var endOfWeek: Date {
        return startOfWeek.nextWeek.previousSecond
    }
    
    var numberOfDaysInMonth: Int {
        return Calendar.gregorian.range(of: .day, in: .month, for: self)?.count ?? 0
    }
    
    var firstDayOfThisYear: Date {
        let components = Calendar(identifier: .gregorian).dateComponents([.year], from: self)
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
    
    var lastDayOfThisYear: Date {
        return self.firstDayOfThisYear.nextYear.yesterday
    }
    
    var hourString: String {
        return self.format(partern: "HH:mm")
    }
    
    func isEqualMonthInYear(with date: Date) -> Bool {
        return self.year == date.year && self.month == date.month
    }
    
    func isInSameDay(as date: Date) -> Bool {
        return Calendar.gregorian.isDate(self, inSameDayAs: date)
    }
    
    func isInSameMonth(as date: Date) -> Bool {
        return self.month == date.month
    }
    
    func subtract(days: Int) -> Date {
        return Calendar.gregorian.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    func add(days: Int) -> Date {
        return Calendar.gregorian.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func add(weeks: Int) -> Date {
        return Calendar.gregorian.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }
    
    func add(minutes: Int) -> Date {
        return Calendar.gregorian.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    func add(hour: Int) -> Date {
        return Calendar.gregorian.date(byAdding: .hour, value: hour, to: self) ?? self
    }
    
    func addHour(_ value: Int) -> Date {
        return self.addingTimeInterval(Double(value) * 60 * 60)
    }
    
    func setTime(hourValue: Int, minutesValue: Int) -> Date? {
        return Calendar.gregorian.date(bySettingHour: hourValue, minute: minutesValue, second: 0, of: self)
    }
    
    func setTime(from date: Date) -> Date? {
        return setTime(hourValue: date.hour, minutesValue: date.minute)
    }
    
    static var zeroTime: Date = "00:00".toDate(pattern: "HH:mm")
}

extension Date {
    
    static func - (recent: Date, previous: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour], from: previous, to: recent)
    }
    
    func getOffsetDayFromNow() -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).dayInt
    }
    
    func offsetFromNow() -> DateComponents {
        return Date() - self
    }
}

extension DateComponents {
    var yearInt: Int {
        return year ?? 0
    }
    var monthInt: Int {
        return month ?? 0
    }
    var dayInt: Int {
        return day ?? 0
    }
    var hourInt: Int {
        return hour ?? 0
    }
}

extension String {
    func toDate(pattern: DatePatterns) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern.patern
        dateFormatter.timeZone = .current
        guard let date = dateFormatter.date(from: self) else {
            fatalError()
        }
        
        return date
    }
    
    func toDateNil(pattern: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.timeZone = .current
        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        
        return date
    }
    
    func toDate(pattern: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.timeZone = .current
        guard let date = dateFormatter.date(from: self) else {
            fatalError()
        }
        
        return date
    }
}

extension Date {
    func format(partern: DatePatterns) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = partern.patern
        return dateFormatterGet.string(from: self)
    }
    
    func format(partern: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = partern
        return dateFormatterGet.string(from: self)
    }
}


extension String {
   static var currentDatePattern: DatePattern {
        return Language.currentDatePattern
    }
}

