//
//  ResourceView.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import SwiftUI


struct ResourceWrapper: View {
    private let transition = AnyTransition.opacity.animation(.easeInOut(duration: 2))
    
    @Namespace var wrapper
    @ObservedObject var resource: ResourceViewModel
    @State var isIdle = false
    @State var positionProgress: CGFloat = 0
    
    var body: some View {
        CenteredGeometryReader { geometry in
            if isVisible {
                ResourceView(resource: resource)
                    .frame(size: size(geometry))
                    .bezierPositioning(curve: positionCurve(geometry), progress: positionProgress)
                    .animation(positionAnimation, value: positionProgress)
                    .offset(point: resourcePosition(geometry))
                    .rotationEffect(vertextRotationAngle)
                    .offset(point: vertexPosition(geometry))
                // TODO: Change constant rotation animation to different animation based on resource or vertex personality
                    .animation(rotationAnimation, value: vertextRotationAngle)
                    .transition(transition)
                    .onAppear {
                        withAnimation {
                            isIdle = true
                        }
                    }.onReceive(resource.objectWillChange) {
                        if resource.metastate.positionAnimated {
                            positionProgress = 1
                        } else {
                            positionProgress = 0
                        }
                    }
            }
        }
    }

    private var isVisible: Bool {
        switch resource.state {
        case .inventory(let player, _, _, _, _):
            return !player.position.isAbscent
        case .vertex(let vertex, _, _):
            return vertex.state.isGrowed
        case .gate:
            return true
        }
    }
    
    private func positionCurve(_ geometry: GeometryProxy) -> BezierCurve {
        switch resource.metastate {
        case .playerMoving(let edge, let direction, let fromIndex, let toIndex, _):
            return alongEdgeCurve(edge: edge, direction: direction, fromIndex: fromIndex, toIndex: toIndex, geometry: geometry)
        case .inGate(let gate, let edge, let vertex, let index):
            return toGateCurve(gate: gate, edge: edge, fromVertex: vertex, fromIndex: index, geometry: geometry)
        default:
            return .zero
        }
    }
    
    private func alongEdgeCurve(edge: Edge, direction: EdgeMovingDirection, fromIndex: Int, toIndex: Int, geometry: GeometryProxy) -> BezierCurve {
        
        let from = direction == .forward ? edge.from : edge.to
        let rawP1 = direction == .forward ? edge.curve.p1 : edge.curve.p2
        let rawP2 = direction == .forward ? edge.curve.p2 : edge.curve.p1
        let to = direction == .forward ? edge.to : edge.from

        var source = resourceSlot(geometry: geometry, vertex: from, index: fromIndex)
        source = source.translated(by: from.point.scaled(geometry))
        var target = resourceSlot(geometry: geometry, vertex: to, index: toIndex)
        target = target.translated(by: to.point.scaled(geometry))
        let p1 = rawP1.scaled(geometry)
        let p2 = rawP2.scaled(geometry)
        
        return .init(points: [source, p1, p2, target])
    }
    
    private func toGateCurve(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int, geometry: GeometryProxy) -> BezierCurve {
        let delta = resourceSlot(geometry: geometry, vertex: fromVertex, index: fromIndex)
        let p0 = fromVertex.point.scaled(geometry).translated(by: delta)
        let p3 = LayoutService.gatePosition(geometry, edge: edge, gate: gate)
        let mid = p0.average(with: p3)
        let p1 = mid.randomPoint(maxDelta: 100)
        let p2 = mid.randomPoint(maxDelta: 100)
        return .init(points: [p0, p1, p2, p3])
    }

    private func size(_ geometry: GeometryProxy) -> CGSize {
        switch resource.state {
        case .gate:
            return CGSize(Layout.EdgeGate.sizeRatio * Layout.EdgeGate.symbolRatio).scaled(geometry.minSize)
        case .inventory:
            return CGSize(Layout.Vertex.diameter * Layout.Resources.Player.sizeRatio).scaled(geometry.minSize)
        case .vertex:
            return CGSize(Layout.Vertex.diameter * Layout.Resources.Vertex.sizeRatio).scaled(geometry.minSize)
        }
    }
    
