package ohos_app_cangjie_entry

import ohos.ark_interop.*
import ohos.ark_interop_macro.*
import ohos.hilog.Hilog
import std.collection.*

// 1. 核心修复点：自定义一个接口，并显式加上 @Interop[ArkTS] 宏
// 这样宏在解析下面的 registerJSFunc 时，就认识 IJSCallback 了
@Interop[ArkTS]
public interface IJSCallback {
    func invoke(): Unit
}

// 2. HashMap 里面保存我们刚才定义的接口类型
public let globalJSFunction = HashMap<String, IJSCallback>()

@Interop[ArkTS]
public func registerJSFunc(name: String, fn: IJSCallback): Unit {
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
@Interop[ArkTS]
public func registerFavCallback( ): Unit {
    // todo，template code:

}
@Interop[ArkTS]
public func testCJ(arg1: String): String {
    // todo，template code:
    "template"
}
@Interop[ArkTS]
public func getQA_Question( ): String {
    // todo，template code:
    "template"
}
@Interop[ArkTS]
public func getQA_Answer( ): String {
    // todo，template code:
    "template"
}
@Interop[ArkTS]
public func syncQA_Action(arg1: Float64,arg2: Float64): Unit {
    // todo，template code:

}
@Interop[ArkTS]
public func registerCommentCallback( ): Unit {
    // todo，template code:

}