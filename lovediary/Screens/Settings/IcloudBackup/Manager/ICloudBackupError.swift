//
//  ICloudBackupError.swift
//  lovediary
//
//  Created by vu dao on 15/05/2021.
//

import Foundation
import CloudKit

struct ICloudBackupError: Error, Codable {
    var message: String
    
    init(message: String) {
        self.message = message
    }
}

extension ICloudBackupError: LocalizedError {
    var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
}

extension ICloudBackupError {
    static let defaultError = ICloudBackupError(message: LocalizedString.ic01IcloudBackupErrorTitle)
    static let notAvailableError = ICloudBackupError(message: LocalizedString.ic01IcloudBackupNotAvailableErrorTitle)
}

extension Error {
    var ckErrorString: String {
        guard let ckError = self as? CKError else {
            return self.localizedDescription
        }
        
        var errorString = ""
        
        switch ckError.code {
        case .requestRateLimited, .zoneBusy, .limitExceeded:
            errorString = LocalizedString.ic01ServerBusyCKErrorTitle
            if let retryTime = ckError.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
                let roundedSeconds = Int(retryTime.rounded())
                errorString += String(format: LocalizedString.ic01RetryCKErrorTitle, String(roundedSeconds))
            }
        case .notAuthenticated:
            errorString = LocalizedString.ic01NotAuthenticatedCKErrorTitle
        case .networkFailure, .networkUnavailable:
            errorString = LocalizedString.ic01NetworkFailureCKErrorTitle
        case .quotaExceeded:
            errorString = LocalizedString.ic01QuotaExceededCKErrorTitle
        case .partialFailure:
            if let dictionary = ckError.userInfo[CKPartialErrorsByItemIDKey] as? NSDictionary,
                let mainCkError = dictionary.allValues.first as? CKError {
                return mainCkError.ckErrorString
            }
        case .internalError, .serviceUnavailable:
            errorString += LocalizedString.ic01ServiceUnavailableCKErrorTitle
        default:
            errorString = LocalizedString.ic01ServerBusyCKErrorTitle
        }
        return errorString
    }
}
