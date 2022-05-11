//
//  PlayerView.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import SwiftUI

struct PlayerWrapperView: View {
    
    @ObservedObject var player: PlayerViewModel
    @State var positionProgress: CGFloat = 0
    
    var body: some View {
        CenteredGeometryReader { geometry in
            if isVisible {
                PlayerView(player: player, superSize: geometry.size)
                    .bezierPositioning(curve: curve(geometry), progress: positionProgress, target: targetPositionProgress(geometry)) {
                        player.model.movingFinished()
                    }
                    .animation(positionAnimation(geometry), value: positionProgress)
                    .onReceive(player.objectWillChange) {
                        positionProgress = targetPositionProgress(geometry)
                    }
            }
        }
    }
    
    private var isVisible: Bool {
        switch player.model.metastate {
        case .abscent:
            return false
        default:
            return true
        }
    }
    
    private func targetPositionProgress(_ geometry: GeometryProxy) -> CGFloat {
        switch player.model.metastate {
        case .moving:
            return 1
        case .movingToGate(let gate, let edge, let forward):
            let progress = LayoutService.gateProgress(geometry, gate: gate, edge: edge)
            return forward ? progress : 1 - progress
        default:
            return 0
        }
    }

    private func curve(_ geometry: GeometryProxy) -> BezierCurve {
        switch player.model.metastate {
        case .abscent:
            return .zero
        case .moving(let edge, let forward),
                .movingToGate(_, let edge, let forward),
                .movingFromGate(_, let edge, let forward):
            let scaled = edge.curve.scaled(geometry)
            return forward ? scaled : scaled.reversed()
        case .vertex(let vertex),
                .compressing(let vertex),
                .expanding(let vertex):
            let point = vertex.point.scaled(geometry)
            return .onePoint(point)
        }
    }
    
    private func positionAnimation(_ geometry: GeometryProxy) -> Animation? {
        switch player.model.metastate {
        case .abscent, .vertex, .compressing, .expanding:
            return nil
        case .moving(let edge, _):
            return .positioning(length: edge.length(geometry))
        case .movingToGate(let gate, let edge, let forward),
                .movingFromGate(let gate, let edge, let forward):
            guard let index = edge.gates.firstIndex(of: gate) else {
                return nil
            }
            let ratio = CGFloat(index + 1) / CGFloat(edge.gates.count + 1)
            let multiplier = forward ? ratio : 1 - ratio
            let length = edge.length(geometry) * multiplier
            return .positioning(length: length)
        }
    }
}

fileprivate extension View {
    func maskToCurrentEdgeVertices(player: PlayerViewModel, size: CGSize) -> some View {
        invertedMask(size: size,
            ZStack {
                ForEach(player.currentEdgeVertices(), id: \.model.id) {
                    viewModel in
                    VertexWrapper(vertex: viewModel)
                }
            }.frame(size: size)
        )
    }
}

struct PlayerView: View {
    @Namespace private var eye
    @ObservedObject var player: PlayerViewModel
    var superSize: CGSize

    var body: some View {
        CenteredGeometryReader { geometry in
            if player.position.currnetEdge != nil {
                ComplexCurveShape(curve: .circle(radius: 0.5))
                    .frame(width: 16, height: 16)
                    .foregroundColor(edgeBlobColor)
                    .maskToCurrentEdgeVertices(player: player, size: superSize)
                    .transition(.identity)
            }
            
            EyeView(eye: $player.eye, color: player.color)
                .frame(width: 40, height: 40)
        }
    }
    
    var edgeBlobColor: Color {
        return player.currentEdgeColor()
    }
}

private extension Animation {
    static func positioning(length: CGFloat) -> Animation {
        let duration = AnimationService.shared.playerMovingDuration(length: length)
        return .linear(duration: duration)
    }
}
