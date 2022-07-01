//
//  AdventureLayerBackgroundView.swift
//  TIA
//
//  Created by serhii.lomov on 27.05.2022.
//

import Foundation
import SwiftUI

struct AdventureLayerBackground: View {

    @ObservedObject var layer: AdventureLayerViewModel
    var theme: AdventureTheme

    var body: some View {
        VisualEffectView(effect: effect)
            .opacity(opacity)
            .onAnimationCompleted(for: opacity) {
                handleAnimationCompletion()
            }
            .animation(animation, value: opacity)
    }

    private var effect: UIVisualEffect {
        switch theme {
        case .dark:
            return UIBlurEffect(style: .dark)
        case .light:
            return UIBlurEffect(style: .light)
        case .truth:
            return UIBlurEffect(style: .dark)
        }
    }

    private var opacity: CGFloat {
        switch layer.state {
        case .hiding, .preparing:
            return 0
        case .growing, .presenting, .shown, .ungrowing:
            return 0.99
        }
    }

    private var animation: Animation? {
        switch layer.state {
        case .presenting: return AnimationService.shared.presentLayer
        case .hiding: return AnimationService.shared.hideLayer
        default: return nil
        }
    }

    private func handleAnimationCompletion() {
        switch layer.state {
        case .presenting:
            layer.layerPresented()
        case .hiding:
            layer.layerWasHidden()
        default:
            break
        }
    }
}
