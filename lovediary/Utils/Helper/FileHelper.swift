//
//  FileHelper.swift
//  lovediary
//
//  Created by daovu on 26/03/2021.
//

import Foundation

struct FileHelper {
    static func getDocumentDirectoryURL(with path: String? = nil) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        guard let path = path else {
            return documentDirectory
        }
        let pathUrl = documentDirectory.appendingPathComponent(path)
        if !fileManager.fileExists(atPath: pathUrl.path) {
            do {
                try fileManager.createDirectory(atPath: pathUrl.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        return pathUrl
    }
    
    static func writeToFile(data: Data?, fileExtension: String) -> URL? {
        guard let data = data else { return nil }
        let fileName = LocalizedString.shareAppName + fileExtension
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch let error {
            print("error saving file with error", error)
            return nil
        }
    }
}

