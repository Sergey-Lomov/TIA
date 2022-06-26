//
//  EnvironmentKeys.swift
//  TIA
//
//  Created by serhii.lomov on 23.06.2022.
//

import SwiftUI

// TODO: Try to use standard stroke width
struct DrawingWidthKey: EnvironmentKey {
    static var defaultValue: CGFloat = 1
}

struct DrawingProgressKey: EnvironmentKey {
    static var defaultValue: CGFloat = 0
}

struct CameraServiceKey: EnvironmentKey {
    static var defaultValue = CameraService(safe: .zero, full: .zero)
}

struct FinalizedAdventureKey: EnvironmentKey {
    static var defaultValue: AdventureDescriptor? = nil
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
    
    var finalizedAdventure: AdventureDescriptor? {
        get { self[FinalizedAdventureKey.self] }
        set { self[FinalizedAdventureKey.self] = newValue }
    }
}
