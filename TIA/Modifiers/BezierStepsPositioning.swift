//
//  BezierStepsPositioning.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import SwiftUI

struct BezierStepsPositioning: AnimatableModifier {
    
    private var _step: Int
    var step: Int {
        get { _step }
        set { _step = newValue.normalized(min: 0, max: curves.count - 1)}
    }
    
    var curves: [BezierCurve]
    var stepProgress: CGFloat = 0
    
    /// To simplify calculation, progress here have value from 0 to curves count insted from 0 to 1 like ussually
    var progress: CGFloat {
        get {
            (1 / CGFloat(curves.count)) * (CGFloat(step) + stepProgress)
        }
        set {
            step = Int(floor(newValue * CGFloat(curves.count)))
            stepProgress = newValue * CGFloat(curves.count) - CGFloat(step)
        }
    }
    
    init(step: Int, curves: [BezierCurve]) {
        self._step = step.normalized(min: 0, max: curves.count - 1)
        self.curves = curves
    }
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        CenteredGeometryReader {
            content
                .offset(x: curves[step].getX(t: stepProgress), y: curves[step].getY(t: stepProgress))
                .animation(nil)
        }
    }
}
