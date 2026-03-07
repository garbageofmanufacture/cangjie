// index.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.ark_interop.*
import ohos.ark_interop_macro.*
import ohos.hilog.Hilog
import std.collection.*

// 定义一个全局 HashMap，用于保存ArkTS注册的函数
// 作为简单演示，此处默认所有ArkTS的回调函数均为无参、无返回值
public let globalJSFunction = HashMap<String, ()->Unit>()

@Interop[ArkTS]
public func registerJSFunc(name: String, fn: ()->Unit): Unit {
    // 如果已经注册过，则打印错误信息，并直接返回
    if (globalJSFunction.contains(name)) {
        Hilog.error(1, "info", "registerJSFunc failed(err: func ${name} already exists)")
        return
    }
    // 保存到 HashMap 中
    globalJSFunction.add(name, fn)
}

@Interop[ArkTS]
public func unregisterJSFunc(name: String): Unit {
    globalJSFunction.remove(name)
}