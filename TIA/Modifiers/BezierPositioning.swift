//
//  BezierPositioning.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import SwiftUI

struct BezierPositioning: AnimatableModifier {
    
    static private let defaultLengthSteps = 100
    
    private let curve: ComplexCurve
    private let ratios: [CGFloat]
    private let onFinish: Action?
    private var progress: CGFloat
    private var targetProgress: CGFloat
    private var deltaT: CGFloat
    
    init(curve: ComplexCurve, onFinish: Action?, progress: CGFloat, targetProgress: CGFloat = 1, deltaT: CGFloat = 0, lengthSteps: Int = defaultLengthSteps) {
        self.curve = curve
        self.onFinish = onFinish
        self.progress = progress
        self.targetProgress = targetProgress
        self.deltaT = deltaT
        
        let lengths = curve.components.map {
            $0.length(stepsCount: lengthSteps)
        }
        let total = lengths.reduce(0, +)
        self.ratios = lengths.map { Math.divide($0, total) }
    }
    
    public var animatableData: CGFloat {
        get { progress }
        set {
            progress = newValue
            if progress == targetProgress {
                onFinish?()
            }
        }
    }
    
    func body(content: Content) -> some View {
        CenteredGeometryReader {
            let point = getPoint(t: progress - deltaT)
            content
                .offset(point: point)
                .animation(nil, value: point)
        }
    }
    
    private func getPoint(t: CGFloat) -> CGPoint {
        guard !curve.components.isEmpty else { return .zero }
        
        var left = t
        var index = 0
        while index < ratios.count - 1 && ratios[index] < left {
            left -= ratios[index]
            index += 1
        }
        let local = Math.divide(left, ratios[index])
        let curve = curve.components[index]
        return curve.getPoint(t: local)
    }
}
