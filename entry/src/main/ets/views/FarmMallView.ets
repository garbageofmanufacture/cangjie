// entry/src/main/ets/views/FarmMallView.ets
import { router } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

export class ProductModel {
  name: string = '';
  price: string | number = '';
  desc: string = '';
  imageUrl?: string | Resource = '';
}

@Component
export struct FarmMallView {
  @StorageLink('DemoProducts') productList: ProductModel[] = [];

  // 🌟 1. 新增：用来绑定搜索框实时内容的变量
  @State searchText: string = '';

  @StorageProp('RefreshMallTrigger') @Watch('loadRealProductsFromDB') refreshTrigger: number = 0;

  aboutToAppear() {
    this.loadRealProductsFromDB();
  }

  async loadRealProductsFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) { this.loadFallback(); return; }

    try {
      let predicates = new relationalStore.RdbPredicates("Product");

      // 🌟 2. 核心魔法：如果搜索框里有字，就加上 SQLite 的模糊查询（LIKE）
      if (this.searchText.trim() !== '') {
        // `%` 是 SQL 里的通配符，代表前后可以有任意字符，实现完全模糊匹配
        predicates.like("name", `%${this.searchText.trim()}%`);
      }

      predicates.orderByDesc("id");
      let rs = await store.query(predicates);

      let temp: ProductModel[] = [];
      while (rs.goToNextRow()) {
        temp.push({
          name: rs.getString(rs.getColumnIndex("name")) || '未知商品',
          price: rs.getDouble(rs.getColumnIndex("price")) || 0,
          desc: rs.getString(rs.getColumnIndex("description")) || '暂无详细描述',
          imageUrl: rs.getString(rs.getColumnIndex("image_url")) || ''
        });
      }
      rs.close();

      if (temp.length > 0) {
        this.productList = temp;
      } else {
        // 如果搜出来是空的
        this.productList = [];
        if (this.searchText === '') {
          this.loadFallback(); // 只有没在搜索的时候，才展示兜底假数据
        }
      }
    } catch (err) {
      this.loadFallback();
    }
  }

  loadFallback() {
    if (this.searchText !== '') return; // 搜索状态下不加载假数据

    let fallback: ProductModel[] = [
      { name: '井冈霉素A（小麦纹枯病专用）', price: '25.8', desc: '有效成分10%，兑水30kg/亩，安全无残留', imageUrl: $r('app.media.applogo') },
      { name: '复合肥（氮磷钾15-15-15）', price: '120', desc: '通用型复合肥，适用于小麦/玉米/蔬菜', imageUrl: $r('app.media.applogo') }
    ];
    this.productList = fallback;
  }

  build() {
    Column() {
      // 🌟 3. UI 升级：把文字换成高颜值的搜索框组件
      Row() {
        Search({ value: this.searchText, placeholder: '搜索农资商品名称...' })
          .searchButton('搜索')
          .width('100%')
          .height(40)
          .backgroundColor('#FFFFFF') // 白色的搜索框，在浅灰背景上很显眼
          .placeholderColor('#999999')
          .textFont({ size: 14 })
          .borderRadius(20) // 圆角药丸形状，更像大厂 App
          .onChange((value: string) => {
            this.searchText = value;
            // 每次输入变化，立刻触发查库，实现“边打字边出结果”的丝滑体验
            this.loadRealProductsFromDB();
          })
      }.width('100%').padding({ left: 15, right: 15, top: 15, bottom: 10 })

      // 🌟 4. 防御设计：如果正在搜索且没有任何商品，展示一个友好的提示
      if (this.productList.length === 0 && this.searchText !== '') {
        Column({ space: 10 }) {
          Text("🔍").fontSize(50).margin({ top: 100 })
          Text(`没有找到与 "${this.searchText}" 相关的商品`).fontColor('#999999').fontSize(14)
          Text("换个关键词试试吧").fontColor('#CCCCCC').fontSize(12)
        }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)

      } else {
        // 原本完美的瀑布流代码保持不变
        WaterFlow() {
          ForEach(this.productList, (item: ProductModel, index: number) => {
            FlowItem() {
              Column() {
                Image(item.imageUrl ? item.imageUrl : $r('app.media.applogo'))
                  .width('100%')
                  .height(index % 2 === 0 ? 180 : 150)
                  .objectFit(ImageFit.Cover)

                Column() {
                  Text(item.name).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 8 }).textAlign(TextAlign.Start).width('100%')
                  Text(item.desc).fontSize(10).fontColor('#FF6600').backgroundColor('#FFF0E5').padding({ left: 4, right: 4, top: 2, bottom: 2 }).borderRadius(4).margin({ bottom: 8 }).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row() {
                    Text(typeof item.price === 'string' && item.price.includes('¥') ? item.price : `¥${item.price}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FF4D4F')
                    Blank()
                    Text("看相似").fontSize(10).fontColor('#999999').border({ width: 0.5, color: '#CCCCCC' }).borderRadius(10).padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  }.width('100%').alignItems(VerticalAlign.Bottom)
                }.padding(10).alignItems(HorizontalAlign.Start)
              }
              .width('100%').backgroundColor('#FFFFFF').borderRadius(12).clip(true)
              .onClick(() => { router.pushUrl({ url: 'pages/product_detail', params: { name: item.name, price: item.price, desc: item.desc, seller: '农资官方自营店', imageUrl: item.imageUrl } }); })
            }
            .width('100%')
          }, (item: ProductModel, index: number) => item.name + "_" + index.toString() + "_" + (item.imageUrl || "noimg"))
        }
        .columnsTemplate("1fr 1fr")
        .columnsGap(10)
        .rowsGap(10)
        .padding({ left: 10, right: 10, bottom: 20 })
        .layoutWeight(1)
        .width('100%')
      }

    }.height('100%').width('100%').backgroundColor('#F4F4F4')
  }
}