// entry/src/main/ets/pages/post_detail.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct PostDetail {
  @State postTitle: string = '';
  @State postAuthor: string = '';
  @State postTime: string = '';
  @State postContent: string = '';

  aboutToAppear() {
    // ArkTS 稳稳接住路由参数
    let params = router.getParams() as Record<string, string>;
    if (params) {
      this.postTitle = params['title'] || '无标题';
      this.postAuthor = params['author'] || '匿名';
      this.postTime = params['time'] || '未知时间';
      this.postContent = params['content'] || '无正文';
    }
  }

  build() {
    Column() {
      // --- 模块 A：原生 ArkTS 导航栏 ---
      Row() {
        Text("< 返回").fontSize(18).fontColor('#333333').fontWeight(FontWeight.Medium).padding(15)
          .onClick(() => { router.back(); })
        Text("帖子详情").fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      // --- 模块 B：原生 ArkTS 正文渲染区 (绝对不白屏) ---
      Scroll() {
        Column() {
          Text(this.postTitle).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%').textAlign(TextAlign.Start).margin({ bottom: 15 })

          Row() {
            Text("👤 " + this.postAuthor).fontSize(16).fontColor('#0D9FFB')
            Blank()
            Text(this.postTime).fontSize(14).fontColor('#999999')
          }.width('100%').margin({ bottom: 25 })

          Divider().color('#F0F0F0').margin({ bottom: 25 })

          Text(this.postContent).fontSize(20).fontColor('#444444').lineHeight(32).width('100%').textAlign(TextAlign.Start)
        }
        .width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 20 })
      }
      .width('100%')
      .layoutWeight(1) // 占满中间所有空间

      // --- 模块 C：🌟 仓颉 (Cangjie) 混合渲染底部互动栏！ ---
      CJHybridComponent({
        library: "ohos_app_cangjie_entry",
        component: "PostToolbar" // 嵌入刚才写的纯仓颉组件
      })
        .width('100%')
        .height(60) // 固定高度，紧贴底部
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}