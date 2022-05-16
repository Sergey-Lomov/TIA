//
//  EdgePathView.swift
//  TIA
//
//  Created by serhii.lomov on 15.05.2022.
//

import SwiftUI

//struct EdgePathView: Animatable, View {
//
//    static private let connectWidth: CGFloat = 10
//    static private let intersectionAccuracy: CGFloat = 4
//    static private let connectLength: CGFloat = 0.05
//
//    var curve: BezierCurve
//    var progress: CGFloat
//    var color: Color
//    var borderColor: Color
//
//    private let fromConnector: (p1: CGPoint, p2: CGPoint)
//    private let fromMinT: CGFloat
//    private let toConnector: (p1: CGPoint, p2: CGPoint)
//
////    var animatableData: AnimatablePair<BezierCurve, CGFloat> {
////        get { .init(curve, progress)}
////        set {
////            curve = newValue.first
////            progress = newValue.second
////        }
////    }
//
//    init(_ geometry: GeometryProxy, curve: BezierCurve, targetCurve: BezierCurve, progress: CGFloat, color: Color, borderColor: Color, onFinishTransfer: (() -> Void)?) {
//
//        self.curve = curve
//        self.progress = progress
//        self.color = color
//        self.borderColor = borderColor
//
//        let radius = Layout.Vertex.diameter / 2 * geometry.minSize
//        let from = curve.from.scaled(geometry)
//        let to = curve.to.scaled(geometry)
//        self.fromMinT = targetCurve.intersectionTWith(center: from, radius: radius, accuracy: Self.intersectionAccuracy)
//        self.fromConnector = Self.connector(center: from, radius: radius, curve: targetCurve)
//        self.toConnector = Self.connector(center: to, radius: radius, curve: targetCurve)
//
////        if progress == 1 { onFinishTransfer?() }
//    }
//
//    var body: some View {
//        CenteredGeometryReader { geometry in
//            SingleCurveShape(curve: curve)
//                .trim(from: 0, to: progress)
//                .stroke(lineWidth: Layout.Edge.undrelineWidth)
//                .foregroundColor(borderColor)
//                .frame(geometry: geometry)
//
//            SingleCurveShape(curve: curve)
//                .trim(from: 0, to: progress)
//                .stroke(lineWidth: Layout.Edge.curveWidth)
//                .foregroundColor(color)
//                .frame(geometry: geometry)
//
//            if fromConnectorVisible {
//                EdgeConnectorShape(p1: fromConnector.p1, p2: fromConnector.p2, target: fromConnectorTarget)
//            }
//        }
//    }
//
//    private var fromConnectorVisible: Bool {
//        print("Progress: \(progress) connector: \(fromMinT) ")
//        return progress > fromMinT
//    }
//
//    private var fromConnectorTarget: CGPoint {
//        let t = min(progress, fromMinT + Self.connectLength)
//        return curve.getPoint(t: t)
//    }
//
//    private static func connector(center: CGPoint, radius: CGFloat, curve: BezierCurve) -> (p1: CGPoint, p2: CGPoint) {
//        let fromIntersection = curve.intersectionWith(center: center, radius: radius, accuracy: intersectionAccuracy)
//        let fromAngle = Math.angle(p1: center, p2: fromIntersection)
//        let p1Angle = fromAngle - (connectWidth / 2 / radius)
//        let p2Angle = fromAngle + (connectWidth / 2 / radius)
//        let p1 = CGPoint(center: center, angle: p1Angle, radius: radius)
//        let p2 = CGPoint(center: center, angle: p2Angle, radius: radius)
//
//        return (p1: p1, p2: p2)
//    }
//}
//
//struct EdgeConnectorShape: Shape {
//
//    let p1: CGPoint
//    let p2: CGPoint
//    var target: CGPoint
//
//    var animatableData: CGPoint {
//        get { target }
//        set { target = newValue }
//    }
//
//    func path(in rect: CGRect) -> Path {
//        let left = BezierCurve(points: [p1, p1, target, target])
//        let right = BezierCurve(points: [target, target, p2, p2])
//        return Path(curves: [left, right])
//    }
//}
