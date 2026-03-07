// postList.ets - 帖子列表页面容器（带返回按钮）
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import router from '@ohos.router'; // 路由模块，用于返回上一页

@Entry
@Component
struct PostListPage {
  build() {
    Column() {
      // --- 1. 顶部返回栏（固定在顶部，不随页面滚动） ---
      Row() {
        // 返回按钮
        Button() {
          Text("返回上一页")
            .fontSize(20) // 字号稍微调小一点点，更精致
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .height(45)
        .backgroundColor('#0D9FFB')
        .borderRadius(10)
        .margin({ left: 15 })
        .padding({ left: 15, right: 15 }) // 给按钮文字留出呼吸感
        .onClick(() => {
          // 点击返回上一页
          router.back();
        })

        // 页面标题
        Text("帖子列表")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 60 }) // 稍微往左边挤一点，让标题在视觉上居中
      }
      .width('100%')
      .height(70) // 用固定高度替代 8%，适配不同屏幕更稳定
      .backgroundColor('#F5F5F5')
      .padding({ top: 10 }) // 防止顶到手机状态栏


      // --- 2. 帖子列表内容区（交给仓颉内部处理自适应滚动） ---
      // 👉 核心修改：删除了外层的 Scroll 和定死的 height，直接把地盘交给仓颉
      CJHybridComponent({
        library: "ohos_app_cangjie_entry",
        component: "PostList"
      })
        .layoutWeight(1) // 👉 核心魔法：让仓颉组件吃掉屏幕下方所有剩余空间
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}