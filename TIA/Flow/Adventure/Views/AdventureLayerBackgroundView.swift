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
        dimView()
            .opacity(opacity)
            .onAnimationCompleted(for: opacity) {
                handleAnimationCompletion()
            }
            .animation(animation, value: opacity)
            .allowsHitTesting(false)
    }

    #if os(iOS)
    private var effect: UIVisualEffect {
        switch theme {
        case .dark: return UIBlurEffect(style: .dark)
        case .light: return UIBlurEffect(style: .light)
        case .truth: return UIBlurEffect(style: .dark)
        }
    }
    #elseif os(macOS)
    private var dimColor: Color {
        switch theme {
        case .dark: return .softBlack
        case .light: return .softWhite
        case .truth: return .softBlack
        }
    }
    #endif

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
        case .presenting: return AnimationService.presentLayer
        case .hiding: return AnimationService.hideLayer
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

    @ViewBuilder private func dimView() -> some View {
        #if os(iOS)
        VisualEffectView(effect: effect)
        #elseif os(macOS)
        dimColor
        #endif
    }
}
