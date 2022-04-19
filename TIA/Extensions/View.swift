//
//  View.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import SwiftUI

extension View {
    func frame(geometry: GeometryProxy) -> some View {
        frame(size: geometry.size)
    }
    
    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }
    
    func offset(point: CGPoint, geometry: GeometryProxy ) -> some View {
        let scaledPoint = point.multedPoint(x: geometry.size.width,
                                          y: geometry.size.height)
        return offset(x: scaledPoint.x, y: scaledPoint.y)
    }
    
    func bezierPositioning(curve: BezierCurve, progress: CGFloat = 0) -> some View {
        modifier(BezierPositioning(curve: curve, progress: progress))
    }
    
    func bezierPositioning(step: Int, curves: [BezierCurve]) -> some View {
        modifier(BezierStepsPositioning(step: step, curves: curves))
    }
    
    func offset(_ point: CGPoint, geomtery: GeometryProxy) -> some View {
        let x = point.x * geomtery.size.width
        let y = point.y * geomtery.size.height
        return offset(x: x, y: y)
    }
}

// TODO: Remove code if still be unused
//extension View where Self: EngineEventsListener {
//    mutating func listenTo(_ source: EngineEventsSource?) -> Self {
//        if let publisher = source?.eventsPublisher {
//            subscribeTo(publisher)
//        }
//        return self
//    }
//}
//
//extension View where Self: ViewEventsSource {
//    func sendEventsTo(_ listener: inout ViewEventsListener?) -> Self {
//        listener?.subscribeTo(eventsPublisher)
//        return self
//    }
//}
