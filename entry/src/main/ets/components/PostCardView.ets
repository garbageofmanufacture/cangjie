// src/main/ets/components/PostCardView.ets
import { PostItem } from '../models/PostItem';
import { router, promptAction } from '@kit.ArkUI';
@Component
export struct PostCardView {
  @Prop item: PostItem;
  @Prop bannerColor: string;
  @Prop userRole: number;
  onDeleteRequest: (id: number) => void = () => {};

  build() {
    Column() {
      Row().width('100%').height(100).backgroundColor(this.bannerColor)
      Column() {
        Text(this.item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ bottom: 5 })
        Text(this.item.content).fontSize(13).fontColor('#666666').margin({ bottom: 8 }).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.item.author + " | " + this.item.time).fontSize(11).fontColor('#999999')
      }.alignItems(HorizontalAlign.Start).padding(10).width('100%')
    }
    .backgroundColor('#FFFFFF').borderRadius(10).clip(true).margin({ bottom: 10 }).width('100%')
    // 🌟 核心：为卡片绑定点击跳转事件
    .onClick(() => {
      // 增加 Promise 的错误捕获机制
      router.pushUrl({
        url: 'pages/post_detail', // 🚨 注意：这里必须和 main_pages.json 里的拼写大小写一模一样！
        params: {
          title: this.item.title,
          author: this.item.author,
          time: this.item.time,
          content: this.item.content
        }
      }).then(() => {
        console.info("💡 跳转成功！");
      }).catch((err: Error) => {
        console.error("❌ 跳转失败: " + JSON.stringify(err));
        promptAction.showToast({ message: '跳转失败，请检查路径: ' + err.message, duration: 3000 });
      });
    })
    // 管理员的长按删除特权依然保留
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (this.userRole === 1) {
            this.onDeleteRequest(this.item.id);
          }
        })
    )
  }
}