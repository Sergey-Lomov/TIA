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
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
