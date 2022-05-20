//
//  EngineEvent.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import Foundation
import Combine

typealias EngineEventsPublisher = PassthroughSubject<EngineEvent, Never>

protocol EngineEventsSource {
    var eventsPublisher: EngineEventsPublisher { get }
}

protocol EngineEventsListener {
    mutating func subscribeTo(_ publisher: EngineEventsPublisher)
}

enum EngineEvent {
    case edgeAdded(edge: Edge)
    case edgeRemoved(edge: Edge)
}
