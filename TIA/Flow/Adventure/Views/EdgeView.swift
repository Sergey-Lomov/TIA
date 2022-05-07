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
        CenteredGeometryReader { geometry in
            EdgePathView(edge: edge)
            
            if edge.model.state.isGrowed {
                ForEach(edge.model.gates.indices, id: \.self) { index in
                    let gate = edge.model.gates[index]
                    let position = LayoutService.gatePosition(geometry, edge: edge.model, gate: gate)
                    
                    EdgeGateView(gate: gate, backColor: edge.color, symbolColor: edge.borderColor)
                        .offset(point: position)
                        .transition(gateTransition(position: position, geometry: geometry))
                }
            }
        }
    }
    
    func gateTransition(position: CGPoint, geometry: GeometryProxy) -> AnyTransition {
        let anchor = position.toUnit(geometry: geometry)
        return .scale(scale: 0, anchor: anchor).animation(.easeOut(duration: 1))
    }
}

struct EdgePathView: View {
    @ObservedObject var edge: EdgeViewModel
    
    var body: some View {
        CenteredGeometryReader { geometry in
            let animation = Animation.easeOut(duration: growDuration)
            SingleCurveShape(curve: curve)
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.undrelineWidth)
                .animation(animation, value: progress)
                .foregroundColor(edge.borderColor)
                .frame(geometry: geometry)
            
            SingleCurveShape(curve: curve)
                .onReach(curve) {
                    edge.growingFinished()
                }
                .trim(from: 0, to: progress)
                .stroke(lineWidth: Layout.Edge.curveWidth)
                .animation(animation, value: progress)
                .foregroundColor(edge.color)
                .frame(geometry: geometry)
        }
    }
    
    private var curve: BezierCurve {
        switch edge.model.state {
        case .seed:
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

struct EdgeGateView: View {
    @ObservedObject var gate: EdgeGate
    var backColor: Color
    var symbolColor: Color
    
    var body: some View {
        CenteredGeometryReader { geometry in
            CircleShape()
                .frame(size: circleSize(geometry))
                .animation(sizeAnimation, value: circleSize(geometry))
                .foregroundColor(backColor)
            
            switch gate.requirement {
            case .resource(let type):
                ResourceShape(type: type)
                    .frame(size: symbolSize(geometry))
                    .animation(sizeAnimation, value: symbolSize(geometry))
                    .foregroundColor(symbolColor)
            }
        }
    }
    
    func circleSize(_ geometry: GeometryProxy) -> CGFloat {
        return gate.isOpen ? 0 : geometry.minSize * Layout.EdgeGate.sizeRatio
    }
    
    func symbolSize(_ geometry: GeometryProxy) -> CGFloat {
        return circleSize(geometry) * Layout.EdgeGate.symbolRatio
    }
    
    private var sizeAnimation: Animation? {
        return gate.isOpen ? AnimationService.shared.closeGate : AnimationService.shared.closeGate
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
            resources: GameEngine.shared.adventureEngine!.resources,
            listener: GameEngine.shared.adventureEngine,
            eventsSource: GameEngine.shared.adventureEngine)
        let edge = viewModel.edges.first
        EdgePathView(edge: edge!)
    }
}
