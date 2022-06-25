//
//  UIScreen.swift
//  TIA
//
//  Created by serhii.lomov on 22.06.2022.
//

import Foundation
import UIKit

extension UIScreen {
    static var size: CGSize { main.bounds.size }
    static var minSize: CGFloat { main.bounds.size.minSize }
    static var maxSize: CGFloat { main.bounds.size.maxSize }
}
