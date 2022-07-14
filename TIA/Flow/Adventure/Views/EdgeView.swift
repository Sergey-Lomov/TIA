//
//  EdgeView.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import SwiftUI

struct EdgeWrapper: View {
    @ObservedObject var edge: EdgeViewModel

    var body: some View {
        let metastate = edge.metastate
        CenteredGeometryReader { geometry in
            EdgePathView(edge: edge)

            ForEach(edge.gates, id: \.id) { gate in
                let position = LayoutService.gatePosition(geometry, gate: gate.model, edge: edge.model)

                EdgeGateView(gate: gate, backColor: edge.color, symbolColor: edge.borderColor)
                    .offset(point: position)
            }
        }.onRedraw {
            // Metastate stroing is a trick for fix unnecessary handling of updated state
            handleViewRedraw(metastate)
        }
        #if EDITOR
        .onTapGesture {
            edge.isEditing.toggle()
        }
        #endif
    }

    private func handleViewRedraw(_ metastate: EdgeViewMetastate) {
        switch metastate {
        case .preextendedSeed:
            edge.seedExtensionPrepared()
        case .pregrowing:
            edge.growingPrepared()
        case .pregrowingElements:
            edge.elementsGrowingPrepared()
        case .preungrowing:
            edge.ungrowingPrepared()
        default:
            break
        }
    }
}

struct EdgePathView: View {
    private static let intersectionAccuracy: CGFloat = 5

    @ObservedObject var edge: EdgeViewModel
    #if EDITOR
    @EnvironmentObject var editorConfig: EditorConfig
    #endif

    var body: some View {
        CenteredGeometryReader { geometry in
            let progress = progress(geometry)
            let animation = animation(geometry)

            // Borders (underline)
            SingleCurveShape(curve: curve)
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.undrelineWidth)
                .animation(animation, value: progress)
                .foregroundColor(borderColor)

            // Line
            let metastate = edge.metastate
            SingleCurveShape(curve: curve)
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.curveWidth)
                .onAnimationCompleted(for: progress) {
                    // Finished mutating for initial metastate, not for current. So metastate should be stored in separate var to avoid updating.
                    handleMutatingFinished(metastate: metastate)
                }
                .animation(animation, value: progress)
                .foregroundColor(edge.color)

            // Connectors
            if edge.metastate.fromConnectorVisible {
                fromConnectorShape(geometry)
                    .animation(animation, value: fromConnectorData(geometry))
                    .foregroundColor(edge.color)
                    .offset(geometry.size.half)
                    .transition(.identity)
            }

            if edge.metastate.toConnectorVisible {
                let connectorData = toConnectorData(geometry)
                toConnectorShape(geometry)
                    .onAnimationCompleted(for: connectorData) {
                        handleMutatingFinished(metastate: metastate)
                    }
                    .animation(animation, value: connectorData)
                    .foregroundColor(edge.color)
                    .offset(geometry.size.half)
                    .transition(.identity)
            }

            #if EDITOR
            if edge.isEditing {
                CurveControlsView(edge: edge)
            }
            #endif
        }
    }

    private var curve: BezierCurve {
        switch edge.metastate {
        case .seed, .pregrowing, .ungrowPath:
            return edge.model.pregrowingCurve
        default:
            return edge.curve
        }
    }

    private var borderColor: Color {
        #if EDITOR
        edge.isEditing ? editorConfig.selectedEdgeColor : edge.borderColor
        #else
        edge.borderColor
        #endif
    }

    private func progress(_ geometry: GeometryProxy) -> CGFloat {
        switch edge.metastate {
        case .seed, .preextendedSeed, .extendedSeed:
            return 0
        case .pregrowing, .ungrowPath:
            let curve = edge.curve.scaled(geometry)
            let center = edge.model.from.point.scaled(geometry)
            let radius = Layout.Vertex.diameter / 2 * geometry.minSize
            return curve.intersectionTWith(center: center, radius: radius)
        default:
            return 1
        }
    }

    private func counterConnectorProgress(_ geometry: GeometryProxy) -> CGFloat {
        switch edge.metastate {
        case .seed, .preextendedSeed, .extendedSeed, .pregrowing, .growPath, .waitingVertex, .ungrowPath, .ungrowElements:
            return 0
        case .pregrowingElements:
            let curve = edge.curve.reversed().scaled(geometry)
            let center = edge.model.to.point.scaled(geometry)
            let radius = Layout.Vertex.diameter / 2 * geometry.minSize
            return curve.intersectionTWith(center: center, radius: radius)
        default:
            return 1
        }
    }

    private var blobing: CGFloat {
        switch edge.metastate {
        case .extendedSeed:
            return 1
        default:
            return 0
        }
    }

    private func animation(_ geometry: GeometryProxy) -> Animation? {
        switch edge.metastate {
        case .preextendedSeed, .pregrowing, .pregrowingElements:
            return Animation.none
        case .extendedSeed:
            return AnimationService.menuSeedExtension
        case .growPath:
            let length = edge.model.length(geometry)
            return AnimationService.edgePathGrowing(length: length)
        case .growElements:
            return AnimationService.edgeElementsGrowing
        case .ungrowPath:
            return AnimationService.edgePathUngrowing
        case .ungrowElements:
            return AnimationService.edgeElementsUngrowing
        default:
            return nil
        }
    }

    private func handleMutatingFinished(metastate: EdgeViewMetastate) {
        switch metastate {
        case .growPath:
            edge.pathGrowingFinished()
        case .growElements:
            edge.elementsGrowingFinished()
        case .ungrowElements:
            edge.elementsUngrowed()
        case .ungrowPath:
            edge.ungrowingFinished()
        default:
            break
        }
    }

    private func fromConnectorShape(_ geometry: GeometryProxy) -> EdgeConnectorShape {
        let curve = curve.scaled(geometry)
        let radius = Layout.Vertex.diameter / 2 * geometry.minSize
        let center = edge.model.from.point.scaled(geometry)
        return .init(curve: curve, progress: progress(geometry), blobing: blobing, center: center, radius: radius)
    }

    private func fromConnectorData(_ geometry: GeometryProxy) -> EdgeConnectorData {
        let curve = curve.scaled(geometry)
        return .init(curve, progress(geometry), blobing)
    }

    private func toConnectorShape(_ geometry: GeometryProxy) -> EdgeConnectorShape {
        let curve = curve.reversed().scaled(geometry)
        let radius = Layout.Vertex.diameter / 2 * geometry.minSize
        let center = edge.model.to.point.scaled(geometry)
        let progress = counterConnectorProgress(geometry)
        return .init(curve: curve, progress: progress, blobing: 0, center: center, radius: radius)
    }

    private func toConnectorData(_ geometry: GeometryProxy) -> EdgeConnectorData {
        let curve = curve.reversed().scaled(geometry)
        let progress = counterConnectorProgress(geometry)
        return .init(curve, progress, blobing)
    }
}
