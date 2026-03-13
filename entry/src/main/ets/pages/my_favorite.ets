// entry/src/main/ets/pages/my_favorites.ets
import { router, promptAction } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

export class FavoriteItem {
  title: string = '';
  type: string = '';
  time: string = '';
}

@Entry
@Component
struct MyFavoritesPage {
  @State favList: FavoriteItem[] = [];

  aboutToAppear() {
    this.loadMyFavoritesFromDB();
  }

  async cancelFavorite(targetTitle: string) {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    let currentUserId = AppStorage.get<string>('currentUserId');
    if (!currentUserId || currentUserId === '') return;

    try {
      let predicates = new relationalStore.RdbPredicates("Favorite");
      predicates.equalTo("user_id", currentUserId).and().equalTo("title", targetTitle);
      let rows = await store.delete(predicates);
      if (rows > 0) {
        promptAction.showToast({ message: '已取消收藏' });
        this.loadMyFavoritesFromDB();
      }
    } catch (e) { promptAction.showToast({ message: '操作失败' }); }
  }

  async loadMyFavoritesFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    let currentUserId = AppStorage.get<string>('currentUserId');
    if (!currentUserId || currentUserId === '') { this.favList = []; return; }

    try {
      let predicates = new relationalStore.RdbPredicates("Favorite");
      predicates.equalTo("user_id", currentUserId);
      predicates.orderByDesc("created_at");
      let rs = await store.query(predicates);
      let temp: FavoriteItem[] = [];
      while (rs.goToNextRow()) {
        temp.push({
          title: rs.getString(rs.getColumnIndex("title")) || '未知内容',
          type: rs.getString(rs.getColumnIndex("type")) || '农事帖子',
          time: '已收藏'
        });
      }
      rs.close();
      this.favList = temp;
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').padding(15).onClick(() => { try{ router.back() }catch(e){} })
        Text("我的收藏").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      if (this.favList.length === 0) {
        Column() {
          Text("📭").fontSize(50).margin({ bottom: 15 })
          Text("您还没有收藏任何内容").fontColor('#999999').fontSize(16)
        }.width('100%').margin({ top: 150 }).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 15 }) {
          ForEach(this.favList, (item: FavoriteItem, index: number) => {
            ListItem() {
              Column() {
                // 🌟 核心新增：把点击跳转事件绑定在“标题栏”上，防止和下面的取消按钮冲突
                Row() {
                  Text(`[${item.type}]`).fontSize(14).fontColor('#FF6600').margin({ right: 8 })
                  Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                }.width('100%').margin({ bottom: 10 })
                .onClick(() => {
                  // 智能判断：如果是商品，跳商品详情页；否则跳帖子详情页
                  if (item.type === '农资商品') {
                    router.pushUrl({ url: 'pages/product_detail', params: { name: item.title } });
                  } else {
                    router.pushUrl({ url: 'pages/post_detail', params: { title: item.title } });
                  }
                })

                Row() {
                  Text(item.time).fontSize(12).fontColor('#999999')
                  Blank()
                  Text("取消收藏").fontSize(12).fontColor('#FF4D4F').border({ width: 1, color: '#FF4D4F'}).borderRadius(10).padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .onClick(() => { this.cancelFavorite(item.title); })
                }.width('100%')
              }.padding(15).backgroundColor('#FFFFFF').borderRadius(12).width('100%').shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 3 })
            }
          }, (item: FavoriteItem, index: number) => item.title + index)
        }.width('95%').padding({ top: 15, bottom: 20 }).layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}