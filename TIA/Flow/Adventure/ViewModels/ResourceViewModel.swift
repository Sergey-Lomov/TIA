//
//  ResourceViewModel.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import Foundation
import SwiftUI
import Combine

class ResourceViewModel: ObservableObject, IdEqutable {
    
    var id: String { model.id }
    var model: Resource
    @Published var status: ResourceViewStatus
    @Published var color: Color
    @Published var borderColor: Color
    
    private var subscriptions: [AnyCancellable] = []
    var eventsPublisher: ViewEventsPublisher?
    
    var type: ResourceType {
        get { model.type }
        set { model.type = newValue }
    }
    
    var state: ResourceState {
        get { model.state }
        set { model.state = newValue }
    }
    
    init(model: Resource, color: Color, borderColor: Color) {
        self.model = model
        self.color = color
        self.borderColor = borderColor
        let state = ResourceViewState.forModel(model.state) ?? .abscent
        self.status = .stable(state: state)
        
        subscriptions.sink(model.$state) { [weak self] newState in
            guard let self = self else { return }
            guard let status = self.statusFor(current: model.state, next: newState) else {
                return
            }
            self.status = status
        }
    }
    
    private func statusFor(current: ResourceState, next: ResourceState) -> ResourceViewStatus? {
        switch next {
        case .vertex, .deletion:
            let sate = ResourceViewState.forModel(next) ?? .abscent
            return .stable(state: sate)
        
        case .inventory(let player, let index, let estimatedIndex, let total, _):
            switch current {
            case .vertex:
                guard case .stable(let state) = status else { return nil }
                guard let nextViewState = ResourceViewState.forModel(next) else { return nil }
                return .transfer(from: state, to: nextViewState, type: .pickup)
            case .gate:
                guard case .stable(let state) = status else { return nil }
                guard let nextViewState = ResourceViewState.forModel(next) else { return nil }
                return .transfer(from: state, to: nextViewState, type: .fromGate)
            default:
                break
            }
            
            switch player.metastate {
            case .abscent:
                return .stable(state: .abscent)
            
            case .vertex(let vertex),
                    .compressing(vertex: let vertex),
                    .expanding(vertex: let vertex):
                let state = ResourceViewState.inVertex(vertex: vertex, slot: index, total: total)
                return .stable(state: state)
            
            case .moving(let edge, let forward):
                guard case .stable(let state) = status else { return nil }
                let toVertex = forward ? edge.to : edge.from
                let nextViewState = ResourceViewState.inVertex(vertex: toVertex, slot: estimatedIndex, total: total)
                return .transfer(from: state, to: nextViewState, type: .alongEdge(edge: edge))
            
            case .movingToGate(let edge, let gateIndex, _):
                guard case .stable(let state) = status else { return nil }
                let gate = edge.gates[gateIndex]
                return .transfer(from: state, to: state, type: .failGate(edge: edge, gate: gate))
            
            case .movingFromGate:
                return nil
            }
        
        case .gate(let gate, let edge, _, _, _, _):
            guard case .stable(let state) = status else { return nil }
            let nextViewState = ResourceViewState.inGate(gate: gate, edge: edge)
            return .transfer(from: state, to: nextViewState, type: .toGate)
        }

    }
}

extension ResourceViewModel {
    func moveToGateFinished() {
        guard case .gate(let gate, _, _, _, _, _) = model.state else { return }
        eventsPublisher?.send(.resourceMovedToGate(gate: gate))
    }
    
    func moveFromGateFinished() {
        guard case .gate(_, _, _, _, _, let prestate) = model.state else { return }
        model.state = prestate
    }
}

enum ResourceViewState {
    case abscent
    case inVertex(vertex: Vertex, slot: Int, total: Int)
    case nearVertex(vertex: Vertex, slot: Int)
    case inGate(gate: EdgeGate, edge: Edge)
//    case nearGate
    
