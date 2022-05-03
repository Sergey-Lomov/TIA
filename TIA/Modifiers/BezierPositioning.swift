//
//  BezierPositioning.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import SwiftUI

struct BezierPositioning: AnimatableModifier  {
    
    let curve: BezierCurve
    let onFinish: (() -> Void)?
    var progress: CGFloat
    var targetProgress: CGFloat
    var point: CGPoint
    
    init(curve: BezierCurve, onFinish: (() -> Void)?, progress: CGFloat, targetProgress: CGFloat = 1) {
        self.curve = curve
        self.onFinish = onFinish
        self.progress = progress
        self.targetProgress = targetProgress
        
        point = CGPoint(x: curve.getX(t: progress), y: curve.getY(t: progress))
    }
    
    public var animatableData: CGFloat {
        get { progress }
        set {
            progress = newValue
            point = CGPoint(x: curve.getX(t: progress), y: curve.getY(t: progress))
            if progress == targetProgress {
                onFinish?()
            }
        }
    }
    
    func body(content: Content) -> some View {
        CenteredGeometryReader {
            content
                .offset(point: point)
                .animation(nil, value: point)
        }
    }
}
