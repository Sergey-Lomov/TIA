//
//  ComplexCurveShape.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import Foundation
import SwiftUI

struct ComplexCurveShape: Shape {

    var curve: ComplexCurve
    var animatableData: ComplexCurve {
        get { curve }
        set { curve = newValue }
    }

    func path(in rect: CGRect) -> Path {
        return Path(curves: curve.components, size: rect.size)
    }
}
