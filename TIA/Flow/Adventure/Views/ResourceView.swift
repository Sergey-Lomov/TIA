//
//  ResourceView.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import SwiftUI

struct ResourceWrapper: View {
    private let transition = AnyTransition.opacity.animation(.easeInOut(duration: 2))
    private let controlsRandomization: CGFloat = 100
    private let toGateP2DistanceRange = CGFloat(50)...CGFloat(100)
    private let failedMovingRandomiztion: CGFloat = 100
    private let failedMovingGap: CGFloat = 0.1
    
    @Namespace var wrapper
    @ObservedObject var resource: ResourceViewModel
    @State var isIdle = false
    @State var progress: CGFloat = 0
    
    var body: some View {
        return CenteredGeometryReader { geometry in
            if isVisible {
                ResourceView(resource: resource)
                    .bezierPositioning(curve: positionCurve(geometry),
                                       progress: progress) {
                        handlePositioningFinish()
                    }
                    .animation(positionAnimation(geometry), value: progress)
                    .frame(size: size(geometry))
                    .animation(sizeAnimation, value: size(geometry))
                    .offset(point: resourcePosition(geometry))
                    .rotationEffect(vertextRotationAngle)
                    .offset(point: vertexPosition(geometry))
                    .animation(rotationAnimation(geometry), value: vertextRotationAngle)
                    .transition(transition)
                    .onAppear {
                        withAnimation { isIdle = true }
                    }.onReceive(resource.model.$state) { state in
                        handleStateUpdate(state)
                    }
            }
        }
    }
    
    // MARK: UI values providers
    private var isVisible: Bool {
        switch resource.metastate {
        case .abscent:
            return false
        case .vertex(let vertex, _, _):
            return vertex.state.isGrowed
        default:
            return true
        }
    }
    
    private func positionCurve(_ geometry: GeometryProxy) -> ComplexCurve {
        switch resource.metastate {
        case .successMoving(let edge, let forward, let fromIndex, let toIndex, _):
            return alongEdgeCurve(edge: edge, forward: forward, fromIndex: fromIndex, toIndex: toIndex, geometry: geometry)
        case .gate(let gate, let edge, let vertex, let index):
            return toGateCurve(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, geometry: geometry)
        case .failedNear(let edge, let gateIndex, let fromVertex, let fromIndex):
            return failNearGateCurve(geometry, edge: edge, gateIndex: gateIndex, vertex: fromVertex, slot: fromIndex)
        default:
            return .zero
        }
    }
    
    private var targetPositionProgress: CGFloat {
        switch resource.metastate {
        case .successMoving, .failedNear, .gate:
            return 1
        default:
            return 0
        }
    }
    
    private func size(_ geometry: GeometryProxy) -> CGSize {
        switch resource.metastate {
        case .gate(let gate, _, _, _):
            let fullSize = CGSize(Layout.EdgeGate.sizeRatio * Layout.EdgeGate.symbolRatio).scaled(geometry.minSize)
            return gate.isOpen ? .zero : fullSize
        case .inventoryAtVertex, .successMoving, .failedNear:
            return CGSize(Layout.Vertex.diameter * Layout.Resources.Player.sizeRatio).scaled(geometry.minSize)
        case .vertex:
            return CGSize(Layout.Vertex.diameter * Layout.Resources.Vertex.sizeRatio).scaled(geometry.minSize)
        case .abscent:
            return .zero
        }
    }
    
    private func vertexPosition(_ geometry: GeometryProxy) -> CGPoint {
        switch resource.metastate {
        case .vertex(let vertex, _, _), .inventoryAtVertex(let vertex, _):
            return vertex.point.scaled(geometry)
        default:
            return .zero
        }
    }
    
    private func resourcePosition(_ geometry: GeometryProxy) -> CGPoint {
        switch resource.metastate {
        case .vertex(_, let index, let total):
            return inVertextResourcePosition(index: index, total: total).scaled(geometry)
        case .inventoryAtVertex(let vertex, let index):
            return resourceSlot(geometry: geometry, vertex: vertex, index: index)
        default:
            return .zero
        }
    }
    
    private var vertextRotationAngle: Angle {
        switch resource.metastate {
        case .vertex:
            return Angle(radians: isIdle ? .pi * 2 : 0.0)
        default:
            return Angle(radians: 0)
        }
    }
    
    private var sizeAnimation: Animation? {
        switch resource.metastate {
        case .gate(let gate, _, _, _):
            return gate.isOpen ? AnimationService.shared.closeGate : AnimationService.shared.closeGate
        default:
            return nil
        }
    }
    
