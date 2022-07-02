//
//  Transpublished.swift
//  TIA
//
//  Created by serhii.lomov on 02.07.2022.
//

import Combine

//@propertyWrapper struct Transpublished<Value: ObservableObject> {
//    private var subscription: AnyCancellable?
//    var publisher: ObservableObjectPublisher? {
//        didSet {
//            let publisher = publisher
//            subscription = wrappedValue.objectWillChange.sink { _ in
//                publisher?.sendOnMain()
//            }
//        }
//    }
//
//    var wrappedValue: Value {
//        didSet {
//            let publisher = publisher
//            subscription = wrappedValue.objectWillChange.sink { _ in
//                publisher?.sendOnMain()
//            }
//        }
//    }
//
//    init(wrappedValue: Value) {
//        self.wrappedValue = wrappedValue
//    }
//}

@propertyWrapper struct Transpublished<Value: ObservableObject> {
    static subscript<T: ObservableObject>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].storage
        }
        set {
            let publisher = instance.objectWillChange as? ObservableObjectPublisher
            publisher?.sendOnMain()
            instance[keyPath: storageKeyPath].subscription = newValue.objectWillChange.sink { _ in
                publisher?.sendOnMain()
            }
            instance[keyPath: storageKeyPath].storage = newValue
        }
    }

    @available(*, unavailable,
        message: "@Published can only be applied to classes"
    )
    var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private var storage: Value
    private var subscription: AnyCancellable?

    init(wrappedValue: Value) {
        storage = wrappedValue
    }
}
