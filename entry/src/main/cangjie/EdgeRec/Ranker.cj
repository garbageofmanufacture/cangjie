// entry/src/main/cangjie/EdgeRec/Ranker.cj
package ohos_app_cangjie_entry.EdgeRec

import std.collection.*
import std.math.*

// ========================================
// 🌟 1. 排序实体定义
// ========================================
public class RankItem {
    public let itemId: String
    public let score: Float64

    public init(itemId: String, score: Float64) {
        this.itemId = itemId
        this.score = score
    }

    public func toString(): String {
        return "[${this.itemId} | 综合得分: ${this.score}]"
    }
}

// ========================================
// 🌟 2. 多因子精排引擎与手写快排
// ========================================
public class Ranker {

    public static func rank(
        candidates: ArrayList<String>,
        userVector: ArrayList<Float64>,
        itemVectors: HashMap<String, ArrayList<Float64>>,
        userProfile: UserProfileManager,
        topK: Int64
    ): ArrayList<RankItem> {

        let scoredItems = ArrayList<RankItem>()

        for (itemId in candidates) {
            // 因子 A：语义向量相似度分 (0.0 ~ 1.0)
            var vecScore = 0.0
            match (itemVectors.get(itemId)) {
                case Some(vec) => vecScore = VectorMath.cosineSimilarity(userVector, vec)
                case None => vecScore = 0.05 // 保底分
            }

            // 因子 B：用户历史行为时间衰减分 (基于 LRU Cache 和牛顿冷却定律)
            let profileScore = userProfile.getItemDecayedWeight(itemId)

            // 🌟 核心打分公式 (大厂策略模式：向量权重占 40%，历史记忆权重占 60%)
            let finalScore = (vecScore * 0.4) + (profileScore * 0.6)

            scoredItems.add(RankItem(itemId, finalScore))
        }

        // 如果候选集大于 1，则触发纯手写快速排序 (降序)
        if (scoredItems.size > 1) {
            quickSort(scoredItems, 0, scoredItems.size - 1)
        }

        // 截取 Top K 返回给 UI 渲染
        let result = ArrayList<RankItem>()
        let limit = if (scoredItems.size < topK) { scoredItems.size } else { topK }

        for (i in 0..limit) {
            result.add(scoredItems[i])
        }

        return result
    }

    // ========================================
    // 🌟 3. 纯手写快速排序 (Quick Sort - 降序排列)
    // ========================================
    private static func quickSort(arr: ArrayList<RankItem>, low: Int64, high: Int64): Unit {
        if (low < high) {
            let pivotIndex = partition(arr, low, high)
            quickSort(arr, low, pivotIndex - 1)
            quickSort(arr, pivotIndex + 1, high)
        }
    }

    private static func partition(arr: ArrayList<RankItem>, low: Int64, high: Int64): Int64 {
        let pivotScore = arr[high].score
        var i = low - 1

        for (j in low..high) {
            if (arr[j].score > pivotScore) {
                i += 1
                swap(arr, i, j)
            }
        }
        swap(arr, i + 1, high)
        return i + 1
    }

    private static func swap(arr: ArrayList<RankItem>, i: Int64, j: Int64): Unit {
        let temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp
    }
}

// ========================================
// 🏆 终极系统联调测试：知农 EdgeRec 全链路运行
// ========================================
main() {
    println("🚀 [知农 EdgeRec 引擎] 系统启动...")

    let graph = KnowledgeGraph()
    let profileManager = UserProfileManager(100)
    let itemVectors = HashMap<String, ArrayList<Float64>>()

    println("📦 正在加载农业知识图谱...")
    graph.addNode(GraphNode("disease_01", "纹枯病", EntityType.Disease))
    graph.addNode(GraphNode("product_01", "井冈霉素", EntityType.Product))
    graph.addNode(GraphNode("post_01", "水稻发黄怎么办？", EntityType.Post))
    graph.addNode(GraphNode("qa_01", "专家解答纹枯病防治", EntityType.QaItem))

    graph.addEdge("post_01", "disease_01", "提及", weight: 0.9)
    graph.addEdge("disease_01", "product_01", "治疗", weight: 1.0)
    graph.addEdge("disease_01", "qa_01", "相关解析", weight: 0.8)

    let vec1 = ArrayList<Float64>(); vec1.add(0.9); vec1.add(0.1); vec1.add(0.2)
    let vec2 = ArrayList<Float64>(); vec2.add(0.8); vec2.add(0.2); vec2.add(0.1)
    let vec3 = ArrayList<Float64>(); vec3.add(0.1); vec3.add(0.9); vec3.add(0.1)

    // 🌟 修复 1：HashMap 必须用索引赋值，不能用 add
    itemVectors["post_01"] = vec1
    itemVectors["product_01"] = vec2
    itemVectors["qa_01"] = vec3

    let currentUserVector = ArrayList<Float64>()
    currentUserVector.add(0.85); currentUserVector.add(0.15); currentUserVector.add(0.1)

    println("👤 正在读取用户实时画像与记忆衰减阵列...")
    profileManager.recordAction("post_01", "view")

    println("🔍 触发引擎双路召回...")
    let seedNodes = ArrayList<String>()
    seedNodes.add("post_01")

    // 🌟 修复 2：去掉所有带冒号的命名参数（maxHops:, limit:）
    let graphCandidates = RecallEngine.graphRecall(graph, seedNodes, 2, 10)
    let vectorCandidates = RecallEngine.vectorRecall(currentUserVector, itemVectors, 10)
    let mergedCandidates = RecallEngine.mergeRecalls(graphCandidates, vectorCandidates)

    println("   - 图谱召回数量: ${graphCandidates.size}")
    println("   - 向量召回数量: ${vectorCandidates.size}")
    println("   - 去重后候选集: ${mergedCandidates.size} 个")

    println("⚖️ 触发多因子精排打分引擎 (QuickSort)...")

    // 🌟 修复 3：去掉 topK: 参数名
    let finalRecommendations = Ranker.rank(mergedCandidates, currentUserVector, itemVectors, profileManager, 3)

    println("\n📱 最终端侧推荐 Feed 流呈现：")
    println("========================================")
    var rankNum = 1
    for (item in finalRecommendations) {
        let nodeOpt = graph.getNode(item.itemId)
        if (nodeOpt.isSome()) {
            let node = nodeOpt.getOrThrow()
            println(" [Top ${rankNum}] ${node.nodeType.toString()} -> ${node.name}")
            println("         (系统唯一ID: ${item.itemId} | 综合打分: ${item.score})")
        }
        rankNum += 1
    }
    println("========================================")
    println("✅ 推荐链路执行完毕，耗时 0.012 毫秒 (Mock)")
}