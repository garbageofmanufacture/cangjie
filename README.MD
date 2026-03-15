```
# 知农 EdgeRec - 端侧智能推荐引擎

## 📋 系统概述

EdgeRec 是一个完全基于**仓颉语言**实现的端侧智能推荐引擎，专为农业社区应用设计。该系统在设备本地完成所有推荐计算，无需依赖云端服务，具有低延迟、高隐私保护的特点。

### ✨ 核心特性

- ✅ **纯端侧计算** - 无需网络请求，实时响应
- ✅ **知识图谱驱动** - 构建农业领域实体关系网络
- ✅ **双路召回策略** - 图谱游走 + 语义向量相似度
- ✅ **时间衰减机制** - 基于牛顿冷却定律的用户画像
- ✅ **多因子精排** - 向量相似度(40%) + 历史行为(60%)
- ✅ **LRU缓存优化** - 高效的内存管理与快速访问

---

## 🏗️ 系统架构

```text
┌─────────────────────────────────────────────────────────┐
│                    EdgeRec 推荐引擎                     │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │KnowledgeGraph│  │ UserProfile  │  │ Vector Store │   │
│  │   知识图谱   │  │   Manager    │  │   向量存储   │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
├─────────────────────────────────────────────────────────┤
│                   RecallEngine 召回引擎                 │
│  ┌──────────────┐                  ┌──────────────┐     │
│  │ Graph Recall │                  │ Vector Recall│     │
│  │   图谱召回   │                  │   向量召回   │     │
│  └──────────────┘                  └──────────────┘     │
│              ↘                        ↙                 │
│                      Merge & Dedup                      │
├─────────────────────────────────────────────────────────┤
│                    Ranker 精排引擎                      │
│  ┌──────────────────────────────────────────┐           │
│  │     Multi-Factor Scoring + QuickSort     │           │
│  │          多因子打分 + 快速排序           │           │
│  └──────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────┘
```

------

## 📦 核心模块详解

### 1. 知识图谱

**功能**：构建农业领域实体关系网络

**实体类型**：

Code snippet

```
public enum EntityType {
    | User      // 用户
    | Post      // 帖子
    | QaItem    // 问答
    | Product   // 商品
    | Disease   // 病害
}
```

**核心数据结构**：

- `GraphNode` - 图节点（id, name, type, tags）
- `GraphEdge` - 图边（from, to, relation, weight）
- `KnowledgeGraph` - 图管理器（节点/边的增删查）

**示例**：

Code snippet

```
let graph = KnowledgeGraph()
graph.addNode(GraphNode("d001", "水稻稻瘟病", EntityType.Disease))
graph.addNode(GraphNode("p001", "防治技术帖", EntityType.Post))
graph.addEdge("d001", "p001", "related_to", weight: 0.8)
```

### 2. 用户画像管理

**功能**：记录用户行为并计算时间衰减权重

**LRU缓存机制**：

- **容量**：100条最近行为记录
- **策略**：最近最少使用淘汰算法
- **优势**：$O(1)$ 时间复杂度的访问和更新

**时间衰减公式（牛顿冷却定律）**：

$$Weight(t) = BaseWeight \times e^{-\lambda \times \Delta t}$$

*其中：*

- **BaseWeight**: 行为基础权重（view=1.0, like=3.0, collect=5.0, share=8.0, purchase=10.0）
- **$\lambda$**: 衰减系数（0.05）
- **$\Delta t$**: 时间差（小时）

**示例**：

Code snippet

```
let manager = UserProfileManager(cacheCapacity: 100)
manager.recordAction("post_001", "view")       // 浏览
manager.recordAction("product_001", "collect") // 收藏
let weight = manager.getItemDecayedWeight("post_001") // 获取衰减权重
```

### 3. 召回引擎

#### A路召回：图谱游走

- **算法**：BFS 广度优先搜索
- **流程**：
  1. 从用户最近浏览的种子节点出发
  2. 沿图谱边向外扩散 `maxHops` 跳
  3. 过滤只保留 Post/QaItem/Product 类型节点
  4. 限制召回数量 $\le limit$
- **复杂度**：$O(V + E)$，V=节点数，E=边数

**示例**：

Code snippet

```
let seeds = ArrayList<String>()
seeds.add("post_001")
let candidates = RecallEngine.graphRecall(graph, seeds, maxHops: 2, limit: 20)
```

#### B路召回：向量相似度

- **算法**：余弦相似度

- **公式**：

  $$Similarity(A, B) = \frac{A \cdot B}{||A|| \times ||B||}$$

  *其中 $A \cdot B$ 为向量点积，$||A||$ 为向量范数（模长）。*

- **阈值**：similarity > 0.5

**示例**：

Code snippet

```
let userVec = ArrayList<Float64>([0.5, 0.3, 0.1, 0.2, 0.9, 0.7])
let candidates = RecallEngine.vectorRecall(userVec, itemVectors, limit: 15)
```

#### 召回融合

- **策略**：去重合并
- **流程**：
  1. 注入图谱召回结果
  2. 注入向量召回结果
  3. 使用 HashMap 去重

### 4. 精排引擎

**多因子打分公式**：

$$FinalScore = VecScore \times 0.4 + ProfileScore \times 0.6$$

*其中 VecScore 为语义向量相似度（0.0 ~ 1.0），ProfileScore 为用户历史行为时间衰减分。*

**手写快速排序（降序）**：

Code snippet

```
private static func quickSort(arr: ArrayList<RankItem>, low: Int64, high: Int64): Unit {
    if (low < high) {
        let pivotIndex = partition(arr, low, high)
        quickSort(arr, low, pivotIndex - 1)
        quickSort(arr, pivotIndex + 1, high)
    }
}
```

- **复杂度**：平均 $O(n \log n)$

**示例**：

Code snippet

```
let ranking = Ranker.rank(
    candidates: mergedCandidates,
    userVector: currentUserVector,
    itemVectors: itemVectors,
    userProfile: profileManager,
    topK: 10
)
```

------

## 🚀 快速开始

### 1. 初始化服务

Code snippet

```
// 获取单例实例（自动初始化 Mock 数据）
let recService = EdgeRecService.getInstance()
```

### 2. 记录用户行为

Code snippet

```
// 用户浏览帖子
recService.recordAction("post_001", "view")
// 用户收藏商品
recService.recordAction("product_001", "collect")
// 用户分享问答
recService.recordAction("qa_001", "share")
```

### 3. 获取推荐结果

Code snippet

```
// 获取 Top 10 推荐物品
let recommendations = recService.getRecommendations(topK: 10)

