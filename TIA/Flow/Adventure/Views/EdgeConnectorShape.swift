//
//  EdgeConnectorShape.swift
//  TIA
//
//  Created by serhii.lomov on 15.05.2022.
//

import Foundation
import SwiftUI

typealias EdgeConnectorData = AnimatableTrio<BezierCurve, CGFloat, CGFloat>

struct EdgeConnectorShape: Shape {

    static private let connectWidth: CGFloat = 0.06
    static private let blobingSize: CGFloat = 0.5
    static private let intersectionAccuracy: CGFloat = 5
    static private let connectLength: CGFloat = 0.05
    static private let length: CGFloat = 0.1
    static private let hConcavity: CGFloat = 0.5
    static private let vConcavity: CGFloat = 0.2
    
    var curve: BezierCurve
    var progress: CGFloat
    var blobing: CGFloat
    let center: CGPoint
    let radius: CGFloat
    
    var animatableData: EdgeConnectorData {
        get { .init(curve, progress, blobing) }
        set {
            curve = newValue.first
            progress = newValue.second
            blobing = newValue.third
        }
    }

    func path(in rect: CGRect) -> Path {
        // In code below uses many postfixes in format x_y. This postfix means, variable are related to point number X in curve number Y. Names "p" is short for point, "a" - for angles, "nb" - no blobing calculations, "fb" - full blobing calculations.
        
        // TODO: Investigate possibility to caches part of calculations. This may be actual for "from" connectors
        let initialT = curve.intersectionTWith(center: center, radius: radius, accuracy: Self.intersectionAccuracy)
        let intersection = curve.getPoint(t: initialT)
        let midAngle = Math.angle(p1: intersection, p2: center)
        
        let connectWidth = Layout.Vertex.diameter * rect.size.minSize * .dpi * Self.connectWidth
        let a0_1 = midAngle - (connectWidth / 2 / radius)
        let a3_2 = midAngle + (connectWidth / 2 / radius)
        let p0_1 = CGPoint(center: center, angle: a0_1, radius: radius)
        let p3_2 = CGPoint(center: center, angle: a3_2, radius: radius)
        
        let currentT = initialT + (progress - initialT) * Self.length
        let t = max(initialT, currentT)
        let normal = curve.getNormalAngle(t: t)
        let controlRadius = p0_1.distanceTo(p3_2) * Self.hConcavity
        let halfWidth = Layout.Edge.curveWidth / 2
        let bRadius = halfWidth * Math.cirleControlCoefficient
        
        let curvePoint = curve.getPoint(t: t)
        let targetAngle = Math.angle(p1: curvePoint, p2: center)
        let blobSize = blobing * Self.blobingSize * connectWidth
        let targetDistance = center.distanceTo(curvePoint) + blobSize
        let target = CGPoint(center: center, angle: targetAngle, radius: targetDistance)
        
        let verticalGap = halfWidth * (1 - blobing)
        let p3_1 = CGPoint(center: target, angle: normal, radius: verticalGap)
        let p0_2 = CGPoint(center: target, angle: normal, radius: -1 * verticalGap)
        
        let vControlT = initialT + (t - initialT) * (1 - Self.vConcavity)
        let vControl = curve.getPoint(t: vControlT)
        
        let nb_a2_1 = curve.getNormalAngle(t: vControlT)
        let nb_a1_2 = nb_a2_1 + .pi
        let nb_p2_1 = CGPoint(center: vControl, angle: nb_a2_1, radius: halfWidth)
        let nb_p1_2 = CGPoint(center: vControl, angle: nb_a1_2, radius: halfWidth)
        let b_a2_1 = a0_1 > midAngle ? midAngle + .hpi : midAngle - .hpi
        let b_a1_2 = a3_2 > midAngle ? midAngle + .hpi : midAngle - .hpi
        let b_p2_1 = CGPoint(center: target, angle: b_a2_1, radius: bRadius)
        let b_p1_2 = CGPoint(center: target, angle: b_a1_2, radius: bRadius)
        let uppedBlobing = min(blobing * 2, 1)
        let p2_1 = CGPoint.from(nb_p2_1, to: b_p2_1, t: uppedBlobing)
        let p1_2 = CGPoint.from(nb_p1_2, to: b_p1_2, t: uppedBlobing)
        
        let nb_a1_1 = a0_1 > midAngle ? a0_1 - .hpi : a0_1 + .hpi
        let nb_a2_2 = a3_2 > midAngle ? a3_2 - .hpi : a3_2 + .hpi
        let nb_p1_1 = CGPoint(center: p0_1, angle: nb_a1_1, radius: controlRadius)
        let nb_p2_2 = CGPoint(center: p3_2, angle: nb_a2_2, radius: controlRadius)
        let b_p1_1 = CGPoint(center: p0_1, angle: midAngle, radius: Self.blobingSize * connectWidth)
        let b_p2_2 = CGPoint(center: p3_2, angle: midAngle, radius: Self.blobingSize * connectWidth)
        let p1_1 = CGPoint.from(nb_p1_1, to: b_p1_1, t: blobing)
        let p2_2 = CGPoint.from(nb_p2_2, to: b_p2_2, t: blobing)
        
        let curve1 = BezierCurve(points: [p0_1, p1_1, p2_1, p3_1])
        let curve2 = BezierCurve(points: [p0_2, p1_2, p2_2, p3_2])
        
        var path = Path()
        path.addCurve(curve1)
        path.addLine(to: curve2.from)
        path.addCurve(curve2)
        return path
    }
}
