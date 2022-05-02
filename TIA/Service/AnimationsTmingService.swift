//
//  AnimationsTmingService.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import CoreGraphics

final class AnimationService {
    static let shared = AnimationService()
    
    private let playerMovingMult: Double = 4
    
    init() {}
    
    func playerMovingDuration(edgeLength: CGFloat) -> TimeInterval {
        return edgeLength * playerMovingMult
    }
}
