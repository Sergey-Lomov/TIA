//
//  CGSize.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import Foundation
import SwiftUI

extension CGSize {
    func multed(_ mult: CGFloat) -> CGSize {
        return CGSize(width: width * mult,
                      height: height * mult)
    }
}
