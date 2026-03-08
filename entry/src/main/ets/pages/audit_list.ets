// entry/src/main/ets/pages/audit_list.ets
import router from '@ohos.router';

@Entry
@Component
struct AuditList {
  build() {
    Column() {
      Row() {
        Text("< 返回").fontSize(18).padding(15).onClick(() => router.back())
        Text("帖子审核中心").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 50 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      Column() {
        Text("📭").fontSize(50).margin({ bottom: 20 })
        Text("这里是管理员审核页面").fontSize(18).fontColor('#666666')
      }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)

    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}