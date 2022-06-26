//
//  CameraModifier.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import SwiftUI

struct CameraModifier: ViewModifier {

    @ObservedObject var camera: CameraViewModel
    
    func body(content: Content) -> some View {
        CenteredGeometryReader { geometry in
            content
                .rotationEffect(angle, anchor: anchor(geometry))
                .scaleEffect(zoom, anchor: anchor(geometry))
                .offset(point: offset)
                // TODO: Test in case, when rotation and zoom is valuable, but offset is zero. Change to state animation.
                .onAnimationCompleted(for: offset) {
                    camera.stepApplied()
                }
                .animation(animation, value: offset)
                .onRedraw {
                    if animation == .none {
                        camera.stepApplied()
                    }
                }
        }
    }
    
    private var zoom: CGFloat { camera.state.zoom }
    private var offset: CGPoint { camera.state.center.scaled(-1) }
    private var angle: Angle { Angle(radians: camera.state.angle) }
    private var animation: Animation { camera.animation }
    
    private func anchor(_ geometry: GeometryProxy) -> UnitPoint {
        let point = camera.anchorState.center.scaled(-1)
        let unitX = 0.5 - point.x / geometry.size.width
        let unitY = 0.5 - point.y / geometry.size.height
        return UnitPoint(x: unitX, y: unitY)
    }
}
