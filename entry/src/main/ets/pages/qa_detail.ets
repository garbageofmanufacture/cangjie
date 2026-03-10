// entry/src/main/ets/pages/qa_detail.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct QADetailPage {
  build() {
    Column() {
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').onClick(() => router.back())
        Blank()
        Text("问答详情").fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text("        ").fontSize(18)
      }.width('100%').padding(15).backgroundColor('#FFFFFF')

      CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "qa_detail" })
        .layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}
