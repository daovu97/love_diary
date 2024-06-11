//
//  ProfileImageManager.swift
//  lovediary
//
//  Created by daovu on 12/03/2021.
//

import Foundation
import UIKit
import Combine
import WidgetKit

struct ProfileImageManager {
    private static let GroupIdentifier = "Lovediary.daovu197"
    
    private static let nameOfMeSource: String = "Lovediary.vu9x.me"
    private static let nameOfYourSource: String = "Lovediary.vu9x.your"
    
    private static func fileName(of type: UserType) -> String {
        return type == UserType.me ? ProfileImageManager.nameOfMeSource : ProfileImageManager.nameOfYourSource
    }
    
    static let didChange = PassthroughSubject<UserType, Never>()
    
    private static var documentsUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    static func saveProfile(image: UIImage, of type: UserType) -> AnyPublisher<String, Error> {
        return Deferred {
            Future { promise in
                let fileName = type == UserType.me ? ProfileImageManager.nameOfMeSource : ProfileImageManager.nameOfYourSource
                if let url = self.documentsUrl {
                    let fileURL = url.appendingPathComponent(fileName)
                    if let imageData = image.jpegData(compressionQuality: 0.3) {
                        do {
                            try imageData.write(to: fileURL, options: .atomic)
                            promise(.success(fileName))
                            if #available(iOS 14.0, *) {
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                            didChange.send(type)
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
    
    static func load(of type: UserType) -> UIImage? {
        guard let url = documentsUrl?.appendingPathComponent(fileName(of: type)) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
    
    private static func delete(of type: UserType) {
        guard let url = documentsUrl?.appendingPathComponent(fileName(of: type)) else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(atPath: url.path)
            }
            didChange.send(type)
        } catch let err as NSError {
            print( err.debugDescription )
        }
        
    }
    
    static func deleteAll() {
        delete(of: .me)
        delete(of: .partner)
    }
}

struct FileError: Error, Codable {
    var message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
}

extension FileError: LocalizedError {
    var errorDescription: String? {
        return NSLocalizedString(message ?? "File not found", comment: "")
    }
}
