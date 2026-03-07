// src/main/ets/views/ForumView.ets
import { relationalStore, preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI'; // 🌟 引入 promptAction 用于提示
import { DatabaseHelper } from '../utils/DatabaseHelper';

// 假设你已经按照之前的回答把 PostItem 和 PostCardView 抽离了
import { PostItem } from '../models/PostItem';
import { PostCardView } from '../components/PostCardView';

@Component
export struct ForumView {
  @State dbPostsData: string = "";
  @State userRole: number = 0;

  // 🌟 监听发布页面发出的刷新信号
  @StorageProp('refreshForumTrigger') @Watch('onRefreshTriggered') refreshTrigger: number = 0;

  async aboutToAppear() {
    // 获取权限和加载数据的逻辑全在这里闭环
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');
    this.userRole = pref.getSync('logged_in_user_role', 0) as number;
    await this.loadPostsFromDB();
  }

  onRefreshTriggered() {
    // 当 PublishView 发布成功并修改了 AppStorage，这里会自动触发重新查库
    this.loadPostsFromDB();
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
    } catch (err) {
      console.error("读取数据库失败");
    }
  }

  // 解析数据字符串为 PostItem 数组
  getParsedPosts(): PostItem[] {
    let list: PostItem[] = [];
    if (!this.dbPostsData) return list;
    let posts = this.dbPostsData.split("^");
    for (let p of posts) {
      if (!p) continue;
      let parts = p.split("|");
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

  build() {
    Column() {
      Text("农业论坛 · 帖子列表")
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ top: 15, bottom: 15 })
        .textAlign(TextAlign.Center)

      // 🌟 帖子列表双列 UI 渲染
      Scroll() {
        Row() {
          // 左侧列 (偶数索引)
          Column() {
            ForEach(this.getParsedPosts().filter((_, i) => i % 2 === 0), (item: PostItem) => {
              PostCardView({
                item: item,
                bannerColor: '#87CEEB',
                userRole: this.userRole,
                onDeleteRequest: (id): void => this.confirmDelete("Post", id)
              })
            })
          }.width('50%').padding({ right: 5 }).justifyContent(FlexAlign.Start)

          // 右侧列 (奇数索引)
          Column() {
            ForEach(this.getParsedPosts().filter((_, i) => i % 2 === 1), (item: PostItem) => {
              PostCardView({
                item: item,
                bannerColor: '#98FB98',
                userRole: this.userRole,
                onDeleteRequest: (id): void => this.confirmDelete("Post", id)
              })
            })
          }.width('50%').padding({ left: 5 }).justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .layoutWeight(1)
      .padding({ left: 10, right: 10, bottom: 10 })
      .scrollBar(BarState.Off)

    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}