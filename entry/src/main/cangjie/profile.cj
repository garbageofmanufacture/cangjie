// entry/src/main/cangjie/profile.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import std.sync.*
import std.convert.*

@HybridComponentEntry
@Component
class ProfileStatsView {
    @State var account: String = ""

    @State
    var realPointsStr: String = "0"

    @State var displayLevel: String = "计算中..."
    @State var displayScore: String = "0"
    @State var displayBadge: String = "🌱 新星"

    // 🌟 把以前写在 aboutToAppear 里的计算逻辑，抽离成一个独立的方法
    func onPointsChanged(): Unit {
        if (this.account == "admin" || this.account == "111") {
            this.displayLevel = "Lv.99 农神"
            this.displayScore = "99999"
            this.displayBadge = "🏅 官方"
            return
        }

        let _ = spawn {
            var points: Int64 = 0
            try {
                points = Int64.parse(this.realPointsStr)
            } catch (e: Exception) {
                points = 0
            }

            let levelStr = ExpertLevelSystem.getLevel(points).toString()

            this.displayScore = points.toString()
            this.displayLevel = levelStr

            if (points >= 1500) {
                this.displayBadge = "👑 泰斗"
            } else if (points >= 500) {
                this.displayBadge = "🌟 活跃"
            } else if (points >= 100) {
                this.displayBadge = "🏅 骨干"
            } else {
                this.displayBadge = "🌱 新星"
            }
        }
    }

    // 刚进入页面时，主动调用一次计算
    protected override func aboutToAppear(): Unit {
        this.onPointsChanged()
    }

    public func build() {
        Row() {
            Column() {
                Text(this.displayLevel).fontSize(16.0).fontWeight(FontWeight.Bold).fontColor(Color(0x0D9FFB))
                Text("当前等级").fontSize(12.0).fontColor(Color(0x999999)).margin(top: 4.0)
            }.layoutWeight(1)

            Divider().vertical(true).height(30.0).color(Color(0xF0F0F0))

            Column() {
                Text(this.displayScore).fontSize(16.0).fontWeight(FontWeight.Bold).fontColor(Color(0xFF9800))
                Text("贡献积分").fontSize(12.0).fontColor(Color(0x999999)).margin(top: 4.0)
            }.layoutWeight(1)

            Divider().vertical(true).height(30.0).color(Color(0xF0F0F0))

            Column() {
                Text(this.displayBadge).fontSize(16.0).fontWeight(FontWeight.Bold).fontColor(Color(0x4CAF50))
                Text("佩戴勋章").fontSize(12.0).fontColor(Color(0x999999)).margin(top: 4.0)
            }.layoutWeight(1)
        }
        .width(90.percent).padding(top: 15.0, bottom: 15.0).backgroundColor(Color(0xFFFFFF))
        .borderRadius(15.0).margin(bottom: 20.0)
    }
}
