// farm_mall.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import router from '@ohos.router';

@Entry
@Component
struct FarmMall {
  build() {
    Column() {
      // 1. 顶部返回栏 (保持不变)
      Row() {
        Button() { Text("返回上一页").fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF') }
        .height(45).backgroundColor('#0D9FFB').borderRadius(10).margin({ left: 15 }).padding({ left: 15, right: 15 })
        .onClick(() => { router.back(); })

        Text("农资商城").fontSize(28).fontWeight(FontWeight.Bold).fontColor('#333333').flexGrow(1).textAlign(TextAlign.Center).margin({ right: 60 })
      }
      .width('100%').height(70).backgroundColor('#F5F5F5').padding({ top: 10 })

      // 2. 仓颉组件区 (👉 注意这里：不要 Scroll 了！)
      CJHybridComponent({
        library: "ohos_app_cangjie_entry",
        component: "farm_mall"
      })
        .layoutWeight(1) // 👉 核心魔法：让仓颉组件吃掉屏幕下方所有剩余空间
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}