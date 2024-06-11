//
//  UIBarButtonItem+Combine+Extension.swift
//  LoveMemory
//
//  Created by daovu on 14/12/2020.
//

import Combine
import UIKit

final class UIBarButtonItemSubscription<SubscriberType: Subscriber>: Subscription
where SubscriberType.Input == UIBarButtonItem {
    private var subscriber: SubscriberType?
    private let control: UIBarButtonItem
    
    init(subscriber: SubscriberType, control: UIBarButtonItem) {
        self.subscriber = subscriber
        self.control = control
        control.target = self
        control.action = #selector(self.eventHandler)
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

struct UIBarButtonItemPublisher: Publisher {
    typealias Output = UIBarButtonItem
    typealias Failure = Never
    
    let control: UIBarButtonItem
    
    init(control: UIBarButtonItem) {
        self.control = control
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == UIBarButtonItemPublisher.Failure,
                                         S.Input == UIBarButtonItemPublisher.Output {
        let subscription = UIBarButtonItemSubscription(subscriber: subscriber, control: control)
        subscriber.receive(subscription: subscription)
    }
}

extension UIBarButtonItem {
    var publisher: UIBarButtonItemPublisher {
        return UIBarButtonItemPublisher(control: self)
    }
    
    var tapPublisher: AnyPublisher<Void, Never> {
        return UIBarButtonItemPublisher(control: self).map { _ in () }.eraseToAnyPublisher()
    }
}
