// entry/src/main/cangjie/profile.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class ProfileView {
    // 🌟 核心修复：跨语言入口必须使用 @State 接收 ArkTS 的 parameter 注入！
    @State var account: String = ""
    @State var username: String = ""
    @State var roleStr: String = "0"
    @State var email: String = ""
    @State var address: String = ""
    @State var bio: String = ""
    @State var avatarChar: String = ""

    public func build() {
        Column() {
            // --- 顶部导航 ---
            Row() {
                Button("返回").backgroundColor(Color.Transparent).fontColor(Color(0x333333)).fontSize(18)
                    .onClick({ _ =>
                        let optFn = globalJSFunction.get("ProfileGoBack")
                           if (let Some(fn) <- optFn) {
                       fn.invoke()  // ✅ 正确调用接口内的方法
}
                    })
                Text("个人中心").fontSize(22).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).margin(right: 40)
            }.width(100.percent).height(60).backgroundColor(Color(0xFFFFFF))

            Scroll() {
                Column() {

                    // --- 1. 头像与身份区 ---
                    Column() {
                        Text(this.avatarChar)
                            .fontSize(40).fontWeight(FontWeight.Bold).fontColor(Color(0xFFFFFF))
                            .width(80).height(80).backgroundColor(if(this.roleStr == "1") { Color(0xFF6B6B) } else { Color(0x0D9FFB) }).borderRadius(40)
                            .textAlign(TextAlign.Center).margin(bottom: 15)

                        Row() {
                            Text(this.username).fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color(0x333333))

                            Text(if(this.roleStr == "1") { "超级管理员" } else { "普通农友" })
                                .fontSize(12).fontColor(Color(0xFFFFFF))
                                .backgroundColor(if(this.roleStr == "1") { Color(0xFF6B6B) } else { Color(0x0D9FFB) })
                                .padding(left: 8, right: 8, top: 4, bottom: 4).borderRadius(12).margin(left: 10)
                        }.margin(bottom: 10)

                        Text(this.bio).fontSize(14).fontColor(Color(0x666666)).margin(bottom: 8).textAlign(TextAlign.Center)
                        Text("账号: " + this.account).fontSize(12).fontColor(Color(0x999999))
                    }.width(90.percent).padding(30).backgroundColor(Color(0xFFFFFF)).borderRadius(15).margin(top: 20)

                    // --- 2. 基础信息区 ---
                    Column() {
                        Row() {
                            Text("基本信息").fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color(0x333333))
                            Blank()
                            Button("✎ 编辑资料").fontSize(14).fontColor(Color(0x0D9FFB)).backgroundColor(Color.Transparent).height(30)
                                .onClick({ _ =>

                                    let optFn = globalJSFunction.get("OpenEditDialog")
if (let Some(fn) <- optFn) {
    fn.invoke()  // ✅ 正确调用接口内的方法
}
                                })
                        }.width(100.percent).margin(bottom: 15)

                        Row() {
                            Text("📧 邮箱").fontSize(16).fontColor(Color(0x333333))
                            Blank()
                            Text(this.email).fontSize(16).fontColor(Color(0x888888))
                        }.width(100.percent).margin(bottom: 15)

                        Divider().color(Color(0xF0F0F0)).margin(bottom: 15)

                        Row() {
                            Text("📍 地址").fontSize(16).fontColor(Color(0x333333))
                            Blank()
                            Text(this.address).fontSize(16).fontColor(Color(0x888888))
                        }.width(100.percent)

                    }.width(90.percent).padding(20).backgroundColor(Color(0xFFFFFF)).borderRadius(15).margin(top: 20)

                   // --- 3. 管理员面板 ---

                    // 👇 🌟 视觉 Debug：直接把它显示在屏幕上！看看括号里到底是什么！
                    Text("【Debug】当前接收到的权限值是: [" + this.roleStr + "]")
                        .fontSize(14).fontColor(Color(0xFF0000)).margin(top: 20)

                    // 👇 🌟 放宽条件：只要它包含 1，或者是 1.0，统统放行！
                    if (this.roleStr == "1" || this.roleStr == "1.0" || this.roleStr != "0") {
                        Column() {
                            Text("🛠️ 管理功能").fontSize(18).fontWeight(FontWeight.Bold).margin(bottom: 15).width(100.percent).textAlign(TextAlign.Start)

                            Row() {
                                Text("🛡️ 帖子审核中心").fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color(0xFF4D4F))
                                Blank()
                                Text("有新待办 >").fontSize(14).fontColor(Color(0xFFC300))
                            }
                            .width(100.percent).height(50).backgroundColor(Color(0xFFF0F0)).borderRadius(10).padding(left: 15, right: 15).margin(bottom: 15)
                            .onClick({ _ =>
                                let optFn = globalJSFunction.get("OpenAuditPage")
                                if (let Some(fn) <- optFn) {
                                fn.invoke()  // ✅ 正确调用接口内的方法
}
                            })

                            Button("系统数据大屏 (演示)").width(100.percent).height(45).backgroundColor(Color(0xFFF0F0)).fontColor(Color(0xFF6B6B))
                        }.width(90.percent).padding(20).backgroundColor(Color(0xFFFFFF)).borderRadius(15).margin(top: 10)
                    }


                    // --- 4. 退出按钮 ---
                    Button("退出登录").width(80.percent).height(50).backgroundColor(Color(0xFFF0F0)).fontColor(Color(0xFF4D4F))
                        .margin(bottom: 40)
                        .onClick({ _ =>
                            let optFn = globalJSFunction.get("ProfileGoBack")
                            if (let Some(fn) <- optFn) {
                            fn.invoke()  // ✅ 正确调用接口内的方法
}
                        })
                }
                .width(100.percent)
                .constraintSize(minHeight: 100.percent)
            }
            .width(100.percent)
            .layoutWeight(1)
        }.width(100.percent).height(100.percent).backgroundColor(Color(0xF5F7FA))
    }
}