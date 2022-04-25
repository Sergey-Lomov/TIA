//
//  AnimatableModifierWrapper.swift
//  TIA
//
//  Created by Serhii.Lomov on 21.04.2022.
//

import Foundation
import SwiftUI

// TODO: Remove if still be unused
//protocol AnimatableModifierWrapper: View, Animatable {
//    associatedtype Modifier: AnimatableModifier
//}
//
//extension AnimatableModifierWrapper {
//
//}

//struct AnimatableModifierWrapper<Modifier>: View, Animatable where Modifier: Animatable & ViewModifier {
//
//    private var content: Modifier.Content
//    private var modifier: Modifier
//    var animatableData: Modifier.AnimatableData = .zero {
//        didSet { modifier.animatableData = animatableData }
//    }
//
//    init(content: Modifier.Content, modifier: Modifier) {
//        self.content = content
//        self.modifier = modifier
//    }
//
//    var body: some View {
//        modifier.body(content: content)
//    }
//}

//typealias BezierPositioningWrapper = AnimatableModifierWrapper<BezierPositioning>
