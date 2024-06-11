//
//  ThemeNotification.swift
//  LocalSettings
//
//  Created by daovu on 24/03/2021.
//

import Combine
import Foundation

protocol ThemeNotification: class {
    var subscription: AnyCancellable? { get set }
    func themeChange()
}

extension ThemeNotification {
    
    func addThemeObserver() {
        subscription =  NotificationCenter.default.publisher(for: .themeChangeNotification)
            .sink(receiveValue: {[weak self] _ in
                self?.themeChange()
            })
    }
    
    func removeThemeObserver() {
        subscription?.cancel()
    }
}
