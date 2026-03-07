// second.cj - 农业论坛详情页面（无返回按钮）
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import ohos.hilog.Hilog

@HybridComponentEntry
@Component
class Second {
    // 论坛详情数据
    @State var title: String = "2026年小麦高产种植技术";
    @State var author: String = "农技专家-李华";
    @State var time: String = "2026-03-06";
    @State var content: String = "一、选种要点：优先选择抗倒伏、抗锈病的优质品种，如济麦44、烟农1212等。\n二、施肥管理：基肥以有机肥为主，每亩施腐熟农家肥2000kg+复合肥50kg；拔节期追施尿素15kg/亩。\n三、田间管理：及时防治蚜虫、红蜘蛛，拔节期注意控旺防倒伏，灌浆期保持土壤湿润。";

    public func build() {
        Row() {
            Column() {
                // 论坛标题
                Text(this.title)
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                    .width(90.percent)
                    .margin(bottom: 10)
                    .textAlign(TextAlign.Center)

                // 作者和时间
                Row() {
                    Text("作者：" + this.author)
                        .fontSize(24)
                        .fontColor(Color(0x666666))
                    Text(" | ")
                        .fontSize(24)
                        .fontColor(Color(0x666666))
                    Text(this.time)
                        .fontSize(24)
                        .fontColor(Color(0x666666))
                }
                .width(90.percent)
                .margin(bottom: 30)
                .justifyContent(FlexAlign.Center)

                // 论坛正文
                Text(this.content)
                    .fontSize(28)
                    .width(90.percent)
                    .lineSpacing(10)
                    .margin(bottom: 40)
                    .textAlign(TextAlign.Start)
            }
            .width(100.percent)
            .justifyContent(FlexAlign.Start) // 内容从上到下排列
            .padding(top: 40)
        }
        .height(100.percent)
        .backgroundColor(Color(0xF5F5F5))
    }
}