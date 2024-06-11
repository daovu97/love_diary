//
//  BackgroundLocalHelper.swift
//  BackgroundManager
//
//  Created by daovu on 12/03/2021.
//

import Combine
import UIKit

struct BackgroundLocalHelper {
    private static var documentsUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    static func save(image: UIImage) -> AnyPublisher<String, Error> {
        return Deferred {
            Future { promise in
                let fileName = "lm" + UUID().uuidString
                if let url = self.documentsUrl {
                    let fileURL = url.appendingPathComponent(fileName)
                    if let imageData = image.jpegData(compressionQuality: 1) {
                        do {
                            try imageData.write(to: fileURL, options: .atomic)
                            promise(.success(fileName))
                        } catch let error {
                            promise(.failure(error))
                        }
                    }
                } else {
                    promise(.failure(FileError(message: "Not found")))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    static func load(fileName: String) -> URL? {
        return documentsUrl?.appendingPathComponent(fileName)
    }
}

