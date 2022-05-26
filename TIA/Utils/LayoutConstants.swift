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
    struct Menu {
        static let vertexDiameter: CGFloat = 0.2
    }
    
    struct Vertex {
        /// Vertex diamtere ration to screen size
        static let diameter: CGFloat = 0.15
    }
    
    struct Edge {
        static let curveWidth: CGFloat = 4
        static let borderWidth: CGFloat = 2
        static let idleDelta: CGFloat = 0.1
        static let idleDuration: CGFloat = 4
        static let undrelineWidth = curveWidth + borderWidth * 2
        static let outSpacing: CGFloat = curveWidth + borderWidth * 6
    }
    
    struct EdgeGate {
        static let sizeRatio: CGFloat = 0.05
        static let symbolRatio: CGFloat = 0.75
    }
    
    struct Resources {
        struct Vertex {
            static let sizeRatio: CGFloat = 0.3
            static let radius: CGFloat = Layout.Vertex.diameter * sizeRatio
            // 6 is coefficient based on full formula: (half of vertex radius - resource radius) / 3 + half of resource radius. By this calculations, distance between vertex's resources is same like a distance between each resource edge and vertex edge
            static let angleScale = (Layout.Vertex.diameter + radius) / 6
        }
        
        struct Player {
            static let sizeRatio: CGFloat = 0.3
            static let vertexGap: CGFloat = 0.15 // Ratio of first radius gap to vertex size
            static let interitemGap: CGFloat = 0.3 // Ratio of interitem gap to item size
        }
    }
}
