//
//  UserDefaults.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 11.07.2022.
//

import Foundation

extension UserDefaults {
    static func set(_ value: Any?, forKey key: StorageKey) {
        standard.setValue(value, forKey: key.rawValue)
    }

    static func string(forKey key: StorageKey) -> String? {
        standard.string(forKey: key.rawValue)
    }
}
