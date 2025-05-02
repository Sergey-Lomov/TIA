//
//  AdventureEngine.swift
//  TIA
//
//  Created by Serhii.Lomov on 15.04.2022.
//

// swiftlint:disable file_length

import Foundation
import Combine

protocol AdventureLayoutProvider {
    func getLayout(_ adventure: AdventurePrototype) -> AdventureLayout
}

// swiftlint:disable type_body_length
final class AdventureEngine: EngineEventsSource {

    private static let menuVertexId = "menu_vertex"
    private static let menuEdgeId = "menu_edge"

    var subscriptions: [AnyCancellable] = []
    var eventsPublisher = EngineEventsPublisher()
    var prototype: AdventurePrototype
    var layoutProvider: AdventureLayoutProvider

    var adventure: Adventure
    var player: Player
    var resources: [Resource]
    var menuItems: [IngameMenuItem]

    var layers: [AdventureLayer] { adventure.layers }
    var currentLayer: AdventureLayer { adventure.currentLayer }
    var state: AdventureState { adventure.state }

    init(prototype: AdventurePrototype, layoutProvider: AdventureLayoutProvider, menuItems: [IngameMenuItem]) {
        let layout = layoutProvider.getLayout(prototype)
        self.adventure = AdventureService.adventureFor(prototype, layout: layout)
        self.player = Player(position: .abscent)
        self.prototype = prototype
        self.layoutProvider = layoutProvider
        self.menuItems = menuItems
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
        subscriptions.sink(publisher) { [weak self] event in
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
            eventsPublisher.send(.resourceAdded(resource: resource))
        }

        subscriptions.sink(vertex.$state) { [weak self] in
            self?.handleVertexStateUpdate(vertex)
        }
    }

    private func growVertex(_ vertex: Vertex) {
        layers.allContain(vertex).forEach {
            CacheService.shared.invalidate(type: .layerCamera($0))
        }

        switch vertex.state {
        case .seed:
            vertex.state = .growing
        default:
            break
        }
    }

