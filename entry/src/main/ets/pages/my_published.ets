// entry/src/main/ets/pages/my_published.ets
import { router } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

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
  @StorageProp('RefreshForumTrigger') @Watch('loadMyRealPosts') refreshTrigger: number = 0;

  aboutToAppear() {
    this.loadMyRealPosts();
  }

  async loadMyRealPosts() {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    let currentUserId = AppStorage.get<string>('currentUserId');
    if (!currentUserId || currentUserId === '') { this.myPosts = []; return; }

    try {
      let predicates = new relationalStore.RdbPredicates("Post");
      predicates.equalTo("author_id", currentUserId);
      predicates.orderByDesc("id");
      let rs = await store.query(predicates);
      let temp: PostItemModel[] = [];
      while (rs.goToNextRow()) {
        temp.push({
          title: rs.getString(rs.getColumnIndex("title")) || '',
          content: rs.getString(rs.getColumnIndex("content")) || '',
          time: '刚刚发布',
          author: currentUserId
        });
      }
      rs.close();
      this.myPosts = temp;
    } catch (err) {}
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
          ForEach(this.myPosts, (item: PostItemModel, index: number) => {
            ListItem() {
              Column() {
                Text(item.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%').margin({ bottom: 8 })
                Text(item.content).fontSize(15).fontColor('#666666').width('100%').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                Row() { Text("状态: 已发布").fontSize(12).fontColor('#0D9FFB') }.width('100%').margin({ top: 10 }).justifyContent(FlexAlign.End)
              }
              .padding(18).backgroundColor('#FFFFFF').borderRadius(12).width('100%')
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 3 })
              // 🌟 核心新增：点击整张卡片，带着参数跳转到详情页！
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/post_detail',
                  params: {
                    title: item.title,
                    content: item.content,
                    author: item.author,
                    time: item.time
                  }
                });
              })
            }
          }, (item: PostItemModel, index: number) => item.title + index)
        }.width('95%').padding({ top: 15, bottom: 20 }).layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}