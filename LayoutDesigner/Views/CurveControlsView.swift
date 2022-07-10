//
//  CurveControlsView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation
import SwiftUI

struct CurveControlsView: View {
    private let controlStyle = StrokeStyle(lineWidth: 2, dash: [10, 10])

    @ObservedObject var edge: EdgeViewModel

    var body: some View {
        CenteredGeometryReader { geometry in
            let scaled = edge.curve.scaled(geometry)
            let translated = scaled.translated(x: geometry.size.width / 2, y: geometry.size.height / 2)

            Path.line(from: translated.p0, to: translated.p1)
                .stroke(style: controlStyle)

            Path.line(from: translated.p3, to: translated.p2)
                .stroke(style: controlStyle)

            Circle()
                .frame(size: 10)
                .offset(point: scaled.p1)

            Circle()
                .frame(size: 10)
                .offset(point: scaled.p2)
        }
        .foregroundColor(edge.color)
    }
}
