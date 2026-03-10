// entry/src/main/cangjie/post_detail.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class post_detail {
    @StorageLink["DetailTitle"] var DetailTitle: String = "";
    @StorageLink["DetailContent"] var DetailContent: String = "";
    @StorageLink["DetailAuthor"] var DetailAuthor: String = "";
    @StorageLink["DetailTime"] var DetailTime: String = "";
    @State var isLiked: Bool = false
    @State var isDisliked: Bool = false
    @State var likeCount: Int64 = 0

    public func build() {
        Column() {
            Scroll() {
                Column() {
                    Text(this.DetailTitle).fontSize(24.0).fontWeight(FontWeight.Bold).fontColor(Color(0xFF333333))
                        .margin(bottom: 15.0).width(100.percent)

                    Row() {
                        Text(this.DetailAuthor).fontSize(16.0).fontColor(Color(0xFF0D9FFB)).margin(right: 15.0)
                        Text(this.DetailTime).fontSize(14.0).fontColor(Color(0xFF999999))
                    }.width(100.percent).margin(bottom: 20.0)

                    Rect().width(100.percent).height(1.0).fill(Color(0xFFEEEEEE)).margin(bottom: 20.0)

                    Text(this.DetailContent).fontSize(18.0).fontColor(Color(0xFF444444)).lineSpacing(8.0)
                        .width(100.percent)

                }.padding(20.0).backgroundColor(Color(0xFFFFFFFF)).borderRadius(12.0)
                 .margin(15.0)
            }.layoutWeight(1)

            Row() {
                Row() {
                    Text(if (this.isLiked) { "❤️" } else { "🤍" }).fontSize(20)
                    Text(" ${this.likeCount}").fontSize(14).fontColor(if (this.isLiked) { Color(0xFFFF4081) } else { Color(0xFF666666) })
                }
                .onClick({ _ =>
                    if (this.isLiked) {
                        this.likeCount -= 1
                        this.isLiked = false
                    } else {
                        this.likeCount += 1
                        if (this.isDisliked) {
                            this.isDisliked = false
                        }
                        this.isLiked = true
                    }
                }).margin(right: 30)

                Row() {
                    Text(if (this.isDisliked) { "👎" } else { "💔" }).fontSize(20)
                }
                .onClick({ _ =>
                    this.isDisliked = !this.isDisliked
                    if (this.isDisliked && this.isLiked) {
                        this.likeCount -= 1
                        this.isLiked = false
                    }
                })
            }
            .width(100.percent).height(50).backgroundColor(Color(0xFFFFFFFF))
            .padding(left: 20, right: 20).justifyContent(FlexAlign.Center)
            .border(width: 1, color: Color(0xFFEEEEEE))
        }.width(100.percent).height(100.percent).backgroundColor(Color(0xFFF5F7FA))
    }
}
