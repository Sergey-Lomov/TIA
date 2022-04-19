//
//  GeometryProxy.swift
//  TIA
//
//  Created by Serhii.Lomov on 19.04.2022.
//

import Foundation
import SwiftUI

extension GeometryProxy {
    var minSize: CGFloat { min(size.width, size.height) }
}
