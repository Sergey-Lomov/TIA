//
//  ObservableObjectPublisher.swift
//  TIA
//
//  Created by serhii.lomov on 09.05.2022.
//

import Foundation
import Combine

extension ObservableObjectPublisher {
    // TODO: Add SwiftLint ule to use sendOnMain always for objectWillChange
    func sendOnMain() {
        DispatchQueue.main.async {
            self.send()
        }
    }
}
