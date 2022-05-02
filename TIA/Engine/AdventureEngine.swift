//
//  AdventureEngine.swift
//  TIA
//
//  Created by Serhii.Lomov on 15.04.2022.
//

import Foundation
import Combine

enum AdventureLifecycle {
    case initiation
    case gameplay
    case finalizing
}

final class AdventureEngine: ViewEventsListener, EngineEventsSource {
    
    private enum Timing {
        // TODO: Remove when view-engine interaction will be finished
        static let queue = DispatchQueue.main
        static let edgeGrowing: TimeInterval = 1.5 //* 0.1
        static let vertexGrowing: TimeInterval = 0.3 //* 0.1
    }
    
    var subscriptions: [AnyCancellable] = []
    var eventsPublisher = EngineEventsPublisher()
    
    var adventure: Adventure
    var lifestate: AdventureLifecycle = .initiation
    var player: Player
    var resources: [Resource]
    
    init(adventure: Adventure) {
        self.adventure = adventure
        self.player = Player(position: .abscent)
        
        self.resources = []
        for vertex in adventure.vertices {
            let total = vertex.initialResources.count
            for index in 0..<total {
                let type = vertex.initialResources[index]
                let state = ResourceState.inVertex(vertex: vertex, index: index, total: total)
                let resource = Resource(type: type, state: state)
                self.resources.append(resource)
            }
        }
        
        // When player update position all owned resources should be notified
        let positionSubscribtion = player.$position.sink {
            [weak self] receiveValue in
            self?.handlePlayerPositionUpdate(receiveValue)
        }
        subscriptions.append(positionSubscribtion)
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
    
    private func handlePlayerPositionUpdate(_ newValue: PlayerPosition) {
        playerResources(player).forEach { resource in
            resource.objectWillChange.send()
        }
        
        switch newValue {
        case .abscent, .vertex:
            break
        case .edge(let edge, let status, let direction):
            switch status {
            case .compressing:
                unfreshPlayerResources(player)
            case .moving:
                let vertex = direction == .forward ? edge.to : edge.from
                addPlayerResources(vertexResources(vertex))
            case .expanding:
                break
            }
        }
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
        player.position = .vertex(vertex: entrance)
    }
    
    private func handleVertexSelection(_ vertex: Vertex) {
        guard case .vertex(let old) = player.position, old.id != vertex.id else {
            return
        }
        
        let sharedEdges = old.edges.intersection(vertex.edges)
        guard let edge = sharedEdges.first, edge.state.isGrowed else {
            return
        }
        
        let direction: EdgeMovingDirection = edge.from.id == old.id ? .forward : .backward
        player.position = .edge(edge: edge, status: .compressing, direction: direction)
    }
    
    // MARK: Resources handling
    private func vertexResources(_ vertex: Vertex) -> [Resource] {
        resources.filter {
            guard case .inVertex(let resVertex, _, _) = $0.state else { return false }
            return resVertex.id == vertex.id
        }
    }
    
    private func playerResources(_ player: Player) -> [Resource]  {
        resources.filter {
            guard case .ownByPlayer(let resPlayer, _, _, _) = $0.state else { return false }
            return resPlayer.id == player.id
        }
    }
    
    private func addPlayerResources(_ resources: [Resource]) {
        let oldResources = playerResources(player)
        let total = oldResources.count + resources.count
        oldResources.forEach {
            guard case .ownByPlayer(_, let index, _, let isFresh) = $0.state else { return }
            $0.state = .ownByPlayer(player: player, index: index, total: total, isFresh: isFresh)
        }
        
        var index = oldResources.count
        resources.forEach {
            $0.state = .ownByPlayer(player: player, index: index, total: total, isFresh: true)
            index += 1
        }
    }
    
    private func unfreshPlayerResources(_ player: Player) {
        let resources = playerResources(player)
        resources.forEach {
            guard case .ownByPlayer(_, let index, let total, _) = $0.state else { return }
            $0.state = .ownByPlayer(player: player, index: index, total: total, isFresh: false)
        }
    }
}
