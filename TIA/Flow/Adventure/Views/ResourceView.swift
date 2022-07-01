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
    private let failedMovingGap: CGFloat = 0.1
    private let destroyingRadius: CGFloat = 0.5

    static let colors: [Color] = [.yellow, .red, .green, .blue]
    static var colorIndex = 0
    static func getColor() -> Color {
        colorIndex = colorIndex < colors.count - 1 ? colorIndex + 1 : 0
        return colors[colorIndex]
    }

    @ObservedObject var resource: ResourceViewModel
    var layer: AdventureLayer

    var body: some View {
        return CenteredGeometryReader { geometry in
            if isVisible {
                let positionCurve = positionCurve(geometry)
                let transform = transform(geometry)
                let animation = stateAnimation(geometry)

                ResourceView(resource: resource)
                    .handleState(transform: transform,
                                 positionCurve: positionCurve,
                                 targetPositioning: resource.positioningStep) {
                        handlePositioningFinish()
                    }
                    .animation(animation, value: transform)
                    .transition(transition)
                    .onAppear {
                        resource.presentationFinished()
                    }

//                let testCurve = positionCurve.scaled(x: 1 / geometry.size.width, y: 1 / geometry.size.height)
//                ComplexCurveShape(curve: testCurve)
//                    .stroke(Self.getColor(), lineWidth: 2)
//                    .frame(geometry: geometry)
            }
        }
    }

    private var isVisible: Bool {
        switch resource.metastate {
        case .abscent:
            return false
        case .vertex(let vertex, _, _),
                .vertexIdle(let vertex, _, _),
                .vertexRestoring(let vertex, _, _):
            return vertex.state.isGrowed
        default:
            return true
        }
    }

    private var opacity: CGFloat {
        switch resource.metastate {
        case .abscent, .destroying:
            return 0
        default:
            return 1
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
        case .predestroying:
            resource.resourceDestroyingPrepared()
        case .destroying:
            resource.destoryingFinished()
        default:
            break
        }
    }

    // MARK: Transform calculation
    // TODO: Try to move transform calcualtions into the modifier
    private func transform(_ geometry: GeometryProxy) -> ResourceStateTransform {
        .init(localOffset: localOffset(geometry),
              localAngle: localRotation,
              size: size(geometry),
              opacity: opacity,
              positioning: resource.positioningStep)
    }

    private func size(_ geometry: GeometryProxy) -> CGSize {
        switch resource.metastate {
        case .toGate(let gate, _, _, _),
                .onGate(let gate, _):
            let fullSize = LayoutService.gateResourceSize(geometry)
            return gate.state == .open ? .zero : fullSize
        case .inventoryAtVertex, .successMoving, .failedNear, .outFromVertex, .prelayerChanging, .layerChanging, .destroying, .predestroying, .fromGate:
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
            return inVertextResourcePosition(index: index, total: total).scaled(geometry.minSize)
        case .inventoryAtVertex(let vertex, let index),
                .outFromVertex(let vertex, let index, _):
            return resourceSlot(geometry: geometry, vertex: vertex, index: index)
        case .prelayerChanging(let vertex, let index, let layer),
                .layerChanging(let vertex, let index, let layer, _):
            return resourceSlot(geometry: geometry, vertex: vertex, index: index, forcedLayer: layer)
        default:
            return .zero
        }
    }

    private var localRotation: CGFloat {
        switch resource.metastate {
        case .vertexIdle:
            return .dpi
        default:
            return 0
        }
    }

    private func stateAnimation(_ geometry: GeometryProxy) -> Animation? {
        switch resource.metastate {
        case .vertexIdle(_, _, let total):
            return total == 1 ? .soloRotation : .groupRotation
        case .vertexRestoring, .predestroying:
            return Animation.none
        case .outFromVertex(_, _, let edge):
            return .vertexOut(edgeLength: edge.length(geometry))
        case .successMoving(let edge, _, _, let toIndex, let total):
            let length = edge.length(geometry)
            return .positioning(geometry, playerLength: length, resourceLength: length, index: toIndex, total: total)
        case .toGate:
            return .toGate
        case .fromGate:
            return AnimationService.shared.resourceFromGate
        case .onGate(let gate, _):
            return gate.state == .open ? AnimationService.shared.closeGate : AnimationService.shared.openGate
        case .failedNear(let gate, let edge, let vertex, let index, let total):
            return failNearGateAnimation(geometry, gate: gate, edge: edge, vertex: vertex, slot: index, total: total)
        case .layerChanging(_, _, _, let type):
            switch type {
            case .presenting: return AnimationService.shared.presentLayer
            case .hiding: return AnimationService.shared.hideLayer
            }
        case .destroying(_, let index, let total):
            return .destroying(index: index, total: total)
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

    private func positionCurve(_ geometry: GeometryProxy) -> ComplexCurve {
        switch resource.metastate {
        case .vertex(let vertex, _, _),
                .vertexIdle(let vertex, _, _),
                .vertexRestoring(let vertex, _, _),
                .outFromVertex(let vertex, _, _),
                .inventoryAtVertex(let vertex, _),
                .prelayerChanging(let vertex, _, _),
                .layerChanging(let vertex, _, _, _):
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
        case .predestroying(let vertex, let index):
            let scaledVertex = vertex.point.scaled(geometry)
            var source = resourceSlot(geometry: geometry, vertex: vertex, index: index)
            source = source.translated(by: scaledVertex)
            return .onePoint(source)
        case .destroying(let from, let index, _):
            return destroyingCurve(vertex: from, index: index, geometry: geometry)
        default:
            return .zero
        }
    }
}

// MARK: Positions and curves calculations
extension ResourceWrapper {
    private func destroyingCurve(vertex: Vertex, index: Int, geometry: GeometryProxy) -> ComplexCurve {

        let scaledVertex = vertex.point.scaled(geometry)
        var source = resourceSlot(geometry: geometry, vertex: vertex, index: index)
        source = source.translated(by: scaledVertex)

        let angle = Math.angle(p1: source, p2: scaledVertex)
        let radius: CGFloat = destroyingRadius * geometry.minSize
        let target = CGPoint(center: scaledVertex, angle: angle, radius: radius)

        let radiusRange = FloatRange(from: radius / 4, to: radius / 2)
        let angleRange =  FloatRange(from: .hpi / 4, to: .hpi / 2)
        let curve = Math.randomCurve(from: source, to: target, controlRadius: radiusRange, controlAngle: angleRange)
        return .init(curve)
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
        let from = fromVertex.point.scaled(geometry).translated(by: delta)
        let to = LayoutService.gatePosition(geometry, gate: gate, edge: edge)
        let distance = from.distanceTo(to)
        let radiusRange = FloatRange(from: distance / 2, to: distance)
        let angleRange =  FloatRange(from: .hpi / 2, to: .hpi)
        let curve = Math.randomCurve(from: from, to: to, controlRadius: radiusRange, controlAngle: angleRange)
        return .init(curve)
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
        let angle = edge.curve.scaled(geometry).getNormalAngle(t: t)
        let c1p2 = CGPoint(center: nearGate, angle: angle, radius: distance)
        let c2p1 = CGPoint(center: nearGate, angle: angle + .pi, radius: distance)

        let result = [c1p1, c1p2, nearGate, c2p1, c2p2]
        GeometryCacheService.shared.setFailNearGate(gate: gate, vertex: vertex, controls: result)
        return result
    }

    private func resourceSlot(geometry: GeometryProxy, vertex: Vertex, index: Int, forcedLayer: AdventureLayer? = nil) -> CGPoint {
        let service = VertexSurroundingService(screenSize: geometry.size)
        let layer = forcedLayer ?? layer
        let surrounding = service.surroundingFor(vertex, layer: layer, slotsCount: index + 1)
        return surrounding.slots.last ?? .zero
    }

    private func inVertextResourcePosition(index: Int, total: Int) -> CGPoint {
        if total == 1 {
            return .zero
        } else {
            let angle = CGFloat.dpi / CGFloat(total) * CGFloat(index)
            var delta = CGPoint(x: cos(angle), y: sin(angle))
            delta.scale(by: Layout.Resources.Vertex.offsetScale)
            return delta
        }
    }
}

struct ResourceView: View {
    @ObservedObject var resource: ResourceViewModel

    var body: some View {
        CenteredGeometryReader {
            if let type = resource.type {
                ResourceShape(type: type)
                    .fill(resource.color)
                ResourceShape(type: type)
                    .stroke(resource.borderColor, lineWidth: 2)
            }
        }
    }

    func handleState(transform: ResourceStateTransform,
                     positionCurve: ComplexCurve,
                     targetPositioning: CGFloat,
                     onFinish: Action?) -> some View {
        self.modifier(ResourceStateHandler(transform: transform, positionCurve: positionCurve, onFinish: onFinish, targetPositioning: targetPositioning, deltaPositioning: targetPositioning - 1))
    }
}

// TODO: Should be moved to AnimationService
private extension Animation {
    static var groupRotation: Animation {
        linear(duration: 40)
    }

    static var soloRotation: Animation {
        linear(duration: 15)
    }

    static var toGate: Animation {
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

    static func destroying(index: Int, total: Int) -> Animation {
        let step = total > 1 ? 1 / CGFloat(total - 1) : 0
        let delay = CGFloat(index) * step
        return .easeInOut(duration: 1).delay(delay)
    }
}
