//
//  EventModel+Backup.swift
//  lovediary
//
//  Created by vu dao on 15/05/2021.
//

import Foundation

extension EventModel {
    
    private static let numberOfFields = 11
    private static let csvFormat = CSVHelper.getFormat(numberFields: numberOfFields)
    
    func toCSVText() -> String {
        return String(format: EventModel.csvFormat,
                      id.handleSpecialCharactersExportToCsv(),
                      title.handleSpecialCharactersExportToCsv(),
                      detail.handleSpecialCharactersExportToCsv(),
                      date.format(partern: CSVConfig.dateFormat),
                      time == nil ? "" : time!.format(partern: CSVConfig.dateFormat),
                      pinned.string,
                      "\(reminderType.rawValue)",
                      reminderTime == nil ? "" : reminderTime!.format(partern: CSVConfig.dateFormat),
                      "\(pushedStatus.rawValue)",
                      reminderDateTime == nil ? "" : reminderDateTime!.format(partern: CSVConfig.dateFormat),
                      isDefault.string)
        
    }
    
    private func extractDateString(date: Date?) -> String {
        return  date == nil ? "" : date!.format(partern: CSVConfig.dateFormat)
    }
    
    static func getCSVTitle() -> String {
        let csvTitle = String(format: EventModel.csvFormat,
                              "id",
                              "title",
                              "detail",
                              "date",
                              "time",
                              "pinned",
                              "reminderType",
                              "reminderTime",
                              "pushedStatus",
                              "reminderDateTime",
                              "isDefault")
        return csvTitle
    }
}

// MARK: - Import
extension EventModel {
    static func getAllEvent(from lines: [String]) -> [EventModel] {
        var allImages: [EventModel] = []
        for (index, line) in lines.enumerated() {
            if index == 0 { continue }
            let csvRecord = CSVHelper.convertLineToValues(from: line,
                                                          with: CSVConfig.delimiter)
            guard let image = getEventModel(csvRecord: csvRecord) else {
                return allImages
            }
            allImages.append(image)
        }
        return allImages
    }
    
    private static func getEventModel(csvRecord: [String]) -> EventModel? {
        guard
            csvRecord.count == numberOfFields,
            !csvRecord[0].isEmpty
        else {
            return nil
        }
        return EventModel(id: csvRecord[0].handleSpecialCharactersImportFromCsv(),
                          title: csvRecord[1].handleSpecialCharactersImportFromCsv(),
                          detail: csvRecord[2].handleSpecialCharactersImportFromCsv(),
                          reminderType: ReminderType(rawValue: Int(csvRecord[6]) ?? 0) ?? .none,
                          reminderTime: csvRecord[7].toDateNil(pattern: CSVConfig.dateFormat),
                          date: csvRecord[3].toDate(pattern: CSVConfig.dateFormat),
                          time: csvRecord[4].toDateNil(pattern: CSVConfig.dateFormat),
                          pinned: .init(value: csvRecord[5]),
                          isDefault: .init(value: csvRecord[10]),
                          pushedStatus: PushStatus(rawValue: Int(csvRecord[8]) ?? 0 ) ?? .waitingRegister,
                          reminderDateTime: csvRecord[9].toDateNil(pattern: CSVConfig.dateFormat))
    }
}

extension Array where Element == EventModel {
    
    func exportRealmToCSVFile() -> URL? {
        return CSVHelper.exportToFile(from: toCSVText(), fileName: CSVConfig.eventFileName)
    }
    
   private func toCSVText() -> String {
         var csvText = EventModel.getCSVTitle()
        forEach { csvText += "\n" + $0.toCSVText() }
        return csvText
    }
}

// MARK: - Helper extension
extension Bool {
    var string: String {
        return "\(value)"
    }
    
    var value: Int {
        return self ? 1 : 0
    }
    
    init(value: String?) {
        self = value == true.string
    }
}
