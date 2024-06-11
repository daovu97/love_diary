//
//  ViewModelType.swift
//  QikNote
//
//  Created by daovu on 01/03/2021.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
}
