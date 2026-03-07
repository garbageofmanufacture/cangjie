// farm_calendar.ets - 农事日历页面容器
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import router from '@ohos.router';

@Entry
@Component
struct FarmCalendar {
  build() {
    Column() {
      // --- 1. 顶部返回栏（固定高度吸顶，不随页面滚动） ---
      Row() {
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
          router.back(); // 返回功能总入口页
        })

        Text("农事日历")
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


      // --- 2. 日历内容区（交给仓颉内部处理自适应滚动） ---
      // 👉 核心修改：删除了外层的 Scroll 和定死的 height，直接把地盘交给仓颉
      CJHybridComponent({
        library: "ohos_app_cangjie_entry",
        component: "farm_calendar" // 对应cj文件类名
      })
        .layoutWeight(1) // 👉 核心魔法：让仓颉组件吃掉屏幕下方所有剩余空间
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}