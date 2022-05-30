//
//  VertexView.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import SwiftUI

struct VertexWrapper: View {
    
    @ObservedObject var vertex: VertexViewModel
    
    var body: some View {
        CenteredGeometryReader { geometry in

            let radius = geometry.minSize * Layout.Vertex.diameter
        
            VertexView(vertex: vertex, radius: radius)
                .offset(point: vertex.point, geometry: geometry)
                .onTapGesture {
                    vertex.wasTapped()
                }
        }
    }
}

struct VertexView: View {
    @ObservedObject var vertex: VertexViewModel
    var radius: CGFloat
    
    var body: some View {
        ZStack {
            ComplexCurveShape(curve: curve)
                .onReach(curve) {
                    vertex.growingFinished()
                }
                .frame(size: radius)
                .foregroundColor(vertex.color)
                .animation(.easeOut(duration: growDuration),
                           value: curve)
        }
    }
    
    private var curve: ComplexCurve {
        switch vertex.model.state {
        case .seed:
            return ComplexCurve.circle(radius: 0)
        default:
            return ComplexCurve.circle(radius: 0.5)
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
