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

            ForEach(edge.model.gates.indices, id: \.self) { index in
                let gate = edge.model.gates[index]
                let position = LayoutService.gatePosition(geometry, gate: gate, edge: edge.model)
                
                EdgeGateView(gate: gate, backColor: edge.color, symbolColor: edge.borderColor)
                    .offset(point: position)
            }
        }.onRedraw {
            // Metastate stroing is a trick for fix unnecessary handling of updated state
            handleViewRedraw(metastate)
        }
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
    
    var body: some View {
        CenteredGeometryReader { geometry in
            let progress = progress(geometry)
            
            // Borders (underline)
            SingleCurveShape(curve: curve)
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.undrelineWidth)
                .animation(animation, value: progress)
                .foregroundColor(edge.borderColor)
            
            // Line
            let metastate = edge.metastate
            SingleCurveShape(curve: curve)
                .onReach(curve) {
                    // Finished mutating for initial metastate, not for current. So metastate should be stored in separate var to avoid updating.
                    handleMutatingFinished(metastate: metastate)
                }
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.curveWidth)
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
                    .onReach(connectorData) {
                        handleMutatingFinished(metastate: metastate)
                    }
                    .animation(animation, value: connectorData)
                    .foregroundColor(edge.color)
                    .offset(geometry.size.half)
                    .transition(.identity)
            }
        }
    }
    
    private var curve: BezierCurve {
        switch edge.metastate {
        case .seed, .pregrowing, .ungrowPath:
            // TODO: Rename seed curve to consistent name (pregrowingCurve)
            return edge.model.seedCurve
        default:
            return edge.curve
        }
    }
    
    private func progress(_ geometry: GeometryProxy) -> CGFloat {
        switch edge.metastate {
        case .seed, .preextendedSeed, .extendedSeed:
            return 0
        // TODO: Think is it necessary to do same preparation in "preungrowing" state
        case .pregrowing, .ungrowPath:
            let curve = edge.curve.scaled(geometry)
            let center = edge.model.from.point.scaled(geometry)
            let radius = Layout.Vertex.diameter / 2 * geometry.minSize
            return curve.intersectionTWith(center: center, radius: radius, accuracy: Self.intersectionAccuracy)
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
            return curve.intersectionTWith(center: center, radius: radius, accuracy: Self.intersectionAccuracy)
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
    
    // TODO: Move all animations to AnimationsService
    private var animation: Animation? {
        switch edge.metastate {
        case .preextendedSeed, .pregrowing, .pregrowingElements:
            return .linear(duration: 0)
        case .extendedSeed:
            return AnimationService.shared.menuSeedExtension
        case .growPath(let duration), .growElements(let duration):
            return .easeOut(duration: duration)
        case .ungrowPath(let duration), .ungrowElements(let duration):
            return .easeIn(duration: duration)
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

struct EdgeGateView: View {
    @ObservedObject var gate: EdgeGate
    var backColor: Color
    var symbolColor: Color
    
    var body: some View {
        CenteredGeometryReader { geometry in
            CircleShape()
                .frame(size: circleSize(geometry))
                .animation(sizeAnimation, value: circleSize(geometry))
                .foregroundColor(backColor)
            
            switch gate.requirement {
            case .resource(let type):
                ResourceShape(type: type)
                    .frame(size: symbolSize(geometry))
                    .animation(sizeAnimation, value: symbolSize(geometry))
                    .foregroundColor(symbolColor)
            }
        }
    }
    
    func circleSize(_ geometry: GeometryProxy) -> CGFloat {
        switch gate.state {
        case .open, .seed, .ungrowing:
            return 0
        case .growing, .close:
            return geometry.minSize * Layout.EdgeGate.sizeRatio
        }
    }
    
    func symbolSize(_ geometry: GeometryProxy) -> CGFloat {
        return circleSize(geometry) * Layout.EdgeGate.symbolRatio
    }
    
    private var sizeAnimation: Animation? {
        switch gate.state {
        case .growing:
            return AnimationService.shared.growingGate
        case .open:
            return AnimationService.shared.openGate
        case .close:
            return AnimationService.shared.closeGate
        case .ungrowing:
            return AnimationService.shared.ungrowingGate
        default:
            return nil
        }
    }
}

