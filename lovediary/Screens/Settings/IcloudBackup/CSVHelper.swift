//
//  CSVHelper.swift
//  lovediary
//
//  Created by vu dao on 15/05/2021.
//

import Foundation

struct CSVConfig {
    static let diaryFileName = "LoveDiaryDatabase.csv"
    static let eventFileName = "LoveEventDatabase.csv"
    static let tableDelimiter = "\n\n\n"
    static let recordDelimiter = "\n"
    static let delimiter = ","
    static let dateFormat = "yyyy_MM_dd_HH_mm_ss"
    
    static let diaryNumberOfTables = 2
    static let eventNumberOfTables = 1
}

struct CSVHelper {
    static func getFormat(numberFields: Int) -> String {
        guard numberFields > 0 else { return "" }
        var csvFormat = "%@"
        for _ in 0..<numberFields - 1 {
            csvFormat += ",%@"
        }
        return csvFormat
    }
    
    static func createCSV(from content: String, fileName: String) -> URL? {
        do {
            let filePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath.absoluteString) {
                try fileManager.removeItem(at: filePath)
            }
            try content.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            return filePath
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    static func convertCSVToText(from fileUrl: URL) -> String? {
        do {
            let contents = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            return contents
        } catch {
            print("File Read Error for file \(fileUrl.absoluteString)")
            return nil
        }
    }
    
    static func convertLineToValues(from line: String, with delimeter: String) -> [String] {
        let pattern = "[ \r\t]*(?:\"((?:[^\"]|\"\")*)\"|([^,\"\\n]*))[ \t]*([,\\n]|$)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        var record: [String] = []
        regex.enumerateMatches(in: line, options: .anchored, range: NSRange(0..<line.utf16.count)) {match, flags, stop in
            guard let match = match else { return }
            
            if match.range(at: 1).location != NSNotFound, let range = Range(match.range(at: 1), in: line) {
                let field = line[range].replacingOccurrences(of: "\"\"", with: "\"")
                record.append(field)
            } else if match.range(at: 2).location != NSNotFound, let range = Range(match.range(at: 2), in: line) {
                let field = line[range].trimmingCharacters(in: .whitespaces)
                record.append(field)
            }
        }
        
        if String(line.suffix(1)) != delimeter {
            record.removeLast()
        }
        
        return record
    }
    
    static func exportToFile(from content: String, fileName: String) -> URL? {
        do {
            let filePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath.absoluteString) {
                try fileManager.removeItem(at: filePath)
            }
            try content.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            return filePath
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
}

extension String {
    func handleSpecialCharactersExportToCsv() -> String {
        if self.contains("\n") || self.contains("\"") || self.contains(",") {
            var result = self.replacingOccurrences(of: "\n", with: "\\n")
            result = result.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(result)\""
        }
        return self
    }
    
    func handleSpecialCharactersImportFromCsv() -> String {
        if self.contains("\\n") {
            return self.replacingOccurrences(of: "\\n", with: "\n")
        }
        return self
    }
}

