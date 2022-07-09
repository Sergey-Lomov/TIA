//
//  GameState.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation
import Combine

final class GameState: ObservableObject {

    private var subscriptions: [AnyCancellable] = []

    @Published var scenario = ScenarioService.restoreScenario()
    @Published var activeAdventure: AdventurePrototype?
    var finalizedAdventure: Adventure?
}
