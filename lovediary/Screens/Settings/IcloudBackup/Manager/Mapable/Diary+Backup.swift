//
//  Diary+Backup.swift
//  lovediary
//
//  Created by vu dao on 15/05/2021.
//

import Foundation

extension DiaryModel {
    private static let numberOfFields = 5
    private static let csvFormat = CSVHelper.getFormat(numberFields: numberOfFields)
    
    func toCSVText() -> String {
        return String(format: DiaryModel.csvFormat,
                      id.handleSpecialCharactersExportToCsv(),
                      text.handleSpecialCharactersExportToCsv(),
                      extractDateString(date: displayDate),
                      extractDateString(date: createdDate),
                      extractDateString(date: updatedDate))
        
    }
    
    private func extractDateString(date: Date?) -> String {
        return  date == nil ? "" : date!.format(partern: CSVConfig.dateFormat)
    }
    
    static func getCSVTitle() -> String {
        let csvTitle = String(format: DiaryModel.csvFormat,
                              "id",
                              "text",
                              "displayDate",
                              "createdDate",
                              "updatedDate")
        return csvTitle
    }
}

extension Array where Element == DiaryModel {
    
    func exportRealmToCSVFile() -> URL? {
        let csvText = convertRealmToCSVText(diaries: self)
        return CSVHelper.exportToFile(from: csvText, fileName: CSVConfig.diaryFileName)
    }
    
    private func toCSVText() -> String {
        var csvText = DiaryModel.getCSVTitle()
        forEach { csvText += "\n" + $0.toCSVText() }
        return csvText
    }
    
    private func convertRealmToCSVText(diaries: [DiaryModel]) -> String {
        var allImages = [ImageAttachment]()
        diaries.forEach {
            allImages.append(contentsOf: $0.attachments)
        }
        var csvText = diaries.toCSVText()
        csvText += CSVConfig.tableDelimiter + allImages.toCSVText()
        return csvText
    }
}

// MARK: - Import
extension DiaryModel {
    
    static func getAllNote(from lines: [String], images: [ImageAttachment]) -> [DiaryModel]? {
        var allNote: [DiaryModel] = []
        for (index, line) in lines.enumerated() {
            if index == 0 { continue }
            let csvRecord = CSVHelper.convertLineToValues(from: line, with: CSVConfig.delimiter)
            guard let note = getNote(csvRecord: csvRecord, allImages: images) else {
                return nil
            }
            allNote.append(note)
        }
        return allNote
    }
    
    private static func getNote(csvRecord: [String], allImages: [ImageAttachment]) -> DiaryModel? {
        guard
            csvRecord.count == numberOfFields,
            !csvRecord[0].isEmpty
        else {
            return nil
        }
        
        let note = DiaryModel(id: csvRecord[0].handleSpecialCharactersImportFromCsv(), text: csvRecord[1].handleSpecialCharactersImportFromCsv(), attachments: allImages,
                              displayDate: csvRecord[2].toDate(pattern: CSVConfig.dateFormat),
                              createdDate: csvRecord[3].toDate(pattern: CSVConfig.dateFormat),
                              updatedDate: csvRecord[4].toDate(pattern: CSVConfig.dateFormat))
        
        return note
    }
}
