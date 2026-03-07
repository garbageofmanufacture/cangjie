// expert_qa.ets - 专家问答页面容器（带返回按钮）
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import router from '@ohos.router'; // 路由模块，用于返回上一页

@Entry
@Component
struct ExpertQA {
  build() {
    Column() {
      // --- 1. 顶部返回栏（固定高度吸顶，不随页面滚动） ---
      Row() {
        // 返回按钮
        Button() {
          Text("返回上一页")
            .fontSize(20) // 字号微调，与前面页面保持一致的精致感
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .height(45)
        .backgroundColor('#0D9FFB')
        .borderRadius(10)
        .margin({ left: 15 })
        .padding({ left: 15, right: 15 })
        .onClick(() => {
          // 点击返回上一页（论坛功能总入口页）
          router.back();
        })

        // 页面标题
        Text("专家问答")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 60 }) // 抵消左边按钮的视觉宽度，确保标题居中
      }
      .width('100%')
      .height(70)
      .backgroundColor('#F5F5F5')
      .padding({ top: 10 })


      // --- 2. 问答内容区（交给仓颉内部处理自适应滚动） ---
      // 👉 核心修改：删除了外层的 Scroll 和定死的 height，直接把地盘交给仓颉
      CJHybridComponent({
        library: "ohos_app_cangjie_entry",
        component: "expert_qa"
      })
        .layoutWeight(1) // 👉 核心魔法：让仓颉组件吃掉屏幕下方所有剩余空间
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}