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
                ForEach(adventure.layers, id:\.id) { layer in
                    AdventureLayerBackground(layer: layer)
                    
                    LayerContentView(layer: layer)
                        .applyCamera(adventure.camera)
                        .onAppear {
                            handleLayerAppear(layer)
                        }
                    
                    let resources = adventure.layerResources(layer)
                    ForEach(resources, id:\.id) { resource in
                        ResourceWrapper(resource: resource, layer: layer.model)
                    }.applyCamera(adventure.camera)
                }
                
                PlayerWrapperView(player: adventure.player)
                    .applyCamera(adventure.camera)
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
            ForEach(layer.edges, id:\.model.id) { edge in
                EdgeWrapper(edge: edge)
            }

            ForEach(layer.vertices, id:\.model.id) { vertex in
                VertexWrapper(vertex: vertex)
            }
        }
    }
    
//    private var blurRadius: CGFloat {
//        return layer.isCurrent ? 0 : 6
//    }
}

private extension View {
    func applyCamera(_ camera: CameraStatus) -> some View {
        let point = camera.state.center.scaled(-1)
        return self.offset(point: point)
            .animation(animation(camera), value: point)
            .scaleEffect(camera.state.zoom)
            .animation(animation(camera), value: camera.state.zoom)
    }
    
    func animation(_ camera: CameraStatus) -> Animation? {
        switch camera {
        case .fixed: return nil
        case .transition(_, let animation): return animation
        }
    }
}
