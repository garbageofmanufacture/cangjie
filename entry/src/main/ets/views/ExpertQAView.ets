// entry/src/main/ets/views/ExpertQAView.ets
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

export class QAModel {
  q: string = '';
  a: string = '';
}

@Component
export struct ExpertQAView {
  @State qaList: QAModel[] = [];
  // 🌟 1. 新增搜索关键词状态
  @State searchText: string = '';

  aboutToAppear() {
    this.loadQAsFromDB();
  }

  async loadQAsFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) { this.loadFallback(); return; }

    try {
      let predicates = new relationalStore.RdbPredicates("ExpertQA");

      // 🌟 2. 如果输入了搜索词，模糊匹配“问题”字段
      if (this.searchText.trim() !== '') {
        predicates.like("question", `%${this.searchText.trim()}%`);
      }

      predicates.orderByDesc("id");
      let rs = await store.query(predicates);

      let temp: QAModel[] = [];
      while (rs.goToNextRow()) {
        temp.push({
          q: rs.getString(rs.getColumnIndex("question")) || '',
          a: rs.getString(rs.getColumnIndex("answer")) || '您的提问已提交，正在等待农业专家解答...'
        });
      }
      rs.close();

      if (temp.length > 0) {
        this.qaList = temp;
      } else {
        this.qaList = [];
        if (this.searchText === '') {
          this.loadFallback();
        }
      }
    } catch(e) {
      this.loadFallback();
    }
  }

  loadFallback() {
    if (this.searchText !== '') return; // 搜索状态下不加载假数据
    this.qaList = [
      { q: '苹果树春季剪枝需要注意什么？', a: '春季剪枝主要目的是调节树势，促进花芽分化。要注意剪除病虫枝、枯死枝和过密枝...' },
      { q: '水稻潜叶蝇怎么防治？', a: '可以使用氧化乐果或者毒死蜱进行喷雾防治，注意用药安全间隔期。' }
    ];
  }

  build() {
    Column() {
      // 🌟 3. 专家问答界面的搜索框
      Row() {
        Search({ value: this.searchText, placeholder: '搜索专家问答...' })
          .searchButton('搜索')
          .width('100%')
          .height(40)
          .backgroundColor('#FFFFFF')
          .placeholderColor('#999999')
          .textFont({ size: 14 })
          .borderRadius(20)
          .onChange((value: string) => {
            this.searchText = value;
            this.loadQAsFromDB(); // 边打字边查库
          })
      }.width('100%').padding({ left: 15, right: 15, top: 15, bottom: 10 })

      // 🌟 4. 搜索不到内容的空状态提示
      if (this.qaList.length === 0 && this.searchText !== '') {
        Column({ space: 10 }) {
          Text("🔍").fontSize(50).margin({ top: 100 })
          Text(`没有找到包含 "${this.searchText}" 的问答`).fontColor('#999999').fontSize(14)
          Text("换个关键词试试吧").fontColor('#CCCCCC').fontSize(12)
        }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
      } else {
        // 原有列表
        List({ space: 15 }) {
          ForEach(this.qaList, (item: QAModel, index: number) => {
            ListItem() {
              Column({ space: 12 }) {
                Row() {
                  Text("问").fontSize(12).fontColor('#FFFFFF').backgroundColor('#FF6600').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4).margin({ right: 10 })
                  Text(item.q).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').layoutWeight(1)
                }.width('100%').alignItems(VerticalAlign.Top)

                Divider().color('#F0F0F0')

                Row() {
                  Text("答").fontSize(12).fontColor('#FFFFFF').backgroundColor('#0D9FFB').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4).margin({ right: 10 })
                  Text(item.a).fontSize(14).fontColor(item.a.includes('等待') ? '#FF9900' : '#666666').lineHeight(22).layoutWeight(1)
                }.width('100%').alignItems(VerticalAlign.Top)
              }
              .padding(18).backgroundColor('#FFFFFF').borderRadius(12)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 3 })
            }
          }, (item: QAModel, index: number) => index.toString() + item.q)
        }.padding({ left: 15, right: 15, bottom: 20 }).layoutWeight(1).width('100%')
      }
    }.width('100%').height('100%').backgroundColor('#F4F4F4')
  }
}