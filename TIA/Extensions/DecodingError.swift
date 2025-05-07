//
//  DecodingError.swift
//  TIA
//
//  Created by Serhii.Lomov on 13.04.2022.
//

import Foundation

extension DecodingError {

    var detailedDescription: String {
        switch self {
        case .typeMismatch(let type, let context):
            return "Type mismatch:\nType: \(type)\nMismatch: \(context.debugDescription)\nPath:\(context.codingPath)"

        case .valueNotFound(let type, let context):
            return "Value not found:\nType: \(type)\nDetails: \(context.debugDescription)\nPath:\(context.codingPath)"

        case .keyNotFound(let key, let context):
            return "Key not found \"\(key)\" details: \"\(context.debugDescription)\""

        case .dataCorrupted(let context):
            return "Data corrupted. Details: \(context.debugDescription)"

        @unknown default:
            return "Unknown decoding error"
        }
    }
}
