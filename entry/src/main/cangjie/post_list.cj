// post_list.cj - 农业论坛帖子列表页面
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*
import ohos.hilog.Hilog
import std.collection.*

@HybridComponentEntry
@Component
class PostList {
    @State var dbData: String = ""

    func getLeftPosts(): Array<Array<String>> {
        let list = ArrayList<Array<String>>()
        // 👉 核心修复：仓颉必须使用 if else 表达式来替代三元运算符
        let finalData = if (this.dbData == "") {
            "桥接断了|系统诊断|03-07|仓颉没有收到ArkTS传来的数据，请检查parameter传递"
        } else {
            this.dbData
        }

        let posts = finalData.split("^")
        for (i in 0..posts.size) {
            if (i % 2 == 0 && posts[i] != "") {
                let parts = posts[i].split("|")
                if (parts.size >= 4) {
                    list.add(parts)
                }
            }
        }
        return list.toArray()
    }

    func getRightPosts(): Array<Array<String>> {
        let list = ArrayList<Array<String>>()
        // 👉 核心修复：同上
        let finalData = if (this.dbData == "") {
            ""
        } else {
            this.dbData
        }

        let posts = finalData.split("^")
        for (i in 0..posts.size) {
            if (i % 2 == 1 && posts[i] != "") {
                let parts = posts[i].split("|")
                if (parts.size >= 4) {
                    list.add(parts)
                }
            }
        }
        return list.toArray()
    }

    public func build() {
        Column() {
            Text("农业论坛 · 帖子列表")
                .fontSize(24).fontWeight(FontWeight.Bold).width(100.percent).margin(top: 15, bottom: 15).textAlign(TextAlign.Center).fontColor(Color(0x333333))

            // 🚨 探照灯：直接把仓颉接收到的真实变量打印在屏幕最显眼的地方！
            Text("【数据探照灯】" + this.dbData)
                .fontSize(14)
                .fontColor(Color(0xFFFF0000))
                .padding(bottom: 10)
                .width(90.percent)

            Scroll() {
                Row() {
                    // ==========================================
                    // 🌟 左列
                    // ==========================================
                    Column() {
                        ForEach(this.getLeftPosts(), { itemData: Array<String>, index: Int64 =>
                            Column() {
                                Row(){}.width(100.percent).height(120).backgroundColor(Color(0x87CEEB))
                                Column() {
                                    Text(itemData[0]).fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color(0x333333)).margin(bottom: 5)
                                    Text(itemData[3]).fontSize(13).fontColor(Color(0x666666)).margin(bottom: 8)
                                    Text(itemData[1] + " | " + itemData[2]).fontSize(11).fontColor(Color(0x999999))
                                }.alignItems(HorizontalAlign.Start).padding(10)
                            }.backgroundColor(Color(0xFFFFFF)).borderRadius(10).clip(true).margin(bottom: 10)
                        })
                    }.width(50.percent).padding(right: 5).justifyContent(FlexAlign.Start)


                    // ==========================================
                    // 🌟 右列
                    // ==========================================
                    Column() {
                        ForEach(this.getRightPosts(), { itemData: Array<String>, index: Int64 =>
                            Column() {
                                Row(){}.width(100.percent).height(160).backgroundColor(Color(0x98FB98))
                                Column() {
                                    Text(itemData[0]).fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color(0x333333)).margin(bottom: 5)
                                    Text(itemData[3]).fontSize(13).fontColor(Color(0x666666)).margin(bottom: 8)
                                    Text(itemData[1] + " | " + itemData[2]).fontSize(11).fontColor(Color(0x999999))
                                }.alignItems(HorizontalAlign.Start).padding(10)
                            }.backgroundColor(Color(0xFFFFFF)).borderRadius(10).clip(true).margin(bottom: 10)
                        })
                    }.width(50.percent).padding(left: 5).justifyContent(FlexAlign.Start)

                }.width(100.percent).alignItems(VerticalAlign.Top)
            }
            .layoutWeight(1).padding(left: 10, right: 10, bottom: 10).scrollBar(BarState.Off)
        }
        .height(100.percent).width(100.percent).backgroundColor(Color(0xF5F5F5))
    }
}