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
}

private struct TransferStep {
    var state: CameraState
    var anchorState: CameraState
    var animation: Animation = .none
}

class CameraViewModel: ObservableObject {
    
    // TODO: remove test code
    var testId: String = UUID().uuidString
    
    @Published var state: CameraState
    @Published var anchorState: CameraState
    @Published var animation: Animation = .none
    var completion: Action?
    
    private var transferInProgress: Bool = true
    private var steps: [TransferStep] = []
    
    init(state: CameraState) {
        self.state = state
        self.anchorState = state
    }
    
    func transferTo(_ targetState: CameraState,
                    animation: Animation = .none,
                    anchorAnimation: AnchorAnimation = .dynamic,
                    completion: Action? = nil) {
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
        // TODO: Here may be a problem - request to published without wrap to main async
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
