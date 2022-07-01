//
//  EdgeGateView.swift
//  TIA
//
//  Created by serhii.lomov on 01.07.2022.
//

import SwiftUI

struct EdgeGateView: View {
    @ObservedObject var gate: EdgeGateViewModel
    var backColor: Color
    var symbolColor: Color
    
    var body: some View {
        CenteredGeometryReader { geometry in
            let size = circleSize(geometry)
            ComplexCurveShape(curve: .circle(radius: 0.5))
                .frame(size: size)
                .onAnimationCompleted(for: size) {
                    handleAnimationFinish()
                }
                .animation(sizeAnimation, value: size)
                .foregroundColor(backColor)
            
            switch gate.model.requirement {
            case .resource(let type):
                ResourceShape(type: type)
                    .frame(size: symbolSize(geometry))
                    .animation(sizeAnimation, value: symbolSize(geometry))
                    .foregroundColor(symbolColor)
            }
        }
    }
    
    func circleSize(_ geometry: GeometryProxy) -> CGFloat {
        switch gate.state {
        case .open, .seed, .ungrowing:
            return 0
        case .growing, .close:
            return geometry.minSize * Layout.EdgeGate.sizeRatio
        }
    }
    
    func symbolSize(_ geometry: GeometryProxy) -> CGFloat {
        return circleSize(geometry) * Layout.EdgeGate.symbolRatio
    }
    
    private var sizeAnimation: Animation? {
        switch gate.state {
        case .growing:
            return AnimationService.shared.growingGate
        case .open:
            return AnimationService.shared.openGate
        case .close:
            return AnimationService.shared.closeGate
        case .ungrowing:
            return AnimationService.shared.ungrowingGate
        default:
            return nil
        }
    }
    
    func handleAnimationFinish() {
        switch gate.state {
        case .close:
            gate.closingFinished()
        default:
            break
        }
    }
}