    private func positionAnimation(_ geometry: GeometryProxy) -> Animation? {
        // Prevent animation in case, when progress sets to 0 before start valuable positioning animation
        if progress == 0 && resource.metastate.positionAnimated { return nil }
        
        switch resource.metastate {
        case .successMoving(let edge, _, _, let toIndex, let total):
            let length = edge.length(geometry)
            return .positioning(length: length, index: toIndex, total: total)
        case .failedNear(let edge, let index, let vertex, let total):
            let ratio = CGFloat(index + 1) / CGFloat(edge.gates.count + 1)
            let multiplier = edge.from == vertex ? ratio : 1 - ratio
            let length = edge.length(geometry) * multiplier * 2
            return .positioning(length: length, index: index, total: total)
        case .gate:
            return .toGate
        default:
            return nil
        }
    }
    
    private func rotationAnimation(_ geometry: GeometryProxy) -> Animation? {
        switch resource.state {
        case .inventory(let player, _, _, _, _):
            switch player.position {
            case .abscent:
                return nil
            case .edge(let edge, _, _):
                return .vertexOut(edgeLength: edge.length(geometry))
            case .vertex:
                return .soloRotation
            }
        case .vertex(_, _, let total):
            return total == 1 ? .soloRotation : .groupRotation
        case .gate, .deletion:
            return nil
        }
    }
    
    private func handlePositioningFinish() {
        switch resource.metastate {
        case .gate:
            resource.moveToGateFinished()
        default:
            break
        }
    }
    
    private func handleStateUpdate(_ state: ResourceState) {
        guard !state.animationIntermediate else { return }
        
        let metastate = state.metastate
        if metastate.positionAnimated {
            progress = 0
            DispatchQueue.main.async {
                progress = targetPositionProgress
            }
        }
    }
    
    // MARK: Calculations
    private func alongEdgeCurve(edge: Edge, forward: Bool, fromIndex: Int, toIndex: Int, geometry: GeometryProxy) -> ComplexCurve {
        
        let from = forward ? edge.from : edge.to
        let rawP1 = forward ? edge.curve.p1 : edge.curve.p2
        let rawP2 = forward ? edge.curve.p2 : edge.curve.p1
        let to = forward ? edge.to : edge.from

        var source = resourceSlot(geometry: geometry, vertex: from, index: fromIndex)
        source = source.translated(by: from.point.scaled(geometry))
        var target = resourceSlot(geometry: geometry, vertex: to, index: toIndex)
        target = target.translated(by: to.point.scaled(geometry))
        let p1 = rawP1.scaled(geometry)
        let p2 = rawP2.scaled(geometry)
        
        return .init(points: [source, p1, p2, target])
    }
    
    private func toGateCurve(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int, geometry: GeometryProxy) -> ComplexCurve {
        let delta = resourceSlot(geometry: geometry, vertex: fromVertex, index: fromIndex)
        let p0 = fromVertex.point.scaled(geometry).translated(by: delta)
        let p3 = LayoutService.gatePosition(geometry, edge: edge, gate: gate)
        let mid = p0.average(with: p3)
        let p1 = mid.randomPoint(maxDelta: controlsRandomization)
        let p2 = mid.randomPoint(maxDelta: controlsRandomization)
        return .init(points: [p0, p1, p2, p3])
    }

    private func failNearGateCurve(_ geometry: GeometryProxy, edge: Edge, gateIndex: Int, vertex: Vertex, slot: Int) -> ComplexCurve {
        let delta = resourceSlot(geometry: geometry, vertex: vertex, index: slot)
        let p0 = vertex.point.scaled(geometry).translated(by: delta)
        let gateT = LayoutService.gateProgress(geometry, edge: edge, index: gateIndex)
        let t = edge.from == vertex ? gateT + failedMovingGap : gateT - failedMovingGap
        let p3 = edge.curve.scaled(geometry).getPoint(t: t)
        let mid = p0.average(with: p3)
        let p1 = mid.randomPoint(maxDelta: controlsRandomization)
        
        let p2Distance = CGFloat.random(in: toGateP2DistanceRange)
        let p2Angle = edge.curve.scaled(geometry).getNormaAngle(t: t)
        let p2 = CGPoint(center: p3, angle: p2Angle, radius: p2Distance)
        let toGate = BezierCurve(points: [p0, p1, p2, p3])
        
        return .init([toGate, toGate.reversed().mirrored()])
    }
    
