// entry/src/main/cangjie/farm_calendar.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class farm_calendar {
    public func build() {
        Column() {
            // 节气面板
            Row() {
                Column() {
                    Text("当前时令").fontSize(14).fontColor(Color(0x999999)).margin(bottom: 8)
                    Text("惊蛰 / 3月").fontSize(26).fontWeight(FontWeight.Bold).fontColor(Color(0x4CAF50))
                }.layoutWeight(1).alignItems(HorizontalAlign.Center)

                Divider().vertical(true).height(50).color(Color(0xE0E0E0))

                Column() {
                    Text("气候特征").fontSize(14).fontColor(Color(0x999999)).margin(bottom: 8)
                    Text("春雷乍动 万物生机").fontSize(16).fontWeight(FontWeight.Medium).fontColor(Color(0x333333))
                }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }
            .width(90.percent).padding(20).backgroundColor(Color(0xFFFFFF)).borderRadius(15)
        }
        .width(100.percent)
        .backgroundColor(Color(0xF5F7FA))
        .alignItems(HorizontalAlign.Center)
    }
}