//
//  IngameMenuView.swift
//  TIA
//
//  Created by serhii.lomov on 14.05.2022.
//

import SwiftUI

struct IngameMenuView: View {
    
    @ObservedObject var viewModel: IngameMenuViewModel
    
    var body: some View {
        CenteredGeometryReader { geometry in
            ComplexCurveShape(curve: bodyCurve())
                .fill(viewModel.color)
        }
    }
    
    func bodyCurve() -> ComplexCurve {
        switch viewModel.state {
        case .abscent:
            return .abscentMenu
        case .closed:
            return .closedMenu
        case .opened, .visited:
            return .openedMenu
        }
    }
}

extension ComplexCurve {
    static var abscentMenu: ComplexCurve {
        let c1 = BezierCurve(points: [
            .init(x: 0.0, y: 0.0),
            .init(x: 0.3, y: 0.0),
            .init(x: 0.2, y: 0.0),
            .init(x: 0.5, y: 0.0)
        ])
        let c2 = BezierCurve(points: [
            .init(x: 0.5, y: 0.0),
            .init(x: 0.8, y: 0.0),
            .init(x: 0.7, y: 0.0),
            .init(x: 1.0, y: 0.0)
        ])
        return .init([c1, c2])
    }
    
    static var closedMenu: ComplexCurve {
        let c1 = BezierCurve(points: [
            .init(x: 0.0, y: 0.0),
            .init(x: 0.3, y: 0.0),
            .init(x: 0.2, y: 0.3),
            .init(x: 0.5, y: 0.3)
        ])
        let c2 = BezierCurve(points: [
            .init(x: 0.5, y: 0.3),
            .init(x: 0.8, y: 0.3),
            .init(x: 0.7, y: 0.0),
            .init(x: 1.0, y: 0.0)
        ])
        return .init([c1, c2])
    }
    
    static var openedMenu: ComplexCurve {
        .zero
    }
}
