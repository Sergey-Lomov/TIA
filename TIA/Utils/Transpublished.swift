//
//  Transpublished.swift
//  TIA
//
//  Created by serhii.lomov on 02.07.2022.
//

import Combine

@propertyWrapper struct Transpublished<Value: ObservableObject> {
    private var subscription: AnyCancellable?
    var publisher: ObservableObjectPublisher? {
        didSet {
            let publisher = publisher
            subscription = wrappedValue.objectWillChange.sink { _ in
                publisher?.sendOnMain()
            }
        }
    }

    var wrappedValue: Value {
        didSet {
            let publisher = publisher
            subscription = wrappedValue.objectWillChange.sink { _ in
                publisher?.sendOnMain()
            }
        }
    }

    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
