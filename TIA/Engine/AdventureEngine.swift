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
    case menu
    case finalizing
}

final class AdventureEngine: ViewEventsListener, EngineEventsSource {
    
    private enum Timing {
        // TODO: Remove when view-engine interaction will be finished
        static let queue = DispatchQueue.main
        static let edgeGrowing: TimeInterval = 1.5 * 0.3
        static let vertexGrowing: TimeInterval = 0.3 * 0.3
    }
    
    private static let menuVertexId = "menu_vertex"
    private static let menuEdgeId = "menu_edge"
    
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
        adventure.allVertices.forEach { handleNewVertex($0) }
        
        subscriptions.sink(player.$position) { [weak self] in
            self?.handlePlayerPositionUpdate($0)
        }
        
        let gates = adventure.allEdges.flatMap { $0.gates }
        for gate in gates {
            subscriptions.sink(gate.$state) { [weak self] in
                self?.handleGateStateUpdate(gate)
            }
        }
    }
    
    func subscribeTo(_ publisher: ViewEventsPublisher) {
        subscriptions.sink(publisher) {
            [weak self] event in
            self?.handleViewEvent(event)
        }
    }
    
    private func handleNewVertex(_ vertex: Vertex) {
        let totalResources = vertex.initialResources.count
        for index in 0..<totalResources {
            let type = vertex.initialResources[index]
            let state = ResourceState.vertex(vertex: vertex, index: index, total: totalResources, idle: .none)
            let resource = Resource(type: type, state: state)
            self.resources.append(resource)
        }
        
        subscriptions.sink(vertex.$state) { [weak self] in
            self?.handleVertexStateUpdate(vertex)
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
        for edge in adventure.currentLayer.outcome(vertex) {
            switch edge.state {
            case .seed:
                growEdge(edge)
            default:
                break
            }
        }
        
        let waitingEdges = adventure.currentLayer.income(vertex).filter {
            let metastate = EdgeViewMetastate.forState($0.state)
            switch metastate {
            case .waitingVertex:
                return true
            default:
                return false
            }
        }
        for edge in waitingEdges {
            edge.state = .growing(phase: .preparingElements)
        }
    }
    
    private func growEdge(_ edge: Edge) {
        edge.state = .growing(phase: .preparing)
    }
    
    private func handleVertexStateUpdate(_ vertex: Vertex) {
        vertexResources(vertex).forEach {
            $0.objectWillChange.sendOnMain()
        }
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
    
    private func handleGateStateUpdate(_ gate: EdgeGate) {
        gateResources(gate).forEach { $0.objectWillChange.send() }
    }
    
    private func recloseGates(edge: Edge) {
        let wipeResources = edge.gates.allSatisfy { $0.state == .open }
        for gate in edge.gates {
            gate.state = .close
            if wipeResources {
                removeResources(gateResources(gate))
            } else {
                gateResources(gate).forEach {
                    guard case .gate(let gate, let edge, let vertex, let index, _, let prestate) = $0.state else { return }
                    $0.state = .gate(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, state: .outcoming, prestate: prestate)
                }
            }
        }
    }
    
    // MARK: View events handling

    private func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewInitFinished:
            growFromVertex(adventure.currentLayer.entrance)
            
        case .layerPrepared(let layer):
            layer.state = .presenting
        case .layerPresented(let layer):
            handleLayerPresented(layer)
        case .layerWasHidden(let layer):
            handleLayerWasHidden(layer)
            
        case .vertexGrowingFinished(let vertex):
            handleVertexGrowed(vertex)
        case .vertexUngrowingFinished(let vertex):
            handleVertexUngrowed(vertex)
        case .vertexSelected(let vertex):
            handleVertexSelection(vertex)
        
        case .edgeSeedExtensionPrepared(let edge):
            edge.state = .seed(phase: .extended)
        case .edgeGrowingPrepared(let edge):
            let duration = Timing.edgeGrowing * edge.length()
            edge.state = .growing(phase: .pathGrowing(duration: duration))
        case .edgePathGrowed(let edge):
            handleEdgePathGrowed(edge)
        case .edgeElementsPrepared(let edge):
            let duration = Timing.edgeGrowing * edge.length()
            edge.state = .growing(phase: .elementsGrowing(duration: duration))
        case .edgeElementsGrowed(let edge):
            handleEdgeCounterConnectorGrowed(edge)
        case .edgeUngrowingPrepared(let edge):
            handleEdgeUngrowingPrepared(edge)
        case .edgeElementsUngrowed(let edge):
            // TODO: Duration should be moved to view instead state associated value
            let duration = AnimationService.Const.Edge.pathUngrowingDuration
            edge.state = .ungrowing(phase: .pathUngrowing(duration: duration))
        case .edgeUngrowed(let edge):
            handleEdgeUngrowed(edge)
        
        case .resourceMovedToGate(let resource):
            handleResourceMovedToGate(resource)
        case .resourcePresented(let resource):
            handleResourcePresented(resource)
        case .resourceIdleFinished(let resource):
            handleResourceFinishIdle(resource)
        case .resourceIdleRestored(let resource):
            handleResourceIdleRestored(resource)
        }
    }
    
    private func handleInitGrowingCompletion() {
        lifestate = .gameplay
        let entrance = adventure.currentLayer.entrance
        player.position = .vertex(vertex: entrance)
    }
    
    private func handleLayerPresented(_ layer: AdventureLayer) {
        layer.state = .growing
        layer.entrance.state = .active
        growFromVertex(layer.entrance)
    }
    
    private func handleLayerWasHidden(_ layer: AdventureLayer) {
        guard case .hiding(let next) = layer.state else { return }
        if layer.type == .menu {
            lifestate = .gameplay
        }
        if let next = next {
            adventure.currentLayer = next
        }
        adventure.layers.remove(layer)
    }
                                                     
    private func handleVertexGrowed(_ vertex: Vertex) {
        vertex.state = .active
        growFromVertex(vertex)
        checkLayerGrowingCompletion()
    }
    
    private func handleVertexUngrowed(_ vertex: Vertex) {
        vertex.state = .seed
        checkLayerUngrowingCompletion()
    }
    
    private func handleVertexSelection(_ newVertex: Vertex) {
        guard case .vertex(let oldVertex) = player.position else { return }
        guard case .shown = adventure.currentLayer.state else { return }
        
        if oldVertex == newVertex {
            switch lifestate {
            case .gameplay:
                showMenu(from: oldVertex)
            case .menu:
                hideMenu(to: oldVertex)
            default:
                break
            }
        } else {
            tryMove(player: player, fromVertex: oldVertex, toVertex: newVertex)
        }
    }
    
    private func handleEdgePathGrowed(_ edge: Edge) {
        if edge.to.state.isGrowed {
            edge.state = .growing(phase: .preparingElements)
        } else {
            edge.state = .growing(phase: .waitingDestinationVertex)
            growVertex(edge.to)
        }
    }
    
    private func handleEdgeCounterConnectorGrowed(_ edge: Edge) {
        edge.state = .active
        checkLayerGrowingCompletion()
    }
    
    private func handleEdgeUngrowingPrepared(_ edge: Edge) {
        // TODO: Duration should be moved to view instead state associated value
        let duration = AnimationService.Const.Edge.elementsUngrowingDuration
        edge.state = .ungrowing(phase: .elementsUngrowing(duration: duration))
        //edge.gates.forEach { $0.state = .ungrowing }
    }
    
    private func handleEdgeUngrowed(_ edge: Edge) {
        edge.state = .seed(phase: .compressed)
        startUngrowingIfReady(edge.to)
        startUngrowingIfReady(edge.from)
    }
    
    private func startUngrowingIfReady(_ vertex: Vertex) {
        guard case .ungrowing(let exit) = adventure.currentLayer.state,
              vertex != exit else {
                  return
              }
        
        let layerEdges = adventure.currentLayer.edges(of: vertex)
        let readyToUngrowing = layerEdges.allSatisfy { $0.state.isSeed }
        if readyToUngrowing && vertex.state.isGrowed {
            // TODO: Move duration to view layer
            let duration = AnimationService.Const.Vertex.ungrowingDuration
            vertex.state = .ungrowing(duration: duration)
        }
    }
    
    private func handleResourcePresented(_ resource: Resource) {
        guard case .vertex(let vertex, let index, let total, _) = resource.state else { return }
        resource.state = .vertex(vertex: vertex, index: index, total: total, idle: .rotation)
    }
    
    private func handleResourceFinishIdle(_ resource: Resource) {
        guard case .vertex(let vertex, let index, let total, _) = resource.state else { return }
        resource.state = .vertex(vertex: vertex, index: index, total: total, idle: .restoring)
    }
    
    private func handleResourceIdleRestored(_ resource: Resource) {
        guard case .vertex(let vertex, let index, let total, _) = resource.state else { return }
        resource.state = .vertex(vertex: vertex, index: index, total: total, idle: .rotation)
    }
    
    private func hideMenu(to: Vertex) {
        let menuLayer = adventure.layers[adventure.layers.count - 1]
        menuLayer.state = .ungrowing(exit: to)
        menuLayer.edges.forEach { $0.state = .ungrowing(phase: .preparing) }
    }
    
    private func showMenu(from: Vertex) {
        lifestate = .menu
        let menuLayer = IngameMenuService.menuLayer(from: from)
        from.state = .changingLayer(from: adventure.currentLayer, to: menuLayer, type: .presenting)
        let resources = playerResources(player)
        resources.forEach { $0.objectWillChange.sendOnMain() }
        adventure.currentLayer = menuLayer
        adventure.layers.append(menuLayer)
    }
    
    private func tryMove(player: Player, fromVertex: Vertex, toVertex: Vertex) {
        let sharedEdges = adventure.currentLayer.edgesBetween(v1: fromVertex, v2: toVertex)
        guard let edge = sharedEdges.first, edge.state.isGrowed else {
            return
        }
        
        let forward = edge.from == fromVertex
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
                
                res.state = .gate(gate: gate, edge: edge, fromVertex: fromVertex, fromIndex: index, state: .incoming, prestate: res.state)
            }
            
            if failIndex != nil { break }
        }
        
        if let failIndex = failIndex {
            let gate = edge.gates[failIndex]
            let direction: EdgeMovingDirection = forward ? .forwardFail(gate: gate, moveToGate: true) : .backwardFail(gate: gate, moveToGate: true)
            player.position = .edge(edge: edge, status: .compressing, direction: direction)
        } else {
            let direction: EdgeMovingDirection = forward ? .forward : .backward
            player.position = .edge(edge: edge, status: .compressing, direction: direction)
            
            if !edge.gates.isEmpty {
                reindexPlayerResources(player)
            }
        }
    }
    
    private func handleResourceMovedToGate(_ resource: Resource) {
        guard case .gate(let gate, let edge, let vertex, let index, let status, let prestate) = resource.state else { return }
        guard status == .incoming else { return }
        resource.state = .gate(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, state: .stay, prestate: prestate)
        gate.state = .open
    }
    
    private func checkLayerGrowingCompletion() {
        guard adventure.currentLayer.isInitialGrowingFinished() else {
            return
        }
        
        if adventure.currentLayer.type == .initial {
            handleInitGrowingCompletion()
        }
        adventure.currentLayer.state = .shown
    }
    
    private func checkLayerUngrowingCompletion() {
        guard case .ungrowing(let exit) = adventure.currentLayer.state else {
            return
        }
        
        let seedsDone = adventure.currentLayer.edges.allSatisfy {
            $0.state.isSeed
        }
        let verticesDone = adventure.currentLayer.vertices.allSatisfy {
            $0.state == .seed || $0 == exit
        }
        
        if seedsDone && verticesDone {
            var nextLayer: AdventureLayer? = nil
            if adventure.layers.count > 1 {
                let prelayer = adventure.layers[adventure.layers.count - 2]
                exit.state = .changingLayer(from: adventure.currentLayer, to: prelayer, type: .hiding)
                let resources = playerResources(player)
                resources.forEach { $0.objectWillChange.sendOnMain() }
                nextLayer = prelayer
            }
            adventure.currentLayer.state = .hiding(next: nextLayer)
        }
    }
    
    // MARK: Resources handling
    private func vertexResources(_ vertex: Vertex) -> [Resource] {
        resources.filter {
            guard case .vertex(let resVertex, _, _, _) = $0.state else { return false }
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
            guard case .gate(let resGate, _, _, _, _, _) = $0.state else { return false }
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
