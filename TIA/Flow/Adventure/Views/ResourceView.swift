//
//  ResourceView.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import SwiftUI

struct ResourceWrapper: View {
    private let transition = AnyTransition.opacity.animation(.easeInOut(duration: 2))
    
    @ObservedObject var resource: ResourceViewModel
    @State var isIdle = false
    
    var body: some View {
        CenteredGeometryReader { geometry in
            let angle = Angle(degrees: isIdle ? 360.0 : 0.0)
            if isVisible {
                switch resource.state {
                case .ownByPlayer:
                    ResourceView(resource: resource)
                        .frame(size: size(geometry))
                        .offset(point: resPosition(geometry))
                        .offset(point: vertexPosition, geometry: geometry)
                    //.animation(rotationAnimation, value: angle)
                    //    .transition(transition)
//                        .onAppear {
//                            withAnimation {
//                                isIdle = true
//                            }
//                        }
                case .inVertex:
                    ResourceView(resource: resource)
                        .frame(size: size(geometry))
                        .offset(point: resPosition(geometry))
                        .rotationEffect(angle)
                        .offset(point: vertexPosition, geometry: geometry)
                    // TODO: Change constant rotation animation to different animation based on resource or vertex personality
                        .animation(rotationAnimation, value: angle)
                        .transition(transition)
                        .onAppear {
                            withAnimation {
                                isIdle = true
                            }
                        }
                }
            }
        }
    }
    
    func size(_ geometry: GeometryProxy) -> CGSize {
        switch resource.state {
        case .ownByPlayer:
            return CGSize(Layout.Vertex.diameter * Layout.Resources.Player.sizeRatio).scaled(geometry.minSize)
        case .inVertex:
            return CGSize(Layout.Vertex.diameter * Layout.Resources.Vertex.sizeRatio).scaled(geometry.minSize)
        }
    }

    var isVisible: Bool {
        switch resource.state {
        case .ownByPlayer(let player, _):
            return !player.position.isAbscent
        case .inVertex(let vertex, _, _):
            return vertex.state.isGrowed
        }
    }
    
    var vertexPosition: CGPoint {
        switch resource.state {
        case .ownByPlayer(let player, _):
            guard let vertex = player.position.resourcesVertex else { return .zero }
            return vertex.point
        case .inVertex(let vertex, _, _):
            return vertex.point
        }
    }
    
    func resPosition(_ geometry: GeometryProxy) -> CGPoint {
        switch resource.state {
        case .ownByPlayer(let player, let index):
            guard let vertex = player.position.resourcesVertex else { return .zero }
            let service = VertexSurroundingService(screenSize: geometry.size)
            let surrounding = service.surroundingFor(vertex, slotsCount: index + 1)
            return surrounding.slots.last ?? .zero
        case .inVertex(_, let index, let total):
            if total == 1 {
                return .zero
            } else {
                let angle = CGFloat.pi * 2.0 / CGFloat(total) * CGFloat(index)
                var delta = CGPoint(x: cos(angle), y: sin(angle))
                delta.scale(by: Layout.Resources.Vertex.angleScale)
                return delta.scaled(geometry)
            }
        }
    }
    
    var rotationAnimation: Animation {
        switch resource.state {
        case .ownByPlayer:
            return .soloRotation
        case .inVertex(_, let index, let total):
            return total == 1 ? .soloRotation : .groupRotation
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
}

private extension PlayerPosition {
    var resourcesVertex: Vertex? {
        switch self {
        case .abscent:
            return nil
        case .edge(let edge, _, let direction):
            return direction == .forward ? edge.to : edge.from
        case .vertex(let vertex):
            return vertex
        }
    }
}
