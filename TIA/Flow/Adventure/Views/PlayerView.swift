//
//  PlayerView.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import SwiftUI

struct PlayerWrapperView: View {

    @ObservedObject var player: PlayerViewModel

    var body: some View {
        CenteredGeometryReader { geometry in
            if isVisible {
                let positionProgress = positionProgress(geometry)
                PlayerView(player: player, superSize: geometry.size)
                    .bezierPositioning(curve: curve(geometry), progress: positionProgress)
                    .onAnimationCompleted(for: positionProgress) {
                        player.model.movingFinished()
                    }
                    .animation(positionAnimation(geometry), value: positionProgress)
            }
        }
    }

    private var isVisible: Bool {
        switch player.metastate {
        case .abscent:
            return false
        default:
            return true
        }
    }

    private func positionProgress(_ geometry: GeometryProxy) -> CGFloat {
        switch player.metastate {
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
        switch player.metastate {
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
        switch player.metastate {
        case .abscent, .vertex, .compressing, .expanding:
            return nil
        case .moving(let edge, _):
            let length = edge.length(geometry)
            return AnimationService.playerMoving(length: length)
        case .movingToGate(let gate, let edge, let forward),
                .movingFromGate(let gate, let edge, let forward):
            guard let index = edge.gates.firstIndex(of: gate) else {
                return nil
            }
            let ratio = CGFloat(index + 1) / CGFloat(edge.gates.count + 1)
            let multiplier = forward ? ratio : 1 - ratio
            let length = edge.length(geometry) * multiplier
            return AnimationService.playerMoving(length: length)
        }
    }
}

fileprivate extension View {
    func maskToCurrentEdgeVertices(player: PlayerViewModel, size: CGSize) -> some View {
        invertedMask(size: size,
            ZStack {
                ForEach(player.currentEdgeVertices(), id: \.model.id) { viewModel in
                    VertexWrapper(vertex: viewModel)
                }
            }.frame(size: size)
        )
    }
}

struct PlayerView: View {
    @ObservedObject var player: PlayerViewModel
    var superSize: CGSize

    var body: some View {
        CenteredGeometryReader { geometry in
            if player.position.currentEdge != nil {
                ComplexCurveShape(curve: .circle(radius: 0.5))
                    .frame(size: blobSize(geometry))
                    .foregroundColor(blobColor)
                    .maskToCurrentEdgeVertices(player: player, size: superSize)
                    .transition(.identity)
            }

            EyeView(eye: player.eye, color: player.color)
                .frame(size: eyeSize(geometry))
        }
    }

    var blobColor: Color {
        return player.currentEdgeColor()
    }

    func blobSize(_ geometry: GeometryProxy) -> CGFloat {
        geometry.minSize * Layout.Player.blobSize
    }

    func eyeSize(_ geometry: GeometryProxy) -> CGFloat {
        geometry.minSize * Layout.Player.eyeSize
    }
}
