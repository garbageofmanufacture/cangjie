// profile.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class ProfileView {
    @State var account: String = ""
    @State var username: String = ""
    @State var roleStr: String = "0"

    public func build() {
        Column() {
            // 顶部导航
            Row() {
                Button("返回").backgroundColor(Color.Transparent).fontColor(Color(0x333333)).fontSize(18)
                    .onClick({ _ =>
                        let optFn = globalJSFunction.get("ProfileGoBack")
                        if (let Some(fn) <- optFn) { fn() }
                    })
                Text("个人中心").fontSize(22).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin(right: 40)
            }.width(100.percent).height(60).backgroundColor(Color(0xFFFFFF))

            // 用户卡片
            Column() {
                Text("农").fontSize(40).fontColor(Color(0xFFFFFF)).width(80).height(80)
                    .backgroundColor(Color(0x0D9FFB)).borderRadius(40).textAlign(TextAlign.Center).margin(bottom: 15)

                Row() {
                    Text(this.username).fontSize(24).fontWeight(FontWeight.Bold)
                    Text(if(this.roleStr == "1") { "管理员" } else { "普通农友" })
                        .fontSize(12).fontColor(Color(0xFFFFFF))
                        .backgroundColor(if(this.roleStr == "1") { Color(0xFF6B6B) } else { Color(0x0D9FFB) })
                        .padding(left: 8, right: 8, top: 4, bottom: 4).borderRadius(12).margin(left: 10)
                }.margin(bottom: 10)

                Text("账号: " + this.account).fontSize(14).fontColor(Color(0x999999))
            }.width(90.percent).padding(30).backgroundColor(Color(0xFFFFFF)).borderRadius(15).margin(top: 20)

            // 管理员专属功能
            if (this.roleStr == "1") {
                Column() {
                    Text("🛠️ 管理功能").fontSize(18).fontWeight(FontWeight.Bold).margin(bottom: 15)
                    Button("管理帖子").width(100.percent).height(45).backgroundColor(Color(0xF5F5F5)).fontColor(Color(0xFF6B6B))
                }.width(90.percent).padding(20).backgroundColor(Color(0xFFFFFF)).borderRadius(15).margin(top: 20)
            }

            Blank()

            Button("退出登录").width(80.percent).height(50).backgroundColor(Color(0xFFF0F0)).fontColor(Color(0xFF4D4F))
                .margin(bottom: 40)
                .onClick({ _ =>
                    let optFn = globalJSFunction.get("LogoutUser")
                    if (let Some(fn) <- optFn) { fn() }
                })
        }.width(100.percent).height(100.percent).backgroundColor(Color(0xF5F7FA))
    }
}