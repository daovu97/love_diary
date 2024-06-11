//
//  FileManager.swift
//  lovediary
//
//  Created by vu dao on 18/03/2021.
//

import Foundation

extension FileManager {
    func clearTempDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            debugPrint("Error clearing tmp folder")
        }
    }
    
    func deleteFile(at filePath: URL) {
        do {
            try self.removeItem(at: filePath)
        } catch {
            debugPrint("Error delete file at: \(filePath)")
        }
    }
    
    var documentURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first
    }
    
}
