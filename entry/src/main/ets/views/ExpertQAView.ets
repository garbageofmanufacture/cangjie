// entry/src/main/ets/views/ExpertQAView.ets
import { router, promptAction } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

export class QAModel {
  id: number = 0;
  q: string = '';
  a: string = '';
}

@CustomDialog
export struct AnswerDialog {
  controller?: CustomDialogController
  questionText: string = ''
  questionId: number = 0
  @State answerText: string = ''
  confirmAction: (id: number, answer: string) => void = () => {}

  build() {
    Column() {
      Text("专家解答").fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
      Text(this.questionText).fontSize(14).fontColor('#666666').margin({ bottom: 15 }).width('100%').maxLines(2).textOverflow({overflow: TextOverflow.Ellipsis})
      TextArea({ placeholder: '请输入您的专业解答...', text: this.answerText }).onChange((v) => { this.answerText = v }).height(120).width('100%').backgroundColor('#F5F5F5').margin({ bottom: 20 })
      Row() {
        Button("取消").backgroundColor(Color.Transparent).fontColor('#999999').onClick(() => { this.controller?.close() })
        Blank()
        Button("提交解答").backgroundColor('#0D9FFB').onClick(() => {
          if (this.answerText.trim() === '') { promptAction.showToast({ message: '解答内容不能为空' }); return; }
          this.confirmAction(this.questionId, this.answerText);
          this.controller?.close();
        })
      }.width('100%')
    }.padding(20).backgroundColor('#FFFFFF').borderRadius(16).width('90%')
  }
}

@Component
export struct ExpertQAView {
  @State qaList: QAModel[] = [];
  @State searchText: string = '';
  @StorageLink('isExpert') isExpert: boolean = false;

  @State currentAnswerId: number = 0;
  @State currentAnswerText: string = '';

  answerDialogController: CustomDialogController = new CustomDialogController({
    builder: AnswerDialog({
      questionId: this.currentAnswerId,
      questionText: this.currentAnswerText,
      confirmAction: (id: number, answer: string) => { this.submitAnswerToDB(id, answer); }
    }),
    alignment: DialogAlignment.Center, customStyle: true
  })

  @StorageProp('RefreshQATrigger') @Watch('loadQAsFromDB') refreshTrigger: number = 0;

  aboutToAppear() {
    this.loadQAsFromDB();
  }

  async submitAnswerToDB(id: number, answer: string) {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    try {
      let predicates = new relationalStore.RdbPredicates("ExpertQA");
      predicates.equalTo("id", id);

      let valueBucket: relationalStore.ValuesBucket = { "answer": answer, "status": 1 };
      let rows = await store.update(valueBucket, predicates);

      if (rows > 0) {
        promptAction.showToast({ message: '解答成功，感谢专家的付出！' });
        // 🌟 提交完立刻重查数据库！
        this.loadQAsFromDB();
      }
    } catch(e) {
      promptAction.showToast({ message: '解答失败，请重试' });
    }
  }

  async loadQAsFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) { this.loadFallback(); return; }

    try {
      let predicates = new relationalStore.RdbPredicates("ExpertQA");
      if (this.searchText.trim() !== '') { predicates.like("question", `%${this.searchText.trim()}%`); }
      predicates.orderByDesc("id");
      let rs = await store.query(predicates);

      let temp: QAModel[] = [];
      while (rs.goToNextRow()) {
        temp.push({
          id: rs.getLong(rs.getColumnIndex("id")),
          q: rs.getString(rs.getColumnIndex("question")) || '',
          a: rs.getString(rs.getColumnIndex("answer")) || '您的提问已提交，正在等待农业专家解答...'
        });
      }
      rs.close();

      if (temp.length > 0) {
        this.qaList = temp;
      } else {
        this.qaList = [];
        if (this.searchText === '') { this.loadFallback(); }
      }
    } catch(e) { this.loadFallback(); }
  }

  loadFallback() {
    if (this.searchText !== '') return;
    this.qaList = [
      { id: 0, q: '苹果树春季剪枝需要注意什么？', a: '春季剪枝主要目的是调节树势，促进花芽分化。要注意剪除病虫枝...' }
    ];
  }

  build() {
    Column() {
      Row() {
        Search({ value: this.searchText, placeholder: '搜索专家问答...' })
          .searchButton('搜索').width('100%').height(40).backgroundColor('#FFFFFF').placeholderColor('#999999').textFont({ size: 14 }).borderRadius(20)
          .onChange((value: string) => { this.searchText = value; this.loadQAsFromDB(); })
      }.width('100%').padding({ left: 15, right: 15, top: 15, bottom: 10 })

      if (this.qaList.length === 0 && this.searchText !== '') {
        Column({ space: 10 }) {
          Text("🔍").fontSize(50).margin({ top: 100 })
          Text(`没有找到包含 "${this.searchText}" 的问答`).fontColor('#999999').fontSize(14)
          Text("换个关键词试试吧").fontColor('#CCCCCC').fontSize(12)
        }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 15 }) {
          ForEach(this.qaList, (item: QAModel, index: number) => {
            ListItem() {
              Column({ space: 12 }) {
                Row() {
                  Text("问").fontSize(12).fontColor('#FFFFFF').backgroundColor('#FF6600').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4).margin({ right: 10 })
                  // 限制问题只显示2行
                  Text(item.q).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').layoutWeight(1).maxLines(2).textOverflow({overflow: TextOverflow.Ellipsis})
                }.width('100%').alignItems(VerticalAlign.Top)

                Divider().color('#F0F0F0')

                Row() {
                  Text("答").fontSize(12).fontColor('#FFFFFF').backgroundColor('#0D9FFB').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4).margin({ right: 10 })
                  // 限制答案只显示3行
                  Text(item.a).fontSize(14).fontColor(item.a.includes('等待') ? '#FF9900' : '#666666').lineHeight(22).layoutWeight(1).maxLines(3).textOverflow({overflow: TextOverflow.Ellipsis})

                  if (this.isExpert && item.a.includes('等待')) {
                    Blank()
                    Button("去解答").height(24).fontSize(12).backgroundColor('#FF9900').onClick(() => {
                      this.currentAnswerId = item.id;
                      this.currentAnswerText = item.q;
                      this.answerDialogController.open();
                    })
                  }
                }.width('100%').alignItems(VerticalAlign.Top)
              }
              .padding(18).backgroundColor('#FFFFFF').borderRadius(12)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 3 })
              .onClick(() => {
                // 🌟 所有人都可以在点击卡片时进入详情页查看全貌
                router.pushUrl({
                  url: 'pages/qa_detail',
                  params: { q: item.q, a: item.a }
                });
              })
            }
          },
            // 🌟 终极修复：把 item.a 加入 Key 里！只要专家一回答，这段字变了，组件就会强制瞬间刷新！
            (item: QAModel, index: number) => item.id.toString() + "_" + item.a)
        }.padding({ left: 15, right: 15, bottom: 20 }).layoutWeight(1).width('100%')
      }
    }.width('100%').height('100%').backgroundColor('#F4F4F4')
  }
}