//
//  AdventureViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import Foundation
import SwiftUI
import Combine

// TODO: Investigate possibility to change provide protocol to Combine concept (provider)
protocol ViewModelsProvider: AnyObject {
    func edgeViewModel(for edge: Edge) -> EdgeViewModel?
    func vertexViewModel(for vertex: Vertex) -> VertexViewModel?
}

final class AdventureViewModel: ObservableObject, ViewEventsSource, EngineEventsListener {
    
    private var subscriptions: [AnyCancellable] = []
    private var currentLayerSubscriptions: [AnyCancellable] = []
    let eventsPublisher: ViewEventsPublisher
    
    private var cameraService: CameraService
    
    var model: Adventure
    var player: PlayerViewModel
    @Published var layers: [AdventureLayerViewModel]
    @Published var resources: [ResourceViewModel]
    @Published var background: Color
    @Published var camera: CameraViewModel
    
    
    init(_ adventure: Adventure,
         cameraService: CameraService,
         player: Player,
         resources: [Resource],
         listener: ViewEventsListener?,
         eventsSource: EngineEventsSource?) {
        let schema = ColorSchema.schemaFor(adventure.theme)
        let publisher = ViewEventsPublisher()
        
        self.model = adventure
        self.player = PlayerViewModel(player: player,
                                      color: schema.player,
                                      movingColor: schema.edge)
        self.background = schema.background
        self.cameraService = cameraService
        self.eventsPublisher = publisher
        
        self.layers = adventure.layers.map {
            AdventureLayerViewModel(model: $0, schema: schema, eventsPublisher: publisher)
        }
        
        self.resources = resources.map {
            ResourceViewModel(model: $0, color: schema.resources, borderColor: schema.resourcesBorder)
        }
        
        // Camera setup
        let entrance = adventure.currentLayer.entrance
        let transState = cameraService.focusOnVertex(entrance)
        let initState = cameraService.forLayer(adventure.currentLayer, focusPoint: entrance.point)
        self.camera = CameraViewModel(state: transState)
        self.camera.transferTo(initState, animation: AnimationService.shared.adventureInitial)
        
        self.player.viewModelsProvider = self
        
        // Combine setup
        listener?.subscribeTo(eventsPublisher)
        if let source = eventsSource {
            subscribeTo(source.eventsPublisher)
        }
       
        self.resources.forEach { resource in
            resource.eventsPublisher = eventsPublisher
        }
        
        subscriptions.sink(camera.objectWillChange) { [weak self] in
            self?.objectWillChange.sendOnMain()
        }
        subscriptions.sink(adventure.$layers) { [weak self] updatedLayers in
            self?.handleLayersUpdate(updatedLayers)
        }
        subscriptions.sink(adventure.$currentLayer) { [weak self] layer in
            self?.handleCurrentLayerChange(layer)
        }
    }
    
    func layerResources(_ layer: AdventureLayerViewModel) -> [ResourceViewModel] {
        resources.filter {
            switch $0.state {
            case .gate(_, let edge, _, _, _, _):
                return layer.edges.contains { $0.model == edge }
            case .vertex(let vertex, _, _, _):
                return layer.vertices.contains { $0.model == vertex }
            case .inventory(let player, _, _, _, _):
                // TODO: Following check for current layer was necessary to handle situation when some vertex represents in few layers. If vertex-sharing solution will be moved out from project, this check should be removed
                let onLayer = player.isOnLayer(layer.model)
                let onCurrent = player.isOnLayer(model.currentLayer)
                let layerIsCurrent = layer.model == model.currentLayer
                return onLayer && (!onCurrent || layerIsCurrent)
            case .destroying(let from, _, _, _):
                return layer.vertices.contains { $0.model == from }
            case .none:
                 return false
            }
        }
    }
    
    private func handleCurrentLayerChange(_ layer: AdventureLayer) {
        currentLayerSubscriptions.removeAll()
        currentLayerSubscriptions.sink(layer.$state) { [weak self] state in
            self?.handleLayer(layer, newState: state)
        }
    }
    
