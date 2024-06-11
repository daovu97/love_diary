//
//  NSObject+Extension.swift
//  QikNote
//
//  Created by daovu on 01/03/2021.
//

import Foundation

protocol NameDescribable {
    var className: String { get }
    static var className: String { get }
}

extension NameDescribable {
    var className: String {
        return String(describing: type(of: self))
    }
    
    static var className: String {
        return String(describing: self)
    }
}

protocol HasApply { }

extension HasApply {
    
    @discardableResult
    func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: NameDescribable, HasApply {}
extension Array: NameDescribable, HasApply {}
