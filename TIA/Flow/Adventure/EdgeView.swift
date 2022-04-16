//
//  EdgeView.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import SwiftUI

struct EdgeWrapper: View {
    @ObservedObject var edge: EdgeViewModel
    
    var body: some View {
        EdgeView(edge: edge)
    }
}

struct EdgeView: View {
    
    private let curveWidth: CGFloat = 4
    private let borderWidth: CGFloat = 2
    private let idleDelta: CGFloat = 0.1
    private let idleDuration: CGFloat = 4
    
    @ObservedObject var edge: EdgeViewModel
    
    var body: some View {
        GeometryReader { geometry in

            ZStack {
                BezierCurveShape(curve: curve)
                    .trim(from: 0, to: progress)
                    .stroke(lineWidth: curveWidth + 2 * borderWidth)
                    .animation(.easeInOut(duration: growDuration),
                               value: progress)
//                    .animation(.linear(duration: growDuration),
//                               value: curve)
                    .foregroundColor(edge.borderColor)
                    .frame(geometry: geometry)
                BezierCurveShape(curve: curve)
                    .trim(from: 0, to: progress)
                    .stroke(lineWidth: curveWidth)
                    .animation(.linear(duration: growDuration),
                               value: progress)
//                    .animation(.linear(duration: growDuration),
//                               value: curve)
                    .foregroundColor(edge.color)
                    .frame(geometry: geometry)
            }.frame(geometry: geometry)
//                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + idleDuration) {
//                        edge.curve = edge.curve.selfMirroredCurve()
//                    }
//                }
        }
    }
    
    private var curve: BezierCurve {
        switch edge.model.state {
//        case .seed:
//            let points = [
//                edge.curve.p0,
//                edge.curve.p1.multedPoint(x: -1, y: -1),
//                edge.curve.p2.multedPoint(x: -1, y: -1),
//                edge.curve.p3
//            ]
//            return BezierCurve(points: points)
//            return edge.curve.selfMirroredCurve()
        case .seed:
            //return edge.curve.randomControlsCurve(maxDelta: idleDelta)
            return edge.curve.selfMirroredCurve()
        default:
            return edge.curve
        }
    }
    
    private var progress: CGFloat {
        switch edge.model.state {
        case .seed:
            return 0
        default:
            return 1
        }
    }
    
    private var growDuration: CGFloat {
        switch edge.model.state {
        case .growing(let duration):
            return duration
        default:
            return 0
        }
    }
}

struct EdgeView_Previews: PreviewProvider {
    static var previews: some View {
        let descriptor = GameState().scenario.adventures[.dark]?.first
        let layout = AdventureLayout.random(for: descriptor!)
        let adventure = ScenarioService.shared.adventureFor(descriptor!, layout: layout)
        let viewModel = AdventureViewModel(adventure)
        let edge = viewModel.edges.first
        EdgeView(edge: edge!)
    }
}
