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
    private let toGateRandomizationRange = CGFloat(50)...CGFloat(100)
    private let failedMovingRandomiztion: CGFloat = 100
    private let failedMovingGap: CGFloat = 0.1
    
    static let colors: [Color] = [.yellow, .red, .green, .blue]
    static var colorIndex = 0
    static func getColor() -> Color {
        colorIndex = colorIndex < colors.count - 1 ? colorIndex + 1 : 0
        return colors[colorIndex]
    }
    
    @ObservedObject var resource: ResourceViewModel
    
    var body: some View {
        return CenteredGeometryReader { geometry in
            if isVisible {
                let positionCurve = positionCurve(geometry)
                let transform = transform(geometry)
                let animation = stateAnimation(geometry)
                
                ResourceView(resource: resource)
                    .modifier(ResourceStateHandler(
                        transform: transform,
                        positionCurve: positionCurve,
                        onFinish: {
                            handlePositioningFinish()
                        }, targetPositioning: resource.positioningStep,
                        deltaPositioning: resource.positioningStep - 1))
                    .animation(animation, value: transform)
                    .transition(transition)
                    .onAppear {
                        resource.presentationFinished()
                    }
                
                let testCurve = positionCurve.scaled(x: 1 / geometry.size.width,
                                                        y: 1 / geometry.size.height)
                ComplexCurveShape(curve: testCurve)
                    .stroke(Self.getColor(), lineWidth: 2)
                    .frame(geometry: geometry)
            }
        }
    }
    
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
    
    private func handlePositioningFinish() {
        switch resource.metastate {
        case .vertexIdle:
            resource.idleFinished()
        case .vertexRestoring:
            resource.idleRestoringFinished()
        case .toGate:
            resource.moveToGateFinished()
        case .fromGate:
            resource.moveFromGateFinished()
        case .failedNear:
            resource.moveNearGateFinished()
        default:
            break
        }
    }
    
    // MARK: Transform calculation
    private func transform(_ geometry: GeometryProxy) -> ResourceStateTransform {
        .init(localOffset: localOffset(geometry),
              localAngle: localRotation,
              size: size(geometry),
              positioning: resource.positioningStep)
    }
    
    private func size(_ geometry: GeometryProxy) -> CGSize {
        switch resource.metastate {
        case .toGate(let gate, _, _, _),
                .onGate(let gate, _),
                .fromGate(let gate, _, _, _):
            let fullSize = LayoutService.gateResourceSize(geometry)
            return gate.isOpen ? .zero : fullSize
        case .inventoryAtVertex, .successMoving, .failedNear, .outFromVertex:
            return LayoutService.inventoryResourceSize(geometry)
        case .vertex, .vertexIdle, .vertexRestoring:
            return LayoutService.vertexResourceSize(geometry)
        case .abscent:
            return .zero
        }
    }

    private func localOffset(_ geometry: GeometryProxy) -> CGPoint {
        switch resource.metastate {
        case .vertex(_, let index, let total),
                .vertexIdle(_, let index, let total),
                .vertexRestoring(_, let index, let total):
            return inVertextResourcePosition(index: index, total: total).scaled(geometry)
        case .inventoryAtVertex(let vertex, let index),
                .outFromVertex(let vertex, let index, _):
            return resourceSlot(geometry: geometry, vertex: vertex, index: index)
        default:
            return .zero
        }
    }
    
    private var localRotation: CGFloat {
        switch resource.metastate {
        case .vertexIdle:
            return .pi * 2
        default:
            return 0
        }
    }
    
    // MARK: Animation
    private func stateAnimation(_ geometry: GeometryProxy) -> Animation? {
        switch resource.metastate {
        case .vertexIdle(_, _, let total):
            return total == 1 ? .soloRotation : .groupRotation
        case .vertexRestoring:
            return .linear(duration: 0)
        case .outFromVertex(_, _, let edge):
            return .vertexOut(edgeLength: edge.length(geometry))
        case .successMoving(let edge, _, _, let toIndex, let total):
            let length = edge.length(geometry)
            return .positioning(geometry, playerLength: length, resourceLength: length, index: toIndex, total: total)
        case .toGate, .fromGate:
            return .gateMoving
        case .onGate(let gate, _):
            return gate.isOpen ? AnimationService.shared.closeGate : AnimationService.shared.openGate
        case .failedNear(let gate, let edge, let vertex, let index, let total):
            return failNearGateAnimation(geometry, gate: gate, edge: edge, vertex: vertex, slot: index, total: total)
        default:
            return nil
        }
    }
    
    private func failNearGateAnimation(_ geometry: GeometryProxy, gate: EdgeGate, edge: Edge, vertex: Vertex, slot: Int, total: Int) -> Animation? {
        guard let gateIndex = edge.gates.firstIndex(of: gate) else { return nil }
        let ratio = CGFloat(gateIndex + 1) / CGFloat(edge.gates.count + 1)
        let multiplier = edge.from == vertex ? ratio : 1 - ratio
        let playerLength = edge.length(geometry) * multiplier * 2
        let curve = failNearGateCurve(geometry, gate: gate, edge: edge, vertex: vertex, slot: slot)
        return .positioning(geometry, playerLength: playerLength, resourceLength: curve.length(), index: slot, total: total)
    }

    // MARK: Positioning curve
    private func positionCurve(_ geometry: GeometryProxy) -> ComplexCurve {
        switch resource.metastate {
        case .vertex(let vertex, _, _),
                .vertexIdle(let vertex, _, _),
                .vertexRestoring(let vertex, _, _),
                .outFromVertex(let vertex, _, _),
                .inventoryAtVertex(let vertex, _):
            let point = vertex.point.scaled(geometry)
            return .onePoint(point)
        case .successMoving(let edge, let forward, let fromIndex, let toIndex, _):
            return alongEdgeCurve(edge: edge, forward: forward, fromIndex: fromIndex, toIndex: toIndex, geometry: geometry)
        case .toGate(let gate, let edge, let vertex, let index):
            return toGateCurve(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, geometry: geometry)
        case .fromGate(let gate, let edge, let vertex, let index):
            return toGateCurve(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, geometry: geometry).reversed()
        case .onGate(let gate, let edge):
            let point = LayoutService.gatePosition(geometry, gate: gate, edge: edge)
            return .onePoint(point)
        case .failedNear(let gate, let edge, let fromVertex, let fromIndex, _):
            return failNearGateCurve(geometry, gate: gate, edge: edge, vertex: fromVertex, slot: fromIndex)
        default:
            return .zero
        }
    }
    
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
        let p3 = LayoutService.gatePosition(geometry, gate: gate, edge: edge)
        let mid = p0.average(with: p3)
        let p1 = mid.randomPoint(maxDelta: controlsRandomization)
        let p2 = mid.randomPoint(maxDelta: controlsRandomization)
        return .init(points: [p0, p1, p2, p3])
    }

    private func failNearGateCurve(_ geometry: GeometryProxy, gate: EdgeGate, edge: Edge, vertex: Vertex, slot: Int) -> ComplexCurve {
        
        let delta = resourceSlot(geometry: geometry, vertex: vertex, index: slot)
        let p0 = vertex.point.scaled(geometry).translated(by: delta)
        let controls = failNearGateControls(geometry, gate: gate, edge: edge, vertex: vertex, slot: slot)
        
        let to = BezierCurve(points: [p0, controls[0], controls[1], controls[2]])
        let from = BezierCurve(points: [controls[2], controls[3], controls[4], p0])
        
        return .init([to, from])
    }
    
    private func failNearGateControls(_ geometry: GeometryProxy, gate: EdgeGate, edge: Edge, vertex: Vertex, slot: Int) -> [CGPoint] {
        let cachedControls = GeometryCacheService.shared.failNearGate(gate: gate, vertex: vertex)
        if let cached = cachedControls { return cached }
        
        let gateT = LayoutService.gateProgress(geometry, gate: gate, edge: edge)
        let t = edge.from == vertex ? gateT + failedMovingGap : gateT - failedMovingGap
        let nearGate = edge.curve.scaled(geometry).getPoint(t: t)
        
        let mid = vertex.point.scaled(geometry).average(with: nearGate)
        let c1p1 = mid.randomPoint(maxDelta: controlsRandomization)
        let c2p2 = mid.randomPoint(maxDelta: controlsRandomization)
        
        let distance = CGFloat.random(in: toGateRandomizationRange)
        let angle = edge.curve.scaled(geometry).getNormaAngle(t: t)
        let c1p2 = CGPoint(center: nearGate, angle: angle, radius: distance)
        let c2p1 = CGPoint(center: nearGate, angle: angle + .pi, radius: distance)
        
        let result = [c1p1, c1p2, nearGate, c2p1, c2p2]
        GeometryCacheService.shared.setFailNearGate(gate: gate, vertex: vertex, controls: result)
        return result
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
        CenteredGeometryReader { geometry in
            
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
        linear(duration: 40)//.repeatForever(autoreverses: false)
    }
    
    static var soloRotation: Animation {
        linear(duration: 5)//.repeatForever(autoreverses: false)
    }
    
    static var gateMoving: Animation {
        let duration = AnimationService.shared.resToGateDuration()
        return .easeInOut(duration: duration)
    }
    
    static func vertexOut(edgeLength: CGFloat) -> Animation {
        let duration = AnimationService.shared.playerMovingDuration(length: edgeLength)
        return .easeOut(duration: duration)
    }
    
    static func positioning(_ geometry: GeometryProxy, playerLength: CGFloat, resourceLength: CGFloat, index: Int, total: Int) -> Animation {
        let timing = AnimationService.shared.resourceMovingTiming(geometry, playerLength: playerLength, resourceLength: resourceLength, index: index, total: total)
        return .easeInOut(duration: timing.duration).delay(timing.delay)
    }
}
