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
            
            SingleCurveShape(curve: curve)
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.undrelineWidth)
                .animation(animation, value: progress)
                .foregroundColor(edge.borderColor)
            
            SingleCurveShape(curve: curve)
                .onReach(curve) {
                    handleMutatingFinished()
                }
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.curveWidth)
                .animation(animation, value: progress)
                .foregroundColor(edge.color)
            
            if edge.model.from.state.isGrowed {
                let scaledCurve = curve.scaled(geometry)
                EdgeConnectorShape(constants: fromConnector(geometry), curve: scaledCurve, progress: progress)
                    .animation(animation, value: AnimatablePair<BezierCurve, CGFloat>(scaledCurve, progress))
                    .foregroundColor(edge.color)
                    .offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
    
    private var curve: BezierCurve {
        switch edge.state {
        case .seed, .preGrowing:
            // TODO: Remove seed curve to consistent name (pregrowingCurve)
            return edge.model.seedCurve
        default:
            return edge.curve
        }
    }
    
    private func progress(_ geometry: GeometryProxy) -> CGFloat {
        switch edge.state {
        case .seed:
            return 0
        case .preGrowing:
            let curve = edge.curve.scaled(geometry)
            let center = edge.model.from.point.scaled(geometry)
            let radius = Layout.Vertex.diameter / 2 * geometry.minSize
            return curve.intersectionTWith(center: center, radius: radius, accuracy: Self.intersectionAccuracy)
        default:
            return 1
        }
    }
    
    private var animation: Animation? {
        switch edge.state {
        case .preGrowing:
            return .linear(duration: 0)
        case .growing(let duration):
            return .easeOut(duration: duration)
        default:
            return nil
        }
    }

    private func handleMutatingFinished() {
        switch edge.state {
        case .preGrowing:
            edge.growingPrepared()
        case .growing:
            edge.growingFinished()
        default:
            break
        }
    }
    
    private func fromConnector(_ geometry: GeometryProxy) -> EdgeConnectorConstants {
        let center = edge.model.from.point.scaled(geometry)
        let radius = Layout.Vertex.diameter / 2 * geometry.minSize
        return .init(geometry: geometry, center: center, radius: radius)
    }
    
    // TODO: Add connectors calcualtion into geometry cashing system
//    private func connector(_ geometry: GeometryProxy, center: CGPoint, radius: CGFloat) -> EdgeConnectorConstants {
//        let curve = edge.curve.scaled(geometry)
//        let initialT = curve.intersectionTWith(center: center, radius: radius, accuracy: intersectionAccuracy)
//        let intersection = curve.getPoint(t: initialT)
//        let fromAngle = Math.angle(p1: intersection, p2: center)
//        let p1Angle = fromAngle - (connectWidth / 2 / radius)
//        let p2Angle = fromAngle + (connectWidth / 2 / radius)
//        let p1 = CGPoint(center: center, angle: p1Angle, radius: radius)
//        let p2 = CGPoint(center: center, angle: p2Angle, radius: radius)
//        let a1 = p1Angle > fromAngle ? p1Angle - .pi / 2 : p1Angle + .pi / 2
//        let a2 = p2Angle > fromAngle ? p2Angle - .pi / 2 : p2Angle + .pi / 2
//
//        return .init(point1: p1, angle1: a1, point2: p2, angle2: a2, initialT: initialT)
//    }
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

