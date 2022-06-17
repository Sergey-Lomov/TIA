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

    case layerPrepared(layer: AdventureLayer)
    case layerPresented(layer: AdventureLayer)
    case layerWasHidden(layer: AdventureLayer)
    
    case vertexGrowingFinished(vertex: Vertex)
    case vertexUngrowingFinished(vertex: Vertex)
    case vertexSelected(vertex: Vertex)
    
    case edgeSeedExtensionPrepared(edge: Edge)
    case edgeGrowingPrepared(edge: Edge)
    case edgePathGrowed(edge: Edge)
    case edgeElementsPrepared(edge: Edge)
    case edgeElementsGrowed(edge: Edge)
    case edgeUngrowingPrepared(edge: Edge)
    case edgeElementsUngrowed(edge: Edge)
    case edgeUngrowed(edge: Edge)
    
    case resourceMovedToGate(resource: Resource)
    case resourceMovedOut(resource: Resource)
    case resourcePresented(resource: Resource)
    case resourceIdleFinished(resource: Resource)
    case resourceIdleRestored(resource: Resource)
}
