//
//  IngameViewEvent.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import Foundation
import Combine

typealias ViewEventsPublisher = PassthroughSubject<IngameViewEvent, Never>

protocol ViewEventsSource {
    var eventsPublisher: ViewEventsPublisher { get }
}

protocol ViewEventsListener {
    func subscribeTo(_ publisher: ViewEventsPublisher)
}

enum IngameViewEvent {
    case viewInitFinished

    case playerCompressed(player: Player)
    case playerExpanded(player: Player)

    case layerPrepared(layer: AdventureLayer)
    case layerPresented(layer: AdventureLayer)
    case layerWasHidden(layer: AdventureLayer)

    case vertexGrowingFinished(vertex: Vertex)
    case vertexUngrowingFinished(vertex: Vertex)
    case vertexSelected(vertex: Vertex)
    case vertexMoved(vertex: Vertex, position: CGPoint, finished: Bool)

    case edgeSeedExtensionPrepared(edge: Edge)
    case edgeGrowingPrepared(edge: Edge)
    case edgePathGrowed(edge: Edge)
    case edgeElementsPrepared(edge: Edge)
    case edgeElementsGrowed(edge: Edge)
    case edgeUngrowingPrepared(edge: Edge)
    case edgeElementsUngrowed(edge: Edge)
    case edgeUngrowed(edge: Edge)
    case edgeControlChanged(edge: Edge, point: ControlPoint, newValue: CGPoint, finished: Bool)

    case resourceMovedToGate(resource: Resource)
    case resourceDestroyingPrepared(resource: Resource)
    case resourceDestroyed(resource: Resource)
    case resourcePresented(resource: Resource)
    case resourceIdleFinished(resource: Resource)
    case resourceIdleRestored(resource: Resource)

    case gateClosed(gate: EdgeGate)
}
