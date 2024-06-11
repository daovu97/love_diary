//
//  ImageManager.swift
//  DiaryManager
//
//  Created by daovu on 19/03/2021.
//

import UIKit
import Combine

protocol ImageManagerType {
    func saveImage(images: [(range: NSRange, image: UIImage)]) -> AnyPublisher<[ImageAttachment], Never>
    func deleteImage(by names: [String]) -> AnyPublisher<Void, Never>
    func deleteAll() -> AnyPublisher<Void, Error>
}

class ImageManager: ImageManagerType {
    func deleteAll() -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { promise in
                let fileManager = FileManager.default
                guard let documentURL = fileManager.documentURL else {
                    promise(.failure(ICloudBackupError.defaultError))
                    return
                }
                let folderURL = documentURL.appendingPathComponent(Constants.dataFolderName)
                if !fileManager.fileExists(atPath: folderURL.path) {
                    fileManager.deleteFile(at: folderURL)
                }
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    
    func saveImage(images: [(range: NSRange, image: UIImage)]) -> AnyPublisher<[ImageAttachment], Never> {
        return Deferred {
            Future { [weak self] promise in
                guard !images.isEmpty else {
                    promise(.success([]))
                    return
                }
                
                let fileManager = FileManager.default
                guard let self = self,
                      let documentURL = fileManager.documentURL else { return }
                
                let folderURL = documentURL.appendingPathComponent(Constants.dataFolderName)
                
                if !fileManager.fileExists(atPath: folderURL.path) {
                    try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                }
                
                var attachments = [ImageAttachment]()
                
                images.forEach {
                    self.saveImage(infor: $0, at: folderURL) { imageAttachment in
                        if let attachment = imageAttachment {
                            attachments.append(attachment)
                        }
                    }
                }
                
                promise(.success(attachments))
            }
        }.eraseToAnyPublisher()
    }
    
    private func saveImage(infor: (range: NSRange, image: UIImage),
                           at folderURL: URL, completion: ((ImageAttachment?) -> Void)?) {
        do {
            let fileName = "\(UUID().uuidString)"
            let fileURL = folderURL.appendingPathComponent("\(fileName).png")
            
            if let pngImageData = infor.image.pngData() {
                try pngImageData.write(to: fileURL, options: .atomic)
            }
            
            let imageAttachment = ImageAttachment(nameUrl: fileName,
                                                  position: infor.range.location,
                                                  length: infor.range.length,
                                                  width: Int(infor.image.size.width),
                                                  height: Int(infor.image.size.height),
                                                  diaryId: "")
            
            completion?(imageAttachment)
            
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
            completion?(nil)
        }
    }
    
    func deleteImage(by names: [String]) -> AnyPublisher<Void, Never> {
        return Deferred {
            Future { [weak self] promise in
                guard !names.isEmpty else {
                    promise(.success(()))
                    return
                }
                
                guard let documentURL = FileManager.default.documentURL else {
                    return
                }
                
                names.forEach { self?.deleteImage(name: $0, at: documentURL) }
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    private func deleteImage(name: String, at documentURL: URL) {
        let folderURL = documentURL.appendingPathComponent(Constants.dataFolderName)
        let fileURL = folderURL.appendingPathComponent("\(name).png")
        FileManager.default.deleteFile(at: fileURL)
    }
}