    private func handleLayer(_ layer: AdventureLayer, newState state: AdventureLayerState) {
        let lifestate = GameEngine.shared.adventureEngine?.lifestate
        guard state != .preparing else { return }
        guard lifestate != .initializing && lifestate != .finalizing else { return }
        
        var targetLayer: AdventureLayer? = layer
        if case .hiding(let nextLayer) = state {
            targetLayer = nextLayer
        }
        
        let focus = player.position.currentVertex ?? layer.entrance
        var cameraState = CameraState.default
        if let targetLayer = targetLayer {
            cameraState = cameraService.forLayer(targetLayer, focusPoint: focus.point)
        }
        
        let animation = cameraAnimation(layerState: state)
        DispatchQueue.main.async {
            self.camera.transferTo(cameraState, animation: animation)
        }
    }
    
    private func cameraAnimation(layerState: AdventureLayerState) -> Animation {
        switch layerState {
        case .presenting:
            return AnimationService.shared.presentLayer
        case .hiding:
            return AnimationService.shared.hideLayer
        default:
            return .none
        }
    }
    
    private func handleLayersUpdate(_ updatedModels: [AdventureLayer]) {
        var newViews: [AdventureLayerViewModel] = []
        for model in updatedModels {
            let existView = layers.first{ $0.model == model }
            if let existView = existView {
                newViews.append(existView)
            } else {
                let schema = ColorSchema.schemaFor(self.model.theme)
                let newView = AdventureLayerViewModel(model: model, schema: schema, eventsPublisher: eventsPublisher)
                newViews.append(newView)
            }
        }
        
        DispatchQueue.main.async {
            self.layers = newViews
        }
    }
    
    // TODO: Remove engine to view publisher system if still be unused
    func subscribeTo(_ publisher: EngineEventsPublisher) {
        subscriptions.sink(publisher) { [self] event in
            handleEngineEvent(event)
        }
    }
    
    // TODO: May be removed if still be unused
    // MARK: Engine events handler
    private func handleEngineEvent(_ event: EngineEvent) {
        switch event {
        case .resourceAdded(let resource):
            handleResourceAdding(resource)
        case .resourceRemoved(let resource):
            handleResourceRemoving(resource)
        case .adventureFinalizing(let exit):
            handleAdventureFinalizing(exit: exit)
        }
    }
    
    private func handleResourceAdding(_ resource: Resource) {
        let schema = ColorSchema.schemaFor(model.theme)
        let emptyView = resources.first { $0.isEmpty }
        if let emptyView = emptyView {
            emptyView.attachModel(resource, color: schema.resources, borderColor: schema.resourcesBorder)
        } else {
            let view = ResourceViewModel(model: resource, color: schema.resources, borderColor: schema.resourcesBorder)
            view.eventsPublisher = eventsPublisher
            resources.append(view)
        }
    }
    
    private func handleResourceRemoving(_ resource: Resource) {
        let viewModel = resources.first { $0.model == resource }
        viewModel?.detachModel()
    }
    
    private func handleAdventureFinalizing(exit: Vertex) {
        let cameraState = cameraService.focusOnVertex(exit)
//        let eyeStatus = EyeStatus.transiotion(from: .opened, to: .compressed)
        DispatchQueue.main.async {
            self.camera.transferTo(cameraState, animation: AnimationService.shared.adventureFinal)
            self.player.eye.compress()
        }
    }
}

extension AdventureViewModel: ViewModelsProvider {
    func edgeViewModel(for edge: Edge) -> EdgeViewModel? {
        let edges = layers.flatMap { $0.edges }
        return edges.first { $0.model == edge }
    }
    
    func vertexViewModel(for vertex: Vertex) -> VertexViewModel? {
        let vertices = layers.flatMap { $0.vertices }
        return vertices.first { $0.model == vertex }
    }
}

// MARK: View interaction methods
extension AdventureViewModel {
    func viewInitCompleted() {
        eventsPublisher.send(.viewInitFinished)
    }
}
