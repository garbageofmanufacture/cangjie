// entry/src/main/ets/views/ExpertQAView.ets
import { router } from '@kit.ArkUI';

export class QAModel {
  q: string = '';
  a: string = '';
}

@Component
export struct ExpertQAView {
  @StorageLink('DemoQAs') qaList: QAModel[] = [
    { q: '小麦叶片发黄是怎么回事？', a: '可能是缺氮或红蜘蛛危害，建议检查叶背并补施尿素。' },
    { q: '现在能种大棚西瓜吗？', a: '立春已过，温度回升，可以开始育苗，注意夜间保温。' },
    { q: '水稻条纹叶枯病如何防治？', a: '该病主要靠灰飞虱传播，建议在分蘖期喷施吡虫啉，同时加强水肥管理。' }
  ];

  build() {
    Column() {
      Text('农业专家在线解答').fontSize(22).fontWeight(FontWeight.Bold).margin({ bottom: 20, top: 20 })
      Scroll() {
        Column() {
          ForEach(this.qaList, (item: QAModel, index: number) => {
            Column() {
              Row() {
                Text('问').fontColor('#FFFFFFFF').backgroundColor('#FF4CAF50')
                  .width(20).height(20).textAlign(TextAlign.Center).borderRadius(4).margin({ right: 10 })
                Text(item.q).fontSize(17).fontWeight(FontWeight.Bold).layoutWeight(1)
              }.width('100%').margin({ bottom: 12 })

              Row() {
                Text('答').fontColor('#FFFFFFFF').backgroundColor('#FF0D9FFB')
                  .width(20).height(20).textAlign(TextAlign.Center).borderRadius(4).margin({ right: 10 })
                Text(item.a).fontSize(15).fontColor('#FF666666').layoutWeight(1)
              }.width('100%')
            }
            .padding(18).backgroundColor('#FFFFFFFF').borderRadius(15).margin({ bottom: 15 })
            .onClick(() => {
              AppStorage.setOrCreate('QADetailQ', item.q);
              AppStorage.setOrCreate('QADetailA', item.a);
              router.pushUrl({ url: 'pages/qa_detail' });
            })
          }, (item: QAModel) => item.q)
        }.padding({ left: 15, right: 15 })
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}
