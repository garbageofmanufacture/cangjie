// entry/src/main/ets/pages/second.ets
import { router } from '@kit.ArkUI';
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { ForumView } from '../views/ForumView';
import { ExpertQAView } from '../views/ExpertQAView';
import { FarmMallView } from '../views/FarmMallView';
import { PublishView } from '../views/PublishView';
import { FarmCalendarView } from '../views/FarmCalendarView';

@Entry
@Component
struct ForumHome {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  switchAndSetType(type: string): void {
    AppStorage.setOrCreate('currentPublishType', type);
    this.tabsController.changeIndex(2);
  }

  handlePublishClick(): void {
    ActionSheet.show({
      title: '选择发布类型',
      message: '请选择您要分享的内容分类',
      autoCancel: true,
      confirm: { value: '取消', action: () => { console.info('取消发布'); } },
      sheets: [
        { title: '📝 发布农事帖子', action: () => { this.switchAndSetType('post'); } },
        { title: '❓ 发布专家问答', action: () => { this.switchAndSetType('qa'); } },
        { title: '📦 发布农资商品', action: () => { this.switchAndSetType('product'); } }
      ]
    });
  }

  build() {
    Column() {
      // 1. 顶部公共导航栏
      Row() {
        Text("知农论坛").fontSize(22).fontWeight(FontWeight.Bold).fontColor('#0D9FFB')
        Blank()
        Text("👤 我的").fontSize(18).fontWeight(FontWeight.Medium).fontColor('#333333')
          .padding(10)
          .onClick(() => {
            router.pushUrl({ url: 'pages/profile' }).catch((err: Error) => {
              console.error("跳转失败", JSON.stringify(err));
            });
          })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor('#FFFFFF')

      // 2. 核心容器：Tabs
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.tabsController }) {
        TabContent() { ForumView() }.tabBar(this.buildBottomNavItem("农事帖子", 0, $r('app.media.startIcon')))

        TabContent() { ExpertQAView() }.tabBar(this.buildBottomNavItem("专家问答", 1, $r('app.media.startIcon')))

        TabContent() { PublishView({ controller: this.tabsController }) }.tabBar(this.buildCenterPublishItem())

        TabContent() { FarmCalendarView() }.tabBar(this.buildBottomNavItem("农事日历", 3, $r('app.media.startIcon')))

        TabContent() { FarmMallView() }.tabBar(this.buildBottomNavItem("农事商城", 4, $r('app.media.startIcon')))
      }
      .barHeight(65)
      .onChange((index: number) => { this.currentIndex = index; })
      .scrollable(false).layoutWeight(1).width('100%').backgroundColor('#FFFFFF')
    }.width('100%').height('100%')
  }

  @Builder buildBottomNavItem(text: string, targetIndex: number, icon: Resource) {
    Column({ space: 4 }) {
      Image(icon).width(24).height(24).fillColor(this.currentIndex === targetIndex ? '#0D9FFB' : '#8A8A8A')
      Text(text).fontSize(12).fontColor(this.currentIndex === targetIndex ? '#0D9FFB' : '#8A8A8A')
    }
    .justifyContent(FlexAlign.Center).width('100%').height('100%')
  }

  @Builder buildCenterPublishItem() {
    Column() { Text("+").fontSize(32).fontColor('#FFFFFF') }
    .justifyContent(FlexAlign.Center).width(45).height(45).backgroundColor('#0D9FFB').borderRadius(22.5)
    .onClick(() => { this.handlePublishClick(); })
  }
}
