//
//  Publisher+Extension.swift
//  LoveMemory
//
//  Created by daovu on 28/12/2020.
//

import Combine

extension Publisher {
    func eraseToVoidAnyPublisher() -> AnyPublisher<Void, Failure> {
        self.map { _ in () }.eraseToAnyPublisher()
    }
    
    func receiveOutput(outPut: ((Output) -> Void)?) -> AnyPublisher<Output, Failure> {
        return self.handleEvents(receiveOutput: outPut).eraseToAnyPublisher()
    }
    
    func receiveComplete(complete: ((Subscribers.Completion<Failure>) -> Void)?) -> AnyPublisher<Output, Failure> {
        return self.handleEvents(receiveCompletion: complete).eraseToAnyPublisher()
    }
    
    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Deferred {
            Future { promise in
                promise(.success(output))
            }
        }.eraseToAnyPublisher()
    }
    
    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }
    
    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}

extension PassthroughSubject where Output == Void, Failure == Never {
    func send() {
        send(())
    }
}
