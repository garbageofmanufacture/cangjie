// entry/src/main/cangjie/post_toolbar.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class PostToolbar {
    // 🌟 仓颉内部独立状态，不需要 ArkTS 传参！
    @State var isLiked: Bool = false
    @State var isStarred: Bool = false
    @State var likeCount: Int64 = 128

    public func build() {
        Row() {
            // 1. 模拟评论输入框
            Row() {
                Text("✍️ 期待你的神评论...").fontSize(16).fontColor(Color(0x999999))
            }
            .layoutWeight(1).height(40).backgroundColor(Color(0xF5F5F5))
            .borderRadius(20).padding(left: 15).margin(right: 15)

            // 2. 仓颉点赞动态组件
            Row() {
                Text(if(this.isLiked){"❤️"}else{"🤍"}).fontSize(24)
                Text(" ${this.likeCount}").fontSize(16).fontColor(if(this.isLiked){Color(0xFF4D4F)}else{Color(0x666666)})
            }
            .onClick({ _ =>
                this.isLiked = !this.isLiked
                if (this.isLiked) { this.likeCount += 1 } else { this.likeCount -= 1 }
            }).margin(right: 15)

            // 3. 仓颉收藏动态组件
            Row() {
                Text(if(this.isStarred){"⭐"}else{"☆"}).fontSize(28).fontColor(if(this.isStarred){Color(0xFFD700)}else{Color(0x666666)})
            }
            .onClick({ _ =>
                this.isStarred = !this.isStarred
            })
        }
        .width(100.percent).height(60).backgroundColor(Color(0xFFFFFF))
        .padding(left: 15, right: 15)
        // 顶部加一条细灰线作为分割

    }
}