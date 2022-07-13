//
//  CameraControlEvents.swift
//  TIA
//
//  Created by serhii.lomov on 14.07.2022.
//

import Foundation
import Combine

typealias CameraControlPublisher = PassthroughSubject<CameraControlEvents, Never>

enum CameraControlEvents {
    case reset
    case setZoom(_ zoom: CGFloat)
    case multiplyZoom(_ multiplier: CGFloat)
}

extension CameraViewModel {

    func handleControlEvent(_ event: CameraControlEvents) {
        guard !transferInProgress else { return }
        switch event {
        case .reset:
            state = .default
        case .setZoom(let zoom):
            state = CameraState(center: state.center,
                                zoom: zoom,
                                angle: state.angle)
        case .multiplyZoom(let multiplier):
            state = CameraState(center: state.center,
                                zoom: state.zoom * multiplier,
                                angle: state.angle)
        }
    }
}
