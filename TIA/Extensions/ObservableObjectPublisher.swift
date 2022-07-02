//
//  ObservableObjectPublisher.swift
//  TIA
//
//  Created by serhii.lomov on 09.05.2022.
//

import Foundation
import Combine

extension ObservableObjectPublisher {
    func sendOnMain() {
        if Thread.isMainThread {
            self.send()
        } else {
            DispatchQueue.main.async {
                self.send()
            }
        }
    }
}
