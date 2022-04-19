//
//  AdventureIconView.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import SwiftUI

struct AdventureIconWrapper: View {
    @ObservedObject var adventure: AdventureDescriptor
    private var stateModifier: BezierPositioning?
    
    private let moveDuration: TimeInterval = 2
    private let scaleDuration: TimeInterval = 2
    
    // TODO: Move to BezierCurve extension
    private enum Layout {
        static let currentToDone = [
            CGPoint(x: 0, y: -0.25),
            CGPoint(x: -0.25, y: -0.25),
            CGPoint(x: -0.4375, y: 0),
            CGPoint(x: -0.345, y: 0.25)
        ]
        static let planedToCurrent = [
            CGPoint(x: 0, y: 0.075),
            CGPoint(x: 0, y: 0.1),
            CGPoint(x: 0, y: -0.25),
            CGPoint(x: -0, y: -0.25)
        ]
    }
    
    var scale: CGFloat {
        switch adventure.state {
        case .planed:
            return 0.0001
        case .current:
            return 0.15
        default:
            return 0.1
        }
    }
    
    init(adventure: AdventureDescriptor) {
        self.adventure = adventure
    }
    
    var body: some View {
        CenteredGeometryReader { geometry in
            AdventureIconView(adventure: adventure)
                .frame(geometry: geometry)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: scaleDuration),
                           value: adventure.state)
                .modifier(bezierSteps(size: geometry.size))
                .animation(.easeInOut(duration: moveDuration),
                           value: adventure.state)
        }
    }

    private func bezierSteps(size: CGSize) -> BezierStepsPositioning {
        let curves = [
            curveForPoints(Layout.planedToCurrent, size: size),
            curveForPoints(Layout.currentToDone, size: size),
        ]
        
        switch adventure.state {
        case .planed:
            return BezierStepsPositioning(step: 0, curves: curves)
        case .current:
            return BezierStepsPositioning(step: 1, curves: curves)
        case .done:
            // FIXME: Here is a crash - step 2, but only 2 curves
            return BezierStepsPositioning(step: 2, curves: curves)
        }
    }
    
    private func curveForPoints(_ points: [CGPoint],
                                size: CGSize) -> BezierCurve {
        var xMult = size.width
        var yMult = size.height
        if case .light = adventure.theme {
            xMult = xMult * -1
            yMult = yMult * -1
        }
        
        let scaledPoints = points.map {
            $0.multedPoint(x: xMult, y: yMult)
        }

        return BezierCurve(points: scaledPoints)
    }
}

struct AdventureIconView: View {
    @StateObject var adventure: AdventureDescriptor
    
    var body: some View {
        ZStack {
            CircleShape()
                .fill(color)
        }
    }
    
    var color: Color {
        switch adventure.theme {
        case .dark:
            return Color.softWhite
        case .light:
            return Color.softBlack
        case .truth:
            return Color.yellow
        }
    }
}
