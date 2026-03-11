// entry/src/main/ets/pages/my_published.ets
import { router } from '@kit.ArkUI';

export class PostItemModel {
  title: string = '';
  content: string = '';
  time: string = '';
  author?: string = '';
}

@Entry
@Component
struct MyPublishedPage {
  @State myPosts: PostItemModel[] = [];

  aboutToAppear() {
    // 🌟 核心：直接从全局数据池中捞取帖子
    let allPosts = AppStorage.get('DemoPosts') as PostItemModel[] || [];
    // 过滤出你刚刚发布的帖子（作者名字里带有 "我" 的）
    this.myPosts = allPosts.filter(post => post.author && post.author.includes('我'));
  }

  build() {
    Column() {
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').onClick(() => { try{ router.back() }catch(e){} })
        Blank()
        Text("我的发布").fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text("        ").fontSize(18)
      }.width('100%').padding(15).backgroundColor('#FFFFFF')

      if (this.myPosts.length === 0) {
        Column() {
          Text("📭").fontSize(50).margin({ bottom: 15 })
          Text("您还没有发布过任何内容").fontColor('#999999').fontSize(16)
        }.width('100%').margin({ top: 150 }).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 15 }) {
          ForEach(this.myPosts, (item: PostItemModel) => {
            ListItem() {
              Column() {
                Text(item.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%').margin({ bottom: 8 })
                Text(item.content).fontSize(15).fontColor('#666666').width('100%').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                Row() {
                  Text("状态: 已发布").fontSize(12).fontColor('#0D9FFB')
                }.width('100%').margin({ top: 10 }).justifyContent(FlexAlign.End)
              }.padding(18).backgroundColor('#FFFFFF').borderRadius(12).width('100%')
              .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetX: 0, offsetY: 4 })
            }
          })
        }.width('95%').padding({ top: 15, bottom: 20 }).layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}