// entry/src/main/cangjie/expert_qa.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class expert_qa {
    @State var currentQAIndex: Int64 = 0

    public func build() {
        Column() {
            Text("农业专家在线解答").fontSize(22).fontWeight(FontWeight.Bold).margin(bottom: 20, top: 20)
            Scroll() {
                Column() {
                    this.buildQACard(0, "小麦叶片发黄是怎么回事？", "可能是缺氮或红蜘蛛危害，建议检查叶背并补施尿素。")
                    this.buildQACard(1, "现在能种大棚西瓜吗？", "立春已过，温度回升，可以开始育苗，注意夜间保温。")
                    this.buildQACard(2, "水稻条纹叶枯病如何防治？", "该病主要靠灰飞虱传播，建议在分蘖期喷施吡虫啉，同时加强水肥管理。")
                }.padding(left: 15, right: 15)
            }.layoutWeight(1)
        }.width(100.percent).height(100.percent).backgroundColor(Color(0xF5F7FA))
    }

    @Builder func buildQACard(index: Int64, q: String, a: String) {
        Column() {
            Row() {
                Text("问").fontColor(Color(0xFFFFFFFF)).backgroundColor(Color(0xFF4CAF50))
                    .width(20).height(20).textAlign(TextAlign.Center).borderRadius(4).margin(right: 10)
                Text(q).fontSize(17).fontWeight(FontWeight.Bold).layoutWeight(1)
            }.width(100.percent).margin(bottom: 12)

            Row() {
                Text("答").fontColor(Color(0xFFFFFFFF)).backgroundColor(Color(0xFF0D9FFB))
                    .width(20).height(20).textAlign(TextAlign.Center).borderRadius(4).margin(right: 10)
                Text(a).fontSize(15).fontColor(Color(0xFF666666)).layoutWeight(1).lineSpacing(6)
            }.width(100.percent)
        }
        .padding(18).backgroundColor(Color(0xFFFFFFFF)).borderRadius(15).margin(bottom: 15)
        .onClick({ _ =>
            AppStorage.setOrCreate("QADetailQ", q)
            AppStorage.setOrCreate("QADetailA", a)
            AppStorage.setOrCreate("NavigateToQA", "true")
            this.currentQAIndex = index
        })
    }
}
