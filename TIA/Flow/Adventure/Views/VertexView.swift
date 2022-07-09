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
            ComplexCurveShape(curve: .circle(radius: 0.5))
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

            #if DEBUG
            #if GAME
            if ProcessInfo.processInfo.environment["VD_SLOTS"] != nil {
                let color = Color.random()
                ForEach(slots(geometry), id: \.self) { slot in
                    ComplexCurveShape(curve: .circle(radius: 0.5))
                        .stroke(color)
                        .frame(size: LayoutService.inventoryResourceSize(geometry))
                        .offset(point: slot)
                }
            }
            #endif
            #endif
        }
    }

    private var scale: CGFloat {
        switch vertex.metastate {
        case .seed, .ungrowing:
            return .unsingularZero
        default:
            return 1
        }
    }

    private var animation: Animation? {
        switch vertex.metastate {
        case .growing:
            return AnimationService.vertexGrowing
        case .ungrowing:
            return AnimationService.vertexUngrowing
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
            return AnimationService.vertexElementsGrowing
        case .playerIncome(let edge):
            let length = edge.curve.scaled(geometry).length()
            return AnimationService.onVisitHiding(incomeLength: length)
        case .ungrowing:
            return AnimationService.vertexUngrowing
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

    #if DEBUG
    #if GAME
    private func slots(_ geometry: GeometryProxy) -> [CGPoint] {
        let service = VertexSurroundingService(screenSize: geometry.size)
        let layer = GameEngine.shared.adventureEngine?.currentLayer
        guard let layer = layer else { return [] }
        guard layer.contains(vertex.model) else { return [] }
        return service.surroundingFor(vertex.model, layer: layer).slots
    }
    #endif
    #endif
}
