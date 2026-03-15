// entry/src/main/cangjie/EdgeRec/EdgeRecService.cj
package ohos_app_cangjie_entry.EdgeRec

import std.collection.*
import std.time.*
import std.math.*

public class EdgeRecService {
    private static var instance: ?EdgeRecService = None

    private let graph: KnowledgeGraph = KnowledgeGraph()
    private let profileManager: UserProfileManager = UserProfileManager(100)
    private let itemVectors: HashMap<String, ArrayList<Float64>> = HashMap<String, ArrayList<Float64>>()
    private let currentUserVector: ArrayList<Float64> = ArrayList<Float64>()
    private var isInitialized: Bool = false

    private init() {
        this.initMockData()
        this.isInitialized = true
    }

    public static func getInstance(): EdgeRecService {
        if (instance.isNone()) {
            instance = Some(EdgeRecService())
        }
        return instance.getOrThrow()
    }

    private func initMockData(): Unit {
        let d1 = GraphNode("d001", "Disease1", EntityType.Disease)
        let d2 = GraphNode("d002", "Disease2", EntityType.Disease)
        let d3 = GraphNode("d003", "Disease3", EntityType.Disease)

        let p1 = GraphNode("post_001", "Post1", EntityType.Post)
        let p2 = GraphNode("post_002", "Post2", EntityType.Post)
        let p3 = GraphNode("post_003", "Post3", EntityType.Post)

        let q1 = GraphNode("q001", "Qa1", EntityType.QaItem)
        let q2 = GraphNode("q002", "Qa2", EntityType.QaItem)

        let pr1 = GraphNode("product_001", "Product1", EntityType.Product)
        let pr2 = GraphNode("product_002", "Product2", EntityType.Product)
        let pr3 = GraphNode("product_003", "Product3", EntityType.Product)

        this.graph.addNode(d1)
        this.graph.addNode(d2)
        this.graph.addNode(d3)
        this.graph.addNode(p1)
        this.graph.addNode(p2)
        this.graph.addNode(p3)
        this.graph.addNode(q1)
        this.graph.addNode(q2)
        this.graph.addNode(pr1)
        this.graph.addNode(pr2)
        this.graph.addNode(pr3)

        this.graph.addEdge("d001", "post_001", "rel")
        this.graph.addEdge("d001", "q001", "rel")
        this.graph.addEdge("d002", "post_002", "rel")
        this.graph.addEdge("d003", "post_003", "rel")

        let v1 = ArrayList<Float64>(); v1.add(0.8); v1.add(0.3); v1.add(0.1)
        let v2 = ArrayList<Float64>(); v2.add(0.6); v2.add(0.4); v2.add(0.2)
        let v3 = ArrayList<Float64>(); v3.add(0.5); v3.add(0.3); v3.add(0.1)
        let v4 = ArrayList<Float64>(); v4.add(0.2); v4.add(0.5); v4.add(0.8)
        let v5 = ArrayList<Float64>(); v5.add(0.3); v5.add(0.2); v5.add(0.1)
        let v6 = ArrayList<Float64>(); v6.add(0.4); v6.add(0.2); v6.add(0.1)

        // 🌟 核心修复：彻底抛弃 .put，使用仓颉原生的 [] 索引赋值法
        this.itemVectors["post_001"] = v1
        this.itemVectors["post_002"] = v2
        this.itemVectors["post_003"] = v3
        this.itemVectors["product_001"] = v4
        this.itemVectors["product_002"] = v5
        this.itemVectors["product_003"] = v6

        this.currentUserVector.add(0.5)
        this.currentUserVector.add(0.3)
        this.currentUserVector.add(0.1)
    }

    public func recordAction(itemId: String, actionType: String): Unit {
        this.profileManager.recordAction(itemId, actionType)
    }

    public func getRecommendations(topK: Int64): ArrayList<RankItem> {
        let profile = this.profileManager.getDecayedProfile()
        let seedNodes = ArrayList<String>()
        for ((itemId, _) in profile) {
            seedNodes.add(itemId)
        }

        if (seedNodes.size == 0) {
            return ArrayList<RankItem>()
        }

        let graphCandidates = RecallEngine.graphRecall(this.graph, seedNodes, 2, 20)
        let vectorCandidates = RecallEngine.vectorRecall(this.currentUserVector, this.itemVectors, 15)
        let mergedCandidates = RecallEngine.mergeRecalls(graphCandidates, vectorCandidates)
        
        let finalRanking = Ranker.rank(
            mergedCandidates,
            this.currentUserVector,
            this.itemVectors,
            this.profileManager,
            topK
        )
        
        return finalRanking
    }
}