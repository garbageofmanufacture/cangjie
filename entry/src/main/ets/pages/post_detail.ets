import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { router, promptAction } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';
// 🌟 只留好用的收藏通道
import { registerFavCallback } from 'libohos_app_cangjie_entry.so';

export class CommentItem {
  id: number = 0; post_title: string = ''; author: string = ''; content: string = ''; time: string = ''; parent_id: number = 0; target_author: string = '';
}

@CustomDialog
export struct CommentInputDialog {
  controller?: CustomDialogController;
  @State inputValue: string = '';
  targetAuthor: string = '';
  onSubmit: (content: string) => void = () => {};

  build() {
    Column() {
      Text(this.targetAuthor === '' ? "发表评论" : `回复 @${this.targetAuthor}`).fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 15 })
      TextArea({ placeholder: '请输入内容...', text: this.inputValue }).onChange((v) => { this.inputValue = v }).height(100).width('100%').backgroundColor('#F5F5F5').margin({ bottom: 20 })
      Row() {
        Button("取消").backgroundColor(Color.Transparent).fontColor('#999999').onClick(() => { this.controller?.close() })
        Blank()
        Button("发布").backgroundColor('#0D9FFB').onClick(() => {
          if (this.inputValue.trim() === '') { promptAction.showToast({ message: '内容不能为空' }); return; }
          this.onSubmit(this.inputValue); this.inputValue = ''; this.controller?.close();
        })
      }.width('100%')
    }.padding(20).backgroundColor('#FFFFFF').borderRadius(16).width('90%')
  }
}

@Entry
@Component
struct PostDetail {
  @State postId: number = 0;
  @State postTitle: string = '';
  @State postAuthor: string = '';
  @State postTime: string = '';
  @State postContent: string = '';
  @State comments: CommentItem[] = [];
  @State currentReplyParentId: number = 0;
  @State currentReplyTargetAuthor: string = '';
  @State isDbReady: boolean = false;

  @State localFavorited: boolean = false;
  @StorageLink('isFavorited') isFavorited: boolean = false;
  @StorageLink('isLiked') isLiked: boolean = false;

  dialogController: CustomDialogController = new CustomDialogController({ builder: CommentInputDialog({ targetAuthor: this.currentReplyTargetAuthor, onSubmit: (content: string) => { this.submitCommentToDB(content); } }), alignment: DialogAlignment.Bottom, customStyle: false });

  aboutToAppear() {
    let params = router.getParams() as Record<string, string>;
    if (params && params['title']) {
      this.postTitle = String(params['title']);
      this.postAuthor = params['author'] || '匿名';
      this.postTime = params['time'] || '刚刚';
      this.postContent = params['content'] || '暂无内容';
    } else {
      this.postTitle = `默认帖子_${new Date().getTime()}`;
    }

    let hash = 0;
    for (let i = 0; i < this.postTitle.length; i++) { hash = (hash << 5) - hash + this.postTitle.charCodeAt(i); hash |= 0; }
    this.postId = Math.abs(hash) || 1;

    this.initData();
  }

  onPageShow() {
    AppStorage.setOrCreate('isFavorited', this.localFavorited);
    AppStorage.setOrCreate('currentPostTitle', this.postTitle);

    try {
      // 🌟 收藏底层回调原封不动
      registerFavCallback(() => {
        this.executeFavoriteToDB();
      });
    } catch(e) {}
  }

  async initData() {
    await this.loadComments();
    await this.checkFavoriteStatusFromDB();
    this.isDbReady = true;
  }

