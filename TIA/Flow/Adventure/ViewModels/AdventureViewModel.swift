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
    private var layerSubscriptions: [AnyCancellable] = []
    let eventsPublisher: ViewEventsPublisher
    
    private var cameraService: CameraService
    
    var model: Adventure
    var player: PlayerViewModel
    @Published var layers: [AdventureLayerViewModel]
    @Published var resources: [ResourceViewModel]
    @Published var background: Color
    @Published var camera: CameraStatus
    
    
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
        self.camera = cameraService.initial(adventure: adventure)
        self.eventsPublisher = publisher
        
        self.layers = adventure.layers.map {
            AdventureLayerViewModel(model: $0, schema: schema, eventsPublisher: publisher)
        }
        
        self.resources = resources.map {
            ResourceViewModel(model: $0, color: schema.resources, borderColor: schema.resourcesBorder)
        }
        
        self.player.viewModelsProvider = self
        
        // Combine setup
        listener?.subscribeTo(eventsPublisher)
        if let source = eventsSource {
            subscribeTo(source.eventsPublisher)
        }
       
        self.resources.forEach { resource in
            resource.eventsPublisher = eventsPublisher
            self.subscriptions.sink(resource.model.$state) { [weak self] newState in
                self?.resource(resource, willChangeState: newState)
            }
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
            case .deletion:
                return false
            }
        }
    }
    
    private func resource(_ resource: ResourceViewModel, willChangeState state: ResourceState) {
        switch state {
            // TODO: Use engine events publisher insted this additional resource state
        case .deletion:
            resources.remove(resource)
        default:
            break
        }
    }
    
    private func handleCurrentLayerChange(_ layer: AdventureLayer) {
        layerSubscriptions.removeAll()
        layerSubscriptions.sink(layer.$state) { [weak self] state in
            self?.handleLayer(layer, newState: state)
        }
    }
    
    private func handleLayer(_ layer: AdventureLayer, newState state: AdventureLayerState) {
        guard state != .preparing else { return }
        
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
        camera = .transition(to: cameraState, animation: animation)
    }
    
    private func cameraAnimation(layerState: AdventureLayerState) -> Animation? {
        switch layerState {
        case .presenting:
            return AnimationService.shared.presentLayer
        case .hiding:
            return AnimationService.shared.hidingLayer
        default:
            return nil
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
        
        layers = newViews
    }
    
    // TODO: Remove engine to view publisher system if still be unused
    func subscribeTo(_ publisher: EngineEventsPublisher) {
//        subscriptions.sink(publisher) {
//            [self] event in
//            handleEngineEvent(event)
//        }
    }
    
    // TODO: May be removed if still be unused
    // MARK: Engine events handler
    private func handleEngineEvent(_ event: EngineEvent) {
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
