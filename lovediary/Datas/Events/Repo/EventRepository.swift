//
//  EventRepository.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import Foundation
import Combine

protocol EventRepositoryType {
    func getAllEvent() -> AnyPublisher<[EventModel], Never>
}
