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
        static let edgeGrowing: TimeInterval = 1.5 * 0.1
        static let vertexGrowing: TimeInterval = 0.3 * 0.1
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
                let state = ResourceState.vertex(vertex: vertex, index: index, total: total)
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
                applyEstimated(playerResources(player))
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
        tryMove(player: player, edge: edge, direction: direction)
    }
    
    private func tryMove(player: Player, edge: Edge, direction: EdgeMovingDirection) {
        let gates = direction == .forward ? edge.gates : edge.gates.reversed()
        
        for gate in gates {
            switch gate.requirement {
            case .resource(let type):
                let res = playerResources(player).first { $0.type == type }
                
                guard let res = res else { break }
                guard case .inventory(_, let index, _, _, _) = res.state else { break }
                
                gate.isOpen = true
                let from = direction == .forward ? edge.from : edge.to
                res.state = .gate(gate: gate, edge: edge, fromVertex: from, fromIndex: index)
            }
        }
        
        if !gates.isEmpty && gates.allSatisfy(validator: { $0.isOpen }) {
            reindexPlayerResources(player)
        }
        
        player.position = .edge(edge: edge, status: .compressing, direction: direction)
    }
    
    // MARK: Resources handling
    private func vertexResources(_ vertex: Vertex) -> [Resource] {
        resources.filter {
            guard case .vertex(let resVertex, _, _) = $0.state else { return false }
            return resVertex.id == vertex.id
        }
    }
    
    private func playerResources(_ player: Player) -> [Resource]  {
        resources.filter {
            guard case .inventory(let resPlayer, _, _, _, _) = $0.state else { return false }
            return resPlayer.id == player.id
        }
    }
    
    private func addPlayerResources(_ resources: [Resource]) {
        let oldResources = playerResources(player)
        let total = oldResources.count + resources.count
        oldResources.forEach {
            guard case .inventory(_, let index, let estimated, _, let isFresh) = $0.state else { return }
            $0.state = .inventory(player: player, index: index, estimatedIndex: estimated ,total: total, isFresh: isFresh)
        }
        
        var index = oldResources.count
        resources.forEach {
            $0.state = .inventory(player: player, index: index, estimatedIndex: index, total: total, isFresh: true)
            index += 1
        }
    }
    
    private func unfreshPlayerResources(_ player: Player) {
        let resources = playerResources(player)
        resources.forEach {
            guard case .inventory(_, let index, let estimatedIndex, let total, _) = $0.state else { return }
            $0.state = .inventory(player: player, index: index, estimatedIndex: estimatedIndex, total: total, isFresh: false)
        }
    }
    
    private func reindexPlayerResources(_ player: Player) {
        let indexator: (Resource) -> Int = { resource in
            guard case .inventory(_, let index, _, _, _) = resource.state else {
                return -1
            }
            return index
        }
        
        let ordered = playerResources(player).sorted { indexator($0) > indexator($1) }
        let total = ordered.count
        ordered.enumerated().forEach { newIndex, res in
            guard case .inventory(_, let index, _, _, let isFresh) = res.state else {
                return
            }
            res.state = .inventory(player: player, index: index, estimatedIndex: newIndex, total: total, isFresh: isFresh)
        }
    }
    
    private func applyEstimated(_ resources: [Resource]) {
        resources.forEach {
            guard case .inventory(let player, _, let estimatedIndex, let total, let isFresh) = $0.state else { return }
            $0.state = .inventory(player: player, index: estimatedIndex, estimatedIndex: estimatedIndex, total: total, isFresh: isFresh)
        }
    }
}
