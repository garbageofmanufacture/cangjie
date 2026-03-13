// entry/src/main/ets/views/PublishView.ets
import { promptAction } from '@kit.ArkUI';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

@Component
export struct PublishView {
  controller: TabsController = new TabsController();
  @StorageLink('currentPublishType') publishType: string = 'post';

  @State newTitle: string = "";
  @State newContent: string = "";
  @State newPrice: string = "";
  @State selectedImageUri: string = '';

  async selectImage() {
    try {
      let photoPicker = new picker.PhotoViewPicker();
      let options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;

      let result = await photoPicker.select(options);
      if (result.photoUris && result.photoUris.length > 0) {
        let originalUri = result.photoUris[0];
        let context = getContext(this) as common.UIAbilityContext;
        let fileName = `${Date.now()}.jpg`;
        let sandboxPath = `${context.filesDir}/${fileName}`;

        let file = fs.openSync(originalUri, fs.OpenMode.READ_ONLY);
        let destFile = fs.openSync(sandboxPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.copyFileSync(file.fd, destFile.fd);
        fs.closeSync(file);
        fs.closeSync(destFile);

        this.selectedImageUri = 'file://' + sandboxPath;
      }
    } catch (err) { promptAction.showToast({ message: '图片加载失败' }); }
  }

  async publishAction() {
    let store = DatabaseHelper.getStore();
    if (!store) { promptAction.showToast({ message: '数据库未就绪' }); return; }
    let currentUserId = AppStorage.get<string>('currentUserId') || 'guest';

    try {
      if (this.publishType === 'post') {
        if (!this.newTitle || !this.newContent) { promptAction.showToast({ message: '请填写完整' }); return; }
        let values: relationalStore.ValuesBucket = { "author_id": currentUserId, "title": this.newTitle, "content": this.newContent };
        await store.insert("Post", values);

        // 🌟 核心修复：发射刷新信号！通知帖子列表和“我的发布”立刻去查库！
        AppStorage.setOrCreate('RefreshForumTrigger', Date.now());

        this.controller.changeIndex(0);

      } else if (this.publishType === 'qa') {
        if (!this.newContent) { promptAction.showToast({ message: '请输入您的问题' }); return; }
        let values: relationalStore.ValuesBucket = { "questioner_id": currentUserId, "question": this.newContent, "status": 0 };
        await store.insert("ExpertQA", values);

        // 发射问答刷新信号！
        AppStorage.setOrCreate('RefreshQATrigger', Date.now());

        this.controller.changeIndex(1);

      } else if (this.publishType === 'product') {
        if (!this.newTitle || !this.newPrice) { promptAction.showToast({ message: '请填写商品名称和价格' }); return; }
        let values: relationalStore.ValuesBucket = { "name": this.newTitle, "price": parseFloat(this.newPrice) || 0, "description": this.newContent || "此商品暂无详细描述", "image_url": this.selectedImageUri };
        await store.insert("Product", values);

        // 发射商城刷新信号！
        AppStorage.setOrCreate('RefreshMallTrigger', Date.now());

        this.controller.changeIndex(4);
      }

      promptAction.showToast({ message: '🎉 发布成功！' });
      this.newTitle = ""; this.newContent = ""; this.newPrice = ""; this.selectedImageUri = "";

    } catch (err) { promptAction.showToast({ message: '发布失败' }); }
  }

  build() {
    Column() {
      Row() { Text(this.publishType === 'qa' ? "发布专家问答" : (this.publishType === 'product' ? "上架农资商品" : "发布新帖子")).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333') }.width('100%').padding({ top: 20, bottom: 20, left: 20 }).backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 15 }) {
          if (this.publishType === 'post') {
            Column({ space: 15 }) {
              TextInput({ placeholder: '给帖子起个响亮的标题...', text: this.newTitle }).onChange(v => this.newTitle = v).width('100%').height(55).backgroundColor('#F9F9F9').borderRadius(12)
              TextArea({ placeholder: '在此输入帖子正文，分享您的农事经验...', text: this.newContent }).onChange(v => this.newContent = v).width('100%').height(200).backgroundColor('#F9F9F9').borderRadius(12)
            }.padding(20).backgroundColor('#FFFFFF').borderRadius(15).width('95%').shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          } else if (this.publishType === 'qa') {
            Column() { TextArea({ placeholder: '请详细描述您遇到的农业问题，例如农作物病虫害现象等，专家将尽快为您解答...', text: this.newContent }).onChange(v => this.newContent = v).width('100%').height(250).backgroundColor('#F9F9F9').borderRadius(12) }.padding(20).backgroundColor('#FFFFFF').borderRadius(15).width('95%').shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          } else if (this.publishType === 'product') {
            Column({ space: 15 }) {
              Stack() {
                if (this.selectedImageUri !== '') { Image(this.selectedImageUri).width('100%').height('100%').objectFit(ImageFit.Cover).borderRadius(12) } else { Column({ space: 10 }) { Text("📸").fontSize(32); Text("点击上传商品图片").fontColor('#999999').fontSize(14) }.justifyContent(FlexAlign.Center) }
              }.width('100%').height(160).backgroundColor('#F9F9F9').borderRadius(12).border({ width: 1, color: '#EBEBEB', style: BorderStyle.Dashed }).onClick(() => this.selectImage())
              TextInput({ placeholder: '商品名称 (如: 高效复合肥)...', text: this.newTitle }).onChange(v => this.newTitle = v).width('100%').height(55).backgroundColor('#F9F9F9').borderRadius(12)
              TextInput({ placeholder: '商品价格 (元)...', text: this.newPrice }).onChange(v => this.newPrice = v).width('100%').height(55).backgroundColor('#F9F9F9').borderRadius(12).type(InputType.Number)
              TextArea({ placeholder: '详细介绍一下这件商品吧...', text: this.newContent }).onChange(v => this.newContent = v).width('100%').height(120).backgroundColor('#F9F9F9').borderRadius(12)
            }.padding(20).backgroundColor('#FFFFFF').borderRadius(15).width('95%').shadow({ radius: 10, color: 'rgba(0,0,0,0.03)', offsetY: 4 })
          }

          Button("立 即 发 布").width('85%').height(55).fontSize(18).fontWeight(FontWeight.Bold).backgroundColor('#0D9FFB').borderRadius(27.5).margin({ top: 20, bottom: 40 }).shadow({ radius: 12, color: 'rgba(13, 159, 251, 0.4)', offsetY: 6 }).onClick(() => { this.publishAction(); })
        }.width('100%').margin({ top: 15 })
      }.layoutWeight(1).width('100%')
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}