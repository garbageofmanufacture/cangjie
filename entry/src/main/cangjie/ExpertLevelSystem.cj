package ohos_app_cangjie_entry

import std.time.*
import std.sync.*

public enum ExpertLevel {
    | Novice
    | Intermediate
    | Advanced
    | Master
    | GrandMaster

    public func toString(): String {
        match (this) {
            case Novice => "Lv.1 农技新手"
            case Intermediate => "Lv.2 种植达人"
            case Advanced => "Lv.3 农业专家"
            case Master => "Lv.4 首席农技师"
            case GrandMaster => "Lv.5 农学泰斗"
        }
    }
}

public struct UserStats {
    public let postsCount: Int64
    public let answersCount: Int64
    public let likesReceived: Int64

    public init(postsCount: Int64, answersCount: Int64, likesReceived: Int64) {
        this.postsCount = postsCount
        this.answersCount = answersCount
        this.likesReceived = likesReceived
    }
}

public class ExpertLevelSystem {

    public static func calculatePoints(stats: UserStats): Int64 {
        return stats.postsCount * 5 + stats.answersCount * 10 + stats.likesReceived * 2
    }

    public static func getLevel(points: Int64): ExpertLevel {
        match (points) {
            case p where p < 100 => ExpertLevel.Novice
            case p where p < 500 => ExpertLevel.Intermediate
            case p where p < 1500 => ExpertLevel.Advanced
            case p where p < 5000 => ExpertLevel.Master
            case _ => ExpertLevel.GrandMaster
        }
    }

    public static func fetchUserStatsAsync(userId: String): UserStats {
        let futureResult = spawn {
            // 🌟 修复 1：仓颉的时间常量乘法语法
            sleep(Duration.millisecond * 200)

            let pseudoRandom = Int64(userId.size)
            // 🌟 修复 2：移除参数名，直接按顺序传参
            return UserStats(
                pseudoRandom * 2,
                pseudoRandom * 5,
                pseudoRandom * 12
            )
        }
        return futureResult.get()
    }

    public static func getUserLevelInfo(userId: String): (Int64, String) {
        let stats = fetchUserStatsAsync(userId)
        let points = calculatePoints(stats)
        let level = getLevel(points)
        return (points, level.toString())
    }
}