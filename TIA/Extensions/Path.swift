//
//  Path.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import SwiftUI

extension Path {
    
    init (curve: BezierCurve, size: CGSize? = nil) {
        self.init()
        
        var normalizedCurve = curve
        if let size = size {
            normalizedCurve = curve
                .multedCurve(x: size.width, y: size.height)
                .translatedCurve(x: size.width / 2, y: size.height / 2)
        }
        
        move(to: normalizedCurve.from)
        addCurve(to: normalizedCurve.to,
                 control1: normalizedCurve.control1,
                 control2: normalizedCurve.control2)
    }
    
    init(curve: BezierCurve, geometry: GeometryProxy? = nil) {
        self.init(curve: curve, size: geometry?.size)
    }
}
