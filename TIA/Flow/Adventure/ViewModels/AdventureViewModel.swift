//
//  AdventureViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import Foundation
import SwiftUI
import Combine

protocol ViewModelsProvider: AnyObject {
    func edgeViewModel(for edge: Edge) -> EdgeViewModel?
    func vertexViewModel(for vertex: Vertex) -> VertexViewModel?
}

final class AdventureViewModel: ObservableObject, ViewEventsSource, EngineEventsListener {

    private let minZoom: CGFloat = 0.2
    private let maxZoom: CGFloat = 5

    private var subscriptions: [AnyCancellable] = []
    private var currentLayerSubscriptions: [AnyCancellable] = []
    let eventsPublisher: ViewEventsPublisher

    private var cameraService: CameraService
    @Transpublished var camera: CameraViewModel
    private var prechangeCamera: CameraState?

    var model: Adventure
    var player: PlayerViewModel
    @Published var layers: [AdventureLayerViewModel]
    @Published var resources: [ResourceViewModel]
    @Published var background: Color

    init(_ adventure: Adventure,
         cameraService: CameraService,
         player: Player,
         resources: [Resource],
         listener: ViewEventsListener?,
         eventsSource: EngineEventsSource?,
         cameraPublisher: CameraControlPublisher? = nil) {
        let palette = ColorPalette.paletteFor(adventure.theme)
        let publisher = ViewEventsPublisher()

        self.model = adventure
        self.player = PlayerViewModel(player: player,
                                      eventsPublisher: publisher,
                                      color: palette.player,
                                      movingColor: palette.edge)
        self.background = palette.background
        self.cameraService = cameraService
        self.eventsPublisher = publisher

        self.layers = adventure.layers.map {
            AdventureLayerViewModel(model: $0, palette: palette, eventsPublisher: publisher)
        }

        self.resources = resources.map {
            ResourceViewModel(model: $0, color: palette.resources, borderColor: palette.borders)
        }

        // Camera setup
        let entrance = adventure.currentLayer.entrance
        let transState = cameraService.focusOnVertex(entrance)
        let initState = cameraService.forLayer(adventure.currentLayer, focusPoint: entrance.point)
        self.camera = CameraViewModel(state: transState)
        self.camera.transferTo(initState, animation: AnimationService.adventureInitial)

        self._camera.publisher = objectWillChange
        self.player.viewModelsProvider = self

        // Combine setup
        listener?.subscribeTo(eventsPublisher)
        if let source = eventsSource {
            subscribeTo(source.eventsPublisher)
        }

        self.resources.forEach { resource in
            resource.eventsPublisher = eventsPublisher
        }

        subscriptions.sink(adventure.$layers) { [weak self] updatedLayers in
            self?.handleLayersUpdate(updatedLayers)
        }
        subscriptions.sink(adventure.$currentLayer) { [weak self] layer in
            self?.handleCurrentLayerChange(layer)
        }

        if let cameraPublisher = cameraPublisher {
            subscriptions.sink(cameraPublisher) { [weak self] event in
                self?.camera.handleControlEvent(event)
            }
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
                // Following check for current layer was necessary to handle situation when some vertex represents in few layers.
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
            self?.handleCurrentLayer(layer, newState: state)
        }
    }

    private func handleCurrentLayer(_ layer: AdventureLayer, newState state: AdventureLayerState) {
        guard state != .preparing else { return }
        guard model.state != .initializing && model.state != .finalizing else { return }

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
            return AnimationService.presentLayer
        case .hiding:
            return AnimationService.hideLayer
        default:
            return .none
        }
    }

    private func handleLayersUpdate(_ updatedModels: [AdventureLayer]) {
        var newViews: [AdventureLayerViewModel] = []
        for model in updatedModels {
            let existView = layers.first { $0.model == model }
            if let existView = existView {
                newViews.append(existView)
            } else {
                let palette = ColorPalette.paletteFor(self.model.theme)
                let newView = AdventureLayerViewModel(model: model, palette: palette, eventsPublisher: eventsPublisher)
                newViews.append(newView)
            }
        }

        DispatchQueue.main.async {
            self.layers = newViews
        }
    }

    // MARK: Engine events handler
    func subscribeTo(_ publisher: EngineEventsPublisher) {
        subscriptions.sink(publisher) { [self] event in
            handleEngineEvent(event)
        }
    }

    private func handleEngineEvent(_ event: EngineEvent) {
        switch event {
        case .resourceAdded(let resource):
            handleResourceAdding(resource)
        case .resourceRemoved(let resource):
            handleResourceRemoving(resource)
        case .adventureFinalizing(let exit):
            handleAdventureFinalizing(exit: exit)
        case .adventureFinalized:
            break
        }
    }

    private func handleResourceAdding(_ resource: Resource) {
        let palette = ColorPalette.paletteFor(model.theme)
        let emptyView = resources.first { $0.isEmpty }
        if let emptyView = emptyView {
            emptyView.attachModel(resource, color: palette.resources, borderColor: palette.borders)
        } else {
            let view = ResourceViewModel(model: resource, color: palette.resources, borderColor: palette.borders)
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
        DispatchQueue.main.async {
            self.camera.transferTo(cameraState, animation: AnimationService.adventureFinal)
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

    func cameraDragged(_ translation: CGPoint) {
        guard !camera.transferInProgress else { return }
        camera.manuallyControlled = true
        let initState = prechangeCamera ?? camera.state
        camera.state = initState.translated(translation)
        prechangeCamera = initState
    }

    func cameraDraggingFinished(_ translation: CGPoint) {
        guard let initState = prechangeCamera else { return }
        prechangeCamera = nil
        camera.state = initState.translated(translation)
        camera.manuallyControlled = false
    }

    func cameraMagnified(_ scale: CGFloat) {
        guard !camera.transferInProgress else { return }
        camera.manuallyControlled = true
        prechangeCamera = prechangeCamera ?? camera.state
        applyCameraZooming(scale)
    }

    func cameraMagnificationFinished(_ scale: CGFloat) {
        applyCameraZooming(scale)
        prechangeCamera = nil
        camera.manuallyControlled = false
    }

    private func applyCameraZooming(_ scale: CGFloat) {
        guard let initState = prechangeCamera else { return }
        let zoomed = initState.zoomed(scale)
        camera.state = zoomed.zoomNormalized(minZoom, maxZoom)
    }
}
