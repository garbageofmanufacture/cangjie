// entry/src/main/ets/pages/DetailPage.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct DetailPage {
  build() {
    Column() {
      // ArkTS 负责顶部返回导航
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').onClick(() => router.back())
        Blank()
        Text("帖子详情").fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text("        ").fontSize(18) // 占位保持视觉居中
      }.width('100%').padding(15).backgroundColor('#FFFFFF')

      // 🌟 ArkUI + Cangjie 核心结合：详情内容由仓颉语言渲染
      CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "post_detail" })
        .layoutWeight(1).width('100%')

    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}