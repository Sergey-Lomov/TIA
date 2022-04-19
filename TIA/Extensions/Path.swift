//
//  Path.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import SwiftUI

extension Path {
    
    init (curves: [BezierCurve], size: CGSize? = nil) {
        self.init()
        
        for curve in curves {
            var normalizedCurve = curve
            if let size = size {
                normalizedCurve = curve
                    .multedCurve(x: size.width, y: size.height)
                    .translatedCurve(x: size.width / 2, y: size.height / 2)
            }
        
            addCurve(normalizedCurve)
        }
        
        //closeSubpath()
    }
    
    init (curve: BezierCurve, size: CGSize? = nil) {
        self.init(curves: [curve], size: size)
    }
    
    init(curve: BezierCurve, geometry: GeometryProxy? = nil) {
        self.init(curve: curve, size: geometry?.size)
    }
    
    mutating func addCurve(_ curve: BezierCurve) {
        if currentPoint != curve.from {
            move(to: curve.from)
        }
        addCurve(to: curve.to, control1: curve.control1, control2: curve.control2)
    }
}
