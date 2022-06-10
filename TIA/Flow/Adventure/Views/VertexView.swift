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
                    handleMutatingFinished()
                }
                .frame(size: radius)
                .foregroundColor(vertex.color)
                .animation(animation, value: curve)
        }
    }
    
    private var curve: ComplexCurve {
        switch vertex.model.state {
        case .seed, .ungrowing:
            return ComplexCurve.circle(radius: 0)
        default:
            return ComplexCurve.circle(radius: 0.5)
        }
    }

    // TODO: Move animation to AnimationService
    private var animation: Animation? {
        switch vertex.state {
        case .growing(let duration):
            return .easeOut(duration: duration)
        case .ungrowing(let duration):
            return .easeIn(duration: duration)
        default:
            return nil
        }
    }
    
    private func handleMutatingFinished() {
        switch vertex.state {
        case .growing:
            vertex.growingFinished()
        case .ungrowing:
            vertex.ungrowingFinished()
        default:
            break
        }
    }
}
