//
//  SingleCurveShape.swift
//  TIA
//
//  Created by Serhii.Lomov on 15.04.2022.
//

import Foundation
import SwiftUI
import Combine

struct SingleCurveShape: Shape {

    var curve: BezierCurve
    var animatableData: BezierCurve {
        get { curve }
        set { curve = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path(curve: curve, size: rect.size)
    }
}
