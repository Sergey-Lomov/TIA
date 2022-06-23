//
//  CameraModifier.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import SwiftUI

struct CameraModifier: ViewModifier {

    var camera: CameraStatus
    var completion: Action?
    
    func body(content: Content) -> some View {
        CenteredGeometryReader { geometry in
            let point = camera.state.center.scaled(-1)
            let unitX = 0.5 + point.x / geometry.size.width
            let unitY = 0.5 + point.y / geometry.size.height
            let zoomAnchor = UnitPoint(x: unitX, y: unitY)
            content
                .offset(point: point)
                .animation(animation, value: point)
                .scaleEffect(camera.state.zoom, anchor: zoomAnchor)
                .animation(animation, value: camera.state.zoom)
                .onAnimationCompleted(for: point, completion: completion)
        }
    }
    
    private var animation: Animation? {
        switch camera {
        case .fixed: return .linear(duration: 0)
        case .transition(_, let animation): return animation
        }
    }
}
