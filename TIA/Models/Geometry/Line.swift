//
//  Line.swift
//  TIA
//
//  Created by Serhii.Lomov on 16.04.2022.
//

import CoreGraphics

struct Line {
    let a: CGFloat
    let b: CGFloat
    let c: CGFloat
    
    var k: CGFloat { -1 * a / b }
    
    init(a: CGFloat, b: CGFloat, c: CGFloat) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    init(p1: CGPoint, p2: CGPoint) {
        if p1.x == p2.x {
            a = 1
            b = 0
            c = -p1.x
        } else if p1.y == p2.y {
            a = 0
            b = 1
            c = -p1.y
        } else {
            a = (p2.y - p1.y) / (p2.x - p1.x)
            b = -1
            c = p1.y - (p1.x * (p2.y - p1.y) / (p2.x - p1.x) )
        }
    }
    
    func y(x: CGFloat) -> CGFloat {
        -1 * (a * x + c) / b
    }
    
    func point(x: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y(x: x))
    }
}