  async checkFavoriteStatusFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store || this.postTitle === '') return;
    try {
      let predicates = new relationalStore.RdbPredicates("Favorite");
      predicates.equalTo("title", this.postTitle);
      let rs = await store.query(predicates);
      let found = rs.rowCount > 0;
      rs.close();
      this.localFavorited = found;
      AppStorage.setOrCreate('isFavorited', found);
    } catch(e) {}
  }

  async executeFavoriteToDB() {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    let targetStatus = !this.localFavorited;
    try {
      let predicates = new relationalStore.RdbPredicates("Favorite");
      predicates.equalTo("title", this.postTitle);
      await store.delete(predicates);

      if (targetStatus) {
        let values: relationalStore.ValuesBucket = { "title": this.postTitle, "type": "农事帖子" };
        await store.insert("Favorite", values);
        promptAction.showToast({ message: '收藏成功！' });
      } else {
        promptAction.showToast({ message: '已取消收藏' });
      }
      this.localFavorited = targetStatus;
      AppStorage.setOrCreate('isFavorited', targetStatus);
    } catch (e) {
      AppStorage.setOrCreate('isFavorited', this.localFavorited);
    }
  }

  async submitCommentToDB(content: string) {
    let store = DatabaseHelper.getStore();
    if (store && this.postId !== 0) {
      try {
        await store.insert("Comment", { "post_id": this.postId, "author_id": "热心农友", "content": content, "parent_id": this.currentReplyParentId, "target_author": this.currentReplyTargetAuthor });
        promptAction.showToast({ message: '发布成功！' });
        this.loadComments();
      } catch (err) {}
    }
  }

  async loadComments() {
    let store = DatabaseHelper.getStore();
    if (!store || this.postId === 0) return;
    try {
      let predicates = new relationalStore.RdbPredicates("Comment");
      predicates.equalTo("post_id", this.postId);
      predicates.orderByAsc("created_at");
      let rs = await store.query(predicates);
      let tempList: CommentItem[] = [];
      let parentIdCol = rs.getColumnIndex("parent_id"); let targetAuthorCol = rs.getColumnIndex("target_author");
      while (rs.goToNextRow()) { tempList.push({ id: rs.getLong(rs.getColumnIndex("id")), post_title: this.postTitle, author: rs.getString(rs.getColumnIndex("author_id")), content: rs.getString(rs.getColumnIndex("content")), time: "刚刚", parent_id: parentIdCol !== -1 ? (rs.getLong(parentIdCol) || 0) : 0, target_author: targetAuthorCol !== -1 ? (rs.getString(targetAuthorCol) || '') : '' }); }
      rs.close(); this.comments = tempList;
    } catch (err) {}
  }

  build() {
    Column() {
      Row() {
        Text("< 返回").fontSize(18).fontColor('#333333').padding(15).onClick(() => { try{ router.back(); }catch(e){} })
        Text("帖子详情").fontSize(22).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          Column() {
            Text(this.postTitle).fontSize(32).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 15 })
            Row() { Text("👤 " + this.postAuthor).fontSize(16).fontColor('#0D9FFB'); Blank(); Text(this.postTime).fontSize(14).fontColor('#999999') }.width('100%').margin({ bottom: 25 })
            Divider().color('#F0F0F0').margin({ bottom: 25 })
            Text(this.postContent).fontSize(20).fontColor('#444444').lineHeight(32).width('100%')
          }.width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 20 })

          Column() {
            Row() { Text(`全部评论 (${this.comments.length})`).fontSize(18).fontWeight(FontWeight.Bold) }.width('100%').margin({ bottom: 15 })
            ForEach(this.comments, (item: CommentItem, index: number) => {
              Column() {
                Row() {
                  Text(item.author).fontSize(14).fontColor('#666666').fontWeight(FontWeight.Medium)
                  if (item.parent_id !== 0 && item.target_author !== '') { Text(` 回复 @${item.target_author}`).fontSize(13).fontColor('#0D9FFB').margin({ left: 5 }) }
                  Blank(); Text(item.time).fontSize(12).fontColor('#999999')
                }.width('100%').margin({ bottom: 8 })
                Text(item.content).fontSize(16).width('100%').padding(item.parent_id !== 0 ? 10 : 0).backgroundColor(item.parent_id !== 0 ? '#F9F9F9' : 'transparent').borderRadius(5)
                Divider().color('#F0F0F0').margin({ top: 15 })
              }.width('100%').padding({ top: 10, bottom: 5 }).onClick(() => {
                this.currentReplyParentId = item.id;
                this.currentReplyTargetAuthor = item.author;
                this.dialogController.open();
              })
            },
              (item: CommentItem, index: number) => index.toString())
          }.width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 15, bottom: 20 })
        }.width('100%')
      }.width('100%').layoutWeight(1)

      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.isDbReady) {
          CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "PostToolbar" }).width('100%').height(60)

          // 🚀 终极物理外挂：透明遮罩层！
          // 精确覆盖在左侧 65% 的宽度（也就是评论输入框的区域）
          // 用户点击时，直接被 ArkTS 拦截弹窗，完全避开跨语言通信！
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
      }.width('100%').height(60)

    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}