    static func forModel(_ model: ResourceState) -> ResourceViewState? {
        switch model {
        case .vertex(let vertex, let index, let total):
            return .inVertex(vertex: vertex, slot: index, total: total)
        case .inventory(let player, let slot, _, _, let isFresh):
            if isFresh {
                guard case .edge(let edge, _, let direction) = player.position else { return nil}
                let to = direction.isForward ? edge.to : edge.from
                return .nearVertex(vertex: to, slot: slot)
            } else {
                guard case .vertex(let vertex) = player.position else { return nil}
                return .nearVertex(vertex: vertex, slot: slot)
            }
        case .gate(let gate, let edge, _, _, _, _):
            return .inGate(gate: gate, edge: edge)
        case .deletion:
            return .abscent
        }
    }
    
    func localOffset(_ geometry: GeometryProxy) -> CGPoint {
        switch self {
        case .inVertex(_, let slot, let total):
            return LayoutService.inVertextResourcePosition(geometry, slot: slot, total: total)
        case .nearVertex(let vertex, let slot):
            return LayoutService.resourceOffset(geometry, vertex: vertex, slot: slot)
        default:
            return .zero
        }
    }
    
    func localAngle() -> Interpolation<CGFloat> {
        switch self {
        case .inVertex:
            return .init(from: 0, to: .pi * 2, timecurve: .linearTiming)
        default:
            return .zero()
        }
    }
    
    func size(_ geometry: GeometryProxy) -> Interpolation<CGSize> {
        switch self {
        case .inVertex:
            let size = LayoutService.vertexResourceSize(geometry)
            return .init(to: size)
        case .nearVertex:
            let size = LayoutService.inventoryResourceSize(geometry)
            return .init(to: size)
        case .inGate(let gate, _):
            let fullSize = LayoutService.gateResourceSize(geometry)
            let size = gate.isOpen ? .zero : fullSize
            return .init(to: size)
        case .abscent:
            return .zero()
        }
    }
    
    func globalOffset(_ geometry: GeometryProxy) -> CGPoint {
        switch self {
        case .abscent:
            return .zero
        case .inVertex(let vertex, _, _), .nearVertex(let vertex, _):
            return vertex.point.scaled(geometry)
        case .inGate(let gate, let edge):
            return LayoutService.gatePosition(geometry, edge: edge, gate: gate)
        }
    }
}

enum ResourceTransferType {
    case unspecify
    case failGate(edge: Edge, gate: EdgeGate)
    case alongEdge(edge: Edge)
    case toGate
    case fromGate
    case pickup
}

enum ResourceViewStatus {
    private typealias VertexSlot = (vertex: Vertex, slot: Int)
    
    private static let controlsRandomization: CGFloat = 100
    private static let toGateRandomizationRange = CGFloat(50)...CGFloat(100)
    private static let failedMovingRandomiztion: CGFloat = 100
    private static let failedMovingGap: CGFloat = 0.1
    
    case stable(state: ResourceViewState)
    case transfer(from: ResourceViewState, to: ResourceViewState, type: ResourceTransferType)
    
    var targetState: ResourceViewState {
        switch self {
        case .stable(let state):
            return state
        case .transfer(_, let to, _):
            return to
        }
    }
    
    func localOffset(_ geometry: GeometryProxy) -> Interpolation<CGPoint> {
        switch self {
        case .stable(let state):
            return .init(to: state.localOffset(geometry))
        case .transfer(let from, let to, _):
            let from = from.localOffset(geometry)
            let to = to.localOffset(geometry)
            return Interpolation<CGPoint>(from: from, to: to, timecurve: .linearTiming)
        }
    }
    
    func size(_ geometry: GeometryProxy) -> Interpolation<CGSize> {
        targetState.size(geometry)
    }
    
    func localAngle() -> Interpolation<CGFloat> {
        targetState.localAngle()
    }
    
