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
            static let lengthMult: CGFloat = 0.005
        }
        
        enum Gate {
            static let resizeDuration: CGFloat = 0.5
        }
        
        enum Resource {
            static let movingGapRatio: CGFloat = 1
            static let startMaxRatio: CGFloat = 0.25
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
    
    var resourceToGate: Animation {
        let closing = eyeTransDuration(from: .opened, to: .closed)
        let compressing = eyeTransDuration(from: .closed, to: .compressed)
        return .easeOut(duration: closing + compressing)
    }
    
    var resourceFromGate: Animation {
        let opening = eyeTransDuration(from: .closed, to: .opened)
        let expanding = eyeTransDuration(from: .compressed, to: .closed)
        return .easeIn(duration: opening + expanding)
    }
    
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
    
    func resourceMovingTiming(_ geometry: GeometryProxy,
                              playerLength: CGFloat,
                              resourceLength: CGFloat,
                              index: Int,
                              total: Int) -> (duration: CGFloat, delay: CGFloat) {
        let playerDuration = playerMovingDuration(length: playerLength)
        guard total > 1 else {
            return (playerDuration, 0)
        }
        
        let size = LayoutService.inventoryResourceSize(geometry)
        let distance = (1 + Const.Resource.movingGapRatio) * size.minSize
        let startEstimated = distance / (resourceLength / playerDuration) * CGFloat(total - 1)
        let startMax = playerDuration * Const.Resource.startMaxRatio
        let start = min(startEstimated, startMax)
        let duration = playerDuration - start
        let delay = start / CGFloat(total - 1) * CGFloat(index)
        return (duration, delay)
    }
}
