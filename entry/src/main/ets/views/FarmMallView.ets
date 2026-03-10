// entry/src/main/ets/views/FarmMallView.ets
import { router } from '@kit.ArkUI';

export class ProductModel {
  name: string = '';
  price: string = '';
  desc: string = '';
}

@Component
export struct FarmMallView {
  @StorageLink('DemoProducts') productList: ProductModel[] = [
    { name: '井冈霉素A（小麦纹枯病专用）', price: '¥25.8/瓶', desc: '有效成分10%，兑水30kg/亩，安全无残留' },
    { name: '复合肥（氮磷钾15-15-15）', price: '¥120/袋（40kg）', desc: '通用型复合肥，适用于小麦/玉米/蔬菜' },
    { name: '矮壮素（控旺专用）', price: '¥18.5/瓶', desc: '1000倍液喷施，控制作物徒长，增产增收' },
    { name: '磷酸二氢钾（叶面肥）', price: '¥15/袋（500g）', desc: '快速补钾，促进果实膨大，提高抗病性' },
    { name: '芸苔素内酯（植物生长调节剂）', price: '¥28/瓶', desc: '增强作物抗逆性，提高产量和品质' }
  ];

  build() {
    Column() {
      Text('农业论坛 · 农资商城')
        .fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 20, top: 20 })
        .textAlign(TextAlign.Center).fontColor('#FF333333')

      Scroll() {
        Column() {
          ForEach(this.productList, (item: ProductModel, index: number) => {
            Column() {
              Text(item.name).fontSize(18).fontWeight(FontWeight.Bold).width('90%').margin({ bottom: 5 }).textAlign(TextAlign.Start).fontColor('#FF333333')
              Text(item.price).fontSize(16).width('90%').margin({ bottom: 10 }).textAlign(TextAlign.Start).fontColor('#FFFF4081')
              Text(item.desc).fontSize(14).width('90%').fontColor('#FF555555').textAlign(TextAlign.Start)
            }.width('90%').padding(20).backgroundColor('#FFFFFFFF').borderRadius(10).margin({ bottom: 15 })
            .onClick(() => {
              AppStorage.setOrCreate('ProductDetailName', item.name);
              AppStorage.setOrCreate('ProductDetailPrice', item.price);
              AppStorage.setOrCreate('ProductDetailDesc', item.desc);
              router.pushUrl({ url: 'pages/product_detail' });
            })
          }, (item: ProductModel) => item.name)
        }
      }.layoutWeight(1)
    }.height('100%').width('100%').padding({ left: 15, right: 15 }).backgroundColor('#F5F5F5')
  }
}
