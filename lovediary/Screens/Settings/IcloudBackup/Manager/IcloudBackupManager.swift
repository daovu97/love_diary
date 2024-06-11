//
//  IcloudBackupManager.swift
//  lovediary
//
//  Created by vu dao on 15/05/2021.
//

import Combine
import CloudKit
import Zip

struct CKConfig {
    static let fileName = "LoveDiaryBackup.zip"
    static let folderName = Constants.dataFolderName
    static let versionFileName = "BackupVersion.txt"
    static let currentVersion = 1
    
    static let recordType = "Backup"
    static let identifierKey = "ID"
    static let fileSizeKey = "FileSize"
    static let fileDataKey = "Resource"
    static let dateModifierKey = "UpdateDate"
    static let recordIdentifier = "CKBACKUP"
}

protocol IcloudBackupManagerType {
    func getInfo() -> AnyPublisher<CKRecord?, Error>
    func backup() -> AnyPublisher<CKRecord, Error>
    func restore() -> AnyPublisher<Void, Error>
    func remove() -> AnyPublisher<Void, Error>
}

class IcloudBackupManager: IcloudBackupManagerType {
    
    private let cloudKitHelper: CloudKitHelperType
    private let diaryManager: DiaryManagerType
    private let userManager: UserManagermentType
    private let eventManager: EventManagerType
    
    private var backupRecord: CKRecord?
    
    private let localBackupFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(CKConfig.fileName)
    private let backupCloudFilePath = CKConfig.fileName.slashBefore
    
    init(cloudKitHelper: CloudKitHelperType,
         diaryManager: DiaryManagerType,
         userManager: UserManagermentType,
         eventManager: EventManagerType) {
        self.cloudKitHelper = cloudKitHelper
        self.diaryManager = diaryManager
        self.userManager = userManager
        self.eventManager = eventManager
    }
    
    
    func getInfo() -> AnyPublisher<CKRecord?, Error> {
        return cloudKitHelper
            .query(id: CKConfig.recordIdentifier, keys: [CKConfig.fileSizeKey], recordType: CKConfig.recordType)
            .receiveOutput {[weak self] result in
                self?.backupRecord = result
            }
    }
    
    func backup() -> AnyPublisher<CKRecord, Error> {
        if let backupRecord = backupRecord {
            return self.update(record: backupRecord)
        } else {
            return getInfo().flatMap {[weak self] record -> AnyPublisher<CKRecord, Error> in
                guard let self = self else {
                    return .fail(ICloudBackupError.defaultError)
                }
                self.backupRecord = record
                return self.update(record: record)
            }.eraseToAnyPublisher()
        }
    }
    
    private func removeTempFile() {
        FileManager.default.clearTempDirectory()
    }
    
    private func update(record: CKRecord?) -> AnyPublisher<CKRecord, Error> {
        removeTempFile()
        if record == nil {
            self.backupRecord = CKRecord(recordType: CKConfig.recordType)
        }
        
        let diary = diaryManager.getAllDiary()
        
        let event = eventManager.getAllEvent()
        
        return  Publishers.CombineLatest(diary, event)
            .flatMap {[weak self] diaryModels, events -> AnyPublisher<CKRecord, Error> in
                do {
                    guard let self = self,
                          let directoryBackupFileUrl = FileHelper.getDocumentDirectoryURL(with: CKConfig.folderName),
                          let diaryCsvFileUrl = diaryModels.exportRealmToCSVFile(),
                          let eventCsvFileUrl = events.exportRealmToCSVFile(),
                          let backupVersionFileUrl = CSVHelper.exportToFile(from: "\(CKConfig.currentVersion)", fileName: CKConfig.versionFileName)
                    else {
                        return .fail(ICloudBackupError.defaultError)
                    }
                    
                    try Zip.zipFiles(paths: [directoryBackupFileUrl,
                                             diaryCsvFileUrl,
                                             backupVersionFileUrl,
                                             eventCsvFileUrl],
                                     zipFilePath: self.localBackupFileUrl,
                                     password: nil,
                                     compression: .BestCompression,
                                     progress: nil)
                    
                    guard let backupRecord = self.backupRecord else {
                        return .fail(ICloudBackupError.defaultError)
                    }
                    backupRecord[CKConfig.identifierKey] = CKConfig.recordIdentifier
                    let fileAsset = CKAsset(fileURL: self.localBackupFileUrl)
                    backupRecord[CKConfig.fileDataKey] = fileAsset
                    backupRecord[CKConfig.fileSizeKey] = self.localBackupFileUrl.fileSizeString
                    
                    return self.cloudKitHelper.update(records: [backupRecord]).receiveOutput {[weak self] _ in
                        self?.removeTempFile()
                    }
                } catch {
                    print("error: \(error.localizedDescription)")
                    return .fail(error)
                }
                
            }.eraseToAnyPublisher()
    }
    
