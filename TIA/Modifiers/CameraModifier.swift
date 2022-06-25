//
//  CameraModifier.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import SwiftUI

struct CameraStateManagerModifier: ViewModifier {
    
    @Binding var camera: CameraStatus
    var completion: Action?
    
    func body(content: Content) -> some View {
        content
            .applyCamera(camera) {
                handleAnimationCompletion()
            }
            .onRedraw {
                handleRedraw()
            }
    }
    
    private func handleRedraw() {
        switch camera {
        case .fixed:
            completion?()
        case .pretransition(_, let to, let animation):
            camera = .transition(to: to, animation: animation)
        default:
            break
        }
    }
    
    private func handleAnimationCompletion() {
        switch camera {
        case .transition(let to, _):
            camera = .fixed(state: to)
        default:
            break
        }
    }
    
}

struct CameraModifier: ViewModifier {

    var camera: CameraStatus
    var completion: Action?
    
    func body(content: Content) -> some View {
        CenteredGeometryReader { geometry in
            content
                .rotationEffect(angle, anchor: anchor(geometry))
                .scaleEffect(zoom, anchor: anchor(geometry))
                .offset(point: offset)
                // TODO: Test in case, when rotation and zoom is valuable, but offset is zero. Change to state animation.
                .onAnimationCompleted(for: offset, completion: completion)
                .animation(animation, value: offset)
        }
    }
    
    private var zoom: CGFloat {
        switch camera {
        case .fixed(let state),
                .pretransition(let state, _, _),
                .transition(let state, _):
            return state.zoom
        }
    }
    
    private var offset: CGPoint {
        switch camera {
        case .fixed(let state),
                .pretransition(let state, _, _),
                .transition(let state, _):
            return state.center.scaled(-1)
        }
    }
    
    private var angle: Angle {
        switch camera {
        case .fixed(let state),
                .pretransition(let state, _, _),
                .transition(let state, _):
            return Angle(radians: state.angle)
        }
    }
    
    private var animation: Animation? {
        switch camera {
        case .fixed, .pretransition: return .linear(duration: 0)
        case .transition(_, let animation): return animation
        }
    }
    
    private func anchor(_ geometry: GeometryProxy) -> UnitPoint {
        switch camera {
        case .fixed(let state),
                .pretransition(_, let state, _),
                .transition(let state, _):
            return anchor(geometry, state: state)
        }
    }
    
    private func anchor(_ geometry: GeometryProxy, state: CameraState) -> UnitPoint {
        let point = state.center.scaled(-1)
        let unitX = 0.5 - point.x / geometry.size.width
        let unitY = 0.5 - point.y / geometry.size.height
        return UnitPoint(x: unitX, y: unitY)
    }
}
