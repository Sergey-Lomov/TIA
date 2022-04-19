//
//  EyeView.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import SwiftUI

private enum EyeState {
    case initial
    case expanding
    case opening
    case opened
    
    var isOpen: Bool {
        switch self {
        case .initial, .expanding:
            return false
        default:
            return true
        }
    }
}

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
    @State private var state: EyeState = .initial
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                EyelidView(state: $state)
                EyeballView(size: geometry.size)
                    .mask(
                        EyeSocketView(state: $state)
                    )
                    
            }
            .foregroundColor(color)
            .frame(geometry: geometry)
            .environment(\.strokeWidth, geometry.minSize * strokeRatio)
        }.onAppear() { state = .expanding }
    }
}

struct EyeView_Previews: PreviewProvider {
    static var previews: some View {
        EyeView(color: .softBlack)
    }
}

private struct EyeSocketView: View {
    
    @Binding fileprivate var state: EyeState
    var curve: ComplexCurve { ComplexCurve.eyelid(state: state) }
    
    var body: some View {
        ComplexCurveShape(curve: curve)
            .onReach(curve) { handleAnimationFinish() }
            .foregroundColor(.black)
            .animation(Animation.forState(state), value: curve)
    }
    
    func handleAnimationFinish() {
        DispatchQueue.main.async {
            if state == .expanding {
                state = .opening
            } else if state == .opening {
                state = .opened
            }
        }
    }
}

private struct EyelidView: View {

    @Environment(\.strokeWidth) var strokeWidth
    @Binding fileprivate var state: EyeState
    var curve: ComplexCurve { ComplexCurve.eyelid(state: state) }
    
    var body: some View {
        ComplexCurveShape(curve: curve)
            .stroke(style: style)
            .animation(Animation.forState(state), value: curve)
    }

    var style: StrokeStyle {
        switch state {
        case .initial, .expanding, .opening:
            return StrokeStyle(lineWidth: strokeWidth, lineJoin: .round)
        case .opened:
            return StrokeStyle(lineWidth: strokeWidth, lineJoin: .miter)
        }
    }
}

private struct EyeballView: View {
    private let pupilSize: CGFloat = 0.2
    private let eyeballSize: CGFloat = 0.4
    
    @Environment(\.strokeWidth) var strokeWidth
    var size: CGSize
    
    var body: some View {
        ZStack {
            let pupilSize = size.multed(pupilSize)
            let eyeballSize = size.multed(eyeballSize)
            
            CircleShape()
                .stroke(lineWidth: strokeWidth)
                .frame(size: eyeballSize)
            CircleShape()
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
        if state == .initial { return .zero }
        return state.isOpen ? .topEyelid : .closedTopEyelid
    }
    
    static func bottomEyelid(state: EyeState) -> BezierCurve {
        if state == .initial { return .zero }
        return state.isOpen ? .bottomEyelid : .closedBottomEyelid
    }
}

private extension ComplexCurve {
    static func eyelid(state: EyeState) -> ComplexCurve {
        return ComplexCurve(components: [
            BezierCurve.topEyelid(state: state),
            BezierCurve.bottomEyelid(state: state)
        ])
    }
}

private extension Animation {
    static var expanding: Animation { .easeOut(duration: 0.5) }
    static var opening: Animation { .easeOut(duration: 1) }
    
    static func forState(_ state: EyeState) -> Animation {
        switch state {
        case .initial:
            return .default
        case .expanding:
            return .expanding
        case .opening:
            return .opening
        case .opened:
            return .default
        }
    }
}
