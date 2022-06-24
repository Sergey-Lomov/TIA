//
//  EnvironmentKeys.swift
//  TIA
//
//  Created by serhii.lomov on 23.06.2022.
//

import SwiftUI

struct DrawingProgressKey: EnvironmentKey {
    static var defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var drawingProgress: CGFloat {
        get { self[DrawingProgressKey.self] }
        set { self[DrawingProgressKey.self] = newValue }
    }
}

struct CameraServiceKey: EnvironmentKey {
    static var defaultValue = CameraService(size: .zero)
}

extension EnvironmentValues {
    var cameraService: CameraService {
        get { self[CameraServiceKey.self] }
        set { self[CameraServiceKey.self] = newValue }
    }
}

// TODO: Try to use standard stroke width
struct DrawingWidthKey: EnvironmentKey {
    static var defaultValue: CGFloat = 1
}

extension EnvironmentValues {
    var drawingWidth: CGFloat {
        get { self[DrawingWidthKey.self] }
        set { self[DrawingWidthKey.self] = newValue }
    }
}
