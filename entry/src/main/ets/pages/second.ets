// src/main/ets/pages/second.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';
import { promptAction, router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

// 定义帖子数据结构
class PostItem {
  id: number = 0; // 增加 ID 方便删除
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

  // 🌟 1. 新增：用户角色状态 (0:普通, 1:管理员)
  @State userRole: number = 0;

  async aboutToAppear() {
    // 读取当前登录用户的角色
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');
    this.userRole = pref.getSync('logged_in_user_role', 0) as number;

    await this.loadPostsFromDB();
  }

  // 1. 查库逻辑
  async loadPostsFromDB() {
    let store = DatabaseHelper.getStore();
    if (!store) return;

    try {
      let predicates = new relationalStore.RdbPredicates("Post");
      predicates.orderByDesc("created_at");
      let resultSet = await store.query(predicates);
      let dataStr = "";

      while (resultSet.goToNextRow()) {
        // 读取数据库原始数据，增加 ID 字段读取
        let id = resultSet.getLong(resultSet.getColumnIndex("id"));
        let title = resultSet.getString(resultSet.getColumnIndex("title")) || "无标题";
        let author = resultSet.getString(resultSet.getColumnIndex("author_id")) || "匿名";
        let content = resultSet.getString(resultSet.getColumnIndex("content")) || "无内容";

        // 组装结构：ID|标题|作者|时间|内容 (注意解析函数也要对应修改)
        dataStr += `${id}|${title}|${author}|03-07|${content}^`;
      }
      resultSet.close();

      if (dataStr.length > 0) {
        this.dbPostsData = dataStr.substring(0, dataStr.length - 1);
      } else {
        this.dbPostsData = ""; // 显式清空防止残留
      }
    } catch (err) {
      console.error("读取数据库失败");
    }
  }

  // 2. 修正后的发布逻辑：先保存值，再清空 UI，最后存库
  async publishPost() {
    if (this.newTitle.trim() === '' || this.newContent.trim() === '') {
      promptAction.showToast({ message: '标题和内容不能为空' });
      return;
    }

    // 🌟 核心修复：先暂存要发布的内容，防止清空逻辑导致写入数据库为空字符串
    const titleToSave = this.newTitle;
    const contentToSave = this.newContent;

    // 内存秒拼显示 (ID 暂时给个临时值 0)
    let newPostStr = `0|${titleToSave}|热心农友|03-07|${contentToSave}`;
    this.dbPostsData = this.dbPostsData ? (newPostStr + "^" + this.dbPostsData) : newPostStr;

    promptAction.showToast({ message: '发布成功！' });

    // 现在可以安全地清空 UI 了
    this.newTitle = "";
    this.newContent = "";
    this.currentIndex = 0;
    this.tabsController.changeIndex(0);

    // 后台存库
    let store = DatabaseHelper.getStore();
    if (store) {
      try {
        let values: relationalStore.ValuesBucket = {
          "author_id": "热心农友",
          "title": titleToSave,
          "content": contentToSave
        };
        await store.insert("Post", values);
        // 重新从数据库刷一遍以获取真实的 ID
        await this.loadPostsFromDB();
      } catch(e) {
        console.error("存库失败: " + JSON.stringify(e));
      }
    }
  }

  // 🌟 3. 新增：管理员删除功能
  async deletePost(id: number) {
    let store = DatabaseHelper.getStore();
    if (!store) return;
    try {
      let predicates = new relationalStore.RdbPredicates("Post");
      predicates.equalTo("id", id);
      await store.delete(predicates);
      promptAction.showToast({ message: '管理员已删除该帖' });
      await this.loadPostsFromDB(); // 刷新列表
    } catch (err) {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  // 4. 解析字符串工具函数 (适配增加 ID 后的 5 段结构)
  getParsedPosts(): PostItem[] {
    let list: PostItem[] = [];
    if (!this.dbPostsData) return list;
    let posts = this.dbPostsData.split("^");
    for (let p of posts) {
      if (!p) continue;
      let parts = p.split("|");
      // 这里的结构变为：ID|标题|作者|时间|内容 (长度需为 5)
      if (parts.length >= 5) {
        list.push({
          id: Number(parts[0]),
          title: parts[1],
          author: parts[2],
          time: parts[3],
          content: parts[4]
        });
      }
    }
    return list;
  }

  // 5. 增强版卡片 UI：增加管理员长按删除
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
    // 🌟 管理员特权：长按卡片弹出删除确认
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (this.userRole === 1) { // 仅 admin 响应
            AlertDialog.show({
              title: '管理员管理',
              message: '确定要删除这条违规帖子吗？',
              primaryButton: { value: '取消', action: () => {} },
              secondaryButton: { value: '删除', fontColor: '#FF4D4F', action: () => this.deletePost(item.id) }
            })
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