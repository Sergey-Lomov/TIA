//
//  AdventureView.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import SwiftUI
import Combine

struct AdventureView: View {

    @StateObject var adventure: AdventureViewModel

    var body: some View {
        CenteredGeometryReader {
            adventure.background
                .edgesIgnoringSafeArea(.all)

            ZStack {
                ForEach(adventure.layers, id: \.id) { layer in
                    AdventureLayerBackground(layer: layer, theme: adventure.model.theme)
                        .edgesIgnoringSafeArea(.all)

                    ZStack {
                        LayerContentView(layer: layer)
                            .onAppear {
                                handleLayerAppear(layer)
                            }

                        let isCurrent = layer.id == adventure.model.currentLayer.id
                        if isCurrent {
                            PlayerWrapperView(player: adventure.player)
                        }

                        let resources = adventure.layerResources(layer)
                        ForEach(resources, id: \.id) { resource in
                            ResourceWrapper(resource: resource, layer: layer.model)
                        }
                    }.applyCamera(adventure.camera)
                }
            }
        }
        .onAppear {
            adventure.viewInitCompleted()
        }
    }

    private func handleLayerAppear(_ layer: AdventureLayerViewModel) {
        if layer.state == .preparing {
            layer.layerPrepared()
        }
    }
}

struct LayerContentView: View {

    @ObservedObject var layer: AdventureLayerViewModel

    var body: some View {
        ZStack {
            ForEach(layer.edges, id: \.model.id) { edge in
                EdgeWrapper(edge: edge)
            }

            ForEach(layer.vertices, id: \.model.id) { vertex in
                VertexWrapper(vertex: vertex)
            }
        }
        .opacity(opacity)
        .animation(AnimationService.hideLayer, value: opacity)
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
