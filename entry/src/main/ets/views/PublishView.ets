// entry/src/main/ets/views/PublishView.ets
import { promptAction } from '@kit.ArkUI';
import { DatabaseHelper } from '../utils/DatabaseHelper';

@Component
export struct PublishView {
  controller: TabsController = new TabsController();

  @StorageLink('currentPublishType') publishType: string = 'post'; // 🌟 监听当前发布类型
  @State newTitle: string = "";
  @State newContent: string = "";

  // 动态获取标题文案
  getDisplayTitle(): string {
    if (this.publishType === 'qa') return "提交专家问答";
    if (this.publishType === 'product') return "上架农资商品";
    return "发布新帖子";
  }

  async publishPost() {
    if (this.newTitle.trim() === '' || this.newContent.trim() === '') {
      promptAction.showToast({ message: '标题和内容不能为空' });
      return;
    }

    // 🌟 1. 管理员审核逻辑弹窗
    promptAction.showDialog({
      title: '提交审核',
      message: `您发布的[${this.getDisplayTitle()}]内容已提交。管理员将进行合规性审核，审核通过后即可在列表中查看。`,
      buttons: [{ text: '好的', color: '#0D9FFB' }]
    }).then(async () => {
      // 🌟 2. 模拟存库 (状态默认为待审核，这里我们可以先存入，但在列表显示时过滤)
      let store = DatabaseHelper.getStore();
      if (store) {
        try {
          await store.insert("Post", {
            "author_id": "热心农友",
            "title": this.newTitle,
            "content": this.newContent,
            "type": this.publishType,
            "status": 0 // 🌟 0代表审核中，1代表通过
          });

          // 清空输入
          this.newTitle = "";
          this.newContent = "";

          // 🌟 3. 切回首页并触发刷新
          this.controller.changeIndex(0);
          AppStorage.setOrCreate('refreshForumTrigger', Date.now());
        } catch(e) { console.error("存库失败"); }
      }
    });
  }

  build() {
    Column() {
      Text(this.getDisplayTitle()).fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 30, bottom: 20 })

      TextInput({ placeholder: '请输入标题...', text: this.newTitle })
        .onChange((v) => this.newTitle = v)
        .width('90%').height(50).margin({ bottom: 20 })
        .backgroundColor('#FFFFFF').borderRadius(10).padding({ left: 15 })

      TextArea({ placeholder: '请输入详细内容描述...', text: this.newContent })
        .onChange((v) => this.newContent = v)
        .width('90%').height(200).margin({ bottom: 30 })
        .backgroundColor('#FFFFFF').borderRadius(10).padding(15)

      Button("提交审核").width('80%').height(50).fontSize(20).fontWeight(FontWeight.Bold).backgroundColor('#0D9FFB').borderRadius(25)
        .onClick(() => { this.publishPost(); })

      Text("注意：所有内容均需经过管理员审核后方可公开显示")
        .fontSize(12).fontColor('#999999').margin({ top: 15 })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}