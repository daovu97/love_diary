//
//  CloudKitHelper.swift
//  lovediary
//
//  Created by vu dao on 15/05/2021.
//

import Foundation
import Combine
import CloudKit

protocol CloudKitHelperType {
    func query(id: String, keys: [String], recordType: String) -> AnyPublisher<CKRecord?, Error>
    func update(records: [CKRecord]) -> AnyPublisher<CKRecord, Error>
    func delete(id: CKRecord.ID) -> AnyPublisher<Void, Error>
}

class CloudKitHelper: CloudKitHelperType {
    internal var database: CKDatabase
    
    init(database: CKDatabase = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }
    
    func query(id: String, keys: [String], recordType: String) -> AnyPublisher<CKRecord?, Error> {
        return Deferred {
            Future { [weak self] promise  in
                var records: [CKRecord] = []
                
                let predicate = NSPredicate(format: "ID = %@", id)
                let query = CKQuery(recordType: recordType, predicate: predicate)
                
                let operation = CKQueryOperation(query: query)
                operation.qualityOfService = .userInitiated
                operation.desiredKeys = keys
                
                operation.recordFetchedBlock = { record in
                    print("Success fetch -\(Date()) (key: \(keys)): \(record)")
                    records.append(record)
                }
                
                operation.queryCompletionBlock = { cursor, error in
                    print("Query completion")
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    promise(.success(records.last))
                }
                
                self?.database.add(operation)
            }
        }.eraseToAnyPublisher()
    }
    
    func update(records: [CKRecord]) -> AnyPublisher<CKRecord, Error> {
        return Deferred {
            Future { [weak self] promise  in
                let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                operation.qualityOfService = .userInitiated
                
                operation.perRecordProgressBlock = { record, progress in
                    print("Progress \(progress)")
                }
                
                operation.modifyRecordsCompletionBlock = { records, _, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    print("Success update - \(Date())")
                    guard let record = records?.first else { return }
                    promise(.success(record))
                }
                
                self?.database.add(operation)
            }
        }.eraseToAnyPublisher()
    }
    
    func delete(id: CKRecord.ID) -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { [weak self] promise  in
                print("Deleting...")
                self?.database.delete(withRecordID: id, completionHandler: { (id, error) in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    print("Success remove backup file")
                    promise(.success(Void()))
                })
            }}.eraseToAnyPublisher()
    }
}