    private func vertexPosition(_ geometry: GeometryProxy) -> CGPoint {
        switch resource.metastate {
        case .inVertex(let vertex, _, _), .playerAtVertex(let vertex, _):
            return vertex.point.scaled(geometry)
        case .playerAbscent, .playerMoving, .inGate:
            return .zero
        }
    }
    
    private func resourcePosition(_ geometry: GeometryProxy) -> CGPoint {
        switch resource.metastate {
        case .inVertex(_, let index, let total):
            return inVertextResourcePosition(index: index, total: total).scaled(geometry)
        case .playerAtVertex(let vertex, let index):
            return resourceSlot(geometry: geometry, vertex: vertex, index: index)
        case .playerAbscent, .playerMoving, .inGate:
            return .zero
        }
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
    
    private var vertextRotationAngle: Angle {
        switch resource.state {
        case .vertex:
            return Angle(radians: isIdle ? .pi * 2 : 0.0)
        case .inventory, .gate:
            return Angle(radians: 0)
        }
    }
    
    private var positionAnimation: Animation? {
        switch resource.metastate {
        case .playerMoving(let edge, _, _, let toIndex, let total):
            return .positioning(edgeLength: edge.length, index: toIndex, total: total)
        case .inGate:
            return .toGate
        default:
            return nil
        }
    }
    
    private var rotationAnimation: Animation? {
        switch resource.state {
        case .inventory(let player, _, _, _, _):
            switch player.position {
            case .abscent:
                return nil
            case .edge(let edge, _, _):
                return .vertexOut(edgeLength: edge.length)
            case .vertex:
                return .soloRotation
            }
        case .vertex(_, _, let total):
            return total == 1 ? .soloRotation : .groupRotation
        case .gate:
            return nil
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
        let duration = AnimationService.shared.playerMovingDuration(edgeLength: edgeLength)
        return .easeOut(duration: duration)
    }
    
    static func positioning(edgeLength: CGFloat, index: Int, total: Int) -> Animation {
        let timing = AnimationService.shared.resourceMovingTiming(edgeLength: edgeLength, index: index, total: total)
        return .easeInOut(duration: timing.duration).delay(timing.delay)
    }
}

// TODO: Check is this solution (flating two nested switch) really useful or not
private enum ResourceMetastate {
    case inVertex(vertex: Vertex, index: Int, total: Int)
    case playerAtVertex(vertex: Vertex, index: Int)
    case playerMoving(edge: Edge, direction: EdgeMovingDirection, fromIndex: Int, toIndex: Int, total: Int)
    case playerAbscent
    case inGate(gate: EdgeGate, edge: Edge, fromVertex: Vertex, fromIndex: Int)
    
    var positionAnimated: Bool {
        switch self {
        case .inGate, .playerMoving:
            return true
        default:
            return false
        }
    }
}

private extension ResourceViewModel {
     var metastate: ResourceMetastate {
        switch state {
        case .vertex(let vertex, let index, let total):
            return .inVertex(vertex: vertex, index: index, total: total)
        case .gate(let gate, let edge, let fromVertex, let fromIndex):
            return .inGate(gate: gate, edge: edge, fromVertex: fromVertex, fromIndex: fromIndex)
        case .inventory(let player, let index, let estimated, let total, let isFresh):
            switch player.position {
            case .abscent:
                return .playerAbscent
            case .vertex(let vertex):
                return .playerAtVertex(vertex: vertex, index: index)
            case .edge(let edge, let status, let direction):
                let from = direction == .forward ? edge.from : edge.to
                let to = direction == .forward ? edge.to : edge.from
                switch status {
                case .compressing:
                    return .playerAtVertex(vertex: from, index: index)
                case .moving:
                    if isFresh {
                        return .playerAtVertex(vertex: to, index: index)
                    } else {
                        return .playerMoving(edge: edge, direction: direction, fromIndex: index, toIndex: estimated, total: total)
                    }
                case .expanding:
                    return .playerAtVertex(vertex: to, index: index)
                }
            }
        }
    }
}
