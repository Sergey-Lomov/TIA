//
//  ResourceStateHandler.swift
//  TIA
//
//  Created by serhii.lomov on 10.05.2022.
//

import SwiftUI

struct ResourceStateHandler: AnimatableModifier  {
    
    static private let defaultLengthSteps = 100
    
    private let id = UUID().uuidString
    private let positionCurve: ComplexCurve
    private let targetPositioning: CGFloat
    private let deltaPositioning: CGFloat
    private let ratios: [CGFloat]
    private var onFinish: Action?
    private var transform: ResourceStateTransform
    
    public var animatableData: ResourceStateTransform {
        get { transform }
        set { transform = newValue
            if newValue.positioning == targetPositioning {
                onFinish?()
                onFinish = nil
            }
        }
    }
    
    init(transform: ResourceStateTransform, positionCurve: ComplexCurve, onFinish: Action?, targetPositioning: CGFloat = 1, deltaPositioning: CGFloat = 0, lengthSteps: Int = defaultLengthSteps) {
        self.transform = transform
        self.positionCurve = positionCurve
        self.onFinish = onFinish
        self.targetPositioning = targetPositioning
        self.deltaPositioning = deltaPositioning
        
        let lengths = positionCurve.components.map {
            $0.length(stepsCount: lengthSteps)
        }
        let total = lengths.reduce(0, +)
        self.ratios = lengths.map { Math.divide($0, total) }
    }
    
    func body(content: Content) -> some View {
        CenteredGeometryReader {
            let point = getPoint(t: transform.positioning - deltaPositioning)
            content
                .offset(point: transform.localOffset)
                .rotationEffect(Angle(radians: transform.localAngle))
                .frame(size: transform.size)
                .opacity(transform.opacity)
                .offset(point: point)
        }
    }
    
    private func getPoint(t: CGFloat) -> CGPoint {
        guard !positionCurve.components.isEmpty else { return .zero }
        
        var left = t
        var index = 0
        while index < ratios.count - 1 && ratios[index] < left {
            left -= ratios[index]
            index += 1
        }
        let local = Math.divide(left, ratios[index])
        let curve = positionCurve.components[index]
        return curve.getPoint(t: local)
    }
}
