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
    @State var isSelected: Bool = false
    @Environment(\.cameraService) var cameraService
    @Environment(\.finalizedAdventure) var finalized
    
    private let moveDuration: TimeInterval = 2
    private let scaleDuration: TimeInterval = 2
    
    // TODO: Move to BezierCurve extension
    private enum Curves {
        static let currentToDone = [
            LayoutService.currentAdventureIconPosition(theme: .dark),
            CGPoint(x: -0.25, y: -0.25),
            CGPoint(x: -0.4375, y: 0),
            CGPoint(x: -0.345, y: 0.25)
        ]
        static let planedToCurrent = [
            CGPoint(x: 0, y: 0.075),
            CGPoint(x: 0, y: 0.1),
            CGPoint(x: 0, y: -0.25),
            LayoutService.currentAdventureIconPosition(theme: .dark)
        ]
    }
    
    // TODO: Remove custom init
    init(adventure: AdventureDescriptor) {
        self.adventure = adventure
    }
    
    var body: some View {
        CenteredGeometryReader { geometry in
            let size = size(geometry)
            AdventureIconView(adventure: adventure)
                .offset(point: offset.scaled(geometry))
                .frame(size: size)
                .animation(animation, value: size)
//                .scaleEffect(scale)
//                .animation(.easeInOut(duration: scaleDuration),
//                           value: adventure.state)
                // TODO: Use View extension metyhod
//                .modifier(bezierSteps(size: geometry.size))
//                .animation(.easeInOut(duration: moveDuration),
//                           value: adventure.state)
                .onTapGesture {
                    isSelected = true
                }
            
            if isSelected {
                Color.clear.preference(key: SelectedAdventuerePreferenceKey.self, value: adventure)
            }
        }
    }
    
    var offset: CGPoint {
        LayoutService.currentAdventureIconPosition(theme: adventure.theme)
    }
    
    func size(_ geometry: GeometryProxy) -> CGFloat {
        if isSelected || finalized == adventure {
            let pickerSize = Layout.MainMenu.pickerSize
            let minScreenSize = UIScreen.main.bounds.size.minSize
            let ratio = minScreenSize * Layout.Vertex.diameter / (pickerSize * Layout.MainMenu.currentIconSize)
            let screenZoom = cameraService.focusOnAdventureZoom()
            let scale = Layout.MainMenu.currentIconSize * ratio / screenZoom
            return round(scale * geometry.minSize)
        }
        
        switch adventure.state {
        case .planed:
            // TODO: Remove hotfix uses new states approach
            // TODO: Move constants to Layout constants or service
            return .unsingularZero
        case .current:
            return Layout.MainMenu.currentIconSize * geometry.minSize
        default:
            return 0.1 * geometry.minSize
        }
    }

    // TODO: May became unused
    private func bezierSteps(size: CGSize) -> BezierStepsPositioning {
        let curves = [
            curveForPoints(Curves.planedToCurrent, size: size),
            curveForPoints(Curves.currentToDone, size: size),
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
    
    // TODO: May became unused
    private func curveForPoints(_ points: [CGPoint],
                                size: CGSize) -> BezierCurve {
        var xMult = size.width
        var yMult = size.height
        if case .light = adventure.theme {
            xMult = xMult * -1
            yMult = yMult * -1
        }
        
        let scaledPoints = points.map {
            $0.scaled(x: xMult, y: yMult)
        }

        return BezierCurve(points: scaledPoints)
    }
    
    var animation: Animation? {
        isSelected ? AnimationService.shared.toAdventure : AnimationService.shared.fromAdventure
    }
}

struct AdventureIconView: View {
    @StateObject var adventure: AdventureDescriptor
    
    var body: some View {
        ZStack {
            ComplexCurveShape(curve: .circle(radius: 0.5))
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
