//
//  AnimationService.swift
//  TIA
//
//  Created by serhii.lomov on 02.05.2022.
//

import Foundation
import CoreGraphics
import SwiftUI

final class AnimationService {
    typealias AnimBuilder = (TimeInterval) -> Animation
    
    static let shared = AnimationService()
    
    enum Const {
        enum Player {
            // TODO: this value was decreased for development purposes, should be changed to more slow
            static let lengthMult: CGFloat = 0.025
        }
        
        enum Gate {
            static let resizeDuration: CGFloat = 0.5
        }
        
        enum Resource {
            static let maxItemDelta: TimeInterval = 0.5
            static let startPhaseRatio: CGFloat = 0.3
        }
    }
    
    private let eyeTransDuration: [EyeState: [EyeState: TimeInterval]] = [
        .closed: [.compressed: 0.5, .opened: 1],
        .compressed: [.closed: 0.5],
        .opened: [.closed:  1],
    ]
    private let eyeTransBulder: [EyeState: [EyeState: AnimBuilder]] = [
        .closed: [.compressed: { .easeIn(duration: $0) },
                  .opened: { .easeOut(duration: $0) }],
        .compressed: [.closed: { .easeIn(duration: $0) }],
        .opened: [.closed:  { .easeIn(duration: $0) }],
    ]
    
    var openGate: Animation { .easeIn(duration: Const.Gate.resizeDuration) }
    var closeGate: Animation { .easeOut(duration: Const.Gate.resizeDuration) }
    
    func eyeTransDuration(from: EyeState, to: EyeState) -> TimeInterval {
        return eyeTransDuration[from]?[to] ?? 0
    }
    
    func eyeTransAnimation(from: EyeState, to: EyeState) -> Animation? {
        guard let builder = eyeTransBulder[from]?[to] else {
            return nil
        }
        return builder(eyeTransDuration(from: from, to: to))
    }
    
    func resToEdgeDuration() -> TimeInterval {
        let closing = AnimationService.shared.eyeTransDuration(from: .opened, to: .closed)
        let compression = AnimationService.shared.eyeTransDuration(from: .closed, to: .compressed)
        return closing + compression
    }
    
    func playerMovingDuration(length: CGFloat) -> TimeInterval {
        return length * Const.Player.lengthMult
    }
    
    func resourceMovingTiming(length: CGFloat, index: Int, total: Int) -> (duration: CGFloat, delay: CGFloat) {
        let playerDuration = playerMovingDuration(length: length)
        guard total > 1 else {
            return (playerDuration, 0)
        }
        
        let startByRatio = playerDuration * Const.Resource.startPhaseRatio
        let startByItems = CGFloat(total) * Const.Resource.maxItemDelta
        let start = min(startByRatio, startByItems)
        let duration = playerDuration - start
        let delay = start / CGFloat(total - 1) * CGFloat(index)
        return (duration, delay)
    }
}
