// entry/src/main/cangjie/profile.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class ProfileStatsView { // 定义一个全新的看板组件
    @State var account: String = ""

    // 🌟 仓颉原生算法 1：动态计算种田等级
    func getLevel(): String {
        if (this.account == "admin" || this.account == "111") {
            return "Lv.99 农神"
        }
        if (this.account.size > 6) {
            return "Lv.5 种植达人"
        }
        return "Lv.2 农技新手"
    }

    // 🌟 仓颉原生算法 2：基于账号特征哈希计算贡献积分
    func getScore(): String {
        let baseScore = this.account.size * 15 + 120
        return baseScore.toString()
    }

    // 🌟 仓颉原生算法 3：动态发放勋章
    func getBadge(): String {
        if (this.account == "admin") { return "🏅 官方" }
        if (this.account.size % 2 == 0) { return "🌟 活跃" }
        return "🌱 新星"
    }

    public func build() {
        // 绘制一个横向的、等分的数据面板
        Row() {
            Column() {
                Text(this.getLevel()).fontSize(16.0).fontWeight(FontWeight.Bold).fontColor(Color(0x0D9FFB))
                Text("当前等级").fontSize(12.0).fontColor(Color(0x999999)).margin(top: 4.0)
            }.layoutWeight(1)

            Divider().vertical(true).height(30.0).color(Color(0xF0F0F0)) // 竖向分割线

            Column() {
                Text(this.getScore()).fontSize(16.0).fontWeight(FontWeight.Bold).fontColor(Color(0xFF9800))
                Text("贡献积分").fontSize(12.0).fontColor(Color(0x999999)).margin(top: 4.0)
            }.layoutWeight(1)

            Divider().vertical(true).height(30.0).color(Color(0xF0F0F0))

            Column() {
                Text(this.getBadge()).fontSize(16.0).fontWeight(FontWeight.Bold).fontColor(Color(0x4CAF50))
                Text("佩戴勋章").fontSize(12.0).fontColor(Color(0x999999)).margin(top: 4.0)
            }.layoutWeight(1)
        }
        .width(90.percent).padding(top: 15.0, bottom: 15.0).backgroundColor(Color(0xFFFFFF))
        .borderRadius(15.0).margin(bottom: 20.0)
        // 加上淡淡的阴影，质感拉满

    }
}