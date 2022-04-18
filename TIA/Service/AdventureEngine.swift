//
//  AdventureEngine.swift
//  TIA
//
//  Created by Serhii.Lomov on 15.04.2022.
//

import Foundation

final class AdventureEngine {
    
    private enum Timing {
        static let edgeGrowing: TimeInterval = 1.5
        static let vertexGrowing: TimeInterval = 0.3
    }
    
    var adventure: Adventure
    private let timingQueue = DispatchQueue.main
    
    init(adventure: Adventure) {
        self.adventure = adventure
    }
    
    func growFromEntrace() {
        for vertex in adventure.vertices {
            if vertex.type == .entrance {
                growFromVertex(vertex)
            }
        }
    }
    
    func edgeGrowingDidFinish(_ edge: Edge) {
        growVertex(edge.to)
    }
    
    private func growVertex(_ vertex: Vertex) {
        switch vertex.state {
        case .seed:
            vertex.state = .growing(duration: Timing.vertexGrowing)
            timingQueue.asyncAfter(deadline: .now() + Timing.vertexGrowing) {
                [weak self] in
                vertex.state = .active
                self?.growFromVertex(vertex)
            }
        default:
            break
        }
    }
    
    private func growFromVertex(_ vertex: Vertex) {
        for edge in vertex.outEdges {
            switch edge.state {
            case .seed:
                growEdge(edge)
            default:
                break
            }
        }
    }
    
    private func growEdge(_ edge: Edge) {
        let duration = Timing.edgeGrowing * edge.length
        edge.state = .growing(duration: duration)
//        timingQueue.asyncAfter(deadline: .now() + duration) {
//            [weak self] in
//            edge.state = .active
//            self?.growVertex(edge.to)
//        }
    }
}
