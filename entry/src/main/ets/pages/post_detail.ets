// entry/src/main/ets/pages/post_detail.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { router, promptAction } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';
import cjlib from 'libohos_app_cangjie_entry.so';
// 🌟 修复1：删除了 import { AppStorage }，因为它已经是全局自带的了！

// 🌟 修复2：严格定义收藏的数据结构，彻底消灭 any 报错
export interface FavoriteItem {
  title: string;
  type: string;
}

// 1. 升级评论数据结构
export class CommentItem {
  id: number = 0;
  post_id: number = 0;
  author: string = '';
  content: string = '';
  time: string = '';
  parent_id: number = 0;
  target_author: string = '';
}

@CustomDialog
export struct CommentInputDialog {
  controller?: CustomDialogController;
  @State inputValue: string = '';
  postId: number = 0;

  @Link parentId: number;
  @Link targetAuthor: string;

  onCommentSuccess: () => void = () => {};

  async submitComment() {
    if (this.inputValue.trim() === '') {
      promptAction.showToast({ message: '内容不能为空' });
      return;
    }
    let store = DatabaseHelper.getStore();
    if (store) {
      try {
        await store.insert("Comment", {
          "post_id": this.postId,
          "author_id": "热心农友",
          "content": this.inputValue,
          "parent_id": this.parentId,
          "target_author": this.targetAuthor
        });
        promptAction.showToast({ message: '发布成功！' });
        this.inputValue = '';
        this.controller?.close();
        this.onCommentSuccess();
      } catch (err) {
        promptAction.showToast({ message: '发布失败' });
      }
    }
  }

  build() {
    Column() {
      Text(this.parentId === 0 ? "发表评论" : `回复 @${this.targetAuthor}`)
        .fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 15 })

      TextArea({ placeholder: '请输入内容...', text: this.inputValue })
        .onChange((value) => { this.inputValue = value })
        .height(100).width('100%').backgroundColor('#F5F5F5').margin({ bottom: 20 })

      Row() {
        Button("取消").backgroundColor(Color.Transparent).fontColor('#999999').onClick(() => { this.controller?.close() })
        Blank()
        Button("发布").backgroundColor('#0D9FFB').onClick(() => { this.submitComment() })
      }.width('100%')
    }.padding(20).backgroundColor('#FFFFFF').borderRadius(16).width('90%')
  }
}

@Entry
@Component
struct PostDetail {
  @State postId: number = 0;
  @State comments: CommentItem[] = [];

  @State postTitle: string = '';
  @State postAuthor: string = '';
  @State postTime: string = '';
  @State postContent: string = '';

  @State currentReplyParentId: number = 0;
  @State currentReplyTargetAuthor: string = '';

  @StorageProp('triggerCommentDialog') @Watch('openCommentDialog') triggerDialog: number = 0;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CommentInputDialog({
      postId: this.postId,
      parentId: $currentReplyParentId,
      targetAuthor: $currentReplyTargetAuthor,
      onCommentSuccess: () => { this.loadComments(); }
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: false
  });

  aboutToAppear() {
    let params = router.getParams() as Record<string, string>;
    if (params) {
      this.postId = Number(params['id']) || 0;
      this.postTitle = params['title'] || '无标题';
      this.postAuthor = params['author'] || '匿名';
      this.postTime = params['time'] || '未知时间';
      this.postContent = params['content'] || '无正文';
    }
    this.loadComments();

    // 🌟 核心：在这里接应仓颉里的星星点击事件！
    cjlib.registerJSFunc('AddToFavorite', () => {
      // 🌟 修复2：用严谨的 FavoriteItem[] 替代 any[]
      let favs = AppStorage.get('MyFavorites') as FavoriteItem[] || [];

      // 检查是否已经收藏过
      if(!favs.some((f: FavoriteItem) => f.title === this.postTitle)) {
        // 加入收藏夹池
        favs.unshift({ title: this.postTitle, type: '农事帖子' });
        AppStorage.setOrCreate('MyFavorites', favs);
        promptAction.showToast({ message: '收藏成功！去个人中心查看吧' });
      } else {
        promptAction.showToast({ message: '您已经收藏过该帖子啦' });
      }
    });
  }

