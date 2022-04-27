//
//  LayoutConstants.swift
//  TIA
//
//  Created by Serhii.Lomov on 26.04.2022.
//

import Foundation
import CoreGraphics

/// This struct constains all layout constants. Constants was moved out of related views because many of it related to each other.
struct Layout {
    struct Vertex {
        /// Vertex radius ration to screen size
        static let radius: CGFloat = 0.15
    }
    
    struct Edge {
        static let curveWidth: CGFloat = 4
        static let borderWidth: CGFloat = 2
        static let idleDelta: CGFloat = 0.1
        static let idleDuration: CGFloat = 4
        static let undrelineWidth = curveWidth + borderWidth * 2
    }
    
    struct Resources {
        struct Vertex {
            static let sizeRatio: CGFloat = 0.25
        }
        
        struct Player {
            static let sizeRatio: CGFloat = 0.3
        }
    }
}
