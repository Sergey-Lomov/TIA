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
                ResourceView(resource: resource)
                    .frame(size: size(geometry))
                    .offset(point: resPosition, geometry: geometry)
                    .rotationEffect(angle)
                    .offset(point: vertexPosition, geometry: geometry)
                // TODO: Change constant rotation animation to different animation based on resource or vertex personality
                    .animation(.rotation, value: angle)
                    .transition(transition)
                    .onAppear {
                        withAnimation {
                            isIdle = true
                        }
                    }
            }
        }
    }
    
    func size(_ geometry: GeometryProxy) -> CGSize {
        switch resource.state {
        case .ownByPlayer:
            return CGSize(Layout.Vertex.radius * Layout.Resources.Player.sizeRatio).multed(geometry.minSize)
        case .inVertex:
            return CGSize(Layout.Vertex.radius * Layout.Resources.Vertex.sizeRatio).multed(geometry.minSize)
        }
    }

    var isVisible: Bool {
        switch resource.state {
        case .ownByPlayer:
            return true
        case .inVertex(let vertex, _, _):
            return vertex.state.isGrowed
        }
    }
    
    var vertexPosition: CGPoint {
        switch resource.state {
        case .ownByPlayer:
            return .zero
        case .inVertex(let vertex, _, _):
            return vertex.point
        }
    }
    
    var resPosition: CGPoint {
        switch resource.state {
        case .ownByPlayer:
            return .zero
        case .inVertex(_, let index, let total):
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

struct ResourceView_Previews: PreviewProvider {
    static var previews: some View {
        let resource = Resource(type: .despair, state: .ownByPlayer)
        let viewModel = ResourceViewModel(model: resource, color: .softBlack, borderColor: .green)
        ResourceView(resource: viewModel)
    }
}

// TODO: Should be removed if became unused after adding different idle animations for resources based on vertex personality.
private extension Animation {
    static var rotation: Animation {
        linear(duration: 10).repeatForever(autoreverses: false)
    }
}
