// entry/src/main/ets/pages/qa_detail.ets
import { router } from '@kit.ArkUI';

@Entry
@Component
struct QADetailPage {
  @State question: string = '';
  @State answer: string = '';

  aboutToAppear() {
    // 接收从列表页传过来的问题和答案
    let params = router.getParams() as Record<string, string>;
    if (params) {
      this.question = params['q'] || '未知问题';
      this.answer = params['a'] || '暂无解答';
    }
  }

  build() {
    Column() {
      // 🌟 顶部导航栏
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').padding(15).onClick(() => { try{ router.back() }catch(e){} })
        Text("问答详情").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // --- 1. 问题展示区 ---
          Column() {
            Row() {
              Text("问").fontSize(14).fontColor('#FFFFFF').backgroundColor('#FF6600').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(4).margin({ right: 10 })
              Text("问题描述").fontSize(14).fontColor('#999999')
            }.width('100%').margin({ bottom: 15 })

            Text(this.question).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%').lineHeight(32)
          }.width('90%').padding(25).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 20, bottom: 15 })
          .shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

          // --- 2. 专家解答区 ---
          Column() {
            Row() {
              Text("答").fontSize(14).fontColor('#FFFFFF').backgroundColor('#0D9FFB').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(4).margin({ right: 10 })
              Text("专家解答").fontSize(14).fontColor('#999999')
            }.width('100%').margin({ bottom: 15 })

            Text(this.answer)
              .fontSize(18)
              .fontColor(this.answer.includes('等待') ? '#FF9900' : '#444444')
              .width('100%')
              .lineHeight(30)
          }.width('90%').padding(25).backgroundColor('#FFFFFF').borderRadius(15).margin({ bottom: 30 })
          .shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })

        }.width('100%')
      }.width('100%').layoutWeight(1)

    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}