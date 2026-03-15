// entry/src/main/cangjie/EdgeRec/TimeDecayEngine.cj
package ohos_app_cangjie_entry.EdgeRec

import std.collection.*
import std.time.*
import std.math.*
import std.convert.*

// ========================================
// 第一部分：行为实体定义
// ========================================

public struct UserAction {
    public let itemId: String
    public let actionType: String
    public let timestamp: Int64
    public let baseWeight: Float64

    public init(itemId: String, actionType: String, timestamp: Int64, baseWeight: Float64) {
        this.itemId = itemId
        this.actionType = actionType
        this.timestamp = timestamp
        this.baseWeight = baseWeight
    }
}

// ========================================
// 第二部分：简化版 LRU 缓存
// ========================================

public class LRUCache {
    private let capacity: Int64
    private let cache: HashMap<String, UserAction> = HashMap<String, UserAction>()
    private let accessOrder: ArrayList<String> = ArrayList<String>()

    public init(capacity: Int64) {
        this.capacity = capacity
    }

    public func put(key: String, action: UserAction): Unit {
        // 🌟 防弹修复：摒弃 match，改用 isSome
        if (this.cache.get(key).isSome()) {
            this.updateExisting(key, action)
        } else {
            this.addNew(key, action)
        }
    }

    private func updateExisting(key: String, action: UserAction): Unit {
        this.cache[key] = action
        this.moveToEnd(key)
    }

    private func addNew(key: String, action: UserAction): Unit {
        this.cache[key] = action
        this.accessOrder.add(key)
        this.evictIfNeeded()
    }

    private func moveToEnd(key: String): Unit {
        let indexOpt = this.findKeyIndex(key)
        // 🌟 防弹修复：用 if 替代导致报错的 match
        if (indexOpt.isSome()) {
            let i = indexOpt.getOrThrow()
            this.accessOrder.remove(at: i)
            this.accessOrder.add(key)
        }
    }

    private func findKeyIndex(key: String): Option<Int64> {
        for (i in 0..this.accessOrder.size) {
            if (this.accessOrder[i] == key) {
                return Some(i)
            }
        }
        return None
    }

    private func evictIfNeeded(): Unit {
        while (this.cache.size > this.capacity) {
            if (this.accessOrder.size > 0) {
                let oldestKey = this.accessOrder[0]
                this.cache.remove(oldestKey)
                this.accessOrder.remove(at: 0)
            } else {
                break
            }
        }
    }

    public func get(key: String): Option<UserAction> {
        let result = this.cache.get(key)
        // 🌟 防弹修复：依然是最稳妥的 if 判断
        if (result.isSome()) {
            this.moveToEnd(key)
            return result
        }
        return None
    }

    public func getAllActions(): ArrayList<UserAction> {
        let result = ArrayList<UserAction>()
        for (key in this.accessOrder) {
            let actionOpt = this.cache.get(key)
            if (actionOpt.isSome()) {
                result.add(actionOpt.getOrThrow())
            }
        }
        return result
    }

    public func size(): Int64 {
        return this.cache.size
    }

    public func clear(): Unit {
        this.cache.clear()
        this.accessOrder.clear()
    }
}

// ========================================
// 第三部分：时间衰减引擎
// ========================================

public class TimeDecayEngine {
    private static let DECAY_LAMBDA: Float64 = 0.05

    public static func calculateDecayedWeight(action: UserAction, currentTime: Int64): Float64 {
        let deltaTime = currentTime - action.timestamp
        let deltaHours = Float64(deltaTime) / (1000.0 * 60.0 * 60.0)
        let exponent = -1.0 * DECAY_LAMBDA * deltaHours
        return action.baseWeight * exp(exponent)
    }

    public static func calculateAllDecayedWeights(actions: ArrayList<UserAction>, currentTime: Int64): HashMap<String, Float64> {
        let result = HashMap<String, Float64>()

        for (action in actions) {
            let weight = calculateDecayedWeight(action, currentTime)
            let existingOpt = result.get(action.itemId)

            // 🌟 防弹修复：纯净的 if-else
            if (existingOpt.isSome()) {
                result[action.itemId] = existingOpt.getOrThrow() + weight
            } else {
                result[action.itemId] = weight
            }
        }

        return result
    }
}

// ========================================
// 第四部分：用户画像管理器
// ========================================

public class UserProfileManager {
    private let cache: LRUCache

    public init(cacheCapacity: Int64) {
        this.cache = LRUCache(cacheCapacity)
    }

    public func recordAction(itemId: String, actionType: String): Unit {
        let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let baseWeight = this.getBaseWeight(actionType)
        let action = UserAction(itemId, actionType, timestamp, baseWeight)
        this.cache.put(itemId, action)
    }

    public func getDecayedProfile(): HashMap<String, Float64> {
        let currentTime = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let actions = this.cache.getAllActions()
        return TimeDecayEngine.calculateAllDecayedWeights(actions, currentTime)
    }

    public func getItemDecayedWeight(itemId: String): Float64 {
        let currentTime = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let actionOpt = this.cache.get(itemId)

        // 🌟 防弹修复：规避 match
        if (actionOpt.isSome()) {
            return TimeDecayEngine.calculateDecayedWeight(actionOpt.getOrThrow(), currentTime)
        }
        return 0.0
    }

    public func getAllActions(): ArrayList<UserAction> {
        return this.cache.getAllActions()
    }

    public func getCacheSize(): Int64 {
        return this.cache.size()
    }

    public func clear(): Unit {
        this.cache.clear()
    }

    private func getBaseWeight(actionType: String): Float64 {
        // 单行表达式 match，编译器能正常识别，予以保留
        match (actionType) {
            case "view" => return 1.0
            case "like" => return 3.0
            case "collect" => return 5.0
            case "share" => return 8.0
            case "purchase" => return 10.0
            case _ => return 1.0
        }
    }
}