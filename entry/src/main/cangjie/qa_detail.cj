// entry/src/main/cangjie/qa_detail.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import ohos.hilog.Hilog

@HybridComponentEntry
@Component
class qa_detail {
    @StorageLink["QADetailQ"] var question: String = ""
    @StorageLink["QADetailA"] var answer: String = ""
    @State var likes: Int64 = 0
    @State var dislikes: Int64 = 0
    @State var userLiked: Bool = false
    @State var userDisliked: Bool = false

    public func build() {
        Column() {
            Row() {
                Text("问答详情").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
            }.width(100.percent).padding(15).backgroundColor(Color(0xFFFFFFFF))

            Scroll() {
                Column() {
                    Column() {
                        Row() {
                            Text("问").fontColor(Color(0xFFFFFFFF)).backgroundColor(Color(0xFF4CAF50))
                                .width(24).height(24).textAlign(TextAlign.Center).borderRadius(4).margin(right: 10)
                            Text(this.question).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1)
                        }.width(100.percent).margin(bottom: 20)

                        Row() {
                            Text("答").fontColor(Color(0xFFFFFFFF)).backgroundColor(Color(0xFF0D9FFB))
                                .width(24).height(24).textAlign(TextAlign.Center).borderRadius(4).margin(right: 10)
                            Text(this.answer).fontSize(16).fontColor(Color(0xFF666666)).layoutWeight(1).lineSpacing(8)
                        }.width(100.percent)
                    }.width(90.percent).padding(20).backgroundColor(Color(0xFFFFFFFF)).borderRadius(15)
                     .margin(top: 20)

                    Row() {
                        Column() {
                            Text("👍 点赞").fontSize(16)
                            Text("${this.likes}").fontSize(14).fontColor(Color(0xFF999999))
                        }
                        .width(80).height(60).backgroundColor(if (this.userLiked) { Color(0xFFE8F5E9) } else { Color(0xFFFFFFFF) })
                        .borderRadius(10).border(width: 1, color: if (this.userLiked) { Color(0xFF4CAF50) } else { Color(0xFFE0E0E0) })
                        .onClick({ _ =>
                            if (this.userLiked) {
                                this.likes -= 1
                                this.userLiked = false
                            } else {
                                this.likes += 1
                                if (this.userDisliked) {
                                    this.dislikes -= 1
                                    this.userDisliked = false
                                }
                                this.userLiked = true
                            }
                        })

                        Blank().width(30)

                        Column() {
                            Text("👎 点踩").fontSize(16)
                            Text("${this.dislikes}").fontSize(14).fontColor(Color(0xFF999999))
                        }
                        .width(80).height(60).backgroundColor(if (this.userDisliked) { Color(0xFFFFEBEE) } else { Color(0xFFFFFFFF) })
                        .borderRadius(10).border(width: 1, color: if (this.userDisliked) { Color(0xFFF44336) } else { Color(0xFFE0E0E0) })
                        .onClick({ _ =>
                            if (this.userDisliked) {
                                this.dislikes -= 1
                                this.userDisliked = false
                            } else {
                                this.dislikes += 1
                                if (this.userLiked) {
                                    this.likes -= 1
                                    this.userLiked = false
                                }
                                this.userDisliked = true
                            }
                        })
                    }.width(90.percent).margin(top: 30).justifyContent(FlexAlign.Center)
                }
            }.layoutWeight(1)
        }.width(100.percent).height(100.percent).backgroundColor(Color(0xFFF5F7FA))
    }
}
