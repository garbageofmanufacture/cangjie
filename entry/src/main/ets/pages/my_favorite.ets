// entry/src/main/ets/pages/my_favorite.ets
import { router, promptAction } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';

export class FavoriteItem {
  title: string = '';
  type: string = '';
}

@Entry
@Component
struct MyFavoritePage {
  @State favorites: FavoriteItem[] = [];

  onPageShow() {
    this.loadFavoritesFromDB();
  }

  // 🌟 从底层的 SQLite 取数据，彻底解决消失问题
  async loadFavoritesFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    try {
      let predicates = new relationalStore.RdbPredicates("Favorite");
      predicates.orderByDesc("created_at");
      let rs = await store.query(predicates);
      let temp: FavoriteItem[] = [];

      while(rs.goToNextRow()) {
        temp.push({
          title: rs.getString(rs.getColumnIndex("title")) || '未知帖子',
          type: rs.getString(rs.getColumnIndex("type")) || '未知来源'
        });
      }
      rs.close();
      this.favorites = temp;
    } catch(e) {}
  }

  // 🌟 删除也直接操作数据库
  async removeFavorite(title: string) {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    try {
      let predicates = new relationalStore.RdbPredicates("Favorite");
      predicates.equalTo("title", title);
      await store.delete(predicates);
      promptAction.showToast({ message: '已取消收藏' });
      this.loadFavoritesFromDB(); // 刷新列表
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').onClick(() => { try{ router.back() }catch(e){} })
        Blank()
        Text("我的收藏").fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text("        ").fontSize(18)
      }.width('100%').padding(15).backgroundColor('#FFFFFF')

      if (this.favorites.length === 0) {
        Column() {
          Text("⭐").fontSize(50).margin({ bottom: 15 })
          Text("您还没有收藏任何内容").fontColor('#999999').fontSize(16)
        }.width('100%').margin({ top: 150 }).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 15 }) {
          ForEach(this.favorites, (item: FavoriteItem) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ bottom: 8 })
                  Text("来源: " + item.type).fontSize(12).fontColor('#999999')
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                Text("取消收藏").fontSize(14).fontColor('#FF4D4F')
                  .onClick(() => { this.removeFavorite(item.title); })
              }.padding(18).backgroundColor('#FFFFFF').borderRadius(12).width('100%').shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetX: 0, offsetY: 4 })
            }
          })
        }.width('95%').padding({ top: 15, bottom: 20 }).layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}