    func positioningCurve(_ geometry: GeometryProxy) -> ComplexCurve {
        switch self {
        case .stable(let state):
            switch state {
            case .abscent:
                return .zero
            case .inVertex(let vertex, _, _), .nearVertex(let vertex, _):
                let point = vertex.point.scaled(geometry)
                return .onePoint(point)
            case .inGate(let gate, let edge):
                let point = LayoutService.gatePosition(geometry, edge: edge, gate: gate)
                return .onePoint(point)
            }
        case .transfer(let from, let to, let type):
            return transferCurve(geometry, from: from, to: to, type: type)
        }
    }
    
    func animationDuration(_ geometry: GeometryProxy) -> TimeInterval {
        return 3
    }

    // MARK: Calculations
    private func transferCurve(_ geometry: GeometryProxy, from: ResourceViewState, to: ResourceViewState, type: ResourceTransferType) -> ComplexCurve {
        switch type {
        case .unspecify, .pickup:
            let point = to.globalOffset(geometry)
            return .onePoint(point)
        case .failGate(let edge, let gate):
            guard case .nearVertex(let fromVertex, let fromSlot) = from else { return .zero }
            guard case .nearVertex(let toVertex, let toSlot) = to else { return .zero }
            let from = VertexSlot(fromVertex, fromSlot)
            let to = VertexSlot(toVertex, toSlot)
            return failNearGateCurve(geometry, edge: edge, gate: gate, from: from, to: to)
        case .alongEdge(let edge):
            guard case .nearVertex(let fromVertex, let fromSlot) = from else { return .zero }
            guard case .nearVertex(let toVertex, let toSlot) = to else { return .zero }
            let from = VertexSlot(fromVertex, fromSlot)
            let to = VertexSlot(toVertex, toSlot)
            return alongEdgeCurve(geometry, edge: edge, from: from, to: to)
        case .toGate:
            guard case .nearVertex(let vertex, let slot) = from else { return .zero }
            guard case .inGate(let gate, let edge) = to else { return .zero }
            let from = VertexSlot(vertex, slot)
            return toGateCurve(geometry, gate: gate, edge: edge, from: from)
        case .fromGate:
            guard case .inGate(let gate, let edge) = from else { return .zero }
            guard case .nearVertex(let vertex, let slot) = to else { return .zero }
            let to = VertexSlot(vertex, slot)
            return toGateCurve(geometry, gate: gate, edge: edge, from: to).reversed()
        }
    }
    
    private func alongEdgeCurve(_ geometry: GeometryProxy, edge: Edge, from: VertexSlot, to: VertexSlot) -> ComplexCurve {
        
        let forward = edge.from == from.vertex
        let rawP1 = forward ? edge.curve.p1 : edge.curve.p2
        let rawP2 = forward ? edge.curve.p2 : edge.curve.p1

        let p0 = LayoutService.resourcePosition(geometry, vertex: from.vertex, slot: from.slot)
        let p3 = LayoutService.resourcePosition(geometry, vertex: to.vertex, slot: to.slot)
        let p1 = rawP1.scaled(geometry)
        let p2 = rawP2.scaled(geometry)
        
        return .init(points: [p0, p1, p2, p3])
    }
    
    private func failNearGateCurve(_ geometry: GeometryProxy, edge: Edge, gate: EdgeGate, from: VertexSlot, to: VertexSlot) -> ComplexCurve {
        
        let p0 = LayoutService.resourcePosition(geometry, vertex: from.vertex, slot: from.slot)
        let p6 = LayoutService.resourcePosition(geometry, vertex: to.vertex, slot: to.slot)
        let controls = failNearGateControls(geometry, edge: edge, gate: gate, vertex: from.vertex, slot: from.slot)
        
        let to = BezierCurve(points: [p0, controls[0], controls[1], controls[2]])
        let from = BezierCurve(points: [controls[2], controls[3], controls[4], p6])
        
        return .init([to, from])
    }
    
