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
        ZStack {
            adventure.background
                .edgesIgnoringSafeArea(.all)

            AdventureContentView(adventure: adventure)
                .applyCamera(adventure.camera)
        }
        .onAppear {
            adventure.viewInitCompleted()
        }
    }
}

struct AdventureContentView: View {
    
    @ObservedObject var adventure: AdventureViewModel
    
    var body: some View {
        ForEach(adventure.edges, id:\.model.id) { edge in
            EdgeWrapper(edge: edge)
        }

        ForEach(adventure.vertices, id:\.model.id) { vertex in
            VertexWrapper(vertex: vertex)
        }
        
        ForEach(adventure.resources, id:\.model.id) { resource in
            ResourceWrapper(resource: resource)
        }
        
        PlayerWrapperView(player: adventure.player)
    }
}

private extension View {
    func applyCamera(_ camera: CameraStatus) -> some View {
        self
            .offset(point: camera.state.center)
            .animation(animation(camera), value: camera.state.center)
            .scaleEffect(camera.state.zoom)
            .animation(animation(camera), value: camera.state.zoom)
    }
    
    func animation(_ camera: CameraStatus) -> Animation? {
        switch camera {
        case .fixed:
            return nil
        case .transition(_, let animation):
            return animation
        }
    }
}