    private func growFromVertex(_ vertex: Vertex) {
        for edge in currentLayer.outcome(vertex) {
            switch edge.state {
            case .seed:
                growEdge(edge)
            default:
                break
            }
        }

        let waitingEdges = currentLayer.income(vertex).filter {
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
        layers.allContain(edge).forEach {
            CacheService.shared.invalidate(type: .layerCamera($0))
            CacheService.shared.invalidate(type: .surrounding(edge.from, $0))
            CacheService.shared.invalidate(type: .surrounding(edge.to, $0))
        }
        edge.state = .growing(phase: .preparing)
    }

    private func handleVertexStateUpdate(_ vertex: Vertex) {
        vertexResources(vertex).forEach {
            $0.objectWillChange.sendOnMain()
        }
    }

    private func handlePlayerPositionUpdate(_ newValue: PlayerPosition) {
        playerResources(player).forEach { resource in
            resource.objectWillChange.sendOnMain()
        }

        switch newValue {
        case .abscent:
            break
        case .vertex(let vertex):
            let visit = VertexVisit(visitor: player, phase: .onVertex)
            vertex.updateVisitInfo(visit)
            incomeToAction(vertex.onVisit, at: vertex)
        case .edge(let edge, let status, let direction):
            switch status {
            case .compressing:
                unfreshPlayerResources(player)
                let startVertex = direction.startVertex(edge)
                let endVertex = direction.endVertex(edge)
                let visit = VertexVisit(visitor: player, phase: .outcome)
                startVertex.updateVisitInfo(visit)
                startCompressing(atVertex: startVertex, targetAction: endVertex.onVisit)
            case .moving:
                let endVertex = direction.endVertex(edge)
                addPlayerResources(vertexResources(endVertex))
                let endVisit = VertexVisit(visitor: player, phase: .income(edge: edge))
                endVertex.updateVisitInfo(endVisit)
                direction.startVertex(edge).updateVisitInfo(nil)
                startMovingToAction(endVertex.onVisit)
            case .expanding:
                applyEstimated(playerResources(player))
                recloseGates(edge: edge)
            }
        }
    }

    private func handleGateStateUpdate(_ gate: EdgeGate) {
        gateResources(gate).forEach { $0.objectWillChange.sendOnMain() }
    }

    private func recloseGates(edge: Edge) {
        let wipeResources = edge.gates.allSatisfy { $0.state == .open }
        for gate in edge.gates {
            gate.state = .close
            if wipeResources {
                removeResources(gateResources(gate))
            }
        }
    }

    private func hideMenu(to: Vertex) {
        let menuLayer = layers[layers.count - 1]
        startUngrowing(menuLayer, exit: to)
    }

    private func showMenu(from: Vertex) {
        guard case .active = from.state else { return }

        adventure.state = .menu
        let menuLayer = IngameMenuService.menuLayer(from: from, theme: adventure.theme, items: menuItems)
        startLayerPresenting(menuLayer, from: from)
    }

    private func tryMove(player: Player, fromVertex: Vertex, toVertex: Vertex) {
        let sharedEdges = currentLayer.edgesBetween(v1: fromVertex, v2: toVertex)
        guard let edge = sharedEdges.first, edge.state.isGrowed else {
            return
        }

        let forward = edge.from == fromVertex
        let count = edge.gates.count
        let range = forward ? Array(0..<count) : (0..<count).reversed()
        let fromVertex = forward ? edge.from : edge.to

        var failIndex: Int?
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

    // MARK: Vertices actions handling
    private func startCompressing(atVertex vertex: Vertex, targetAction action: VertexAction?) {
        switch action {
        case .restart, .exit, .completeAdventure:
            releasePlayerResources(player)
        default:
            break
        }
    }

    private func startMovingToAction(_ action: VertexAction?) {
        switch action {
        case .restart, .exit:
            let layers = layers.filter { $0.type != .menu }
            layers.forEach { startUngrowing($0, exit: nil) }
        case .completeAdventure:
            let layers = layers.filter { $0 != currentLayer }
            layers.forEach { startUngrowing($0, exit: nil) }
        case .none:
            break
        }
    }

    private func incomeToAction(_ action: VertexAction?, at vertex: Vertex) {
        switch action {
        case .restart:
            restartAdventure(vertex)
        case .exit:
            exitFromAdventure(vertex)
        case .completeAdventure:
            completeAdventure(vertex)
        case .none:
            break
        }
    }

    private func restartAdventure(_ vertex: Vertex) {
        let layout = layoutProvider.getLayout(prototype)
        let layer = AdventureService.layerFor(prototype, layout: layout, forcedEntrance: vertex)
        layer.state = .preparing
        startLayerPresenting(layer, from: vertex)
        adventure.state = .gameplay
    }

    private func exitFromAdventure(_ vertex: Vertex) {
        let menuLayer = layers.first { $0.type == .menu }
        guard let menuLayer = menuLayer else { return }
        adventure.state = .finalizing
        eventsPublisher.send(.adventureFinalizing(exit: vertex))
        startUngrowing(menuLayer, exit: vertex)
    }

    private func completeAdventure(_ vertex: Vertex) {
        layers.forEach {
            let exit = $0.contains(vertex) ? vertex : nil
            startUngrowing($0, exit: exit)
        }
        adventure.state = .finalizing
        eventsPublisher.send(.adventureFinalizing(exit: vertex))
    }

    // MARK: Layers handling
    private func appendLayer(_ layer: AdventureLayer) {
        layer.vertices.forEach { vertex in
            let isNew = layers.allSatisfy { !$0.contains(vertex) }
            if isNew {
                handleNewVertex(vertex)
            }
        }
        adventure.layers.append(layer)
    }

    private func removeLayer(_ layer: AdventureLayer) {
        adventure.layers.remove(layer)
        resources.forEach { resource in
            guard case .vertex(let vertex, _, _, _) = resource.state else { return }
            let hasOwner = layers.contains { $0.contains(vertex) }
            if !hasOwner { resources.remove(resource) }
        }
    }

    private func checkLayerGrowingCompletion() {
        guard currentLayer.isInitialGrowingFinished() else {
            return
        }

        if currentLayer.type == .initial {
            handleInitGrowingCompletion()
        }
        currentLayer.state = .shown
    }

    private func checkLayerUngrowingCompletion(_ layer: AdventureLayer) {
        guard case .ungrowing(let exit) = layer.state else { return }

        let seedsDone = layer.edges.allSatisfy {
            if case .seed = $0.state {
                return true
            } else {
                return false
            }
        }

        let verticesDone = layer.vertices.allSatisfy {
            $0.state == .seed || $0 == exit
        }

        if seedsDone && verticesDone {
            handleLayerUngrowedCompleted(layer)
        }
    }

    private func handleLayerUngrowedCompleted(_ layer: AdventureLayer) {
        if state == .finalizing {
            let done = player.position.currentVertex?.onVisit == .completeAdventure
            eventsPublisher.send(.adventureFinalized(adventure, isDone: done))
        } else if layer == currentLayer {
            hideCurrentLayer()
        } else {
            layer.state = .hiding(next: nil)
        }
    }

    private func startLayerPresenting(_ layer: AdventureLayer, from: Vertex) {
        guard case .active(let visit, _) = from.state else { return }
        let transfer = VertexLayerTransfer(from: currentLayer, to: layer, type: .presenting)
        from.state = .active(visit: visit, layerTransfer: transfer)
        let resources = playerResources(player)
        resources.forEach { $0.objectWillChange.sendOnMain() }
        adventure.currentLayer = layer
        appendLayer(layer)
    }

    private func hideCurrentLayer() {
        guard case .ungrowing(let exit) = currentLayer.state,
            let exit = exit else { return }

        var nextLayer: AdventureLayer?
        if layers.count > 1 {
            guard case .active(let visit, _) = exit.state else { return }
            let prelayer = layers[layers.count - 2]
            let transfer = VertexLayerTransfer(from: currentLayer, to: prelayer, type: .hiding)
            exit.state = .active(visit: visit, layerTransfer: transfer)
            let resources = playerResources(player)
            resources.forEach { $0.objectWillChange.sendOnMain() }
            nextLayer = prelayer
        }
        currentLayer.state = .hiding(next: nextLayer)
    }

    private func startUngrowing(_ layer: AdventureLayer, exit: Vertex?) {
        layer.state = .ungrowing(exit: exit)
        layer.edges.forEach { $0.state = .ungrowing(phase: .preparing) }
    }

    // MARK: Resources handling
    private func vertexResources(_ vertex: Vertex) -> [Resource] {
        resources.filter {
            guard case .vertex(let resVertex, _, _, _) = $0.state else { return false }
            return resVertex == vertex
        }
    }

    private func playerResources(_ player: Player) -> [Resource] {
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
            $0.state = .inventory(player: player, index: index, estimatedIndex: estimated, total: total, isFresh: isFresh)
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

    private func removeResources(_ removingResources: [Resource]) {
        removingResources.forEach {
            eventsPublisher.send(.resourceRemoved(resource: $0))
        }
        resources.removeAll { removingResources.contains($0) }
    }

    private func releasePlayerResources(_ player: Player) {
        var vertex: Vertex = currentLayer.entrance
        switch player.position {
        case .abscent:
            break
        case .edge(let edge, _, let direction):
            vertex = direction.endVertex(edge)
        case .vertex(let positionVertex):
            vertex = positionVertex
        }

        playerResources(player).forEach {
            guard case .inventory(_, let index, _, let total, _) = $0.state else { return }
            $0.state = .destroying(from: vertex, index: index, total: total, state: .preparing)
        }
    }
}

private extension EdgeState {
    var blocksToUngrowing: Bool {
        switch self {
        case .seed:
            return false
        case .ungrowing(let phase):
            switch phase {
            case .preparing, .elementsUngrowing:
                return true
            case .pathUngrowing:
                return false
            }
        default:
            return true
        }
    }

    var blocksFromUngrowing: Bool {
        switch self {
        case .seed:
            return false
        default:
            return true
        }
    }
}

// MARK: View events handling
extension AdventureEngine: ViewEventsListener {

    // swiftlint:disable function_body_length
    private func handleViewEvent(_ event: IngameViewEvent) {
        switch event {
        case .viewInitFinished:
            growFromVertex(currentLayer.entrance)

        case .playerCompressed(let player):
            player.compressingFinished()
        case .playerExpanded(let player):
            handlePlayerExpanded(player)

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
        case .vertexMoved(let vertex, let position, let finished):
            handleVertexMoved(vertex, position: position, finished: finished)

        case .edgeSeedExtensionPrepared(let edge):
            edge.state = .seed(phase: .extended)
        case .edgeGrowingPrepared(let edge):
            edge.state = .growing(phase: .pathGrowing)
        case .edgePathGrowed(let edge):
            handleEdgePathGrowed(edge)
        case .edgeElementsPrepared(let edge):
            edge.state = .growing(phase: .elementsGrowing)
        case .edgeElementsGrowed(let edge):
            handleEdgeCounterConnectorGrowed(edge)
        case .edgeUngrowingPrepared(let edge):
            handleEdgeUngrowingPrepared(edge)
        case .edgeElementsUngrowed(let edge):
            handleEdgeElementsUngrowed(edge)
        case .edgeUngrowed(let edge):
            handleEdgeUngrowed(edge)
        case .edgeControlChanged(let edge, let point, let newValue, let finished):
            handleEdgeControlChanged(edge: edge, point: point, newValue: newValue, finished: finished)

        case .gateClosed(let gate):
            handleGateClosed(gate)

        case .resourceMovedToGate(let resource):
            handleResourceMovedToGate(resource)
        case .resourcePresented(let resource):
            handleResourcePresented(resource)
        case .resourceIdleFinished(let resource):
            handleResourceFinishIdle(resource)
        case .resourceIdleRestored(let resource):
            handleResourceIdleRestored(resource)
        case .resourceDestroyingPrepared(let resource):
            handleResourceDestroingPrepared(resource)
        case .resourceDestroyed(let resource):
            handleResourceDestroyed(resource)
        }
    }
    // swiftlint:enable function_body_length

    private func handleInitGrowingCompletion() {
        let entrance = currentLayer.entrance
        player.position = .vertex(vertex: entrance)
    }

    private func handlePlayerExpanded(_ player: Player) {
        player.expandingFinished()
        if player == self.player && state == .initializing {
            adventure.state = .gameplay
        }
    }

    private func handleLayerPresented(_ layer: AdventureLayer) {
        layer.state = .growing
        let visit = VertexVisit(visitor: player, phase: .onVertex)
        layer.entrance.state = .active(visit: visit)
        growFromVertex(layer.entrance)

        // Hide menu after restart
        if layer.type == .initial {
            let menuLayers = layers.filter { $0.type == .menu }
            menuLayers.forEach { startUngrowing($0, exit: layer.entrance) }
        }
    }

    private func handleLayerWasHidden(_ layer: AdventureLayer) {
        guard case .hiding(let next) = layer.state else { return }
        if layer.type == .menu {
            adventure.state = .gameplay
        }
        if let next = next {
            adventure.currentLayer = next
        }
        removeLayer(layer)
    }

    private func handleVertexGrowed(_ vertex: Vertex) {
        vertex.state = .active()
        growFromVertex(vertex)
        checkLayerGrowingCompletion()
    }

    private func handleVertexUngrowed(_ vertex: Vertex) {
        vertex.state = .seed
        layers.allContain(vertex).forEach { checkLayerUngrowingCompletion($0) }
    }

    private func handleVertexSelection(_ newVertex: Vertex) {
        guard state == .gameplay || state == .menu else { return }
        guard case .vertex(let oldVertex) = player.position else { return }
        guard case .shown = currentLayer.state else { return }

        if oldVertex == newVertex {
            switch state {
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

    private func handleVertexMoved(_ vertex: Vertex, position: CGPoint, finished: Bool) {
        // TODO: Add connectors cache clearing. For this purpose should be added new way to invalidate cash by some keys/ids. Connectors cache should be cleared event if finished is false.

        vertex.point = position
        layers.allContain(vertex).forEach { layer in
            layer.outcome(vertex).forEach {
                $0.curve.p0 = position
                $0.objectWillChange.sendOnMain()
            }
            layer.income(vertex).forEach {
                $0.curve.p3 = position
                $0.objectWillChange.sendOnMain()
            }
        }

        vertexResources(vertex).forEach {
            $0.objectWillChange.sendOnMain()
        }

        if player.position.currentVertex == vertex {
            player.objectWillChange.sendOnMain()
            let resources = playerResources(player)
            resources.forEach { $0.objectWillChange.sendOnMain() }
        }

        guard finished else { return }

        let layers = layers.allContain(vertex)
        layers.forEach {
            CacheService.shared.invalidate(type: .surrounding(vertex, $0))
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
        edge.state = .ungrowing(phase: .elementsUngrowing)
    }

    private func handleEdgeElementsUngrowed(_ edge: Edge) {
        edge.state = .ungrowing(phase: .pathUngrowing)
        startUngrowingIfReady(edge.to)
    }

    private func handleEdgeUngrowed(_ edge: Edge) {
        edge.state = .seed(phase: .compressed)
        startUngrowingIfReady(edge.from)
        layers.allContain(edge).forEach { checkLayerUngrowingCompletion($0) }
    }

    private func handleEdgeControlChanged(edge: Edge, point: ControlPoint, newValue: CGPoint, finished: Bool) {
        // TODO: Add connectors cache clearing. For this purpose should be added new way to invalidate cash by some keys/ids. Connectors cache should be cleared event if finished is false.
        edge.curve.setPoint(point, newValue: newValue)
        edge.objectWillChange.sendOnMain()

        guard finished else { return }

        let layers = layers.allContain(edge)
        layers.forEach {
            CacheService.shared.invalidate(type: .surrounding(edge.from, $0))
            CacheService.shared.invalidate(type: .surrounding(edge.to, $0))
        }

        let playerVertex = player.position.currentVertex
        if playerVertex == edge.from || playerVertex == edge.to {
            let resources = playerResources(player)
            resources.forEach { $0.objectWillChange.sendOnMain() }
        }
    }

    private func handleGateClosed(_ gate: EdgeGate) {
        gateResources(gate).forEach {
            guard case .gate(let gate, let edge, let vertex, let index, _, let prestate) = $0.state else { return }
            $0.state = .gate(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, state: .outcoming, prestate: prestate)
        }
    }

    private func startUngrowingIfReady(_ vertex: Vertex) {
        let notExit = layers.allContain(vertex).allSatisfy {
            guard case .ungrowing(let exit) = $0.state else { return true }
            return exit != vertex
        }
        guard notExit else { return }

        let edgeBlockVertex: (Edge) -> Bool = { edge in
            if edge.to == vertex { return edge.state.blocksToUngrowing }
            if edge.from == vertex { return edge.state.blocksFromUngrowing }
            return false
        }

        let edges = layers.flatMap { $0.edges(of: vertex) }
        let readyToUngrowing = edges.allSatisfy { !edgeBlockVertex($0) }
        if readyToUngrowing && vertex.state.isGrowed {
            vertex.state = .ungrowing
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

    private func handleResourceMovedToGate(_ resource: Resource) {
        guard case .gate(let gate, let edge, let vertex, let index, let status, let prestate) = resource.state else { return }
        guard status == .incoming else { return }
        resource.state = .gate(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, state: .stay, prestate: prestate)
        gate.state = .open
    }

    private func handleResourceDestroingPrepared(_ resource: Resource) {
        guard case .destroying(let from, let index, let total, _) = resource.state else { return }
        resource.state = .destroying(from: from, index: index, total: total, state: .moving)
    }

    private func handleResourceDestroyed(_ resource: Resource) {
        removeResources([resource])
    }
}
