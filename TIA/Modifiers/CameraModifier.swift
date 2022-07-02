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
            let transform = transform(geometry)
            content
                .modifier(CameraTransformApplier(transform: transform))
                .onAnimationCompleted(for: transform) {
                    camera.stepApplied()
                }
                .animation(camera.animation, value: transform)
                .onRedraw {
                    if camera.immideatelyUpdate {
                        camera.stepApplied()
                    }
                }
        }
    }

    private func transform(_ geometry: GeometryProxy) -> CameraTransform {
        .init(zoom: camera.state.zoom,
              offset: camera.state.center.scaled(-1),
              angle: camera.state.angle,
              anchor: anchor(geometry))
    }

    private func anchor(_ geometry: GeometryProxy) -> UnitPoint {
        let point = camera.anchorState.center.scaled(-1)
        let unitX = 0.5 - point.x / geometry.size.width
        let unitY = 0.5 - point.y / geometry.size.height
        return UnitPoint(x: unitX, y: unitY)
    }
}

private struct CameraTransformApplier: AnimatableModifier {

    var transform: CameraTransform

    var animatableData: CameraTransform {
        get { transform }
        set { transform = newValue }
    }

    func body(content: Content) -> some View {
        content
            .rotationEffect(angle, anchor: transform.anchor)
            .scaleEffect(transform.zoom, anchor: transform.anchor)
            .offset(point: transform.offset)
    }

    private var angle: Angle {
        Angle(radians: transform.angle)
    }
}

private struct CameraTransform {
    var zoom: CGFloat
    var offset: CGPoint
    var angle: CGFloat
    var anchor: UnitPoint
}

extension CameraTransform: VectorArithmetic {

    mutating func scale(by rhs: Double) {
        zoom.scale(by: rhs)
        offset.scale(by: rhs)
        angle.scale(by: rhs)
        anchor.scale(by: rhs)
    }

    var magnitudeSquared: Double {
        zoom * zoom + offset.magnitudeSquared * offset.magnitudeSquared + angle * angle + anchor.magnitudeSquared * anchor.magnitudeSquared
    }

    static var zero: CameraTransform {
        .init(zoom: .zero, offset: .zero, angle: .zero, anchor: .zero)
    }

    static func + (lhs: CameraTransform, rhs: CameraTransform) -> CameraTransform {
        .init(zoom: lhs.zoom + rhs.zoom, offset: lhs.offset + rhs.offset, angle: lhs.angle + rhs.angle, anchor: lhs.anchor + rhs.anchor)
    }

    static func - (lhs: CameraTransform, rhs: CameraTransform) -> CameraTransform {
        .init(zoom: lhs.zoom - rhs.zoom, offset: lhs.offset - rhs.offset, angle: lhs.angle - rhs.angle, anchor: lhs.anchor - rhs.anchor)
    }
}
