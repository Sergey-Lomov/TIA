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
            if let position = player.position, !position.isAbscent {
                PlayerView(player: player, superSize: geometry.size)
                    .position(position, player: player, geometry: geometry)
            }
        }
    }
    
    func maskToCurrentEdgeVertices(player: PlayerViewModel) -> some View {
        CenteredGeometryReader {
            ForEach(player.currentEdgeVertices(), id: \.model.id) {
                viewModel in
                VertexWrapper(vertex: viewModel)
            }
        }
    }
}

fileprivate extension View {
    func position(_ position: PlayerPosition,
                  player: PlayerViewModel,
                  geometry: GeometryProxy) -> some View {
        var curve: BezierCurve = .zero
        var progress: CGFloat = 0
        var duration: TimeInterval = 0
        
        switch position {
        case .abscent:
            break
        case .edge(let edge, let status, let dir):
            curve = edge.curve.scaled(geometry)
            if dir == .backward { curve = curve.reversed() }
            progress = progressForStatus(status)
            duration = AnimationService.shared.playerMovingDuration(edgeLength: edge.length)
        case .vertex(let vertex):
            let point = vertex.point.scaled(geometry)
            curve = BezierCurve.onePoint(point)
        }

        return bezierPositioning(curve: curve, progress: progress) {
            player.model.movingFinished()
        }.animation(.linear(duration: duration), value: progress)
    }
    
    private func progressForStatus(_ status: EdgeMovingStatus) -> CGFloat {
        switch status {
        case .compressing:
            return 0
        case .moving:
            return 1
        case .expanding:
            return 1
        }
    }
    
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