  aboutToDisappear() {
    cjlib.unregisterJSFunc('AddToFavorite');
  }

  async loadComments() {
    let store = DatabaseHelper.getStore();
    if (!store || this.postId === 0) return;
    try {
      let predicates = new relationalStore.RdbPredicates("Comment");
      predicates.equalTo("post_id", this.postId);
      predicates.orderByDesc("created_at");

      let resultSet = await store.query(predicates);
      let tempList: CommentItem[] = [];
      while (resultSet.goToNextRow()) {
        tempList.push({
          id: resultSet.getLong(resultSet.getColumnIndex("id")),
          post_id: resultSet.getLong(resultSet.getColumnIndex("post_id")),
          author: resultSet.getString(resultSet.getColumnIndex("author_id")),
          content: resultSet.getString(resultSet.getColumnIndex("content")),
          time: "刚刚",
          parent_id: resultSet.getLong(resultSet.getColumnIndex("parent_id")) || 0,
          target_author: resultSet.getString(resultSet.getColumnIndex("target_author")) || ''
        });
      }
      resultSet.close();
      this.comments = tempList;
    } catch (err) {
      console.error("读取评论失败", err);
    }
  }

  openCommentDialog() {
    if (this.triggerDialog > 0) {
      this.currentReplyParentId = 0;
      this.currentReplyTargetAuthor = '';
      this.dialogController.open();
    }
  }

  build() {
    Column() {
      Row() {
        Text("< 返回").fontSize(18).fontColor('#333333').fontWeight(FontWeight.Medium).padding(15)
          .onClick(() => { try{ router.back(); }catch(e){} })
        Text("帖子详情").fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
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

          Column() {
            Row() {
              Text(`全部评论 (${this.comments.length})`).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
            }.width('100%').margin({ bottom: 15 })

            ForEach(this.comments, (item: CommentItem) => {
              Column() {
                Row() {
                  Text(item.author).fontSize(14).fontColor('#666666').fontWeight(FontWeight.Medium)
                  if (item.parent_id !== 0) {
                    Text(` 回复 @${item.target_author}`).fontSize(13).fontColor('#0D9FFB').margin({ left: 5 })
                  }
                  Blank()
                  Text(item.time).fontSize(12).fontColor('#999999')
                }.width('100%').margin({ bottom: 8 })

                Text(item.content)
                  .fontSize(16).fontColor('#333333').width('100%').textAlign(TextAlign.Start)
                  .padding(item.parent_id !== 0 ? 10 : 0)
                  .backgroundColor(item.parent_id !== 0 ? '#F9F9F9' : 'transparent')
                  .borderRadius(5)

                Divider().color('#F0F0F0').margin({ top: 15 })
              }
              .width('100%').padding({ top: 10, bottom: 5 })
              .onClick(() => {
                this.currentReplyParentId = item.id;
                this.currentReplyTargetAuthor = item.author;
                this.dialogController.open();
              })
            }, (item: CommentItem) => item.id.toString() + "_" + Date.now().toString())
          }
          .width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 15, bottom: 20 })

        }.width('100%')
      }
      .width('100%')
      .layoutWeight(1)

      Stack({ alignContent: Alignment.BottomStart }) {

        CJHybridComponent({
          library: "ohos_app_cangjie_entry",
          component: "PostToolbar"
        })
          .width('100%')
          .height(60)

        Row()
          .width('65%')
          .height(60)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.currentReplyParentId = 0;
            this.currentReplyTargetAuthor = '';
            this.dialogController.open();
          })

      }
      .width('100%')
      .height(60)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}