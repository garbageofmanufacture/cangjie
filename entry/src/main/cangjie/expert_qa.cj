// entry/src/main/cangjie/expert_qa.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class expert_qa {
    public func build() {
        Column() {
            Text("农业专家在线解答").fontSize(22).fontWeight(FontWeight.Bold).margin(bottom: 20, top: 20)
            Scroll() {
                Column() {
                    this.buildQACard("小麦叶片发黄是怎么回事？", "可能是缺氮或红蜘蛛危害，建议检查叶背并补施尿素。")
                    this.buildQACard("现在能种大棚西瓜吗？", "立春已过，温度回升，可以开始育苗，注意夜间保温。")
                }.padding(left: 15, right: 15) // 🌟 修复: 仓颉不支持 horizontal 简写
            }.layoutWeight(1)
        }.width(100.percent).backgroundColor(Color(0xF5F7FA))
    }

    @Builder func buildQACard(q: String, a: String) {
        Column() {
            Row() {
                Text("问").fontColor(Color(0xFFFFFF)).backgroundColor(Color(0xFF4CAF50))
                    .width(20).height(20).textAlign(TextAlign.Center).borderRadius(4).margin(right: 10)
                Text(q).fontSize(17).fontWeight(FontWeight.Bold).layoutWeight(1)
            }.width(100.percent).margin(bottom: 12)

            Row() {
                Text("答").fontColor(Color(0xFFFFFF)).backgroundColor(Color(0xFF0D9FFB))
                    .width(20).height(20).textAlign(TextAlign.Center).borderRadius(4).margin(right: 10)
                Text(a).fontSize(15).fontColor(Color(0x666666)).layoutWeight(1).lineSpacing(6)
            }.width(100.percent)
        }
        .padding(18).backgroundColor(Color(0xFFFFFF)).borderRadius(15).margin(bottom: 15)
        // 🌟 修复: 补全所有参数名前缀

    }
}