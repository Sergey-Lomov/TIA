//
//  BezierPositioning.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import SwiftUI

struct BezierPositioning: Animatable, ViewModifier  {
    
    let curve: BezierCurve
    var progress: CGFloat
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        CenteredGeometryReader {
            content
                .offset(x: curve.getX(t: progress), y: curve.getY(t: progress))
                .animation(nil)
        }
    }
}
