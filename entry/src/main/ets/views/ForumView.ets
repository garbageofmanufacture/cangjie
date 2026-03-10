// entry/src/main/ets/views/ForumView.ets
import { router } from '@kit.ArkUI';

// 🌟 1. 核心修复：定义明确的数据结构，彻底消灭 any
export class PostModel {
  title: string = '';
  content: string = '';
  author: string = '';
  time: string = '';
}

@Component
export struct ForumView {
  // 🌟 2. 将 any[] 替换为 PostModel[]
  @StorageLink('DemoPosts') postList: PostModel[] = [
    { title: '小麦纹枯病近期高发，大家注意防范！', content: '最近气温回升，田间湿度大，请及时喷洒井冈霉素或戊唑醇进行预防，重点喷洒茎基部...', author: '农技老王', time: '2小时前' },
    { title: '大棚番茄开始坐果，如何施肥？', content: '目前第一穗果处于膨大期，建议开始追施高钾复合肥，配合叶面喷施磷酸二氢钾...', author: '种植大户李姐', time: '5小时前' }
  ];

  build() {
    Column() {
      List({ space: 15 }) {
        // 🌟 3. ForEach 里也把 any 替换为 PostModel
        ForEach(this.postList, (item: PostModel, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Text("👤").fontSize(20).margin({ right: 10 })
                Column() {
                  Text(item.author).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333')
                  Text(item.time).fontSize(12).fontColor('#999999').margin({ top: 2 })
                }.alignItems(HorizontalAlign.Start)
              }.width('100%').margin({ bottom: 10 })

              Text(item.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#000000').width('100%').margin({ bottom: 8 })
              Text(item.content).fontSize(15).fontColor('#666666').width('100%').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .padding(18).backgroundColor('#FFFFFF').borderRadius(12).width('100%')
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetX: 0, offsetY: 4 })
          }
          // 🌟 核心修复：点击时传递数据并跳转！使用URL参数
          .onClick(() => {
            let params: Record<string, string> = {
              'title': item.title,
              'content': item.content,
              'author': item.author,
              'time': item.time
            };
            router.pushUrl({ url: 'pages/post_detail', params: params });
          })
        })
      }
      .width('95%')
      .height('100%')
      .padding({ top: 15, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
