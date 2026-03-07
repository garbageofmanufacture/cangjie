// src/main/ets/pages/second.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';
import { promptAction, router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

// 🌟 数据结构：包含帖子 ID，用于精准删除
class PostItem {
  id: number = 0;
  title: string = '';
  author: string = '';
  time: string = '';
  content: string = '';
}

@Entry
@Component
struct ForumHome {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  @State dbPostsData: string = "";
  @State newTitle: string = "";
  @State newContent: string = "";

  // 🌟 管理员角色状态 (0:普通, 1:管理员)
  @State userRole: number = 0;

  async aboutToAppear() {
    // 1. 读取当前登录用户的角色
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');
    this.userRole = pref.getSync('logged_in_user_role', 0) as number;

    // 2. 加载数据
    await this.loadPostsFromDB();
  }

  // 🌟 ArkTS 原生通用删除弹窗
  confirmDelete(tableName: string, id: number) {
    AlertDialog.show({
      title: '🛡️ 管理员特权',
      message: '确定要永久删除这条违规帖子吗？操作不可恢复。',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '确认删除',
        fontColor: '#FF4D4F',
        action: () => {
          this.deleteDataFromDB(tableName, id);
        }
      }
    })
  }

  // 🌟 ArkTS 原生物理删除方法
  async deleteDataFromDB(tableName: string, id: number) {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    try {
      let predicates = new relationalStore.RdbPredicates(tableName);
      predicates.equalTo("id", id);
      await store.delete(predicates);
      promptAction.showToast({ message: '管理员已执行删除' });
      // 删完后重新查库刷新列表
      await this.loadPostsFromDB();
    } catch (err) {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  // 查库逻辑
  async loadPostsFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    try {
      let predicates = new relationalStore.RdbPredicates("Post");
      predicates.orderByDesc("created_at");
      let resultSet = await store.query(predicates);
      let dataStr = "";
      while (resultSet.goToNextRow()) {
        let id = resultSet.getLong(resultSet.getColumnIndex("id"));
        let title = resultSet.getString(resultSet.getColumnIndex("title")) || "无标题";
        let author = resultSet.getString(resultSet.getColumnIndex("author_id")) || "匿名";
        let content = resultSet.getString(resultSet.getColumnIndex("content")) || "无内容";
        // 注意拼接格式加入了 id
        dataStr += `${id}|${title}|${author}|03-07|${content}^`;
      }
      resultSet.close();
      this.dbPostsData = dataStr.length > 0 ? dataStr.substring(0, dataStr.length - 1) : "";
    } catch (err) { console.error("读取数据库失败"); }
  }

  // 发布逻辑
  async publishPost() {
    if (this.newTitle.trim() === '' || this.newContent.trim() === '') {
      promptAction.showToast({ message: '标题和内容不能为空' });
      return;
    }
    const titleToSave = this.newTitle;
    const contentToSave = this.newContent;

    // 内存预填充显示 (临时 ID 给 0)
    let newPostStr = `0|${titleToSave}|热心农友|03-07|${contentToSave}`;
    this.dbPostsData = this.dbPostsData ? (newPostStr + "^" + this.dbPostsData) : newPostStr;

    promptAction.showToast({ message: '发布成功！' });
    this.newTitle = "";
    this.newContent = "";
    this.currentIndex = 0;
    this.tabsController.changeIndex(0);

    // 实际存库逻辑
    let store = DatabaseHelper.getStore();
    if (store) {
      try {
        await store.insert("Post", { "author_id": "热心农友", "title": titleToSave, "content": contentToSave });
        // 存库成功后刷新获取真实 ID
        await this.loadPostsFromDB();
      } catch(e) { console.error("存库失败"); }
    }
  }

  // 解析数据字符串
  getParsedPosts(): PostItem[] {
    let list: PostItem[] = [];
    if (!this.dbPostsData) return list;
    let posts = this.dbPostsData.split("^");
    for (let p of posts) {
      if (!p) continue;
      let parts = p.split("|");
      if (parts.length >= 5) {
        list.push({ id: Number(parts[0]), title: parts[1], author: parts[2], time: parts[3], content: parts[4] });
      }
    }
    return list;
  }

  // 🌟 帖子卡片 UI 组件
  @Builder PostCard(item: PostItem, bannerColor: string) {
    Column() {
      Row().width('100%').height(100).backgroundColor(bannerColor)
      Column() {
        Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ bottom: 5 })
        Text(item.content).fontSize(13).fontColor('#666666').margin({ bottom: 8 }).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.author + " | " + item.time).fontSize(11).fontColor('#999999')
      }.alignItems(HorizontalAlign.Start).padding(10).width('100%')
    }
    .backgroundColor('#FFFFFF').borderRadius(10).clip(true).margin({ bottom: 10 }).width('100%')
    // 🌟 纯 ArkTS 原生的长按删除，彻底告别报错！
    .gesture(
      LongPressGesture()
        .onAction(() => {
          // 如果是管理员，直接调用 ArkTS 的方法
          if (this.userRole === 1) {
            this.confirmDelete("Post", item.id);
          }
        })
    )
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text("知农论坛").fontSize(22).fontWeight(FontWeight.Bold).fontColor('#0D9FFB')
        Blank()
        Row({ space: 5 }) {
          Text(this.userRole === 1 ? "🛡️ 管理员" : "👤 我的").fontSize(18).fontWeight(FontWeight.Medium).fontColor('#333333')
        }
        .padding(10)
        .onClick(() => { router.pushUrl({ url: 'pages/profile' }); })
      }
      .width('100%').height(50).padding({ left: 15, right: 15 }).backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#F0F0F0' })

      Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.tabsController }) {
        // Tab 1: 帖子列表
        TabContent() {
          Column() {
            Text("农业论坛 · 帖子列表").fontSize(24).fontWeight(FontWeight.Bold).width('100%').margin({ top: 15, bottom: 15 }).textAlign(TextAlign.Center)
            Scroll() {
              Row() {
                Column() {
                  ForEach(this.getParsedPosts().filter((_, i) => i % 2 === 0), (item: PostItem) => { this.PostCard(item, '#87CEEB') })
                }.width('50%').padding({ right: 5 }).justifyContent(FlexAlign.Start)
                Column() {
                  ForEach(this.getParsedPosts().filter((_, i) => i % 2 === 1), (item: PostItem) => { this.PostCard(item, '#98FB98') })
                }.width('50%').padding({ left: 5 }).justifyContent(FlexAlign.Start)
              }.width('100%').alignItems(VerticalAlign.Top)
            }.layoutWeight(1).padding({ left: 10, right: 10, bottom: 10 }).scrollBar(BarState.Off)
          }.width('100%').height('100%').backgroundColor('#F5F5F5')
        }.tabBar(this.buildBottomNavItem("帖子", 0, $r('app.media.startIcon')))

        // 问答板块 (去掉 parameter 传参防止仓颉报错)
        TabContent() { CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "expert_qa" }).width('100%').height('100%') }
        .tabBar(this.buildBottomNavItem("问答", 1, $r('app.media.startIcon')))

        // Tab 3: 发布
        TabContent() {
          Column() {
            Text("发布新帖子").fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 30, bottom: 20 })
            TextInput({ placeholder: '请输入标题', text: this.newTitle }).onChange((v) => this.newTitle = v).width('90%').height(50).margin({ bottom: 20 }).backgroundColor('#FFFFFF')
            TextArea({ placeholder: '请输入正文', text: this.newContent }).onChange((v) => this.newContent = v).width('90%').height(200).margin({ bottom: 30 }).backgroundColor('#FFFFFF')
            Button("立即发布").width('80%').height(50).fontSize(20).fontWeight(FontWeight.Bold).backgroundColor('#0D9FFB').onClick(() => { this.publishPost(); })
          }.width('100%').height('100%').backgroundColor('#F5F5F5')
        }.tabBar(this.buildCenterPublishItem(2))

        // 日历和商城板块
        TabContent() { CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "farm_calendar" }).width('100%').height('100%') }.tabBar(this.buildBottomNavItem("日历", 3, $r('app.media.startIcon')))
        TabContent() { CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "farm_mall" }).width('100%').height('100%') }.tabBar(this.buildBottomNavItem("商城", 4, $r('app.media.startIcon')))
      }
      .onChange((index: number) => { this.currentIndex = index; }).scrollable(false).layoutWeight(1).width('100%').backgroundColor('#FFFFFF')
    }.width('100%').height('100%')
  }

  @Builder buildBottomNavItem(text: string, targetIndex: number, icon: Resource) {
    Column({ space: 4 }) {
      Image(icon).width(24).height(24).fillColor(this.currentIndex === targetIndex ? '#0D9FFB' : '#8A8A8A')
      Text(text).fontSize(12).fontColor(this.currentIndex === targetIndex ? '#0D9FFB' : '#8A8A8A')
    }.justifyContent(FlexAlign.Center).width('100%')
  }

  @Builder buildCenterPublishItem(targetIndex: number) {
    Column() { Text("+").fontSize(32).fontColor('#FFFFFF') }.justifyContent(FlexAlign.Center).width(45).height(45).backgroundColor('#0D9FFB').borderRadius(22.5)
  }
}