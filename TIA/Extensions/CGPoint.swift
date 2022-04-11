//
//  CGPoint.swift
//  TIA
//
//  Created by Serhii.Lomov on 10.04.2022.
//

import CoreGraphics

extension CGPoint {
    func multPoint(x mx: CGFloat, y my: CGFloat) -> CGPoint {
        CGPoint(x: x * mx, y: y * my)
    }
}
