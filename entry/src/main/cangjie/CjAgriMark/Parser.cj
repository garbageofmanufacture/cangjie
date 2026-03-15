package ohos_app_cangjie_entry.CjAgriMark

import std.collection.*
import std.convert.*

public class AgriParser {
    public static func parse(input: String): ArrayList<AgriNode> {
        let nodes = ArrayList<AgriNode>()
        let chars = input.toRuneArray()
        let len = chars.size
        var i = 0
        var currentText = ""

        func flushText() {
            if (currentText.size > 0) {
                // 🌟 核心修复：将 append 改为 add
                nodes.add(AgriNode.PlainText(currentText))
                currentText = ""
            }
        }

        while (i < len) {
            // 1. 匹配高亮语法 **xxx**
            if (i + 1 < len && chars[i] == r'*' && chars[i+1] == r'*') {
                flushText()
                i += 2
                var highlightText = ""
                while (i < len && !(i + 1 < len && chars[i] == r'*' && chars[i+1] == r'*')) {
                    highlightText = highlightText + chars[i].toString()
                    i++
                }
                if (i + 1 < len) { i += 2 }

                // 🌟 核心修复：将 append 改为 add
                nodes.add(AgriNode.Highlight(highlightText))
                continue
            }

            // 2. 匹配专属标签语法 [类型:名称,参数]
            if (chars[i] == r'[') {
                flushText()
                i++
                var tagContent = ""
                while (i < len && chars[i] != r']') {
                    tagContent = tagContent + chars[i].toString()
                    i++
                }
                if (i < len) { i++ }

                let parts = tagContent.split(":")
                if (parts.size >= 2) {
                    let tagType = parts[0]
                    let tagData = parts[1]

                    if (tagType == "病害") {
                        nodes.add(AgriNode.DiseaseTag("病害", tagData))
                    } else if (tagType == "农资") {
                        let dataParts = tagData.split(",")
                        if (dataParts.size >= 2) {
                            let name = dataParts[0]
                            var price: Float64 = 0.0
                            try {
                                price = Float64.parse(dataParts[1])
                            } catch(e: Exception) {
                                price = 0.0
                            }
                            nodes.add(AgriNode.ProductTag(name, price))
                        } else {
                            nodes.add(AgriNode.ProductTag(tagData, 0.0))
                        }
                    } else {
                        nodes.add(AgriNode.PlainText("[" + tagContent + "]"))
                    }
                } else {
                    nodes.add(AgriNode.PlainText("[" + tagContent + "]"))
                }
                continue
            }

            // 3. 收集普通文本
            currentText = currentText + chars[i].toString()
            i++
        }

        flushText()
        return nodes
    }
}