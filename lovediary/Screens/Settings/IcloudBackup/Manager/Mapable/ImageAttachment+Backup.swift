//
//  ImageAttachment+Backup.swift
//  lovediary
//
//  Created by vu dao on 15/05/2021.
//

import Foundation

extension ImageAttachment {
    private static let numberOfFields = 8
    private static let csvFormat = CSVHelper.getFormat(numberFields: numberOfFields)
    
    func toCSVText() -> String {
        return String(format: ImageAttachment.csvFormat,
                      id.handleSpecialCharactersExportToCsv(),
                      nameUrl.handleSpecialCharactersExportToCsv(),
                      position.string,
                      width.string,
                      height.string,
                      diaryId.handleSpecialCharactersExportToCsv(),
                      length.string,
                      extractDateString(date: createDate))
    }
    
    private func extractDateString(date: Date?) -> String {
        return  date == nil ? "" : date!.format(partern: CSVConfig.dateFormat)
    }
    
    static func getCSVTitle() -> String {
        let csvTitle = String(format: ImageAttachment.csvFormat,
                              "id",
                              "nameUrl",
                              "position",
                              "width",
                              "height",
                              "diaryId",
                              "length",
                              "createDate")
        return csvTitle
    }
}

// MARK: - Import
extension ImageAttachment {
    static func getAllImage(from lines: [String]) -> [ImageAttachment] {
        var allImages: [ImageAttachment] = []
        for (index, line) in lines.enumerated() {
            if index == 0 { continue }
            let csvRecord = CSVHelper.convertLineToValues(from: line,
                                                          with: CSVConfig.delimiter)
            guard let image = getImage(csvRecord: csvRecord) else {
                return allImages
            }
            allImages.append(image)
        }
        return allImages
    }
    
    private static func getImage(csvRecord: [String]) -> ImageAttachment? {
        guard
            csvRecord.count == numberOfFields,
            !csvRecord[0].isEmpty,
            let position = Int(csvRecord[2]),
            let width = Int(csvRecord[3]),
            let height = Int(csvRecord[4]),
            let length = Int(csvRecord[6])
        else {
            return nil
        }
        
        return ImageAttachment(id: csvRecord[0].handleSpecialCharactersImportFromCsv(),
                               nameUrl: csvRecord[1].handleSpecialCharactersImportFromCsv(),
                               position: position, length: length, width: width, height: height, diaryId: csvRecord[5].handleSpecialCharactersImportFromCsv(),
                               createDate: csvRecord[7].toDate(pattern: CSVConfig.dateFormat))
    }
}

extension Array where Element == ImageAttachment {
    func toCSVText() -> String {
        var csvText = ImageAttachment.getCSVTitle()
        forEach { csvText += "\n" + $0.toCSVText() }
        return csvText
    }
}

// MARK: - Helper extension
private extension Int {
    var string: String {
        return "\(self)"
    }
    
    init(string: String) {
        let numberFormatter = NumberFormatter()
        let number = numberFormatter.number(from: string)
        self = number?.intValue ?? .zero
    }
}
