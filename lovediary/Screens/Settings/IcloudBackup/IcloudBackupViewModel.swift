//
//  IcloudBackupViewModel.swift
//  lovediary
//
//  Created by daovu on 23/04/2021.
//

import Foundation
import Combine
import CloudKit

class IcloudBackupViewModel: ViewModelType {
    
    private let navigator: IcloudBackupNavigatorType
    private let manager: IcloudBackupManagerType
    
    init(navigator: IcloudBackupNavigatorType, manager: IcloudBackupManagerType) {
        self.navigator = navigator
        self.manager = manager
    }
    
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
        let overWriteBackup: AnyPublisher<Void, Never>
        let restoreBackup: AnyPublisher<Void, Never>
        let createBackup: AnyPublisher<Void, Never>
        let deleteBackup: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let fileInfo: AnyPublisher<FileInfo?, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let errorContent: AnyPublisher<String, Never>
        let actionVoid: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input) -> Output {
        let isLoading = PassthroughSubject<Bool, Never>()
        let fileInfo = CurrentValueSubject<FileInfo?, Never>(nil)
        let errorContent = PassthroughSubject<String, Never>()
        
        let createBackup = Publishers.Merge(input.createBackup, input.overWriteBackup)
            .flatMap { [weak self] _ -> AnyPublisher<FileInfo?, Never> in
                guard let self = self else { return .empty() }
                isLoading.send(true)
                return self.createBackup()
                    .handleEvents(receiveOutput: { info in
                        fileInfo.send(info)
                       
                    }, receiveCompletion: { complete in
                        switch complete {
                        case .finished:
                            break
                        case .failure(let error):
                            errorContent.send(error.ckErrorString)
                        }
                        isLoading.send(false)
                    })
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }.eraseToVoidAnyPublisher()
        
        let deleteBackup = input.deleteBackup
            .flatMap {[weak self] _  -> AnyPublisher<Void, Never> in
            guard let self = self else { return .empty() }
            isLoading.send(true)
            return self.deleteBackup()
                .handleEvents(receiveOutput: { _ in
                    fileInfo.send(nil)
                }, receiveCompletion: { complete in
                    switch complete {
                    case .finished:
                        break
                    case .failure(let error):
                        errorContent.send(error.ckErrorString)
                    }
                    isLoading.send(false)
                })
                .replaceError(with: ())
                .eraseToAnyPublisher()
        }.eraseToVoidAnyPublisher()
        
        let load = input.loadTrigger
            .flatMap { [weak self] _ -> AnyPublisher<FileInfo?, Never> in
                guard let self = self else { return .empty() }
                isLoading.send(true)
                return self.loadFileInfo()
                    .handleEvents(receiveOutput: { info in
                        fileInfo.send(info)
                      
                    }, receiveCompletion: { complete in
                        switch complete {
                        case .finished:
                            break
                        case .failure(let error):
                            errorContent.send(error.ckErrorString)
                        }
                        isLoading.send(false)
                    })
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
           .eraseToVoidAnyPublisher()
        
        let restore = input.restoreBackup
            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                isLoading.send(true)
                return self.restoreBackup()
                    .handleEvents(receiveCompletion: { complete in
                        switch complete {
                        case .finished:
                            break
                        case .failure(let error):
                            errorContent.send(error.ckErrorString)
                        }
                        isLoading.send(false)
                    })
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            }
           .eraseToVoidAnyPublisher()
        
        return .init(fileInfo: fileInfo.eraseToAnyPublisher(),
                     isLoading: isLoading.eraseToAnyPublisher(),
                     errorContent: errorContent.eraseToAnyPublisher(),
                     actionVoid: Publishers.Merge4(createBackup, deleteBackup, load, restore).eraseToAnyPublisher())
    }
    
    private func loadFileInfo() -> AnyPublisher<FileInfo?, Error> {
        return manager.getInfo().map { record -> FileInfo? in
            return record == nil ? nil : FileInfo(size: record!.sizeString(), updateDate: record!.updateDate())
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func createBackup() -> AnyPublisher<FileInfo?, Error> {
        return manager.backup().map { record -> FileInfo? in
            return FileInfo(size: record.sizeString(), updateDate: record.updateDate())
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func deleteBackup() -> AnyPublisher<Void, Error> {
        return manager.remove()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func restoreBackup() -> AnyPublisher<Void, Error>{
        return manager.restore()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    struct FileInfo {
        let size: String
        let updateDate: String
    }
}

struct IcloudBackupError: Error {
    var message: String
}

extension IcloudBackupError: LocalizedError {
    var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
}

private extension CKRecord {
    func sizeString() -> String {
        var fileSizeString = ""
        if let formatString = self[CKConfig.fileSizeKey] as? String {
            fileSizeString = formatString
        }
        
        return fileSizeString
    }
    
    func updateDate() -> String {
        var updateDateFormated = ""
        if let date = self.modificationDate {
            updateDateFormated = date.format(partern: .fullDateTime)
        }
        return updateDateFormated
    }
}
