// entry/src/main/ets/views/PublishView.ets
import { promptAction } from '@kit.ArkUI';
import { PostModel } from './ForumView';

// 🌟 为问答和商品定义专门的数据模型
export class QAModel {
  q: string = '';
  a: string = '';
}

export class ProductModel {
  name: string = '';
  price: string = '';
  desc: string = '';
}

@Component
export struct PublishView {
  controller: TabsController = new TabsController();
  @StorageLink('currentPublishType') publishType: string = 'post';

  // 统一的状态绑定
  @State newTitle: string = "";
  @State newContent: string = "";
  @State newPrice: string = ""; // 商品专用的价格字段

  async publishAction() {
    // 🌟 根据不同类型，执行不同的校验和数据流向
    if (this.publishType === 'post') {
      if (!this.newTitle || !this.newContent) { promptAction.showToast({ message: '请填写完整' }); return; }
      let temp = AppStorage.get('DemoPosts') as PostModel[] || [];
      temp.unshift({ title: this.newTitle, content: this.newContent, author: "热心农友", time: "刚刚" });
      AppStorage.setOrCreate('DemoPosts', temp);
      this.controller.changeIndex(0); // 跳转回帖子

    } else if (this.publishType === 'qa') {
      if (!this.newContent) { promptAction.showToast({ message: '请输入您的问题' }); return; }
      let temp = AppStorage.get('DemoQAs') as QAModel[] || [];
      temp.unshift({ q: this.newContent, a: "您的提问已提交，正在等待农业专家解答..." });
      AppStorage.setOrCreate('DemoQAs', temp);
      this.controller.changeIndex(1); // 跳转回问答

    } else if (this.publishType === 'product') {
      if (!this.newTitle || !this.newPrice) { promptAction.showToast({ message: '请填写商品名称和价格' }); return; }
      let temp = AppStorage.get('DemoProducts') as ProductModel[] || [];
      temp.unshift({ name: this.newTitle, price: "¥" + this.newPrice, desc: this.newContent || "此商品暂无详细描述" });
      AppStorage.setOrCreate('DemoProducts', temp);
      this.controller.changeIndex(4); // 跳转回商城
    }

    promptAction.showToast({ message: '发布成功！' });
    this.newTitle = ""; this.newContent = ""; this.newPrice = "";
  }

  build() {
    Column() {
      // 动态标题
      Text(this.publishType === 'qa' ? "发布专家问答" : (this.publishType === 'product' ? "上架农资商品" : "发布新帖子"))
        .fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 30, bottom: 20 })

      // 🌟 根据分类渲染不同的输入界面
      if (this.publishType === 'post') {
        TextInput({ placeholder: '请输入帖子标题...', text: this.newTitle }).onChange(v => this.newTitle = v)
          .width('90%').height(50).margin({ bottom: 15 }).backgroundColor('#FFFFFF').borderRadius(10).padding({ left: 15 })
        TextArea({ placeholder: '请输入帖子正文...', text: this.newContent }).onChange(v => this.newContent = v)
          .width('90%').height(150).margin({ bottom: 30 }).backgroundColor('#FFFFFF').borderRadius(10).padding(15)

      } else if (this.publishType === 'qa') {
        TextArea({ placeholder: '请输入您想咨询的农业问题，专家将为您在线解答...', text: this.newContent }).onChange(v => this.newContent = v)
          .width('90%').height(200).margin({ bottom: 30 }).backgroundColor('#FFFFFF').borderRadius(10).padding(15)

      } else if (this.publishType === 'product') {
        // 模拟商品图片上传
        Column() { Text("+ 添加商品图片 (选填)").fontColor('#999999') }
        .width('90%').height(100).backgroundColor('#E5E5E5').borderRadius(10).justifyContent(FlexAlign.Center).margin({ bottom: 15 })

        TextInput({ placeholder: '商品名称 (如: 高效复合肥)...', text: this.newTitle }).onChange(v => this.newTitle = v)
          .width('90%').height(50).margin({ bottom: 15 }).backgroundColor('#FFFFFF').borderRadius(10).padding({ left: 15 })
        TextInput({ placeholder: '商品价格 (元)...', text: this.newPrice }).onChange(v => this.newPrice = v)
          .width('90%').height(50).margin({ bottom: 15 }).backgroundColor('#FFFFFF').borderRadius(10).padding({ left: 15 }).type(InputType.Number)
        TextArea({ placeholder: '商品详细介绍...', text: this.newContent }).onChange(v => this.newContent = v)
          .width('90%').height(100).margin({ bottom: 30 }).backgroundColor('#FFFFFF').borderRadius(10).padding(15)
      }

      Button("立即发布").width('80%').height(50).fontSize(20).fontWeight(FontWeight.Bold).backgroundColor('#0D9FFB').borderRadius(25)
        .onClick(() => { this.publishAction(); })
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}