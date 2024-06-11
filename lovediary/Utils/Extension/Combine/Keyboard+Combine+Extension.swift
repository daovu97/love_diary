//
//  Keyboard+Combine+Extension.swift
//  lovediary
//
//  Created by daovu on 18/03/2021.
//

import UIKit
import Combine

extension UIViewController {
    var keyboardPublisher: AnyPublisher<CGFloat, Never> {
        
        let keyboardShow = NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
            .flatMap({ notification -> AnyPublisher<CGFloat, Never> in
                guard let keyboardSizeValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return .empty() }
                return .just(keyboardSizeValue.cgRectValue.height)
            })
        
        let keyboardHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .flatMap({ _ -> AnyPublisher<CGFloat, Never> in return .just(0)})
        
        return Publishers.Merge(keyboardShow, keyboardHide).eraseToAnyPublisher()
    }
}
