// entry/src/main/cangjie/product_detail.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import ohos.hilog.Hilog

@HybridComponentEntry
@Component
class product_detail {
    @StorageLink["ProductDetailName"] var name: String = ""
    @StorageLink["ProductDetailPrice"] var price: String = ""
    @StorageLink["ProductDetailDesc"] var desc: String = ""
    @StorageLink["ProductDetailSeller"] var seller: String = "热心农友"
    @State var interested: Bool = false
    @State var notInterested: Bool = false

    public func build() {
        Column() {
            Row() {
                Text("商品详情").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
            }.width(100.percent).padding(15).backgroundColor(Color(0xFFFFFFFF))

            Scroll() {
                Column() {
                    Column() {
                        Text(this.name).fontSize(22).fontWeight(FontWeight.Bold).fontColor(Color(0xFF333333))
                            .width(100.percent).margin(bottom: 15)

                        Text(this.price).fontSize(28).fontWeight(FontWeight.Bold).fontColor(Color(0xFFFF4081))
                            .width(100.percent).margin(bottom: 20)

                        Rect().width(100.percent).height(1).fill(Color(0xFFEEEEEE)).margin(bottom: 20)

                        Text("商品介绍").fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color(0xFF333333))
                            .width(100.percent).margin(bottom: 10)

                        Text(this.desc).fontSize(16).fontColor(Color(0xFF666666)).lineSpacing(6)
                            .width(100.percent)
                    }.width(90.percent).padding(20).backgroundColor(Color(0xFFFFFFFF)).borderRadius(15)
                     .margin(top: 20)

                    Row() {
                        Column() {
                            Text("👍 感兴趣").fontSize(16)
                        }
                        .width(100).height(50).backgroundColor(if (this.interested) { Color(0xFFE8F5E9) } else { Color(0xFFFFFFFF) })
                        .borderRadius(25).border(width: 2, color: if (this.interested) { Color(0xFF4CAF50) } else { Color(0xFFE0E0E0) })
                        .onClick({ _ =>
                            this.interested = !this.interested
                            if (this.notInterested) {
                                this.notInterested = false
                            }
                        })

                        Blank().width(20)

                        Column() {
                            Text("👎 不感兴趣").fontSize(16)
                        }
                        .width(100).height(50).backgroundColor(if (this.notInterested) { Color(0xFFFFEBEE) } else { Color(0xFFFFFFFF) })
                        .borderRadius(25).border(width: 2, color: if (this.notInterested) { Color(0xFFF44336) } else { Color(0xFFE0E0E0) })
                        .onClick({ _ =>
                            this.notInterested = !this.notInterested
                            if (this.interested) {
                                this.interested = false
                            }
                        })
                    }.width(90.percent).margin(top: 30).justifyContent(FlexAlign.Center)

                    Button("📞 联系卖家").width(90.percent).height(50).fontSize(18).fontColor(Color(0xFFFFFFFF))
                        .backgroundColor(Color(0xFF0D9FFB)).borderRadius(25).margin(top: 30)
                        .onClick({ _ =>
                            Hilog.info(1, "info", "联系卖家: ${this.seller}")
                        })
                }
            }.layoutWeight(1)
        }.width(100.percent).height(100.percent).backgroundColor(Color(0xFFF5F7FA))
    }
}
