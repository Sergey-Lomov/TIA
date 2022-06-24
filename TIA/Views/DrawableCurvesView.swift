//
//  DrawableCurvesView.swift
//  TIA
//
//  Created by serhii.lomov on 11.06.2022.
//

import SwiftUI

struct DrawableCurvesView: View {
    
    let elements: [DrawableCurve]
    var lineCap: CGLineCap = .round
    @Environment(\.drawingProgress) var drawingProgress
    @Environment(\.drawingWidth) var drawingWidth

    var body: some View {
        CenteredGeometryReader { geometry in
            ForEach(elements, id: \.id) { element in
                Path(curve: element.curve, geometry: geometry)
                    .trimmedPath(from: 0, to: relativeProgress(element))
                    .stroke(style: strokeStyle(element))
            }
        }
    }

    private func relativeProgress(_ element: DrawableCurve) -> CGFloat {
        let length = element.finishAt - element.startAt
        let relative = (drawingProgress - element.startAt) / length
        return relative.normalized(min: 0, max: 1)
    }
    
    private func strokeStyle(_ element: DrawableCurve) -> StrokeStyle {
        let width = element.widthMult * drawingWidth
        return StrokeStyle(lineWidth: width, lineCap: lineCap)
    }
}
