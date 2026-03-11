// entry/src/main/cangjie/profile.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class ProfileStatsView {
    @State var account: String = ""

    func getLevel(): String {
        if (this.account == "admin" || this.account == "111") { return "Lv.99 农神" }
        if (this.account.size > 6) { return "Lv.5 种植达人" }
        return "Lv.2 农技新手"
    }

    func getScore(): String {
        let baseScore = this.account.size * 15 + 120
        return baseScore.toString()
    }

    func getBadge(): String {
        if (this.account == "admin") { return "🏅 官方" }
        if (this.account.size % 2 == 0) { return "🌟 活跃" }
        return "🌱 新星"
    }

    public func build() {
        Row() {
            Column() {
                Text(this.getLevel()).fontSize(16.0).fontWeight(FontWeight.Bold).fontColor(Color(0x0D9FFB))
                Text("当前等级").fontSize(12.0).fontColor(Color(0x999999)).margin(top: 4.0)
            }.layoutWeight(1)

            Divider().vertical(true).height(30.0).color(Color(0xF0F0F0))

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
    }
}