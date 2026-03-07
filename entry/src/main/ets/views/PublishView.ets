import { promptAction } from '@kit.ArkUI';
import { DatabaseHelper } from '../utils/DatabaseHelper';

@Component
export struct PublishView {
  // 🌟 核心：接收外壳页面传进来的 TabsController，用于切换 Tab
  controller: TabsController = new TabsController();
//新加页面
  @State newTitle: string = "";
  @State newContent: string = "";

  async publishPost() {
    if (this.newTitle.trim() === '' || this.newContent.trim() === '') {
      promptAction.showToast({ message: '标题和内容不能为空' });
      return;
    }

    let store = DatabaseHelper.getStore();
    if (store) {
      try {
        await store.insert("Post", { "author_id": "热心农友", "title": this.newTitle, "content": this.newContent });
        promptAction.showToast({ message: '发布成功！' });

        this.newTitle = "";
        this.newContent = "";

        // 🌟 发布成功后，调用外层传入的 controller 切换回首页 (Index 0)
        this.controller.changeIndex(0);

        // 通知 ForumView 刷新数据 (可以使用 AppStorage 发送一个刷新信号)
        AppStorage.setOrCreate('refreshForumTrigger', Date.now());
      } catch(e) { console.error("存库失败"); }
    }
  }

  build() {
    Column() {
      Text("发布新帖子").fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 30, bottom: 20 })
      TextInput({ placeholder: '请输入标题', text: this.newTitle }).onChange((v) => this.newTitle = v).width('90%').height(50).margin({ bottom: 20 }).backgroundColor('#FFFFFF')
      TextArea({ placeholder: '请输入正文', text: this.newContent }).onChange((v) => this.newContent = v).width('90%').height(200).margin({ bottom: 30 }).backgroundColor('#FFFFFF')
      Button("立即发布").width('80%').height(50).fontSize(20).fontWeight(FontWeight.Bold).backgroundColor('#0D9FFB')
        .onClick(() => { this.publishPost(); })
    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}