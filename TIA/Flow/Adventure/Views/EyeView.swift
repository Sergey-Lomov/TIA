//
//  EyeView.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import SwiftUI

private struct StrokeWidthKey: EnvironmentKey {
    static var defaultValue: CGFloat = 1
}

private extension EnvironmentValues {
    var strokeWidth: CGFloat {
        get { self[StrokeWidthKey.self] }
        set { self[StrokeWidthKey.self] = newValue }
    }
}

struct EyeView: View {
    @Binding var eye: EyeViewModel

    var color: Color
    var onAnimationFinish: Action?

    var body: some View {
        return GeometryReader { geometry in
            ZStack {
                EyelidView(status: $eye.status)
                EyeballView(size: geometry.size)
                    .mask(
                        EyeSocketView(eye: $eye)
                    )

            }
            .foregroundColor(color)
            .frame(geometry: geometry)
            .environment(\.strokeWidth, strockeWidth(geometry))
        }.onAppear {
            eye.open()
        }
    }

    private func strockeWidth(_ geometry: GeometryProxy) -> CGFloat {
        geometry.minSize * Layout.Player.strokeRatio
    }
}

private struct EyeSocketView: View {

    @Binding var eye: EyeViewModel

    var curve: ComplexCurve { ComplexCurve.eyelid(status: eye.status) }
    var animation: Animation? { Animation.forStatus(eye.status) }

    var body: some View {
        ComplexCurveShape(curve: curve)
            .foregroundColor(.black)
            .onAnimationCompleted(for: curve) {
                eye.transitionFinished()
            }
            .animation(animation, value: curve)
    }
}

private struct EyelidView: View {

    private let compressedMult: CGFloat = 4

    @Environment(\.strokeWidth) var strokeWidth
    @Binding var status: EyeStatus

    var curve: ComplexCurve { ComplexCurve.eyelid(status: status) }
    var animation: Animation? { Animation.forStatus(status) }

    var body: some View {
        ComplexCurveShape(curve: curve, close: true)
            .stroke(style: style)
            .animation(animation, value: curve)
    }

    var style: StrokeStyle {
        var width: CGFloat = 0
        switch status.targetState {
        case .compressed:
            width = strokeWidth * compressedMult
        default:
            width = strokeWidth
        }

        return StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
    }
}

private struct EyeballView: View {
    private let pupilSize: CGFloat = 0.2
    private let eyeballSize: CGFloat = 0.4

    @Environment(\.strokeWidth) var strokeWidth
    var size: CGSize

    var body: some View {
        ZStack {
            let pupilSize = size.scaled(pupilSize)
            let eyeballSize = size.scaled(eyeballSize)

            ComplexCurveShape(curve: .circle(radius: 0.5))
                .stroke(lineWidth: strokeWidth)
                .frame(size: eyeballSize)
            ComplexCurveShape(curve: .circle(radius: 0.5))
                .frame(size: pupilSize)
        }.frame(size: size)
    }
}

private extension BezierCurve {

    private static let closedTopEyelid = BezierCurve(points: [
        CGPoint(x: -0.5, y: 0),
        CGPoint(x: -0.25, y: 0),
        CGPoint(x: 0.25, y: 0),
        CGPoint(x: 0.5, y: 0)
    ])

    private static let topEyelid = BezierCurve(points: [
        CGPoint(x: -0.5, y: 0),
        CGPoint(x: -0.25, y: -0.375),
        CGPoint(x: 0.25, y: -0.375),
        CGPoint(x: 0.5, y: 0)
    ])

    static func topEyelid(state: EyeState) -> BezierCurve {
        switch state {
        case .compressed: return .zero
        case .closed: return .closedTopEyelid
        case .opened: return .topEyelid
        }
    }
}

private extension ComplexCurve {
    static func eyelid(state: EyeState) -> ComplexCurve {
        return ComplexCurve([
            .topEyelid(state: state),
            .topEyelid(state: state).mirrored().reversed()
        ])
    }

    static func eyelid(status: EyeStatus) -> ComplexCurve {
        switch status {
        case .state(let state):
            return ComplexCurve.eyelid(state: state)
        case .transiotion(_, let to):
            return ComplexCurve.eyelid(state: to)
        }
    }
}

private extension Animation {

    static func forStatus(_ status: EyeStatus) -> Animation? {
        switch status {
        case .state:
            return .default
        case .transiotion(let from, let to):
            return AnimationService.eyeTransAnimation(from: from, to: to)
        }
    }
}
