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
        
        enum Layer {
            static let transitionDuration: CGFloat = 1
        }
        
        enum Vertex {
            static let ungrowingDuration: CGFloat = 0.5
        }
        
        enum Edge {
            // TODO: After edge animations refactoring this constant shoiuld be used to control counter connector growing duration
            static let elementsGrowingDuration: CGFloat = 0.5
            static let elementsUngrowingDuration: CGFloat = 0.3
            static let pathUngrowingDuration: CGFloat = 0.7
        }
        
        enum Gate {
            static let resizeDuration: CGFloat = 0.5
        }
        
        enum Resource {
            static let movingGapRatio: CGFloat = 1
            static let startMaxRatio: CGFloat = 0.25
        }
    }
    
    // TODO: Introduce player moving phases duration instead calculate durations each time based on eye transforamation durations. This will be clear concept instead current solution, which make many unrelated animations be based at yey transformation pahases.
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
    
    var presentLayer: Animation {
        .easeOut(duration: Const.Layer.transitionDuration)
    }
    var hideLayer: Animation {
        .easeIn(duration: Const.Layer.transitionDuration)
    }

    var growingGate: Animation {
        .easeOut(duration: Const.Edge.elementsGrowingDuration)
    }
    var ungrowingGate: Animation {
        .easeIn(duration: Const.Edge.elementsUngrowingDuration)
    }
    var openGate: Animation {
        .easeIn(duration: Const.Gate.resizeDuration)
    }
    var closeGate: Animation {
        .easeOut(duration: Const.Gate.resizeDuration)
    }
    
    var menuSeedExtension: Animation {
        let duration = eyeTransDuration(from: .compressed, to: .closed) + eyeTransDuration(from: .closed, to: .opened)
        return .easeOut(duration: duration * 10)
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
    
    func resToGateDuration() -> TimeInterval {
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
