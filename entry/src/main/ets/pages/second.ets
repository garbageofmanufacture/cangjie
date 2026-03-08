// src/main/ets/pages/second.ets
import { router } from '@kit.ArkUI';
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

// 🌟 导入你的独立业务组件
import { ForumView } from '../views/ForumView';
import { PublishView } from '../views/PublishView';
import { FarmCalendarView } from '../views/FarmCalendarView';

//导航
@Entry
@Component
struct ForumHome {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  // 🌟 新增：用户角色状态 (0:普通, 1:管理员)
  @State userRole: number = 0;

  async aboutToAppear() {
    // 🌟 页面加载时，读取当前登录用户的角色
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');
    this.userRole = pref.getSync('logged_in_user_role', 0) as number;
  }

  build() {
    Column() {
      // 1. 顶部公共导航栏
      Row() {
        Text("知农论坛").fontSize(22).fontWeight(FontWeight.Bold).fontColor('#0D9FFB')
        Blank()
        Row({ space: 5 }) {
          // 🌟 动态显示：如果是管理员显示盾牌，否则显示头像
          Text(this.userRole === 1 ? "🛡️ 管理员" : "👤 我的")
            .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#333333')
        }
        .padding(10)
        .onClick(() => {
          // 🌟 核心：跳转时把角色权限传给 profile 个人中心页面！
          router.pushUrl({
            url: 'pages/profile',
            params: {
              roleStr: this.userRole.toString()
            }
          });
        })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor('#FFFFFF')

      // 2. 核心容器：Tabs
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.tabsController }) {

        // Tab 1: 论坛首页 (直接使用封装好的组件)
        TabContent() {
          ForumView()
        }.tabBar(this.buildBottomNavItem("农事帖子", 0, $r('app.media.startIcon')))

        // Tab 2: 问答板块 (原有的 Cangjie 混合组件)
        TabContent() {
          CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "expert_qa" }).width('100%').height('100%')
        }.tabBar(this.buildBottomNavItem("专家问答", 1, $r('app.media.startIcon')))

        // Tab 3: 发布页
        TabContent() {
          PublishView({ controller: this.tabsController })
        }.tabBar(this.buildCenterPublishItem(2))

        // Tab 4: 🌟 农事日历 (替换为带有 AI 的全新混合组件)
        TabContent() {
          FarmCalendarView()
        }.tabBar(this.buildBottomNavItem("农事日历", 3, $r('app.media.startIcon')))

        // Tab 5: 商城
        TabContent() {
          CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "farm_mall" }).width('100%').height('100%')
        }.tabBar(this.buildBottomNavItem("农事商城", 4, $r('app.media.startIcon')))
      }
      .barHeight(65) // 🌟 确保底部导航栏高度正确，防止之前遇到的白屏问题
      .onChange((index: number) => { this.currentIndex = index; })
      .scrollable(false).layoutWeight(1).width('100%').backgroundColor('#FFFFFF')
    }.width('100%').height('100%')
  }

  @Builder buildBottomNavItem(text: string, targetIndex: number, icon: Resource) {
    Column({ space: 4 }) {
      Image(icon).width(24).height(24).fillColor(this.currentIndex === targetIndex ? '#0D9FFB' : '#8A8A8A')
      Text(text).fontSize(12).fontColor(this.currentIndex === targetIndex ? '#0D9FFB' : '#8A8A8A')
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%') // 撑满高度
  }

  @Builder buildCenterPublishItem(targetIndex: number) {
    Column() { Text("+").fontSize(32).fontColor('#FFFFFF') }
    .justifyContent(FlexAlign.Center)
    .width(45).height(45).backgroundColor('#0D9FFB').borderRadius(22.5)
  }
}