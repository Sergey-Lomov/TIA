//
//  BezierCurve.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import CoreGraphics

struct BezierCurve {
    let p0: CGPoint
    let p1: CGPoint
    let p2: CGPoint
    let p3: CGPoint
    
    init(from: CGPoint, to: CGPoint, control1: CGPoint, control2: CGPoint) {
        self.init(points: [from, control1, control2, to])
    }
    
    init(points:[CGPoint]) {
        p0 = points[0]
        p1 = points[1]
        p2 = points[2]
        p3 = points[3]
    }
    
    private func getCoord(t: CGFloat, p0: CGFloat, p1: CGFloat, p2: CGFloat, p3: CGFloat) -> CGFloat {
        let c1 = pow(1 - t, 3) * p0
        let c2 = 3 * pow(1 - t, 2) * t * p1
        let c3 = 3 * (1 - t) * pow(t, 2) * p2
        let c4 = pow(t, 3) * p3
        return c1 + c2 + c3 + c4
    }
    
    func getX(t: CGFloat) -> CGFloat {
        return getCoord(t: t, p0: p0.x, p1: p1.x, p2: p2.x, p3: p3.x)
    }
    
    func getY(t: CGFloat) -> CGFloat {
        return getCoord(t: t, p0: p0.y, p1: p1.y, p2: p2.y, p3: p3.y)
    }
}
