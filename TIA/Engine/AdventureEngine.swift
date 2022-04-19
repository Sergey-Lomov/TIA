//
//  AdventureEngine.swift
//  TIA
//
//  Created by Serhii.Lomov on 15.04.2022.
//

import Foundation
import Combine

enum PlayerPosition {
    case edge(edge: Edge, success: Bool)
    case vertex(vertex: Vertex)
}

enum AdventureLifecycle {
    case initiation
    case gameplay
    case finalizing
}

final class AdventureEngine: ViewEventsListener, EngineEventsSource {
    
    private enum Timing {
        // TODO: Remove when view-engine interaction will be finished
        static let queue = DispatchQueue.main
        static let edgeGrowing: TimeInterval = 1.5
        static let vertexGrowing: TimeInterval = 0.3
    }
    
    var subscriptions: [AnyCancellable] = []
    var eventsPublisher = EngineEventsPublisher()
    
    var adventure: Adventure
    var lifestate: AdventureLifecycle = .initiation
    var playerPosition: PlayerPosition? = nil {
        didSet {
            eventsPublisher.send(.playerMoves(from: oldValue, to: playerPosition))
        }
    }
    
    init(adventure: Adventure) {
        self.adventure = adventure
    }
    
    func subscribeTo(_ publisher: ViewEventsPublisher) {
        let subscription = publisher.sink {
            [weak self] event in
            self?.handleViewEvent(event)
        }
        subscriptions.append(subscription)
    }
    
    private func growFromEntrace() {
        for vertex in adventure.vertices {
            if vertex.type == .entrance {
                vertex.state = .active
                growFromVertex(vertex)
            }
        }
    }
    
    private func growVertex(_ vertex: Vertex) {
        switch vertex.state {
        case .seed:
            vertex.state = .growing(duration: Timing.vertexGrowing)
        default:
            break
        }
    }
    
    private func growFromVertex(_ vertex: Vertex) {
        for edge in vertex.outEdges {
            switch edge.state {
            case .seed:
                growEdge(edge)
            default:
                break
            }
        }
    }
    
    private func growEdge(_ edge: Edge) {
        let duration = Timing.edgeGrowing * edge.length
        edge.state = .growing(duration: duration)
    }
    
    private func checkInitGrowingCompletion() {
        let inactiveEdges = adventure.edges.filter { !$0.state.isGrowed}
        let inactiveVertex = adventure.vertices.filter { !$0.state.isGrowed}
        
        if inactiveEdges.isEmpty && inactiveVertex.isEmpty {
            handleInitGrowingCompletion()
        }
    }
    
    private func handleInitGrowingCompletion() {
        guard let entrance = adventure.entrances.first else {
            fatalError("Adventure \"\(adventure.id)\" have no entrances")
        }
        
        lifestate = .gameplay
        playerPosition = .vertex(vertex: entrance)
    }
    
    // MARK: View events handling

    private func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewInitFinished:
            growFromEntrace()
        case .edgeGrowingFinished(let edge):
            edge.state = .active
            growVertex(edge.to)
            checkInitGrowingCompletion()
        case .vertexGrowingFinished(let vertex):
            vertex.state = .active
            growFromVertex(vertex)
            checkInitGrowingCompletion()
        case .vertexSelected(let vertex):
            handleVertexSelection(vertex)
        }
    }
    
    private func handleVertexSelection(_ vertex: Vertex) {
        guard case .vertex(let old) = playerPosition else {
            return
        }
        
        let sharedEdges = old.edges.intersection(vertex.edges)
        guard let edge = sharedEdges.first, edge.state.isGrowed else {
            return
        }
        
        playerPosition = .vertex(vertex: vertex)
    }
}
