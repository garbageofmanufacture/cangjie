// expert_qa.cj - 农业论坛专家问答页面
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import ohos.hilog.Hilog

@HybridComponentEntry
@Component
class expert_qa { // 类名与文件名一致，适配ets中component参数
    // 模拟专家问答数据
    @State var qa1Title: String = "小麦纹枯病用什么药防治效果好？";
    @State var qa1Asker: String = "农户-张三";
    @State var qa1Expert: String = "农技专家-李华";
    @State var qa1Time: String = "2026-03-06";
    @State var qa1Answer: String = "推荐使用井冈霉素A或噻呋酰胺，兑水30公斤/亩，均匀喷雾，间隔7天再喷一次，注意避开高温时段。";

    @State var qa2Title: String = "玉米缺氮的症状及补救措施？";
    @State var qa2Asker: String = "种植户-李四";
    @State var qa2Expert: String = "土肥专家-王军";
    @State var qa2Time: String = "2026-03-05";
    @State var qa2Answer: String = "缺氮表现为叶片发黄、植株矮小，可叶面喷施1%尿素溶液，同时根部追施尿素15-20kg/亩，补充氮素。";

    @State var qa3Title: String = "大棚黄瓜徒长怎么控制？";
    @State var qa3Asker: String = "菜农-赵五";
    @State var qa3Expert: String = "蔬菜专家-张芳";
    @State var qa3Time: String = "2026-03-04";
    @State var qa3Answer: String = "控制浇水频率，降低夜间温度至15-18℃，喷施矮壮素1000倍液，同时增施磷钾肥，减少氮肥使用。";

    public func build() {
        Row() {
            Scroll() {
            Column() {
                // 页面标题
                Text("农业论坛 · 专家问答")
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                    .width(90.percent)
                    .margin(bottom: 30)
                    .textAlign(TextAlign.Center)
                    .fontColor(Color(0x333333))

                // 问答1条目
                Column() {
                    Text(this.qa1Title)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 5)
                        .textAlign(TextAlign.Start)

                    Row() {
                        Text("提问：" + this.qa1Asker)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(" | ")
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text("回答：" + this.qa1Expert)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(" | ")
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(this.qa1Time)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                    }
                    .width(90.percent)
                    .margin(bottom: 10)

                    Text("专家解答：" + this.qa1Answer)
                        .fontSize(24)
                        .width(90.percent)
                        .fontColor(Color(0x555555))
                        .textAlign(TextAlign.Start)
                }
                .width(90.percent)
                .padding(20)
                .backgroundColor(Color(0xFFFFFF))
                .borderRadius(10)
                .margin(bottom: 20)

                // 问答2条目
                Column() {
                    Text(this.qa2Title)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 5)
                        .textAlign(TextAlign.Start)

                    Row() {
                        Text("提问：" + this.qa2Asker)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(" | ")
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text("回答：" + this.qa2Expert)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(" | ")
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(this.qa2Time)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                    }
                    .width(90.percent)
                    .margin(bottom: 10)

                    Text("专家解答：" + this.qa2Answer)
                        .fontSize(24)
                        .width(90.percent)
                        .fontColor(Color(0x555555))
                        .textAlign(TextAlign.Start)
                }
                .width(90.percent)
                .padding(20)
                .backgroundColor(Color(0xFFFFFF))
                .borderRadius(10)
                .margin(bottom: 20)


                // 问答3条目
                Column() {
                    Text(this.qa3Title)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 5)
                        .textAlign(TextAlign.Start)

                    Row() {
                        Text("提问：" + this.qa3Asker)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(" | ")
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text("回答：" + this.qa3Expert)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(" | ")
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                        Text(this.qa3Time)
                            .fontSize(22)
                            .fontColor(Color(0x666666))
                    }
                    .width(90.percent)
                    .margin(bottom: 10)

                    Text("专家解答：" + this.qa3Answer)
                        .fontSize(24)
                        .width(90.percent)
                        .fontColor(Color(0x555555))
                        .textAlign(TextAlign.Start)
                }
                .width(90.percent)
                .padding(20)
                .backgroundColor(Color(0xFFFFFF))
                .borderRadius(10)
            }
            }
            .width(100.percent)
//            .justifyContent(FlexAlign.Start)
            .padding(top: 10, bottom: 40)
        }
        .height(100.percent)
        .width(100.percent)
        .backgroundColor(Color(0xF5F5F5))
    }
}