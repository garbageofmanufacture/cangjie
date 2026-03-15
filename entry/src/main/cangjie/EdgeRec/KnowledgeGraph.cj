// entry/src/main/cangjie/EdgeRec/KnowledgeGraph.cj
package ohos_app_cangjie_entry.EdgeRec

import std.collection.*
import std.convert.*

public enum EntityType <: ToString & Equatable<EntityType> {
    | User | Post | QaItem | Product | Disease

    public func toString(): String {
        match (this) {
            case User => "User"
            case Post => "Post"
            case QaItem => "QaItem"
            case Product => "Product"
            case Disease => "Disease"
        }
    }

    public operator func ==(other: EntityType): Bool {
        match (this) {
            case User => match (other) { case User => true; case _ => false }
            case Post => match (other) { case Post => true; case _ => false }
            case QaItem => match (other) { case QaItem => true; case _ => false }
            case Product => match (other) { case Product => true; case _ => false }
            case Disease => match (other) { case Disease => true; case _ => false }
        }
    }
}

public class GraphNode {
    public let id: String
    public let name: String
    public let nodeType: EntityType
    public let tags: ArrayList<String>

    public init(id: String, name: String, nodeType: EntityType, tags!: ArrayList<String> = ArrayList<String>()) {
        this.id = id
        this.name = name
        this.nodeType = nodeType
        this.tags = tags
    }

    public func addTag(tag: String): Unit {
        this.tags.add(tag)
    }

    public func hasTag(tag: String): Bool {
        for (t in this.tags) {
            if (t == tag) { return true }
        }
        return false
    }

    public func toString(): String {
        return "GraphNode(id=${this.id}, name=${this.name}, nodeType=${this.nodeType.toString()}, tags=${this.tags.size})"
    }
}

public class GraphEdge {
    public let fromId: String
    public let toId: String
    public let relationType: String
    public let weight: Float64

    public init(fromId: String, toId: String, relationType: String, weight!: Float64 = 1.0) {
        this.fromId = fromId
        this.toId = toId
        this.relationType = relationType
        this.weight = weight
    }

    public func toString(): String {
        return "GraphEdge(${this.fromId} --[${this.relationType}:${this.weight}]--> ${this.toId})"
    }
}

public class KnowledgeGraph {
    private let nodes: HashMap<String, GraphNode> = HashMap<String, GraphNode>()
    private let edges: HashMap<String, ArrayList<GraphEdge>> = HashMap<String, ArrayList<GraphEdge>>()

    public func addNode(node: GraphNode): Unit {
        // 🌟 修复：使用更安全的 put 方法
        this.nodes.add(node.id, node)
    }

    public func addEdge(fromId: String, toId: String, relation: String, weight!: Float64 = 1.0): Unit {
        let edge = GraphEdge(fromId, toId, relation, weight: weight)

        if (!this.edges.contains(fromId)) {
            // 🌟 修复：使用更安全的 put 方法
            this.edges.add(fromId, ArrayList<GraphEdge>())
        }

        let edgeListOpt = this.edges.get(fromId)
        if (edgeListOpt.isSome()) {
            let edgeList = edgeListOpt.getOrThrow()
            edgeList.add(edge)
        }
    }

    public func getNeighbors(nodeId: String): ArrayList<GraphEdge> {
        let result = ArrayList<GraphEdge>()
        let edgeListOpt = this.edges.get(nodeId)
        if (edgeListOpt.isSome()) {
            let edgeList = edgeListOpt.getOrThrow()
            for (edge in edgeList) {
                result.add(edge)
            }
        }
        return result
    }

    public func getNodesByType(entityType: EntityType): ArrayList<GraphNode> {
        let result = ArrayList<GraphNode>()
        for ((_, node) in this.nodes) {
            if (node.nodeType == entityType) {
                result.add(node)
            }
        }
        return result
    }

    // 🌟 修复：明确使用 Option<GraphNode> 替代旧版语法
    public func getNode(nodeId: String): Option<GraphNode> {
        return this.nodes.get(nodeId)
    }

    public func getNodeCount(): Int64 {
        return this.nodes.size
    }

    public func getEdgeCount(): Int64 {
        var count: Int64 = 0
        for ((_, edgeList) in this.edges) {
            count += edgeList.size
        }
        return count
    }

    public func clear(): Unit {
        this.nodes.clear()
        this.edges.clear()
    }
}