// farm_mall.cj - 农业论坛农资商城页面
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import ohos.hilog.Hilog

@HybridComponentEntry
@Component
class farm_mall { // 类名与文件名一致
    // 模拟农资商品数据
    @State var goods1Name: String = "井冈霉素A（小麦纹枯病专用）";
    @State var goods1Price: String = "¥25.8/瓶";
    @State var goods1Desc: String = "有效成分10%，兑水30kg/亩，安全无残留";

    @State var goods2Name: String = "复合肥（氮磷钾15-15-15）";
    @State var goods2Price: String = "¥120/袋（40kg）";
    @State var goods2Desc: String = "通用型复合肥，适用于小麦/玉米/蔬菜";

    @State var goods3Name: String = "矮壮素（控旺专用）";
    @State var goods3Price: String = "¥18.5/瓶";
    @State var goods3Desc: String = "1000倍液喷施，控制作物徒长，增产增收";

    public func build() {
        Row() {
            Scroll() {
            Column() {
                // 页面标题
                Text("农业论坛 · 农资商城")
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                    .width(90.percent)
                    .margin(bottom: 30)
                    .textAlign(TextAlign.Center)
                    .fontColor(Color(0x333333))

                // 商品1卡片
                Column() {
                    Text(this.goods1Name)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 5)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0x333333))

                    Text(this.goods1Price)
                        .fontSize(28)
                        .width(90.percent)
                        .margin(bottom: 10)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0xFF4081))

                    Text(this.goods1Desc)
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

                // 商品2卡片
                Column() {
                    Text(this.goods2Name)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 5)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0x333333))

                    Text(this.goods2Price)
                        .fontSize(28)
                        .width(90.percent)
                        .margin(bottom: 10)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0xFF4081))

                    Text(this.goods2Desc)
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

                // 商品3卡片
                Column() {
                    Text(this.goods3Name)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 5)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0x333333))

                    Text(this.goods3Price)
                        .fontSize(28)
                        .width(90.percent)
                        .margin(bottom: 10)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0xFF4081))

                    Text(this.goods3Desc)
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