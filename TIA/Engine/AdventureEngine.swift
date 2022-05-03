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
        
        subscriptions.sink(player.$position) { [weak self] in
            self?.handlePlayerPositionUpdate($0)
        }
        
        let gates = adventure.edges.flatMap { $0.gates }
        for gate in gates {
            subscriptions.sink(gate.$isOpen) { [weak self] in
                self?.handleGateStatusUpdate(gate)
            }
        }
    }
    
    func subscribeTo(_ publisher: ViewEventsPublisher) {
        subscriptions.sink(publisher) {
            [weak self] event in
            self?.handleViewEvent(event)
        }
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
                let vertex = direction.endVertex(edge)
                addPlayerResources(vertexResources(vertex))
            case .expanding:
                applyEstimated(playerResources(player))
                recloseGates(edge: edge)
            }
        }
    }
    
    private func handleGateStatusUpdate(_ gate: EdgeGate) {
        gateResources(gate).forEach { $0.objectWillChange.send() }
    }
    
    private func recloseGates(edge: Edge) {
        let wipeResources = edge.gates.allSatisfy { $0.isOpen }
        for gate in edge.gates {
            gate.isOpen = false
            if wipeResources {
                removeResources(gateResources(gate))
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
        case .resourceMovedToGate(let gate):
            gate.isOpen = true
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
        
        tryMove(player: player, edge: edge, forward: edge.from == old)
    }
    
    private func tryMove(player: Player, edge: Edge, forward: Bool) {
        let count = edge.gates.count
        let range = forward ? Array(0..<count) : (0..<count).reversed()
        let fromVertex = forward ? edge.from : edge.to
        
        var failIndex: Int? = nil
        for i in range {
            let gate = edge.gates[i]
            
            switch gate.requirement {
            case .resource(let type):
                let res = playerResources(player).first { $0.type == type }
                guard let res = res else {
                    failIndex = i
                    break
                }
                guard case .inventory(_, let index, _, _, _) = res.state else { break }
                
                res.state = .gate(gate: gate, edge: edge, fromVertex: fromVertex, fromIndex: index)
            }
            
            if failIndex ~= nil { break }
        }
        
        if let failIndex = failIndex {
            let direction: EdgeMovingDirection = forward ? .forwardFail(gateIndex: failIndex, moveToGate: true) : .backwardFail(gateIndex: failIndex, moveToGate: true)
            player.position = .edge(edge: edge, status: .compressing, direction: direction)
        } else {
            let direction: EdgeMovingDirection = forward ? .forward : .backward
            player.position = .edge(edge: edge, status: .compressing, direction: direction)
            
            if !edge.gates.isEmpty {
                reindexPlayerResources(player)
            }
        }
    }
    
    // MARK: Resources handling
    private func vertexResources(_ vertex: Vertex) -> [Resource] {
        resources.filter {
            guard case .vertex(let resVertex, _, _) = $0.state else { return false }
            return resVertex == vertex
        }
    }
    
    private func playerResources(_ player: Player) -> [Resource]  {
        resources.filter {
            guard case .inventory(let resPlayer, _, _, _, _) = $0.state else { return false }
            return resPlayer == player
        }
    }
    
    private func gateResources(_ gate: EdgeGate) -> [Resource] {
        resources.filter {
            guard case .gate(let resGate, _, _, _) = $0.state else { return false }
            return resGate == gate
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
    
    private func removeResources(_ resources: [Resource]) {
        resources.forEach { $0.state = .deletion }
        self.resources.removeAllDeletion()
    }
}
