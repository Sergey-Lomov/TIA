//
//  AnyTransaction.swift
//  TIA
//
//  Created by Serhii.Lomov on 11.04.2022.
//

import Foundation
import SwiftUI

extension AnyTransition {
    static func adventureIcon(curve: BezierCurve) -> AnyTransition {
        .modifier(active: BezierPositioning(curve: curve, progress: 0),
                  identity: BezierPositioning(curve: curve, progress: 1))
    }
}
