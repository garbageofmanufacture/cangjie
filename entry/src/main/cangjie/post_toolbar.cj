package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import std.time.DateTime

internal import ohos.ark_interop.*

var arktsFavCallback: Option<JSFunction> = None

func registerFavCallback(context: JSContext, callInfo: JSCallInfo): JSValue {
    if (callInfo.count > 0) { arktsFavCallback = callInfo[0].asFunction() }
    return context.undefined().toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports =>
        exports["registerFavCallback"] = runtime.function(registerFavCallback).toJSValue()
}

@HybridComponentEntry
@Component
class PostToolbar {
    @StorageLink["isLiked"] var isLiked: Bool = false
    @StorageLink["likeCount"] var likeCount: Int64 = 128
    @StorageLink["isFavorited"] var isStarred: Bool = false
    @StorageLink["currentPostTitle"] var postTitle: String = ""

    public func build() {
        Row() {
            // 📝 评论 (去除点击事件，因为 ArkTS 会用透明遮罩直接接管点击！)
            Row() { Text("✍️ 期待你的神评论...").fontSize(16.0).fontColor(Color(0x999999)) }
            .layoutWeight(1).height(40.0).backgroundColor(Color(0xF5F5F5)).borderRadius(20.0).padding(left: 15.0).margin(right: 15.0)

            // ❤️ 点赞
            Row() {
                Text(if(this.isLiked){"❤️"}else{"🤍"}).fontSize(24.0)
                Text(" ${this.likeCount}").fontSize(16.0).fontColor(if(this.isLiked){Color(0xFF4D4F)}else{Color(0x666666)})
            }.padding(10.0)
            .onClick({ _ =>
                this.isLiked = !this.isLiked
                if (this.isLiked) { this.likeCount += 1 } else { this.likeCount -= 1 }
                AppStorage.setOrCreate<Bool>("isLiked", this.isLiked)
            }).margin(right: 5.0)

            // ⭐ 收藏 (你测试好用的原版代码，绝对不动！)
            Row() {
                Text(if(this.isStarred){"⭐"}else{"☆"}).fontSize(28.0).fontColor(if(this.isStarred){Color(0xFFD700)}else{Color(0x666666)})
            }.padding(15.0)
            .onClick({ _ =>
                this.isStarred = !this.isStarred
                AppStorage.setOrCreate<Bool>("isFavorited", this.isStarred)

                match (arktsFavCallback) {
                    case Some(cb) => cb.call()
                    case None => ()
                }
            })
        }
        .width(100.percent).height(60.0).backgroundColor(Color(0xFFFFFF))
        .padding(left: 15.0, right: 15.0)
        .border(width: 1.0, color: Color(0xF0F0F0))
    }
}