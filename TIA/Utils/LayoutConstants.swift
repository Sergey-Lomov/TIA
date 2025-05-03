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
    struct MainMenu {
        static let pickerSize: CGFloat = 200
        static let currentIconY: CGFloat = 0.25
        static let currentIconSize: CGFloat = 0.15
        static let doneIconSize: CGFloat = 0.125
        static let doneIconsInteritem: CGFloat = 15
        static let doneIconsGap: CGFloat = 10
        static let horizontalInset: CGFloat = 16
    }

    struct Menu {
        static let zoom: CGFloat = 1
        static let gap: CGFloat = 0.1
        static let radius: CGFloat = (1 - gap * 2 - Vertex.diameter) / zoom / 2
    }

    struct Player {
        static let strokeRatio: CGFloat = 0.05
        static let blobSize: CGFloat = Vertex.diameter * 0.25
        static let eyeSize: CGFloat = Vertex.diameter * 0.66
    }

    struct Adventure {
        static let border: CGFloat = 0.05
    }

    struct Vertex {
        /// Vertex diamtere ration to screen size
        static let diameter: CGFloat = 0.15
        static let onVisitIcon: CGFloat = 0.75
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
            static let offsetScale = (Layout.Vertex.diameter + radius) / 6
        }

        struct Player {
            static let sizeRatio: CGFloat = 0.3
            static let vertexGap: CGFloat = 4 
            static let interitemGap: CGFloat = 0.3 // Ratio of interitem gap to item size
        }
    }
}
