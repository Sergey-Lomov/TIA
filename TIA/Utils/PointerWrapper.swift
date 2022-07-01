//
//  PointerWrapper.swift
//  TIA
//
//  Created by Serhii.Lomov on 17.04.2022.
//

import Foundation

class PointerWrapper<T> {

    private let pointer: UnsafeMutablePointer<T>
    var value: T {
        get { pointer.pointee }
        set { pointer.pointee = newValue }
    }

    init(_ value: inout T) {
        pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        pointer.initialize(to: value)
    }

    deinit {
        pointer.deinitialize(count: 1)
        pointer.deallocate()
    }
}
