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
    
    private let playerMovingMult: CGFloat = 0.005 // TODO: this value was decreased for development purposes, should be changed to more slow
    private let resourceMovingPhase: CGFloat = 0.3
    private let gateResizeDuration: CGFloat = 0.5
    
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
    
    var openGate: Animation { .easeIn(duration: gateResizeDuration) }
    var closeGate: Animation { .easeOut(duration: gateResizeDuration) }
    
    init() {}
    
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
        return length * playerMovingMult
    }
    
    func resourceMovingTiming(length: CGFloat, index: Int, total: Int) -> (duration: CGFloat, delay: CGFloat) {
        let playerDuration = playerMovingDuration(length: length)
        guard total > 1 else {
            return (playerDuration, 0)
        }
        
        let duration = playerDuration * (1 - resourceMovingPhase)
        let delay = (resourceMovingPhase * playerDuration) / CGFloat(total) * CGFloat(index)
        return (duration, delay)
    }
}
