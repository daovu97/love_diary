//
//  UIGestureRecognizer+Combine+Extension.swift
//  LoveMemory
//
//  Created by daovu on 14/12/2020.
//

import Combine
import UIKit

final class UIGestureRecognizerSubscription<SubscriberType: Subscriber, Recognizer: UIGestureRecognizer>: Subscription
where SubscriberType.Input == Recognizer {
    private var subscriber: SubscriberType?
    private let control: Recognizer
    
    init(subscriber: SubscriberType, control: Recognizer) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(self.eventHandler))
    }
    
    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }
    
    func cancel() {
        self.subscriber = nil
    }
    
    @objc private func eventHandler() {
        _ = self.subscriber?.receive(self.control)
    }
}

struct UIGestureRecognizerPublisher<Recognizer: UIGestureRecognizer>: Publisher {
    typealias Output = Recognizer
    typealias Failure = Never
    
    let control: Recognizer
    
    init(control: Recognizer) {
        self.control = control
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == UIGestureRecognizerPublisher.Failure,
                                         S.Input == UIGestureRecognizerPublisher.Output {
        let subscription = UIGestureRecognizerSubscription(subscriber: subscriber, control: control)
        subscriber.receive(subscription: subscription)
    }
}

protocol CombineCompatible {}

extension UIGestureRecognizer: CombineCompatible {}
extension CombineCompatible where Self: UIGestureRecognizer {
    var publisher: UIGestureRecognizerPublisher<Self> {
        return UIGestureRecognizerPublisher(control: self)
    }
}

class SingleTapGestureRecognizer: UITapGestureRecognizer {
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        numberOfTapsRequired = 1
    }
}

extension UIView {
    func viewTapPublisher(_ numberTap: Int = 1) -> AnyPublisher<Void, Never> {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.numberOfTapsRequired = numberTap
        self.addGestureRecognizer(tapGesture)
        return tapGesture.publisher.map {_ in () }.eraseToAnyPublisher()
    }
}
