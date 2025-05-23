//
//  EnvironmentKeys.swift
//  TIA
//
//  Created by serhii.lomov on 23.06.2022.
//

import SwiftUI

struct DrawingWidthKey: EnvironmentKey {
    static var defaultValue: CGFloat = 1
}

struct DrawingProgressKey: EnvironmentKey {
    static var defaultValue: CGFloat = 0
}

struct CameraServiceKey: EnvironmentKey {
    static var defaultValue = CameraService(safe: .zero, full: .zero)
}

enum ControlsShowingMode {
    case none
    case selected
    case all
}

struct ControlsShowingModeKey: EnvironmentKey {
    static var defaultValue: ControlsShowingMode = .none
}

extension EnvironmentValues {
    var drawingWidth: CGFloat {
        get { self[DrawingWidthKey.self] }
        set { self[DrawingWidthKey.self] = newValue }
    }

    var drawingProgress: CGFloat {
        get { self[DrawingProgressKey.self] }
        set { self[DrawingProgressKey.self] = newValue }
    }

    var cameraService: CameraService {
        get { self[CameraServiceKey.self] }
        set { self[CameraServiceKey.self] = newValue }
    }

    var controlsShowingMode: ControlsShowingMode {
        get { self[ControlsShowingModeKey.self] }
        set { self[ControlsShowingModeKey.self] = newValue }
    }
}