    private func failNearGateControls(_ geometry: GeometryProxy, edge: Edge, gate: EdgeGate, vertex: Vertex, slot: Int) -> [CGPoint] {
        let cached = GeometryCacheService.shared.failNearGate(gate: gate, vertex: vertex)
        if let cached = cached { return cached }
        
        let gateT = LayoutService.gateProgress(geometry, edge: edge, gate: gate)
        let t = edge.from == vertex ? gateT + Self.failedMovingGap : gateT - Self.failedMovingGap
        let nearGate = edge.curve.scaled(geometry).getPoint(t: t)
        
        let mid = vertex.point.scaled(geometry).average(with: nearGate)
        let c1p1 = mid.randomPoint(maxDelta: Self.controlsRandomization)
        let c2p2 = mid.randomPoint(maxDelta: Self.controlsRandomization)
        
        let distance = CGFloat.random(in: Self.toGateRandomizationRange)
        let angle = edge.curve.scaled(geometry).getNormaAngle(t: t)
        let c1p2 = CGPoint(center: nearGate, angle: angle, radius: distance)
        let c2p1 = CGPoint(center: nearGate, angle: angle + .pi, radius: distance)
        
        let result = [c1p1, c1p2, nearGate, c2p1, c2p2]
        GeometryCacheService.shared.setFailNearGate(gate: gate, vertex: vertex, controls: result)
        return result
    }
    
    private func toGateCurve(_ geometry: GeometryProxy, gate: EdgeGate, edge: Edge, from: VertexSlot) -> ComplexCurve {
        let p0 =  LayoutService.resourcePosition(geometry, vertex: from.vertex, slot: from.slot)
        let p3 = LayoutService.gatePosition(geometry, edge: edge, gate: gate)
        let mid = p0.average(with: p3)
        let p1 = mid.randomPoint(maxDelta: Self.controlsRandomization)
        let p2 = mid.randomPoint(maxDelta: Self.controlsRandomization)
        return .init(points: [p0, p1, p2, p3])
    }

}

struct Interpolation<Value> where Value: VectorArithmetic {
    let from: Value
    let to: Value
    let timecurve: BezierCurve?
    
    static func zero() -> Interpolation<Value> {
        return Interpolation<Value>(to: .zero)
    }
    
    func value(_ t: CGFloat) -> Value {
        guard let timecurve = timecurve else { return to }
        let progress = timecurve.getY(t: t)
        return from + (to - from).scaled(by: progress)
    }
    
    subscript(_ t: CGFloat) -> Value {
        return value(t)
    }
    
    init (to: Value) {
        self.from = to
        self.to = to
        self.timecurve = nil
    }
    
    init (from: Value, to: Value, timecurve: BezierCurve? = nil) {
        self.from = from
        self.to = to
        self.timecurve = timecurve
    }
}

struct ReourceViewStatusHandler: AnimatableModifier {

    let positioningCurve: ComplexCurve
    let positioningProgress: Interpolation<CGFloat>
    let size: Interpolation<CGSize>
//    let globalOffset: Interpolation<CGPoint>
    let localOffset: Interpolation<CGPoint>
    let localAngle: Interpolation<CGFloat>
    
    private var progress: CGFloat = 0

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue
            print("Progress: \(progress)")
        }
    }
    
    init(_ geometry: GeometryProxy, status: ResourceViewStatus, progress: CGFloat) {
        positioningCurve = status.positioningCurve(geometry)
        positioningProgress = .init(from: 0, to: 1, timecurve: .linearTiming)
        size = status.size(geometry)
        localOffset = status.localOffset(geometry)
        localAngle = status.localAngle()
        
        self.progress = progress
    }
    
    func body(content: Content) -> some View {
        content
            .frame(size: size[progress])
            .offset(point: localOffset[progress])
            .rotationEffect(Angle(radians:localAngle[progress]))
            .bezierPositioning(curve: positioningCurve, progress: positioningProgress[progress])
//            .offset(point: globalOffset[progress]])
    }
}

extension VectorArithmetic {
    func scaled(by: Double) -> Self {
        var copy = self
        copy.scale(by: by)
        return copy
    }
}
