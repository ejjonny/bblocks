//
//  djk.swift
//  bblocks
//
//  Created by Ethan John on 4/4/22.
//

import Foundation

class Vertex: Equatable, Hashable {
    init(
        neighbours: [(Vertex, Double)] = [],
        pathLengthFromStart: Double = Double.infinity,
        pathVerticesFromStart: [Vertex] = [],
        block: Block
    ) {
        self.neighbours = neighbours
        self.pathLengthFromStart = pathLengthFromStart
        self.pathVerticesFromStart = pathVerticesFromStart
        self.block = block
    }
    
    var identifier: String {
        block.id.uuidString
    }
    var neighbours: [(Vertex, Double)] = []
    var pathLengthFromStart = Double.infinity
    var pathVerticesFromStart: [Vertex] = []
    var block: Block
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    public static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    func clearCache() {
        pathLengthFromStart = Double.infinity
        pathVerticesFromStart = []
    }
}

struct Dijkstra {
    private var totalVertices: Set<Vertex>

    init(vertices: Set<Vertex>) {
        totalVertices = vertices
    }
    mutating func clearCache() {
        totalVertices.forEach { $0.clearCache() }
    }

    mutating func findShortestPaths(from start: Vertex) {
        clearCache()
        start.pathLengthFromStart = 0
        start.pathVerticesFromStart.append(start)
        var currentVertex: Vertex? = start
        while let vertex = currentVertex {
            totalVertices.remove(vertex)
            let filteredNeighbours = vertex.neighbours.filter { totalVertices.contains($0.0) }
            for neighbour in filteredNeighbours {
                let neighbourVertex = neighbour.0
                let weight = neighbour.1
                let theoreticNewWeight = vertex.pathLengthFromStart + weight
                if theoreticNewWeight < neighbourVertex.pathLengthFromStart {
                    neighbourVertex.pathLengthFromStart = theoreticNewWeight
                    neighbourVertex.pathVerticesFromStart = vertex.pathVerticesFromStart
                    neighbourVertex.pathVerticesFromStart.append(neighbourVertex)
                }
            }
            if totalVertices.isEmpty {
                currentVertex = nil
                break
            }
            currentVertex = totalVertices.min { $0.pathLengthFromStart < $1.pathLengthFromStart }
        }
    }
}
