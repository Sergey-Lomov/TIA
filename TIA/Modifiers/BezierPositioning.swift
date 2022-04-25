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
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue
            if progress == 1 {
                onFinish?()
            }
        }
    }
    
    func body(content: Content) -> some View {
        CenteredGeometryReader {
            content
                .offset(x: curve.getX(t: progress), y: curve.getY(t: progress))
                .animation(nil)
        }
    }
}
