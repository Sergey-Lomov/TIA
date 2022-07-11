//
//  EditorStorageService.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 11.07.2022.
//

import Foundation
import Combine

enum StorageKey: String {
    case adventurePath
    case layoutPath
    case screenSize
}

final class EditorStorageService {

    static let shared = EditorStorageService()

    private var subscriptions: [StorageKey: AnyCancellable] = [:]

    func startSink<P: Publisher>(_ key: StorageKey, publisher: P) where P.Failure == Never, P.Output: RawRepresentable, P.Output.RawValue == String {
        let subscription = publisher.sink { value in
            let string = value.rawValue
            UserDefaults.set(string, forKey: key)
        }
        subscriptions[key] = subscription
    }

    static func getAdventurePath() -> String? {
        UserDefaults.string(forKey: .adventurePath)
    }

    static func setAdventurePath(_ path: String) {
        UserDefaults.set(path, forKey: .adventurePath)
    }

    static func getLayoutPath() -> String? {
        UserDefaults.string(forKey: .layoutPath)
    }

    static func setLayoutPath(_ path: String) {
        UserDefaults.set(path, forKey: .layoutPath)
    }

    static func getScreenSize() -> ScreenSize? {
        let raw = UserDefaults.string(forKey: .screenSize)
        guard let raw = raw else { return nil }
        return ScreenSize(rawValue: raw)
    }
}
