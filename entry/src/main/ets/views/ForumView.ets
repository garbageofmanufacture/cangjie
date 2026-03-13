// entry/src/main/ets/views/ForumView.ets
import { router } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

export class PostModel {
  title: string = '';
  content: string = '';
  author: string = '';
  time: string = '';
}

@Component
export struct ForumView {
  @State postList: PostModel[] = [];
  @State searchText: string = '';

  // 🌟 核心：监听来自发布页的信号！听到信号立马执行 loadPostsFromDB
  @StorageProp('RefreshForumTrigger') @Watch('loadPostsFromDB') refreshTrigger: number = 0;

  aboutToAppear() {
    this.loadPostsFromDB();
  }

  async loadPostsFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) { this.loadFallback(); return; }

    try {
      let predicates = new relationalStore.RdbPredicates("Post");

      if (this.searchText.trim() !== '') {
        predicates.like("title", `%${this.searchText.trim()}%`);
      }

      predicates.orderByDesc("id");
      let rs = await store.query(predicates);

      let temp: PostModel[] = [];
      while (rs.goToNextRow()) {
        temp.push({
          title: rs.getString(rs.getColumnIndex("title")) || '无标题',
          content: rs.getString(rs.getColumnIndex("content")) || '',
          author: rs.getString(rs.getColumnIndex("author_id")) || '匿名农友',
          time: '刚刚'
        });
      }
      rs.close();

      if (temp.length > 0) {
        this.postList = temp;
      } else {
        this.postList = [];
        if (this.searchText === '') { this.loadFallback(); }
      }
    } catch(e) {
      this.loadFallback();
    }
  }

  loadFallback() {
    if (this.searchText !== '') return;
    this.postList = [
      { title: '小麦纹枯病怎么治？', content: '最近地里的小麦出现了纹枯病，请问各位大佬用什么药比较好？', author: '张大爷', time: '10分钟前' }
    ];
  }

  build() {
    Column() {
      Row() {
        Search({ value: this.searchText, placeholder: '搜索农事帖子...' })
          .searchButton('搜索').width('100%').height(40).backgroundColor('#FFFFFF')
          .placeholderColor('#999999').textFont({ size: 14 }).borderRadius(20)
          .onChange((value: string) => {
            this.searchText = value;
            this.loadPostsFromDB();
          })
      }.width('100%').padding({ left: 15, right: 15, top: 15, bottom: 10 })

      if (this.postList.length === 0 && this.searchText !== '') {
        Column({ space: 10 }) {
          Text("🔍").fontSize(50).margin({ top: 100 })
          Text(`没有找到包含 "${this.searchText}" 的帖子`).fontColor('#999999').fontSize(14)
          Text("换个关键词试试吧").fontColor('#CCCCCC').fontSize(12)
        }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 15 }) {
          ForEach(this.postList, (item: PostModel, index: number) => {
            ListItem() {
              Column() {
                Text(item.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ bottom: 8 }).width('100%').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.content).fontSize(14).fontColor('#666666').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 12 }).width('100%')
                Row() {
                  Text(`👤 ${item.author}`).fontSize(12).fontColor('#0D9FFB')
                  Blank()
                  Text(item.time).fontSize(12).fontColor('#999999')
                }.width('100%')
              }
              .padding(15).backgroundColor('#FFFFFF').borderRadius(12)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 3 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/post_detail', params: { title: item.title, content: item.content, author: item.author, time: item.time }});
              })
            }
          }, (item: PostModel, index: number) => item.title + index) // 唯一 key 防渲染混乱
        }.padding({ left: 15, right: 15, bottom: 20 }).layoutWeight(1).width('100%')
      }
    }.width('100%').height('100%').backgroundColor('#F4F4F4')
  }
}