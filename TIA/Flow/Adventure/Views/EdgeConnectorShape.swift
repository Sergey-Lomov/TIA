//
//  EdgeConnectorShape.swift
//  TIA
//
//  Created by serhii.lomov on 15.05.2022.
//

import Foundation
import SwiftUI

struct EdgeConnectorConstants {
    let geometry: GeometryProxy
    let center: CGPoint
    let radius: CGFloat
    
//    let point1: CGPoint
//    let angle1: CGFloat
//    let point2: CGPoint
//    let angle2: CGFloat
//    /// Thit value defines, what value of ''t'' should be used like zero for connector. This should be value of intersection of edge and vertex
//    let initialT: CGFloat
}

struct EdgeConnectorShape: Shape {
    
    private let connectWidth: CGFloat = 20
    private let intersectionAccuracy: CGFloat = 5
    private let connectLength: CGFloat = 0.05

    static private let length: CGFloat = 0.1
    static private let hConcavity: CGFloat = 0.5
    static private let vConcavity: CGFloat = 0.2
    
    let constants: EdgeConnectorConstants
    var curve: BezierCurve
    var progress: CGFloat
    
    var animatableData: AnimatablePair<BezierCurve, CGFloat> {
        get { .init(curve, progress) }
        set {
            curve = newValue.first
            progress = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let center = constants.center
        let radius = constants.radius
        let initialT = curve.intersectionTWith(center: center, radius: radius, accuracy: intersectionAccuracy)
        let intersection = curve.getPoint(t: initialT)
        let fromAngle = Math.angle(p1: intersection, p2: center)
        let p1Angle = fromAngle - (connectWidth / 2 / radius)
        let p2Angle = fromAngle + (connectWidth / 2 / radius)
        
        let p1 = CGPoint(center: center, angle: p1Angle, radius: radius)
        let p2 = CGPoint(center: center, angle: p2Angle, radius: radius)
        let a1 = p1Angle > fromAngle ? p1Angle - .pi / 2 : p1Angle + .pi / 2
        let a2 = p2Angle > fromAngle ? p2Angle - .pi / 2 : p2Angle + .pi / 2
        let halfWidth = Layout.Edge.curveWidth / 2
        
        let currentT = initialT + (progress - initialT) * Self.length
        let t = max(initialT, currentT)
        let normal = curve.getNormalAngle(t: t)
        let controlRadius = p1.distanceTo(p2) * Self.hConcavity
        
        let target = curve.getPoint(t: t)
        let toLeft = CGPoint(center: target, angle: normal, radius: halfWidth)
        let toRight = CGPoint(center: target, angle: normal, radius: -1 * halfWidth)
        
        let vControlT = initialT + (t - initialT) * (1 - Self.vConcavity)
        let vControlNormal = curve.getNormalAngle(t: vControlT)
        let vControl = curve.getPoint(t: vControlT)
        let vControlLeft = CGPoint(center: vControl, angle: vControlNormal, radius: halfWidth)
        let vControlRight = CGPoint(center: vControl, angle: vControlNormal, radius: -1 * halfWidth)
        
        let hControlLeft = CGPoint(center: p1, angle: a1, radius: controlRadius)
        let hControlRight = CGPoint(center: p2, angle: a2, radius: controlRadius)
        
        let left = BezierCurve(points: [p1, hControlLeft, vControlLeft, toLeft])
        let right = BezierCurve(points: [toRight, vControlRight, hControlRight, p2])
        
        var path = Path()
        path.addCurve(left)
        path.addLine(to: toRight)
        path.addCurve(right)
        return path
    }
}
