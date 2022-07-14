//
//  CurveControlsView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation
import SwiftUI

struct CurveControlsView: View {
    private let controlSize: CGFloat = 10
    private let controlStyle = StrokeStyle(lineWidth: 2, dash: [10, 10])

    @ObservedObject var edge: EdgeViewModel
    @EnvironmentObject var editorConfig: EditorConfig

    var body: some View {
        CenteredGeometryReader { geometry in
            let scaled = edge.curve.scaled(geometry)
            let translated = scaled.translated(x: geometry.size.width / 2, y: geometry.size.height / 2)

            Path.line(from: translated.p0, to: translated.p1)
                .stroke(style: controlStyle)

            Path.line(from: translated.p3, to: translated.p2)
                .stroke(style: controlStyle)

            Circle()
                .frame(size: controlSize)
                .offset(point: scaled.p1)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            handleUpdate(geometry, gesture.translation, point: .p1, finished: false)
                        }
                        .onEnded { gesture in
                            handleUpdate(geometry, gesture.translation, point: .p1, finished: true)
                        }
                    )

            Circle()
                .frame(size: controlSize)
                .offset(point: scaled.p2)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            handleUpdate(geometry, gesture.translation, point: .p2, finished: false)
                        }
                        .onEnded { gesture in
                            handleUpdate(geometry, gesture.translation, point: .p2, finished: true)
                        }
                    )
        }
        .foregroundColor(editorConfig.selectedEdgeColor)
    }

    func handleUpdate(_ geometry: GeometryProxy, _ translation: CGSize, point: ControlPoint, finished: Bool) {
        let delta = translation.devided(geometry.size)
        let curve = edge.prechangeCurve ?? edge.curve
        let newValue = curve.point(point).translated(by: delta)
        if finished {
            edge.controlChangingFinished(point: point, newValue: newValue)
        } else {
            edge.controlChanged(point: point, newValue: newValue)
        }
    }
}
