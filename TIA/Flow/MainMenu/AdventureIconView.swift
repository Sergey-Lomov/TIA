//
//  AdventureIconView.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import SwiftUI

struct AdventureIconWrapper: View {
    
    @ObservedObject var model: AdventureIconViewModel
    @Environment(\.cameraService) var cameraService
    @State var isSelected = false
    
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
    
    var body: some View {
        CenteredGeometryReader { geometry in
            let transform = transform(geometry)
            AdventureIconView(model: model)
                .applyTransform(transform)
                .onAnimationCompleted(for: transform) {
                    model.animationCompleted()
                }
                .animation(animation, value: transform)
                .onTapGesture {
                    if model.state == .current {
                        isSelected = true
                    }
                }
            
            if isSelected {
                Color.clear.preference(key: SelectedAdventurePreferenceKey.self, value: model.adventure)
            }
        }
    }
    
    private func transform(_ geometry: GeometryProxy) -> AdventureIconStateTransform {
        .init(size: size(geometry), angle: angle(geometry), offset: offset(geometry))
    }
    
    private func offset(_ geometry: GeometryProxy) -> CGPoint {
        switch model.state {
        case .opening, .becameCurrent, .current, .preclosing, .closing:
            return LayoutService.currentAdventureIconPosition(theme: model.adventure.theme).scaled(geometry)
        case .planed:
            return .zero
        case .becameDone, .done:
            var y = geometry.minSize / 2 + size(geometry) / 2 + Layout.MainMenu.doneIconsGap
            y = model.adventure.theme == .dark ? y * -1 : y
            return CGPoint(x: 0, y: y)
        }
    }
    
    private func angle(_ geometry: GeometryProxy) -> CGFloat {
        switch model.state {
        case .done(let slot), .becameDone(let slot):
            let size = size(geometry) + Layout.MainMenu.doneIconsInteritem
            let radius = offset(geometry).distanceTo(.zero)
            return -1 * size / radius * CGFloat(slot)
        default:
            return .zero
        }
    }
    
    private func size(_ geometry: GeometryProxy) -> CGFloat {
        switch model.state {
        case .planed:
            return 0
        case .opening, .preclosing:
            return zoomCompensationSize(geometry)
        case .current, .becameCurrent, .closing:
            return Layout.MainMenu.currentIconSize * geometry.minSize
        case .done, .becameDone:
            return Layout.MainMenu.doneIconSize * geometry.minSize
        }
    }
    
    var animation: Animation? {
        switch model.state {
        case .planed, .preclosing, .current:
            return nil
        case .opening:
            return AnimationService.shared.toAdventure
        case .closing:
            return AnimationService.shared.fromAdventure
        case .done, .becameDone, .becameCurrent:
            return AnimationService.shared.switchAdventure
        }
    }

    // MARK: Calculations
    private func zoomCompensationSize(_ geometry: GeometryProxy) -> CGFloat {
        let pickerSize = Layout.MainMenu.pickerSize
        let minScreenSize = UIScreen.main.bounds.size.minSize
        let ratio = minScreenSize * Layout.Vertex.diameter / (pickerSize * Layout.MainMenu.currentIconSize)
        let screenZoom = cameraService.focusOnAdventureZoom()
        let scale = Layout.MainMenu.currentIconSize * ratio / screenZoom
        return round(scale * geometry.minSize)
    }
}

struct AdventureIconView: View {
    @StateObject var model: AdventureIconViewModel
    
    var body: some View {
        ZStack {
            let palette = ColorPalette.paletteFor(model.adventure.theme)
            ComplexCurveShape(curve: curve)
                .fill(color)
                .animation(.linear(duration: 1), value: color)
            ComplexCurveShape(curve: curve)
                .stroke(palette.borders)
        }
    }
    
    var color: Color {
        let palette = ColorPalette.paletteFor(model.adventure.theme)
        switch model.state {
        case .done:
            return palette.borders
        default:
            return palette.vertex
        }
    }
    
    var curve: ComplexCurve {
        switch model.state {
        case .preclosing:
            let doneShape = model.adventure.doneShape
            let curve = AdventuresIconsService.curveFor(doneShape)
            return .circle(radius: 0.5, componentsCount: curve.components.count)
        case .closing, .done, .becameDone:
            let doneShape = model.adventure.doneShape
            return AdventuresIconsService.curveFor(doneShape)
        default:
            return .circle(radius: 0.5)
        }
    }
    
    func applyTransform(_ transform: AdventureIconStateTransform) -> ModifiedContent<Self, AdventureIconStateHandler> {
        modifier(AdventureIconStateHandler(transform: transform))
    }
}
