//
//  JSONDecoder.swift
//  TIA
//
//  Created by Serhii.Lomov on 12.04.2022.
//

import Foundation

extension JSONDecoder {
    typealias Scenario = ScenarioService.ScenarioPrototype
    typealias Adventure = ScenarioService.AdventurePrototype
    typealias Layout = AdventureLayout.Prototype
    
    func decodeScenario() -> Scenario {
        do {
            return try decode(Scenario.self, from: Data.scenarioData())
        } catch {
            fatalError("Error at parsing scenarion json: \(error.localizedDescription)")
        }
    }
    
    func decodeAdventure(id: String) -> Adventure {
        do {
            let data = Data.adventureData(id: id)
            return try decode(Adventure.self, from: data)
        } catch {
            fatalError("Error at parsing adventure json for id \"\(id)\": \(error.localizedDescription)")
        }
    }
    
    func decodeLayout(adventureId: String, index: Int) -> Layout {
        do {
            let data = Data.layoutData(adventureId: adventureId, index: index)
            return try decode(Layout.self, from: data)
        } catch {
            fatalError("Error at parsing adventure layout json for adventure \"\(adventureId)\" index \(index): \(error.localizedDescription)")
        }
    }
}
