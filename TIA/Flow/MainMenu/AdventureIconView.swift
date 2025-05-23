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
                Color.clear.preference(key: SelectedAdventureKey.self, value: model.model)
            }
        }
    }

    private func transform(_ geometry: GeometryProxy) -> AdventureIconStateTransform {
        .init(size: size(geometry), angle: angle(geometry), offset: offset(geometry))
    }

    private func offset(_ geometry: GeometryProxy) -> CGPoint {
        switch model.state {
        case .opening, .becameCurrent, .current, .preclosing, .closing:
            return LayoutService.currentAdventureIconPosition(theme: model.model.theme).scaled(geometry)
        case .planed:
            return .zero
        case .becameDone, .done:
            var y = geometry.minSize / 2 + size(geometry) / 2 + Layout.MainMenu.doneIconsGap
            y = model.model.theme == .dark ? y * -1 : y
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
            return AnimationService.toAdventure
        case .closing:
            return AnimationService.fromAdventure
        case .done, .becameDone, .becameCurrent:
            return AnimationService.switchAdventure
        }
    }

    // MARK: Calculations
    private func zoomCompensationSize(_ geometry: GeometryProxy) -> CGFloat {
        let pickerSize = Layout.MainMenu.pickerSize
        let minScreenSize = UIScreen.main.bounds.size.minSize
        let ratio = minScreenSize * Layout.Vertex.diameter / (pickerSize * Layout.MainMenu.currentIconSize)
        let screenZoom = cameraService.focusOnAdventureZoom()
        let scale = Layout.MainMenu.currentIconSize * ratio / screenZoom
        return scale * geometry.minSize
    }
}

struct AdventureIconView: View {
    @StateObject var model: AdventureIconViewModel

    var body: some View {
        ComplexCurveShape(curve: shapeCurve)
            .fill(color)
            .animation(animation, value: color)
    }

    var color: Color {
        let palette = ColorPalette.paletteFor(model.model.theme)
        switch model.state {
        case .done:
            return palette.borders
        default:
            return palette.vertex
        }
    }

    var shapeCurve: ComplexCurve {
        shapeFor(model.state)
    }

    var animation: Animation? {
        switch model.state {
        case .becameDone, .done:
            return AnimationService.switchAdventure
        default:
            return nil
        }
    }

    private func shapeFor(_ state: AdventureIconState) -> ComplexCurve {
        switch state {
        case .closing(let willBeDone):
            return willBeDone ? shapeFor(.done(slot: 0)) : shapeFor(.current)
        case .done, .becameDone:
            let doneShape = model.model.doneShape
            return AdventuresIconsService.curveFor(doneShape)
        default:
            let doneShape = model.model.doneShape
            let curve = AdventuresIconsService.curveFor(doneShape)
            return .circle(radius: 0.5, componentsCount: curve.components.count)
        }
    }

    func applyTransform(_ transform: AdventureIconStateTransform) -> ModifiedContent<Self, AdventureIconStateHandler> {
        modifier(AdventureIconStateHandler(transform: transform))
    }
}
