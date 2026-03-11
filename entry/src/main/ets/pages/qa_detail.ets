// entry/src/main/ets/pages/qa_detail.ets
import { router } from '@kit.ArkUI';

@Entry
@Component
struct QADetailPage {
  // 👉 1. 直接从全局字典取货（和发货端完美对接）
  @StorageProp('QADetailQ') question: string = '';
  @StorageProp('QADetailA') answer: string = '';

  // 👉 2. 交互状态留在 ArkTS 处理，反应最快
  @State likes: number = 0;
  @State dislikes: number = 0;
  @State userLiked: boolean = false;
  @State userDisliked: boolean = false;

  build() {
    Column() {
      // --- 导航栏 ---
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').onClick(() => router.back())
        Blank()
        Text("问答详情").fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text("        ").fontSize(18) // 占位保持居中
      }.width('100%').padding(15).backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // --- 🌟 问答卡片（纯 ArkTS 渲染，瞬间满血展示！） ---
          Column() {
            Row() {
              Text("问").fontColor('#FFFFFF').backgroundColor('#4CAF50')
                .width(24).height(24).textAlign(TextAlign.Center).borderRadius(4).margin({ right: 10 })
              Text(this.question).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1)
            }.width('100%').margin({ bottom: 20 }).alignItems(VerticalAlign.Top)

            Row() {
              Text("答").fontColor('#FFFFFF').backgroundColor('#0D9FFB')
                .width(24).height(24).textAlign(TextAlign.Center).borderRadius(4).margin({ right: 10 })
              Text(this.answer).fontSize(16).fontColor('#666666').layoutWeight(1).lineHeight(24)
            }.width('100%').alignItems(VerticalAlign.Top)
          }
          .width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 20 })

          // --- 👍 点赞 / 👎 点踩模块 ---
          Row() {
            Column() {
              Text("👍 点赞").fontSize(16).fontColor('#333333')
              Text(`${this.likes}`).fontSize(14).fontColor('#999999').margin({ top: 5 })
            }
            .width(90).height(65).backgroundColor(this.userLiked ? '#E8F5E9' : '#FFFFFF')
            .borderRadius(10).borderWidth(1).borderColor(this.userLiked ? '#4CAF50' : '#E0E0E0')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (this.userLiked) { this.likes -= 1; this.userLiked = false; }
              else {
                this.likes += 1;
                if (this.userDisliked) { this.dislikes -= 1; this.userDisliked = false; }
                this.userLiked = true;
              }
            })

            Blank().width(30)

            Column() {
              Text("👎 点踩").fontSize(16).fontColor('#333333')
              Text(`${this.dislikes}`).fontSize(14).fontColor('#999999').margin({ top: 5 })
            }
            .width(90).height(65).backgroundColor(this.userDisliked ? '#FFEBEE' : '#FFFFFF')
            .borderRadius(10).borderWidth(1).borderColor(this.userDisliked ? '#F44336' : '#E0E0E0')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (this.userDisliked) { this.dislikes -= 1; this.userDisliked = false; }
              else {
                this.dislikes += 1;
                if (this.userLiked) { this.likes -= 1; this.userLiked = false; }
                this.userDisliked = true;
              }
            })
          }.width('90%').margin({ top: 30 }).justifyContent(FlexAlign.Center)

        }
      }.layoutWeight(1)

    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}