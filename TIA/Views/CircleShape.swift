//
//  CircleShape.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import SwiftUI

// TODO: Investigate possiblity to remove custom CircleShape and use dafault Circle or ComplexCurvesShape. This check should be done only after all circles animation completion (vertex shape change, vertex icon shape change e.t.c.)
struct CircleShape: Shape {
    private let cirleControlCoefficient: CGFloat = 0.66666

    func path(in rect: CGRect) -> Path {
        let bottom = CGPoint(x: rect.midX, y: rect.height)
        let top = CGPoint(x: rect.midX, y: 0)
        
        let controlX = rect.width * cirleControlCoefficient
        let control1 = CGPoint(x: rect.width / 2 - controlX, y: rect.height)
        let control2 = CGPoint(x: rect.width / 2 - controlX, y: 0)
        let control3 = CGPoint(x: rect.width / 2 + controlX, y: 0)
        let control4 = CGPoint(x: rect.width / 2 + controlX, y: rect.height)
        
        var path = Path()
        path.move(to: bottom)
        path.addCurve(to: top, control1: control1, control2: control2)
        path.addCurve(to: bottom, control1: control3, control2: control4)
        return path
    }
}
