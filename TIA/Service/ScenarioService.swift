//
//  ScenarioService.swift
//  TIA
//
//  Created by Serhii.Lomov on 08.04.2022.
//

import Foundation

class ScenarioService {
    
    static var shared = ScenarioService()
    
    func restoreScenario() -> Scenario {
        let states = StorageService.shared.getAdventuresStates()
        return Scenario(prototype: prototype, states: states)
    }
    
    lazy var prototype: ScenarioPrototype = {
        ScenarioPrototype(adventures: [
            darkAdventure1,
            darkAdventure2,
            lightAdventure1,
            truthAdventure1
        ])
    }()
    
    lazy var darkAdventure1: AdventurePrototype = {
        let v1 = VertexPrototype(type: .entrance, resources: [])
        let v2 = VertexPrototype(type: .intermediate, resources: [.anger])
        let v3 = VertexPrototype(type: .intermediate, resources: [.anger, .despair])
        let v4 = VertexPrototype(type: .intermediate, resources: [.yearning, .yearning])
        let v5 = VertexPrototype(type: .intermediate, resources: [.despair])
        let v6 = VertexPrototype(type: .exit, resources: [])
        
        let e1 = EdgePrototype(from: v1, to: v2)
        let e2 = EdgePrototype(from: v1, to: v3)
        let e3 = EdgePrototype(from: v2, to: v3)
        let e4 = EdgePrototype(from: v3, to: v4, price: [.despair])
        let e5 = EdgePrototype(from: v2, to: v4, price: [.anger])
        let e6 = EdgePrototype(from: v4, to: v6, price: [.despair])
        let e7 = EdgePrototype(from: v2, to: v5, price: [.anger])
        let e8 = EdgePrototype(from: v3, to: v5, price: [.despair])
        let e9 = EdgePrototype(from: v5, to: v6, price: [.yearning])
        
        var vertices = [v1, v2, v3,v4, v5, v6]
        var edges = [e1, e2, e3, e4, e5, e6, e7, e8, e9]
        
        return AdventurePrototype(id: "dark1",
                                  index: 1,
                                  theme: .dark,
                                  vertices: vertices,
                                  edges: edges)
    }()
    
    lazy var darkAdventure2: AdventurePrototype = {
        let v1 = VertexPrototype(type: .entrance, resources: [])
        let v2 = VertexPrototype(type: .exit, resources: [])
        
        let e1 = EdgePrototype(from: v1, to: v2)
        
        var vertices = [v1, v2]
        var edges = [e1]
        
        return AdventurePrototype(id: "dark2",
                                  index: 2,
                                  theme: .dark,
                                  vertices: vertices,
                                  edges: edges)
    }()
    
    lazy var lightAdventure1: AdventurePrototype = {
        let v1 = VertexPrototype(type: .entrance, resources: [])
        let v2 = VertexPrototype(type: .exit, resources: [])
        
        let e1 = EdgePrototype(from: v1, to: v2)
        
        var vertices = [v1, v2]
        var edges = [e1]
        
        return AdventurePrototype(id: "light1",
                                  index: 1,
                                  theme: .light,
                                  vertices: vertices,
                                  edges: edges)
    }()
    
    lazy var truthAdventure1: AdventurePrototype = {
        let v1 = VertexPrototype(type: .entrance, resources: [])
        let v2 = VertexPrototype(type: .exit, resources: [])
        
        let e1 = EdgePrototype(from: v1, to: v2)
        
        var vertices = [v1, v2]
        var edges = [e1]
        
        return AdventurePrototype(id: "truth1",
                                  index: 1,
                                  theme: .truth,
                                  vertices: vertices,
                                  edges: edges)
    }()
}
