//
//  CGFloat.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import CoreGraphics

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random())
    }
    
    static func random(max: CGFloat, min: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}
