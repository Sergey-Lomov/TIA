//
//  VertexView.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import SwiftUI

struct VertexWrapper: View {
    private let radiusCoefficient: CGFloat = 0.15
    
    @ObservedObject var vertex: VertexViewModel
    
    var body: some View {
        GeometryReader { geometry in
            
            let radius = min(geometry.size.height, geometry.size.width) * radiusCoefficient
            
            ZStack {
                VertexView(vertex: vertex, radius: radius)
                    .offset(point: vertex.point, geometry: geometry)
            }
            .frame(geometry: geometry)
        }
    }
}

struct VertexView_Previews: PreviewProvider {
    static var previews: some View {
        let descriptor = GameState().scenario.adventures[.dark]?.first
        let layout = AdventureLayout.random(for: descriptor!)
        let adventure = ScenarioService.shared.adventureFor(descriptor!, layout: layout)
        let viewModel = VertexViewModel(vertex: adventure.vertices[0],
                                        isCurrent: false,
                                        color: Color.softWhite)
        VertexWrapper(vertex: viewModel)
    }
}

struct VertexView: View {

    @ObservedObject var vertex: VertexViewModel
    var radius: CGFloat
    
    var body: some View {
        ZStack {
            CircleShape()
                .frame(width: radius, height: radius)
                .foregroundColor(vertex.color)
                .scaleEffect(scale)
                .animation(.easeOut(duration: growDuration),
                           value: scale)
        }
    }
    
    private var scale: CGFloat {
        switch vertex.model.state {
        case .seed:
            return 0.001
        default:
            return 1
        }
    }
    
    private var growDuration: CGFloat {
        switch vertex.model.state {
        case .growing(let duration):
            return duration
        default:
            return 0
        }
    }
}
