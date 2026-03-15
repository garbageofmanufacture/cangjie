package ohos_app_cangjie_entry.CjAgriMark

// 🌟 核心亮点 1：利用高级枚举定义 AST 节点，拒绝松散的面向对象继承体系，内存极其安全
public enum AgriNode {
    | PlainText(String)               // 普通文本
    | Highlight(String)               // 高亮文本 (**包裹**)
    | DiseaseTag(String, String)      // 病害专属标签 (类型, 名称)
    | ProductTag(String, Float64)     // 农资专属标签 (名称, 价格)
}