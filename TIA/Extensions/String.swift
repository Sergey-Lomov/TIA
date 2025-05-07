//
//  String.swift
//  TIA
//
//  Created by serhii.lomov on 10.07.2022.
//

import Foundation

extension String {

    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}
