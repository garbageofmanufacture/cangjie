// entry/src/main/cangjie/post_toolbar.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import std.time.DateTime

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
            // 👇 🌟 核心修改：加上点击事件，跨语言唤起 ArkTS 的弹窗
            .onClick({ _ =>
                println("🚀🚀🚀 【Cangjie侧】点击事件已触发！准备写入 AppStorage...")
                // 将当前时间戳写入 AppStorage，确保每次点击值都不同，从而触发 ArkTS 侧的 @Watch
                let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds()
                AppStorage.setOrCreate<Int64>("triggerCommentDialog", timestamp)
                println("🚀🚀🚀 【Cangjie侧】AppStorage 写入完成，当前值: ${timestamp}")
            })

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
        .border(width: 1, color: Color(0xF0F0F0)) // 补充你注释里说的顶部细灰线边框

    }
}