    func restore() -> AnyPublisher<Void, Error> {
        removeTempFile()
        
        return cloudKitHelper.query(id: CKConfig.recordIdentifier,
                                    keys: [CKConfig.fileSizeKey, CKConfig.fileDataKey],
                                    recordType: CKConfig.recordType)
            .flatMap {[weak self] record -> AnyPublisher<Void, Error> in
                guard let self = self else { return .fail(ICloudBackupError.defaultError) }
                return self.restore(from: record)
            }
            .receiveOutput(outPut: {[weak self] _ in
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.2) {
                    self?.eventManager.updateDefaultEvent().sink{}.cancel()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func restore(from record: CKRecord?) -> AnyPublisher<Void, Error> {
        guard let record = record,
              let asset = record[CKConfig.fileDataKey] as? CKAsset,
              let backupFileUrl = asset.fileURL,
              let directoryBackupFileUrl = FileHelper.getDocumentDirectoryURL()
        else {
            return .fail(ICloudBackupError.defaultError)
        }
        
        let fileManager = FileManager.default
        
        do {
            
            // delete image data when need
            if let folderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(CKConfig.folderName),
               fileManager.fileExists(atPath: folderURL.path) {
                try fileManager.removeItem(atPath: folderURL.path)
            }
            
            self.removeTempFile()
            try fileManager.moveItem(at: backupFileUrl, to: self.localBackupFileUrl)
            
            try Zip.unzipFile(self.localBackupFileUrl,
                              destination: directoryBackupFileUrl,
                              overwrite: true,
                              password: nil)
            
            guard let localDocumentUrl = FileHelper.getDocumentDirectoryURL() else {
                return .fail(ICloudBackupError.defaultError)
            }
            
            let backupVersionFileUrl = localDocumentUrl.appendingPathComponent(CKConfig.versionFileName)
            
            return self.importCSVTextToRealm(from: localDocumentUrl, with: backupVersionFileUrl)
                .receiveOutput(outPut: {[weak self] _ in
                    try? fileManager.removeItem(atPath: CSVConfig.diaryFileName)
                    self?.removeTempFile()
                })
        } catch {
            print("error: \(error.localizedDescription)")
            return .fail(error)
        }
        
    }
    
    private func importCSVTextToRealm(from fileURL: URL, with backupVersionFileUrl: URL) -> AnyPublisher<Void, Error> {
        // Handle migration
        if let backupVersionContent = CSVHelper.convertCSVToText(from: backupVersionFileUrl),
           let backupVersionNumber = Int(backupVersionContent) {
            handlerMigrationData(from: backupVersionNumber)
        }
        
        let saveDiary = handleDiarySave(from: fileURL.appendingPathComponent(CSVConfig.diaryFileName))
        let saveEvent = handleEventSave(from: fileURL.appendingPathComponent(CSVConfig.eventFileName))
        
        return Publishers.CombineLatest(saveDiary, saveEvent).map {_ in return ()}.eraseToAnyPublisher()
        
    }
    
    private func handleDiarySave(from fileURL: URL) -> AnyPublisher<Void, Error> {
        guard let csvText = CSVHelper.convertCSVToText(from: fileURL) else {
            print("IcloudBackup: - convertCSVToTextbaseObjectFailure")
            return .fail(ICloudBackupError.defaultError)
        }
        
        let objectSections = csvText.components(separatedBy: CSVConfig.tableDelimiter)
        let allImage = ImageAttachment.getAllImage(from: objectSections[1].components(separatedBy: CSVConfig.recordDelimiter))
        guard
            objectSections.count == CSVConfig.diaryNumberOfTables,
            let allNote = DiaryModel.getAllNote(from: objectSections[0].components(separatedBy: CSVConfig.recordDelimiter),
                                                images: allImage)
        else {
            print("IcloudBackup: - convertCSVTextToDatabaseObjectFailure")
            return .fail(ICloudBackupError.defaultError)
        }
        
        return self.diaryManager.deleteAllDiary().flatMap {[weak self] _ -> AnyPublisher<Void, Error> in
            guard let self = self else { return .fail(ICloudBackupError.defaultError) }
            return self.diaryManager.saveMany(diaryModels: allNote).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    private func handleEventSave(from fileURL: URL) -> AnyPublisher<Void, Error>  {
        guard let csvText = CSVHelper.convertCSVToText(from: fileURL) else {
            print("IcloudBackup: - convertCSVToTextbaseObjectFailure")
            return .fail(ICloudBackupError.defaultError)
        }
        
        let objectSections = csvText.components(separatedBy: CSVConfig.tableDelimiter)
        guard
            objectSections.count == CSVConfig.eventNumberOfTables
        else {
            print("IcloudBackup: - convertCSVTextToDatabaseObjectFailure")
            return .fail(ICloudBackupError.defaultError)
        }
        
        let allEvent = EventModel.getAllEvent(from: objectSections[0].components(separatedBy: CSVConfig.recordDelimiter))
        
        return self.eventManager.deleteAll().flatMap {[weak self] _ -> AnyPublisher<Void, Error> in
            guard let self = self else { return .fail(ICloudBackupError.defaultError) }
            return self.eventManager.addNewEventErr(events: allEvent).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    private func handlerMigrationData(from backupVersionNumber: Int) {
        switch backupVersionNumber {
        case CKConfig.currentVersion:
            print("Not need migration if backup file version number match current backup file version number")
        default:
            break
        }
        print("backupFileVersionNumber: \(backupVersionNumber) - currentBackupFileVersionNumber: \(CKConfig.currentVersion)")
    }
    
    func remove() -> AnyPublisher<Void, Error> {
        if let backupRecord = backupRecord {
            return self.cloudKitHelper.delete(id: backupRecord.recordID)
                .receiveOutput {[weak self] _ in
                    self?.backupRecord = nil
                }
        } else {
            return getInfo().flatMap {[weak self] record -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return .fail(ICloudBackupError.defaultError)
                }
                
                if let record = record {
                    return self.cloudKitHelper.delete(id: record.recordID)
                        .receiveOutput {[weak self] _ in
                            self?.backupRecord = nil
                        }
                } else {
                    return .fail(ICloudBackupError.notAvailableError)
                }
                
            }.eraseToAnyPublisher()
            
        }
    }
}

private extension String {
    var slashBefore: String {
        return "/\(self)"
    }
}

private extension URL {
    
    var attributes: [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

