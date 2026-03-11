// entry/src/main/ets/pages/my_favorite.ets
import { router } from '@kit.ArkUI';

export class FavoriteItem {
  title: string = '';
  type: string = '';
}

@Entry
@Component
struct MyFavoritePage {
  // 🌟 核心：使用 StorageLink 动态绑定全局收藏夹
  @StorageLink('MyFavorites') favorites: FavoriteItem[] = [];

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
                  .onClick(() => {
                    // 点击取消收藏时，同步更新全局数据池
                    this.favorites = this.favorites.filter(f => f.title !== item.title);
                  })
              }.padding(18).backgroundColor('#FFFFFF').borderRadius(12).width('100%')
              .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetX: 0, offsetY: 4 })
            }
          })
        }.width('95%').padding({ top: 15, bottom: 20 }).layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}