    private func resourceSlot(geometry: GeometryProxy, vertex: Vertex, index: Int) -> CGPoint {
        let service = VertexSurroundingService(screenSize: geometry.size)
        let surrounding = service.surroundingFor(vertex, slotsCount: index + 1)
        return surrounding.slots.last ?? .zero
    }
    
    private func inVertextResourcePosition(index: Int, total: Int) -> CGPoint {
        if total == 1 {
            return .zero
        } else {
            let angle = CGFloat.pi * 2.0 / CGFloat(total) * CGFloat(index)
            var delta = CGPoint(x: cos(angle), y: sin(angle))
            delta.scale(by: Layout.Resources.Vertex.angleScale)
            return delta
        }
    }
}

struct ResourceView: View {
    @ObservedObject var resource: ResourceViewModel
    
    var body: some View {
        ZStack {
            ResourceShape(type: resource.type)
                .fill(resource.color)
            ResourceShape(type: resource.type)
                .stroke(resource.borderColor, lineWidth: 2)
        }
    }
}

// TODO: Should be removed if became unused after adding different idle animations for resources based on vertex personality.
private extension Animation {
    static var groupRotation: Animation {
        linear(duration: 40).repeatForever(autoreverses: false)
    }
    
    static var soloRotation: Animation {
        linear(duration: 15).repeatForever(autoreverses: false)
    }
    
    static var toGate: Animation {
        let duration = AnimationService.shared.resToEdgeDuration()
        return .easeInOut(duration: duration)
    }
    
    static func vertexOut(edgeLength: CGFloat) -> Animation {
        let duration = AnimationService.shared.playerMovingDuration(length: edgeLength)
        return .easeOut(duration: duration)
    }
    
    static func positioning(length: CGFloat, index: Int, total: Int) -> Animation {
        let timing = AnimationService.shared.resourceMovingTiming(length: length, index: index, total: total)
        return .easeInOut(duration: timing.duration).delay(timing.delay)
    }
}

// TODO: Check is this solution (flating two nested switch) really useful or not
private enum ResourceMetastate {
    case abscent
    case vertex(vertex: Vertex, index: Int, total: Int)
    case inventoryAtVertex(vertex: Vertex, index: Int)
    case successMoving(edge: Edge, forward: Bool, fromIndex: Int, toIndex: Int, total: Int)
    case failedNear(edge: Edge, gateIndex: Int, vertex: Vertex, index: Int)
//    case failedMovingTo(edge: Edge, gateIndex: Int, fromVertex: Vertex, fromIndex: Int)
//    case failedMovingFrom(edge: Edge, gateIndex: Int, toVertex: Vertex, toIndex: Int)
    case gate(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int)

    var positionAnimated: Bool {
        switch self {
        case .successMoving, .failedNear, .gate:
            return true
        default:
            return false
        }
    }
}

private extension ResourceState {
    var animationIntermediate: Bool {
        switch self {
        case .inventory(let player, _, _, _, _):
            switch player.metastate {
            case .movingFromGate:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    var metastate: ResourceMetastate {
        switch self {
        case .vertex(let vertex, let index, let total):
            return .vertex(vertex: vertex, index: index, total: total)
        
        case .gate(let gate, let edge, let fromVertex, let fromIndex):
            return .gate(gate: gate, edge: edge, fromVertex: fromVertex, fromIndex: fromIndex)
        
        case .deletion:
            return .abscent
        
        case .inventory(let player, let index, let estimated, let total, let isFresh):
            switch player.metastate {
            
            case .abscent:
                return .abscent
            
            case .vertex(let vertex),
                    .compressing(let vertex),
                    .expanding(let vertex):
                return .inventoryAtVertex(vertex: vertex, index: index)
           
            case .moving(let edge, let forward):
                if isFresh {
                    let vertex = forward ? edge.to : edge.from
                    return .inventoryAtVertex(vertex: vertex, index: index)
                } else {
                    return .successMoving(edge: edge, forward: forward, fromIndex: index, toIndex: estimated, total: total)
                }
            
            case .movingToGate(let edge, let gateIndex, let forward):
                let vertex = forward ? edge.from : edge.to
                return .failedNear(edge: edge, gateIndex: gateIndex, vertex: vertex, index: index)
            case .movingFromGate(let edge, let gateIndex, let forward):
                let vertex = forward ? edge.from : edge.to
                return .failedNear(edge: edge, gateIndex: gateIndex, vertex: vertex, index: index)
            }
        }
    }
}

private extension ResourceViewModel {
    var metastate: ResourceMetastate { state.metastate }
}
