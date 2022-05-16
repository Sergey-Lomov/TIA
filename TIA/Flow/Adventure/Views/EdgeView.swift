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
        CenteredGeometryReader { geometry in
            EdgePathView(edge: edge)

            if edge.model.state.isGrowed {
                ForEach(edge.model.gates.indices, id: \.self) { index in
                    let gate = edge.model.gates[index]
                    let position = LayoutService.gatePosition(geometry, gate: gate, edge: edge.model)
                    
                    EdgeGateView(gate: gate, backColor: edge.color, symbolColor: edge.borderColor)
                        .offset(point: position)
                        .transition(gateTransition(position: position, geometry: geometry))
                }
            }
        }
    }
    
    func gateTransition(position: CGPoint, geometry: GeometryProxy) -> AnyTransition {
        let anchor = position.toUnit(geometry: geometry)
        return .scale(scale: 0, anchor: anchor).animation(.easeOut(duration: 1))
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
                    .animation(animation, value: fromAnimPair(geometry))
                    .foregroundColor(edge.color)
                    .offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            
            if edge.metastate.toConnectorVisible {
                toConnectorShape(geometry)
                    .onReach(toAnimPair(geometry)) {
                        handleMutatingFinished(metastate: metastate)
                    }
                    .animation(animation, value: toAnimPair(geometry))
                    .foregroundColor(edge.color)
                    .offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .onAppear {
                        edge.counterConnectorGrowingPrepared()
                    }
            }
        }
    }
    
    private var curve: BezierCurve {
        switch edge.metastate {
        case .seed, .pregrowing:
            // TODO: Rename seed curve to consistent name (pregrowingCurve)
            return edge.model.seedCurve
        default:
            return edge.curve
        }
    }
    
    private func progress(_ geometry: GeometryProxy) -> CGFloat {
        switch edge.metastate {
        case .seed:
            return 0
        case .pregrowing:
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
        case .seed, .pregrowing, .growPath, .waitingVertex:
            return 0
        case .pregrowingCounterConnector:
            let curve = edge.curve.reversed().scaled(geometry)
            let center = edge.model.to.point.scaled(geometry)
            let radius = Layout.Vertex.diameter / 2 * geometry.minSize
            return curve.intersectionTWith(center: center, radius: radius, accuracy: Self.intersectionAccuracy)
        default:
            return 1
        }
    }
    
    private var animation: Animation? {
        switch edge.metastate {
        case .pregrowing, .pregrowingCounterConnector:
            return .linear(duration: 0)
        case .growPath(let duration), .growCounterConnector(let duration):
            return .easeOut(duration: duration)
        default:
            return nil
        }
    }

    private func handleMutatingFinished(metastate: EdgeViewMetastate) {
        if edge.model.id == "e1" { print("Metastate: \(metastate)") }
        switch metastate {
        case .pregrowing:
            edge.growingPrepared()
        case .growPath:
            edge.pathGrowingFinished()
        case .pregrowingCounterConnector:
            edge.counterConnectorGrowingPrepared()
        case .growCounterConnector:
            edge.counterConnectorGrowingFinished()
        default:
            break
        }
    }
    
    private func fromConnectorShape(_ geometry: GeometryProxy) -> EdgeConnectorShape {
        let curve = curve.scaled(geometry)
        let radius = Layout.Vertex.diameter / 2 * geometry.minSize
        let center = edge.model.from.point.scaled(geometry)
        return .init(curve: curve, progress: progress(geometry), center: center, radius: radius)
    }
    
    private func fromAnimPair(_ geometry: GeometryProxy) -> AnimatablePair<BezierCurve, CGFloat> {
        return .init(curve.scaled(geometry), progress(geometry))
    }
    
    private func toConnectorShape(_ geometry: GeometryProxy) -> EdgeConnectorShape {
        let curve = curve.reversed().scaled(geometry)
        let radius = Layout.Vertex.diameter / 2 * geometry.minSize
        let center = edge.model.to.point.scaled(geometry)
        return .init(curve: curve, progress: counterConnectorProgress(geometry), center: center, radius: radius)
    }
    
    private func toAnimPair(_ geometry: GeometryProxy) -> AnimatablePair<BezierCurve, CGFloat> {
        return .init(curve.reversed().scaled(geometry), counterConnectorProgress(geometry))
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
        return gate.isOpen ? 0 : geometry.minSize * Layout.EdgeGate.sizeRatio
    }
    
    func symbolSize(_ geometry: GeometryProxy) -> CGFloat {
        return circleSize(geometry) * Layout.EdgeGate.symbolRatio
    }
    
    private var sizeAnimation: Animation? {
        return gate.isOpen ? AnimationService.shared.closeGate : AnimationService.shared.closeGate
    }
}

