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
    
    private let playerMovingMult: CGFloat = 4
    private let resourceMovingPhase: CGFloat = 0.3
    
    init() {}
    
    func playerMovingDuration(edgeLength: CGFloat) -> TimeInterval {
        return edgeLength * playerMovingMult
    }
    
    func resourceMovingTiming(edgeLength: CGFloat, index: Int, total: Int) -> (duration: CGFloat, delay: CGFloat) {
        let playerDuration = playerMovingDuration(edgeLength: edgeLength)
        let duration = playerDuration * (1 - resourceMovingPhase)
        let delay = (resourceMovingPhase * playerDuration) / CGFloat(total) * CGFloat(index)
        return (duration, delay)
    }
}
