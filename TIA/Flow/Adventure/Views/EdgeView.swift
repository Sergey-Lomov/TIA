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
        CenteredGeometryReader { geometry in
            let animation = Animation.easeOut(duration: growDuration)
            SingleCurveShape(curve: curve)
                .trim(from: 0, to: progress)
                .stroke(lineWidth: curveWidth + 2 * borderWidth)
                .animation(animation, value: progress)
                .foregroundColor(edge.borderColor)
                .frame(geometry: geometry)
            
            SingleCurveShape(curve: curve)
                .onReach(curve) {
                    edge.growingFinished()
                }
                .trim(from: 0, to: progress)
                .stroke(lineWidth: curveWidth)
                .animation(animation, value: progress)
                .foregroundColor(edge.color)
                .frame(geometry: geometry)
        }
    }
    
    private var curve: BezierCurve {
        switch edge.model.state {
        case .seed:
//            return edge.curve.randomControlsCurve(maxDelta: idleDelta)
            //return edge.curve.selfMirroredCurve()
            return edge.model.seedCurve
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
        let viewModel = AdventureViewModel(
            adventure,
            player: GameEngine.shared.adventureEngine!.player,
            listener: GameEngine.shared.adventureEngine,
            eventsSource: GameEngine.shared.adventureEngine)
        let edge = viewModel.edges.first
        EdgeView(edge: edge!)
    }
}
