import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ProductDetail {
  // 🌟 1. 定义状态变量
  @State productName: string = '';
  @State productPrice: number | string = 0;
  @State productDesc: string = '';
  @State sellerName: string = '';
  // 🌟 新增：专门用来接收图片的变量（兼容本地沙盒路径和 Resource 资源）
  @State productImage: string | Resource = '';

  aboutToAppear() {
    // 🌟 2. 核心修复：安全获取路由参数，并加入多重保底机制！
    try {
      let params = router.getParams() as Record<string, string | number | Resource>;
      if (params) {
        this.productName = (params['name'] || params['title'] || '未知农产品') as string;
        this.productPrice = (params['price'] || '面议') as string | number;
        this.productDesc = (params['desc'] || params['description'] || params['content'] || '暂无商品详细介绍') as string;
        this.sellerName = (params['seller'] || params['author'] || '热心农友') as string;

        // 🌟 新增：接住从上一个页面传过来的图片地址
        if (params['imageUrl'] || params['image_url']) {
          this.productImage = (params['imageUrl'] || params['image_url']) as string | Resource;
        }
      } else {
        // 兜底测试数据
        this.productName = '优质测试商品（未收到传参）';
        this.productPrice = '99.00';
        this.productDesc = '这是一段兜底的商品介绍。如果您在真实环境看到这段话，说明从上一个页面跳转（router.pushUrl）时，没有把具体的商品参数传递过来。';
      }
    } catch (e) {
      this.productName = '数据加载异常';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').padding(15).onClick(() => { try { router.back(); } catch (e) {} })
        Text("商品详情").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      Scroll() {
        Column() {

          // 🌟🌟🌟 新增：高颜值商品大图展示区！
          // 只有当 productImage 有值的时候才会渲染，没有图片时自动隐藏
          if (this.productImage !== '') {
            Image(this.productImage)
              .width('92%')
              .height(280) // 腾出 280 的高度放主图
              .borderRadius(15)
              .margin({ top: 15, bottom: 5 })
              .objectFit(ImageFit.Cover) // 保证图片不变形
              .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 5 })
          }

          // 商品主信息卡片
          Column() {
            Text(this.productName)
              .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#333333')
              .width('100%').margin({ bottom: 15 }).textAlign(TextAlign.Start)

            Row() {
              Text("¥ ").fontSize(18).fontColor('#FF4D4F').fontWeight(FontWeight.Bold)
              Text(this.productPrice.toString()).fontSize(32).fontColor('#FF4D4F').fontWeight(FontWeight.Bold)
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text("卖家: " + this.sellerName).fontSize(14).fontColor('#999999')
            }.width('100%')

          }.width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 15 })

          // 商品介绍卡片
          Column() {
            Text("商品介绍").fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333').width('100%').margin({ bottom: 15 })
            Divider().color('#F0F0F0').margin({ bottom: 15 })
            Text(this.productDesc)
              .fontSize(16).fontColor('#666666').lineHeight(28).width('100%').textAlign(TextAlign.Start)
          }.width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 15, bottom: 30 })

          // 互动按钮区
          Row({ space: 20 }) {
            Button("👍 感兴趣")
              .backgroundColor('#F9F9F9')
              .fontColor('#333333')
              .border({ width: 1, color: '#E0E0E0' })
              .onClick(() => { promptAction.showToast({ message: '已标记为感兴趣，将增加此类推荐' }) })

            Button("👎 不感兴趣")
              .backgroundColor('#F9F9F9')
              .fontColor('#333333')
              .border({ width: 1, color: '#E0E0E0' })
              .onClick(() => { promptAction.showToast({ message: '将减少此类推荐' }) })
          }.margin({ bottom: 30 })

          // 联系卖家大按钮
          Button("📞 联系卖家")
            .width('90%').height(50).fontSize(18).backgroundColor('#0D9FFB').borderRadius(25)
            .onClick(() => { promptAction.showToast({ message: `正在为您联系卖家：${this.sellerName}` }) })

        }.width('100%')
      }.layoutWeight(1).width('100%')

    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}