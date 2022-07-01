//
//  DrawingProgressModifier.swift
//  TIA
//
//  Created by serhii.lomov on 14.06.2022.
//

import Foundation
import SwiftUI

struct DrawingProgressModifier: AnimatableModifier {

    var drawingProgress: CGFloat
    var animatableData: CGFloat {
        get { drawingProgress }
        set { drawingProgress = newValue  }
    }

    func body(content: Content) -> some View {
        content
            .environment(\.drawingProgress, drawingProgress)
    }
}
