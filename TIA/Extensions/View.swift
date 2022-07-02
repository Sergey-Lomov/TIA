//
//  View.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import SwiftUI

extension View {

    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func frame(geometry: GeometryProxy) -> some View {
        frame(size: geometry.size)
    }

    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }

    func frame(size: CGFloat) -> some View {
        frame(width: size, height: size)
    }

    func offset(point: CGPoint) -> some View {
        return offset(x: point.x, y: point.y)
    }

    func offset(point: CGPoint, geometry: GeometryProxy) -> some View {
        let scaled = point.scaled(geometry)
        return offset(x: scaled.x, y: scaled.y)
    }

    func bezierPositioning(curve: BezierCurve,
                           progress: CGFloat = 0) -> some View {
        bezierPositioning(curve: ComplexCurve(curve), progress: progress)
    }

    func bezierPositioning(curve: ComplexCurve,
                           progress: CGFloat = 0) -> some View {
        modifier(BezierPositioning(curve: curve, progress: progress))
    }

    func offset(_ point: CGPoint, geomtery: GeometryProxy) -> some View {
        let x = point.x * geomtery.size.width
        let y = point.y * geomtery.size.height
        return offset(x: x, y: y)
    }

    func invertedMask<Mask>(size: CGSize, _ mask: Mask) -> some View where Mask: View {
        self.mask(
            ZStack {
                Rectangle()
                    .foregroundColor(.yellow)
                mask.blendMode(.destinationOut)
            }.frame(size: size)
        )
    }

    func onRedraw(closure: @escaping Action) -> some View {
        modifier(ViewRedrawHandlerModifier(handler: closure))
    }

    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: Action?) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion ?? emptyAction))
    }

    func drawingProgress(_ value: CGFloat) -> some View {
        modifier(DrawingProgressModifier(drawingProgress: value))
    }

    func applyCamera(_ camera: CameraViewModel, completion: Action? = nil) -> some View {
        if let completion = completion { camera.completion = completion }
        return modifier(CameraModifier(camera: camera	))
    }
}

extension View where Self: Animatable {
    func animate(builder: (inout [AnimationState<AnimatableData>]) -> Void) -> StatesAnimationView<Self> {
        var states = [AnimationState<AnimatableData>]()
        builder(&states)
        return StatesAnimationView(content: self, states: states)
    }
}
