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
            static let premoveDuration: CGFloat = 1.5
            static let postmoveDuration: CGFloat = 1.5
            static let eyeCompressing: CGFloat = 0.33
            static let eyeOpening: CGFloat = 0.33
        }

        enum Layer {
            static let transitionDuration: CGFloat = 1
        }

        enum Vertex {
            static let growingDuration: CGFloat = 0.5
            static let ungrowingDuration: CGFloat = 0.5
            static let elementsGrowingDuration: CGFloat = 1
        }

        enum Edge {
            static let pathGrowingMult: CGFloat = 0.005
            static let elementsGrowingDuration: CGFloat = 1.0
            static let elementsUngrowingDuration: CGFloat = 0.3
            static let pathUngrowingDuration: CGFloat = 0.7
            static let seedExtensionMult: CGFloat = 10
        }

        enum Gate {
            static let resizeDuration: CGFloat = 0.5
        }

        enum Resource {
            static let soloIdleDuration: CGFloat = 15
            static let groupIdleDuration: CGFloat = 40
            static let movingGapRatio: CGFloat = 1
            static let startMaxRatio: CGFloat = 0.25
        }
    }

    private let eyeTransDuration: [EyeState: [EyeState: TimeInterval]] = [
        .closed: [
            .compressed: Const.Player.eyeCompressing * Const.Player.premoveDuration,
            .opened: Const.Player.eyeOpening * Const.Player.premoveDuration
        ],
        .compressed: [
            .closed: Const.Player.eyeCompressing * Const.Player.postmoveDuration
        ],
        .opened: [
            .closed: Const.Player.eyeOpening * Const.Player.postmoveDuration
        ]
    ]
    private let eyeTransBulder: [EyeState: [EyeState: AnimBuilder]] = [
        .closed: [.compressed: { .easeIn(duration: $0) },
                  .opened: { .easeOut(duration: $0) }],
        .compressed: [.closed: { .easeIn(duration: $0) }],
        .opened: [.closed: { .easeIn(duration: $0) }]
    ]

    func eyeTransDuration(from: EyeState, to: EyeState) -> TimeInterval {
        return eyeTransDuration[from]?[to] ?? 0
    }

    func eyeTransAnimation(from: EyeState, to: EyeState) -> Animation? {
        guard let builder = eyeTransBulder[from]?[to] else {
            return nil
        }
        return builder(eyeTransDuration(from: from, to: to))
    }

    var fromAdventure: Animation { .linear(duration: 2) }
    var toAdventure: Animation { .linear(duration: 2) }
    var switchAdventure: Animation { .linear(duration: 1) }
    var adventureInitial: Animation { .easeOut(duration: 1.5) }
    var adventureFinal: Animation {
        let duration = Const.Edge.elementsUngrowingDuration + Const.Edge.pathUngrowingDuration
        return .linear(duration: duration)
    }

    var presentLayer: Animation {
        .easeOut(duration: Const.Layer.transitionDuration)
    }
    var hideLayer: Animation {
        .easeIn(duration: Const.Layer.transitionDuration)
    }

    var vertexGrowing: Animation {
        .easeOut(duration: Const.Vertex.growingDuration)
    }

    var vertexUngrowing: Animation {
        .easeIn(duration: Const.Vertex.ungrowingDuration)
    }

    var vertexElementsGrowing: Animation {
        .linear(duration: Const.Vertex.elementsGrowingDuration)
    }

    func edgePathGrowing(length: CGFloat) -> Animation {
        let duration = Const.Edge.pathGrowingMult * length
        return .easeOut(duration: duration)
    }

    var edgeElementsGrowing: Animation {
        .easeOut(duration: Const.Edge.elementsGrowingDuration)
    }

    var edgePathUngrowing: Animation {
        .easeIn(duration: Const.Edge.pathUngrowingDuration)
    }

    var edgeElementsUngrowing: Animation {
        .easeIn(duration: Const.Edge.elementsUngrowingDuration)
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
        let duration = Const.Player.postmoveDuration * Const.Edge.seedExtensionMult
        return .easeOut(duration: duration)
    }

    func playerMovingDuration(length: CGFloat) -> TimeInterval {
        return length * Const.Player.lengthMult
    }

    func onVisitHiding(incomeLength: CGFloat) -> Animation {
        let duration = playerMovingDuration(length: incomeLength)
        return .linear(duration: duration)
    }

    var resourceGroupRotation: Animation {
        .linear(duration: Const.Resource.groupIdleDuration)
    }

    var resourceSoloRotation: Animation {
        .linear(duration: Const.Resource.soloIdleDuration)
    }

    func resourceVertexOut(edgeLength: CGFloat) -> Animation {
        let duration = playerMovingDuration(length: edgeLength)
        return .easeOut(duration: duration)
    }

    func resourceMoving(_ geometry: GeometryProxy,
                        playerLength: CGFloat,
                        resourceLength: CGFloat,
                        index: Int,
                        total: Int) -> Animation {
        let playerDuration = playerMovingDuration(length: playerLength)
        guard total > 1 else {
            return .easeInOut(duration: playerDuration)
        }

        let size = LayoutService.inventoryResourceSize(geometry)
        let distance = (1 + Const.Resource.movingGapRatio) * size.minSize
        let startEstimated = distance / (resourceLength / playerDuration) * CGFloat(total - 1)
        let startMax = playerDuration * Const.Resource.startMaxRatio
        let start = min(startEstimated, startMax)
        let duration = playerDuration - start
        let delay = start / CGFloat(total - 1) * CGFloat(index)

        return .easeInOut(duration: duration).delay(delay)
    }

    var resourceFromGate: Animation {
        let duration = Const.Player.postmoveDuration - Const.Gate.resizeDuration
        return .easeOut(duration: duration)
    }

    var resourceToGate: Animation {
        return .easeInOut(duration: Const.Player.premoveDuration)
    }

    func resourceDestroying(index: Int, total: Int) -> Animation {
        let step = total > 1 ? 1 / CGFloat(total - 1) : 0
        let delay = CGFloat(index) * step
        return .easeInOut(duration: 1).delay(delay)
    }
}
