// entry/src/main/cangjie/EdgeRec/RecallEngine.cj
package ohos_app_cangjie_entry.EdgeRec

import std.collection.*
import std.math.*

// ========================================
// 🌟 核心算法 1：高维向量数学计算库
// ========================================
public class VectorMath {
    // 纯手写计算余弦相似度：(A·B) / (||A|| * ||B||)
    public static func cosineSimilarity(vecA: ArrayList<Float64>, vecB: ArrayList<Float64>): Float64 {
        if (vecA.size == 0 || vecA.size != vecB.size) { return 0.0 }

        var dotProduct: Float64 = 0.0
        var normA: Float64 = 0.0
        var normB: Float64 = 0.0

        for (i in 0..vecA.size) {
            dotProduct += vecA[i] * vecB[i]
            normA += vecA[i] * vecA[i]
            normB += vecB[i] * vecB[i]
        }

        if (normA == 0.0 || normB == 0.0) { return 0.0 }
        return dotProduct / (sqrt(normA) * sqrt(normB))
    }
}

// ========================================
// 🌟 核心算法 2：双路召回引擎
// ========================================
public class RecallEngine {

    // 🚀 A路召回：图谱游走 (Graph BFS)
    // 算法描述：从用户最近浏览的种子节点出发，模拟突触传导，向外扩散 maxHops 跳寻找关联内容
    public static func graphRecall(graph: KnowledgeGraph, seedNodeIds: ArrayList<String>, maxHops: Int64, limit: Int64): ArrayList<String> {
        let result = ArrayList<String>()

        // 使用 HashMap 记录访问状态防死循环，极其稳定
        let visited = HashMap<String, Bool>()
        let hopMap = HashMap<String, Int64>()
        let queue = ArrayList<String>()

        // 播撒种子
        for (seed in seedNodeIds) {
            queue.add(seed)
            visited.add(seed, true)
            hopMap.add(seed, 0)
        }

        var head = 0
        while (head < queue.size && result.size < limit) {
            let currentId = queue[head]
            head += 1

            var currentHop: Int64 = 0
            match (hopMap.get(currentId)) {
                case Some(h) => currentHop = h
                case None => ()
            }

            // 达到最大扩散深度，停止当前分支
            if (currentHop >= maxHops) { continue }

            let neighbors = graph.getNeighbors(currentId)
            for (edge in neighbors) {
                let nextId = edge.toId
                if (!visited.contains(nextId)) {
                    visited.add(nextId, true)
                    queue.add(nextId)
                    hopMap.add(nextId, currentHop + 1)

                    // 业务过滤：只把农资商品、问答和帖子加入推荐列表，不推荐用户本身
                    match (graph.getNode(nextId)) {
                        case Some(node) =>
                            if (node.nodeType == EntityType.Product ||
                                node.nodeType == EntityType.QaItem ||
                                node.nodeType == EntityType.Post) {
                                result.add(nextId)
                            }
                        case None => ()
                    }

                    if (result.size >= limit) { break }
                }
            }
        }
        return result
    }

    // 🚀 B路召回：语义向量 (Vector Recall)
    public static func vectorRecall(userVector: ArrayList<Float64>, itemVectors: HashMap<String, ArrayList<Float64>>, limit: Int64): ArrayList<String> {
        let result = ArrayList<String>()
        // 遍历比对所有物品向量
        for ((itemId, vec) in itemVectors) {
            let sim = VectorMath.cosineSimilarity(userVector, vec)
            // 设定相似度阈值 0.5
            if (sim > 0.5 && result.size < limit) {
                result.add(itemId)
            }
        }
        return result
    }

    // 🚀 召回融合：将两条路的候选集去重合并
    public static func mergeRecalls(graphResults: ArrayList<String>, vectorResults: ArrayList<String>): ArrayList<String> {
        let finalResult = ArrayList<String>()
        let existMap = HashMap<String, Bool>()

        // 注入图谱召回结果
        for (id in graphResults) {
            if (!existMap.contains(id)) {
                existMap.add(id, true)
                finalResult.add(id)
            }
        }

        // 注入向量召回结果并去重
        for (id in vectorResults) {
            if (!existMap.contains(id)) {
                existMap.add(id, true)
                finalResult.add(id)
            }
        }

        return finalResult
    }
}