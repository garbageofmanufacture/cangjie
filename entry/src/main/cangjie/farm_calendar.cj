// farm_calendar.cj - 农业论坛农事日历页面
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import ohos.hilog.Hilog

@HybridComponentEntry
@Component
class farm_calendar { // 类名与文件名一致
    // 模拟农事日历数据（3月节气+农事）
    @State var solar1: String = "惊蛰（3月6日）";
    @State var solar1Farm: String = "小麦返青期：追肥、浇水，防治纹枯病；果树修剪、施肥，防治蚜虫。";
    
    @State var solar2: String = "春分（3月21日）";
    @State var solar2Farm: String = "玉米/棉花育苗准备；大棚蔬菜定植，加强通风；水稻育秧，整理秧田。";
    
    @State var monthTip: String = "3月农事总提醒：北方防春旱，南方防渍涝；及时查苗补苗，做好病虫害预防。";

    public func build() {
        Row() {
            Scroll() {
            Column() {
                // 页面标题
                Text("农业论坛 · 农事日历")
                    .fontSize(40)
                    .fontWeight(FontWeight.Bold)
                    .width(90.percent)
                    .margin(bottom: 30)
                    .textAlign(TextAlign.Center)
                    .fontColor(Color(0x333333))

                // 2026年3月标题
                Text("2026年3月 · 农事指南")
                    .fontSize(36)
                    .fontWeight(FontWeight.Bold)
                    .width(90.percent)
                    .margin(bottom: 20)
                    .textAlign(TextAlign.Center)
                    .fontColor(Color(0x0D9FFB))

                // 惊蛰节气卡片
                Column() {
                    Text(this.solar1)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 10)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0x333333))

                    Text(this.solar1Farm)
                        .fontSize(24)
                        .width(90.percent)
                        .fontColor(Color(0x555555))
                        .lineSpacing(10)
                        .textAlign(TextAlign.Start)
                }
                .width(90.percent)
                .padding(20)
                .backgroundColor(Color(0xFFFFFF))
                .borderRadius(10)
                .margin(bottom: 20)

                // 春分节气卡片
                Column() {
                    Text(this.solar2)
                        .fontSize(32)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 10)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0x333333))

                    Text(this.solar2Farm)
                        .fontSize(24)
                        .width(90.percent)
                        .fontColor(Color(0x555555))
                        .lineSpacing(10)
                        .textAlign(TextAlign.Start)
                }
                .width(90.percent)
                .padding(20)
                .backgroundColor(Color(0xFFFFFF))
                .borderRadius(10)
                .margin(bottom: 20)

                // 月度提醒
                Column() {
                    Text("月度农事提醒")
                        .fontSize(28)
                        .fontWeight(FontWeight.Bold)
                        .width(90.percent)
                        .margin(bottom: 10)
                        .textAlign(TextAlign.Start)
                        .fontColor(Color(0xFF4081))

                    Text(this.monthTip)
                        .fontSize(24)
                        .width(90.percent)
                        .fontColor(Color(0x555555))
                        .textAlign(TextAlign.Start)
                }
                .width(90.percent)
                .padding(20)
                .backgroundColor(Color(0xFFF8F8))
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