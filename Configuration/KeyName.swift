//
//  KeyName.swift
//  Configuration
//
//  Created by daovu on 30/03/2021.
//

import Foundation

private class KeyName {}

public extension AppConfigs {
    static func infoForKey(_ key: String) -> String {
        return Bundle(for: KeyName.self).object(forInfoDictionaryKey: key) as? String ?? ""
    }
}
