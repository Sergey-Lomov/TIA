//
//  HandleableAnimationData.swift
//  TIA
//
//  Created by Serhii.Lomov on 18.04.2022.
//

import Foundation
import SwiftUI

// TODO: Finish or remove
@propertyWrapper
struct HandleableAnimationData<T: VectorArithmetic> {
    var source: UnsafeMutablePointer<T>
    
    var wrappedValue: T {
        get { source.pointee }
        set { source.pointee = newValue }
    }
}
