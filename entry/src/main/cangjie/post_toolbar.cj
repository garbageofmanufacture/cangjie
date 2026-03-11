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
    @State var isLiked: Bool = false
    @State var isStarred: Bool = false
    @State var likeCount: Int64 = 128

    public func build() {
        Row() {
            // 1. 模拟评论输入框
            Row() {
                Text("✍️ 期待你的神评论...").fontSize(16.0).fontColor(Color(0x999999))
            }
            .layoutWeight(1).height(40.0).backgroundColor(Color(0xF5F5F5))
            .borderRadius(20.0).padding(left: 15.0).margin(right: 15.0)
            .onClick({ _ =>
                println("🚀🚀🚀 【Cangjie侧】点击事件已触发！准备写入 AppStorage...")
                let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds()
                AppStorage.setOrCreate<Int64>("triggerCommentDialog", timestamp)
                println("🚀🚀🚀 【Cangjie侧】AppStorage 写入完成，当前值: ${timestamp}")
            })

            // 2. 仓颉点赞动态组件
            Row() {
                Text(if(this.isLiked){"❤️"}else{"🤍"}).fontSize(24.0)
                Text(" ${this.likeCount}").fontSize(16.0).fontColor(if(this.isLiked){Color(0xFF4D4F)}else{Color(0x666666)})
            }
            .onClick({ _ =>
                this.isLiked = !this.isLiked
                if (this.isLiked) { this.likeCount += 1 } else { this.likeCount -= 1 }
            }).margin(right: 15.0)

            // 3. 仓颉收藏动态组件
            Row() {
                Text(if(this.isStarred){"⭐"}else{"☆"}).fontSize(28.0).fontColor(if(this.isStarred){Color(0xFFD700)}else{Color(0x666666)})
            }
            .onClick({ _ =>
                this.isStarred = !this.isStarred
                // 👇 🌟 核心修复：必须使用 fn.invoke() 来调用跨端事件！
                let optFn = globalJSFunction.get("AddToFavorite")
                if (let Some(fn) <- optFn) {
                    fn.invoke()
                }
            })
        }
        .width(100.percent).height(60.0).backgroundColor(Color(0xFFFFFF))
        .padding(left: 15.0, right: 15.0)
        .border(width: 1.0, color: Color(0xF0F0F0))
    }
}