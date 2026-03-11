// entry/src/main/cangjie/farm_mall.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class farm_mall {
    public func build() {
        Column() {

            Scroll() {
                Column() {
                    this.buildProductCard("井冈霉素A（小麦纹枯病专用）", "¥25.8/瓶", "有效成分10%，兑水30kg/亩，安全无残留")
                    this.buildProductCard("复合肥（氮磷钾15-15-15）", "¥120/袋（40kg）", "通用型复合肥，适用于小麦/玉米/蔬菜")
                    this.buildProductCard("矮壮素（控旺专用）", "¥18.5/瓶", "1000倍液喷施，控制作物徒长，增产增收")
                    this.buildProductCard("磷酸二氢钾（叶面肥）", "¥15/袋（500g）", "快速补钾，促进果实膨大，提高抗病性")
                    this.buildProductCard("芸苔素内酯（植物生长调节剂）", "¥28/瓶", "增强作物抗逆性，提高产量和品质")
                }
            }.layoutWeight(1)
        }.height(100.percent).width(100.percent).padding(left: 15, right: 15).backgroundColor(Color(0xFFF5F5F5))
    }

    @Builder func buildProductCard(name: String, price: String, desc: String) {
        Column() {
            Text(name).fontSize(18).fontWeight(FontWeight.Bold).width(90.percent).margin(bottom: 5).textAlign(TextAlign.Start).fontColor(Color(0xFF333333))
            Text(price).fontSize(16).width(90.percent).margin(bottom: 10).textAlign(TextAlign.Start).fontColor(Color(0xFFFF4081))
            Text(desc).fontSize(14).width(90.percent).fontColor(Color(0xFF555555)).textAlign(TextAlign.Start)
        }.width(90.percent).padding(20).backgroundColor(Color(0xFFFFFFFF)).borderRadius(10).margin(bottom: 15)
        .onClick({ _ =>
            AppStorage.setOrCreate("ProductDetailName", name)
            AppStorage.setOrCreate("ProductDetailPrice", price)
            AppStorage.setOrCreate("ProductDetailDesc", desc)
            AppStorage.setOrCreate("NavigateToProduct", "true")
        })
    }
}
