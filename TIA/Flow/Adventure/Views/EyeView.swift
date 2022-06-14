//
//  EyeView.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import SwiftUI

// TODO: Try to use default stroke style modifier instead
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
    private let strokeRatio = 0.05
    
    @Binding var eye: EyeViewModel
    
    var color: Color
    var onAnimationFinish: (() -> Void)?

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
            .environment(\.strokeWidth, geometry.minSize * strokeRatio)
        }.onAppear {
            eye.open()
        }
    }
}

private struct EyeSocketView: View {
    
    @Binding var eye: EyeViewModel
    
    var curve: ComplexCurve { ComplexCurve.eyelid(status: eye.status) }
    var animation: Animation? { Animation.forStatus(eye.status) }
    
    var body: some View {
        ComplexCurveShape(curve: curve)
            .onReach(curve) {
                eye.transitionFinished()
            }
            .foregroundColor(.black)
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
            
            CircleShape()
                .stroke(lineWidth: strokeWidth)
                .frame(size: eyeballSize)
            CircleShape()
                .frame(size: pupilSize)
        }.frame(size: size)
    }
}

private extension BezierCurve {
    // TODO: Change bottom eyelid curves from predefined valus to calculated. To convert top eyelid to bottom should be used mirroring and reversing (change curve direction)
    private static let closedTopEyelid = BezierCurve(points: [
        CGPoint(x: -0.5, y: 0),
        CGPoint(x: -0.25, y: 0),
        CGPoint(x: 0.25, y: 0),
        CGPoint(x: 0.5, y: 0)
    ])
    
    private static let closedBottomEyelid = BezierCurve(points: [
        CGPoint(x: 0.5, y: 0),
        CGPoint(x: 0.25, y: 0),
        CGPoint(x: -0.25, y: 0),
        CGPoint(x: -0.5, y: 0),
    ])
    
    private static let topEyelid = BezierCurve(points: [
        CGPoint(x: -0.5, y: 0),
        CGPoint(x: -0.25, y: -0.375),
        CGPoint(x: 0.25, y: -0.375),
        CGPoint(x: 0.5, y: 0)
    ])
    
    private static let bottomEyelid = BezierCurve(points: [
        CGPoint(x: 0.5, y: 0),
        CGPoint(x: 0.25, y: 0.375),
        CGPoint(x: -0.25, y: 0.375),
        CGPoint(x: -0.5, y: 0),
    ])
    
    static func topEyelid(state: EyeState) -> BezierCurve {
        switch state {
        case .compressed:
            return .zero
        case .closed:
            return .closedTopEyelid
        case .opened:
            return .topEyelid
        }
    }
    
    static func bottomEyelid(state: EyeState) -> BezierCurve {
        switch state {
        case .compressed:
            return .zero
        case .closed:
            return .closedBottomEyelid
        case .opened:
            return .bottomEyelid
        }
    }
}

private extension ComplexCurve {
    static func eyelid(state: EyeState) -> ComplexCurve {
        return ComplexCurve([
            BezierCurve.topEyelid(state: state),
            BezierCurve.bottomEyelid(state: state)
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
            return AnimationService.shared.eyeTransAnimation(from: from, to: to)
        }
    }
}