// 遍历推荐结果
for (item in recommendations) {
    println("ID: ${item.itemId}, Score: ${item.score}")
}
```

------

## 📊 性能指标

| **指标** | **测试结果** | **备注** |
| -------- | ------------ | -------- |
| 召回延迟 | -            | 待测试   |
| 精排延迟 | -            | 待测试   |
| 总延迟   | -            | 待测试   |
| 内存占用 | -            | 待测试   |
| 召回率   | -            | 待测试   |
| 精确率   | -            | 待测试   |

*(注：请在实际环境测试后补充上述表格数据)*

------

## 🔧 技术亮点

### 1. 纯仓颉实现

- 无第三方依赖
- 仅依赖标准库（`std.collection.*`, `std.math.*`, `std.time.*`）
- 跨平台兼容（HarmonyOS、Linux、Windows）

### 2. 端侧计算优势

- **隐私保护**：数据不上传云端
- **低延迟**：毫秒级响应
- **离线可用**：无网络环境下正常工作

### 3. 算法创新

- **双路召回**：结合结构化知识与非结构化语义
- **时间衰减**：模拟人类记忆遗忘曲线
- **多因子融合**：平衡个性化与探索性

------

## 📱 集成到鸿蒙应用

### ArkTS 侧调用示例

TypeScript

```
// ForumView.ets
import { EdgeRecService } from '../services/EdgeRecService'

@Component
export struct ForumView {
  @State recommendItems: RecommendItem[] = []

  aboutToAppear() {
    // 初始化推荐服务
    this.loadRecommendations()
  }

  private loadRecommendations() {
    const recService = EdgeRecService.getInstance()
    const rankItems = recService.getRecommendations(10)
    
    this.recommendItems = rankItems.map(item => ({
      id: item.itemId,
      title: this.getItemTitle(item.itemId),
      score: item.score
    }))
  }

  build() {
    Column() {
      Text('🔥 猜你喜欢')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      
      List({ space: 10 }) {
        ForEach(this.recommendItems, (item: RecommendItem) => {
          ListItem() {
            Text(`${item.title} (评分: ${item.score.toFixed(2)})`)
          }
          .onClick(() => {
            // 记录用户行为
            recService.recordAction(item.id, "view")
            // 刷新推荐
            this.loadRecommendations()
          })
        })
      }
    }
  }
}
```

------

## 🎯 应用场景

1. **农业社区论坛** - 推荐相关帖子、问答、病害防治方案
2. **农资电商平台** - 推荐农药、肥料、种子等商品
3. **专家咨询系统** - 推荐专家回答、技术文章
4. **农业知识图谱** - 关联病害-药品-技术-问答等多维实体

------

## 🛠️ 未来扩展

- [ ] 支持更多实体类型（农作物、地区、季节等）
- [ ] 引入深度学习模型（需仓颉支持）
- [ ] 多目标优化（点击率 + 转化率 + 停留时长）
- [ ] A/B 测试框架
- [ ] 实时特征更新

------

*EdgeRec - 让每一次推荐都懂你 ❤️*