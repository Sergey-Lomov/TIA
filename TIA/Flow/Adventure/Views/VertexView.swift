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

            let diameter = geometry.minSize * Layout.Vertex.diameter
        
            VertexView(vertex: vertex, diameter: diameter)
                .offset(point: vertex.point, geometry: geometry)
                .onTapGesture {
                    vertex.wasTapped()
                }
        }
    }
}

struct VertexView: View {
    
    @ObservedObject var vertex: VertexViewModel
    var diameter: CGFloat
    
    var body: some View {
        CenteredGeometryReader { geometry in
            ComplexCurveShape(curve: curve)
                /*.onReach(curve) {
                    handleMutatingFinished()
                }*/
                .scaleEffect(scale)
                .frame(size: diameter)
                .foregroundColor(vertex.color)
                .onAnimationCompleted(for: scale) {
                    handleMutatingFinished()
                }
                .animation(animation, value: scale)
            
            
            onVisitView()
                .scaleEffect(scale)
                .frame(size: diameter * Layout.Vertex.onVisitIcon)
                .animation(onVisitAnimation(geometry), value: onVisitProgress)
                .foregroundColor(vertex.elementsColor)
        }
    }
    
    private var curve: ComplexCurve {
//        switch vertex.model.state {
//        case .seed, .ungrowing:
//            return ComplexCurve.circle(radius: 0)
//        default:
            return ComplexCurve.circle(radius: 0.5)
//        }
    }
    
    private var scale: CGFloat {
        switch vertex.metastate {
        case .seed, .ungrowing:
            return .unsingularZero
        default:
            return 1
        }
    }

    // TODO: Move animation to AnimationService. In onVisitAnimation also.
    private var animation: Animation? {
        switch vertex.metastate {
        case .growing:
            return AnimationService.shared.vertexGrowing
        case .ungrowing:
            return AnimationService.shared.vertexUngrowing
        default:
            return nil
        }
    }
    
    var onVisitProgress: CGFloat {
        switch vertex.metastate {
        case .active:
            return 1
        default:
            return 0
        }
    }
    
    private func onVisitAnimation(_ geometry: GeometryProxy) -> Animation? {
        switch vertex.metastate {
        case .active:
            return AnimationService.shared.vertexElementsGrowing
        case .playerIncome(let edge):
            let length = edge.curve.scaled(geometry).length()
            return AnimationService.shared.onVisitHiding(incomeLength: length)
        case .ungrowing:
            return AnimationService.shared.vertexUngrowing
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
    
    @ViewBuilder
    private func onVisitView() -> some View {
        if let action = vertex.model.onVisit,
              let elements = VertexActionsIconsService.elements(action) {
            DrawableCurvesView(elements: elements)
                .drawingProgress(onVisitProgress)
                .environment(\.drawingWidth, 4)
        }
    }
}
