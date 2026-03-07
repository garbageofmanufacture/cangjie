// src/main/ets/components/PublishTabView.ets
@Component
export struct PublishTabView {
  @Link newTitle: string;
  @Link newContent: string;
  // 暴露发布点击事件给父组件去执行具体的存库逻辑
  onPublishClick: () => void = () => {};

  build() {
    Column() {
      Text("发布新帖子").fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 30, bottom: 20 })
      TextInput({ placeholder: '请输入标题', text: this.newTitle })
        .onChange((v) => this.newTitle = v).width('90%').height(50).margin({ bottom: 20 }).backgroundColor('#FFFFFF')
      TextArea({ placeholder: '请输入正文', text: this.newContent })
        .onChange((v) => this.newContent = v).width('90%').height(200).margin({ bottom: 30 }).backgroundColor('#FFFFFF')
      Button("立即发布").width('80%').height(50).fontSize(20).fontWeight(FontWeight.Bold).backgroundColor('#0D9FFB')
        .onClick(() => { this.onPublishClick(); })
    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}