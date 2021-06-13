//
//  Graph.swift
//  Algo Visualizer 2.0 app
//
//  Created by Omar Nader on April/17/21.
//


import Foundation


public class Node : Hashable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var canVisit : Bool! = true
    var isFromPath : Bool! = false
    
    var value : Int
    var weight : Int
    var connections : [Node]
    let identifier = UUID()
    var visited : Bool
    init(value : Int , weight : Int , connections : [Node] , visited : Bool) {
        self.value = value
        self.weight = weight
        self.connections = connections
        self.visited = visited
    }
    public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
    }
    
    public func printNode() {
        var l : [Int : [Int]] = [:]
        var con : [Int] = []
        for i in self.connections {
            con.append(i.value)
        }
        
        l[self.value] = con
        
        print(l )
    }
    
}
public class Graph {
    
    var list : [Node]
    init(list : [Node]) {
        self.list = list;
        
    }
    
    public func addNewConnection(from node : Node , to secondNode : Node) {
        if node.value-1 < self.list.count {
            self.list[node.value-1].connections.append(secondNode)
        }
        else {
            let newNode = Node(value: node.value, weight: node.weight, connections: [secondNode], visited: false)
            self.list.append(newNode)
        }
        
    }
  
    public func generateMap(rowCount : Int , columnCount : Int) {
        

        var index3 = 1
        for _ in 0...rowCount {
            for _ in 0..<columnCount {
                self.list.append(Node(value: index3, weight: index3, connections: [], visited: false))
                index3+=1;
                
            }
        }

        index3 = 1;
        for i in 0...rowCount {
            for x in 0..<columnCount {
                let conn = getNeighbours(row: i, column: x, index: index3 , columnCount : columnCount , rowCount : rowCount)
                
                for f in conn {
                    if f > self.list.count {
                        continue
                    }
                    self.addNewConnection(from: self.list[index3-1], to: self.list[f-1] )
                }
                index3+=1
            }
        }

    }
    func generateEdges() -> [(Node , Node)]{
        
        var edgesList : [(Node,Node)] = []
        for i in self.list {
            for j in i.connections {
                edgesList.append((i , j))
            }
        }
        return edgesList
        
    }
    
    func getNeighbours(row : Int , column : Int, index : Int , columnCount : Int , rowCount : Int ) -> [Int] {
        var answer : [Int] = [];
        if column != 0 {
            answer.append(index-1)
            
        }
        if column != columnCount-1 {
            answer.append( index + 1)
        }
        
        if row != 0 {
            
            answer.append((index - (columnCount)))
        }
        if row != rowCount {
           
            answer.append((index + (columnCount)))
        }
        
        return answer
    }
    
    
    
}
