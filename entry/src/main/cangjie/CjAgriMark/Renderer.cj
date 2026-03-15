package ohos_app_cangjie_entry.CjAgriMark
import std.collection.ArrayList

public class AgriRenderer {
    // 🌟 核心亮点 3：利用 match 模式匹配极速消费 AST，代码极其优雅无副作用
    public static func renderToConsole(nodes: ArrayList<AgriNode>) {
        for (node in nodes) {
            match (node) {
                case PlainText(text) => 
                    print("[Span: ${text}]")
                case Highlight(text) => 
                    print("[Span(Bold): ${text} (Color: #333333)]")
                case DiseaseTag(_, name) => 
                    print("[Span(Disease): 🦠 ${name} (Color: Red, Bg: Pink)]")
                case ProductTag(name, price) => 
                    print("[Span(Product): 🛍️ ${name} ¥${price} (Color: Orange)]")
            }
        }
        println("")
    }
}

// ================= 测试入口 =================
main() {
    let input = "春季小麦容易发生[病害:纹枯病]，请**注意防范**，建议提前购买[农资:井冈霉素A,25.8]进行喷施。"
    
    println("====== 1. 词法扫描与 AST 构建 ======")
    let ast = AgriParser.parse(input)
    println("AST 节点数: ${ast.size}")
    
    println("\n====== 2. 模拟 ArkUI 渲染输出 ======")
    AgriRenderer.renderToConsole(ast)
}