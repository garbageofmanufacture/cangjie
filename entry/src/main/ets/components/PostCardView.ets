// src/main/ets/components/PostCardView.ets
import { PostItem } from '../models/PostItem';

@Component
export struct PostCardView {
  @Prop item: PostItem;
  @Prop bannerColor: string;
  @Prop userRole: number;
  // 暴露一个删除回调给父组件，不在这里直接写弹窗逻辑
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
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (this.userRole === 1) {
            this.onDeleteRequest(this.item.id); // 触发父组件的删除方法
          }
        })
    )
  }
}