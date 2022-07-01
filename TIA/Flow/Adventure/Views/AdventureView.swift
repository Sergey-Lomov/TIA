//
//  AdventureView.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import SwiftUI
import Combine

struct AdventureView: View {
    
    private let blurStep = 15.0

    @StateObject var adventure: AdventureViewModel
    
    var body: some View {
        CenteredGeometryReader {
            adventure.background
                .edgesIgnoringSafeArea(.all)

            ZStack {
                ForEach(adventure.layers, id:\.id) { layer in
                    let blur = blur(layer)
                    let resources = adventure.layerResources(layer)
                    LayerContentView(layer: layer, resources: resources)
                        .onAppear {
                            handleLayerAppear(layer)
                        }
                        .blur(radius: blur)
                        .animation(animation(layer), value: blur)
                    
                    
                }.applyCamera(adventure.camera) {
                    handleCameraCompletion()
                }
                
                PlayerWrapperView(player: adventure.player)
                    .applyCamera(adventure.camera)
            }
        }
        .onAppear {
            adventure.viewInitCompleted()
        }
    }
    
    private func blur(_ layer: AdventureLayerViewModel) -> CGFloat {
        let index = adventure.layers.firstIndex(of: layer) ?? 0
        let deep = adventure.layers.count - index - 1
        return CGFloat(deep) * blurStep
    }
    
    private func animation(_ layer: AdventureLayerViewModel) -> Animation {
        switch layer.state {
        case .presenting: return AnimationService.shared.presentLayer
        case .hiding: return AnimationService.shared.hideLayer
        default: return .none
        }
    }
    
    private func handleLayerAppear(_ layer: AdventureLayerViewModel) {
        if layer.state == .preparing {
            layer.layerPrepared()
        }
    }

    private func handleCameraCompletion() {
        let currentLayer = adventure.layers.first { $0.id == adventure.model.currentLayer.id }
        guard let layer = currentLayer else { return }
        switch layer.state {
        case .presenting:
            layer.layerPresented()
        case .hiding:
            layer.layerWasHidden()
        default:
            break
        }
    }
}

struct LayerContentView: View {
    
    @ObservedObject var layer: AdventureLayerViewModel
    var resources: [ResourceViewModel]
    
    var body: some View {
        ZStack {
            ForEach(layer.edges, id:\.model.id) { edge in
                EdgeWrapper(edge: edge)
            }

            ForEach(layer.vertices, id:\.model.id) { vertex in
                VertexWrapper(vertex: vertex)
            }
            
            ForEach(resources, id:\.id) { resource in
                ResourceWrapper(resource: resource, layer: layer.model)
            }
        }
        .opacity(opacity)
        .animation(AnimationService.shared.hideLayer, value: opacity)
    }
    
    private var opacity: CGFloat {
        switch layer.state {
        case .hiding(let next):
            return next == nil ? 0: 1
        default:
            return 1
        }
    }
}
