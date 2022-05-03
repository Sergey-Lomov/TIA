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
                    .bezierPositioning(curve: curve(geometry), progress: positionProgress) {
                        player.model.movingFinished()
                    }
                    .animation(positionAnimation, value: positionProgress)
                    .onReceive(player.objectWillChange) {
                        positionProgress = positionProgress(geometry)
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
    
    private func positionProgress(_ geometry: GeometryProxy) -> CGFloat {
        switch player.model.metastate {
        case .moving:
            return 1
        case .movingToGate(let edge, let index, let forward):
            let progress = LayoutService.gateProgress(geometry, edge: edge, index: index)
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
                .movingToGate(let edge, _, let forward),
                .movingFromGate(let edge, _, let forward):
            let scaled = edge.curve.scaled(geometry)
            return forward ? scaled : scaled.reversed()
        case .vertex(let vertex),
                .compressing(let vertex),
                .expanding(let vertex):
            let point = vertex.point.scaled(geometry)
            return .onePoint(point)
        }
    }
    
    private var positionAnimation: Animation? {
        switch player.position {
        case .abscent, .vertex:
            return nil
        case .edge(let edge, _, _):
            return .positioning(length: edge.length)
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
        let duration = AnimationService.shared.playerMovingDuration(edgeLength: length)
        return .linear(duration: duration)
    }
}
