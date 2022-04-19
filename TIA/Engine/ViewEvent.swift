//
//  ViewEvent.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import Foundation
import Combine

typealias ViewEventsPublisher = PassthroughSubject<ViewEvent, Never>

protocol ViewEventsSource {
    var eventsPublisher: ViewEventsPublisher { get }
}

protocol ViewEventsListener {
    func subscribeTo(_ publisher: ViewEventsPublisher)
}

enum ViewEvent {
    case viewInitFinished
    case edgeGrowingFinished(edge: Edge)
    case vertexGrowingFinished(vertex: Vertex)
}
