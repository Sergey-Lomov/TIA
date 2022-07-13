//
//  CameraViewModel.swift
//  TIA
//
//  Created by serhii.lomov on 26.06.2022.
//

import Foundation
import SwiftUI

enum AnchorAnimation {
    case initial
    case dynamic
    case final
}

struct CameraState {
    let center: CGPoint
    let zoom: CGFloat
    let angle: CGFloat

    init (center: CGPoint, zoom: CGFloat = 1, angle: CGFloat = 0) {
        self.center = center
        self.zoom = zoom
        self.angle = angle
    }

    static var `default` = CameraState(center: .zero)

    static func == (lhs: CameraState, rhs: CameraState) -> Bool {
        lhs.angle == rhs.angle && lhs.zoom == rhs.zoom && lhs.center == rhs.center
    }

    func translated(_ translation: CGPoint) -> CameraState {
        CameraState(center: center.translated(by: translation), zoom: zoom, angle: angle)
    }

    func zoomed(_ scale: CGFloat) -> CameraState {
        CameraState(center: center, zoom: zoom * scale, angle: angle)
    }

    func zoomNormalized(_ minZoom: CGFloat, _ maxZoom: CGFloat) -> CameraState {
        let zoom = min(maxZoom, max(minZoom, zoom))
        return CameraState(center: center, zoom: zoom, angle: angle)
    }
}

private struct TransferStep {
    var state: CameraState
    var anchorState: CameraState
    var animation: Animation = .none
}

final class CameraViewModel: ObservableObject {
    
    @Published var state: CameraState
    @Published var anchorState: CameraState
    @Published var animation: Animation = .none
    var immideatelyUpdate = true
    var completion: Action?

    var transferInProgress = true
    var manuallyControlled = false
    private var steps: [TransferStep] = []

    init(state: CameraState) {
        self.state = state
        self.anchorState = state
    }

    func transferTo(_ targetState: CameraState,
                    animation: Animation = .none,
                    anchorAnimation: AnchorAnimation = .dynamic,
                    completion: Action? = nil) {
        guard !manuallyControlled else { return }

        self.completion = completion
        steps = []

        if anchorAnimation == .final {
            steps.append(state: state, anchor: targetState)
        }

        let anchor = anchorAnimation == .initial ? state : targetState
        steps.append(state: targetState, anchor: anchor, animation: animation)

        if anchorAnimation == .initial {
            steps.append(state: targetState, anchor: targetState)
        }

        if !transferInProgress {
            executeNextStep()
        }
    }

    func stepApplied() {
        executeNextStep()
    }

    private func executeNextStep() {
        guard let next = steps.first else {
            transferInProgress = false
            // Following trick with completion fixed case, when inside completion calls new transform with new completion
            let completion = self.completion
            self.completion = nil
            completion?()
            return
        }

        transferInProgress = true
        steps.removeFirst()
        immideatelyUpdate = next.state == state && next.anchorState == anchorState
        state = next.state
        anchorState = next.anchorState
        animation = next.animation
    }
}

extension Array where Element == TransferStep {
    mutating func append(state: CameraState, anchor: CameraState, animation: Animation = .none) {
        let new = TransferStep(state: state, anchorState: anchor, animation: animation)
        append(new)
    }
}
