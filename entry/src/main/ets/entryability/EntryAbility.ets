import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DatabaseHelper } from '../utils/DatabaseHelper';

// 👉 1. 导入首选项模块
import { preferences } from '@kit.ArkData';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // 👉 2. 在方法前加上 async，使其支持异步读取
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      await DatabaseHelper.initDb(this.context);
      // 👉 3. 获取首选项实例（必须和仓颉代码里的 PREF_NAME 保持绝对一致！）
      let pref = await preferences.getPreferences(this.context, 'LoginPrefs');

      // 👉 4. 获取登录状态（必须和仓颉里的 KEY_USER_ID 保持一致！）
      let userId = pref.getSync('logged_in_user_id', '') as string;

      // 👉 5. 核心路由逻辑：决定启动时加载哪个页面
      let targetPage = 'pages/Index'; // 默认进入首页/登录页

      if (userId !== '') {
        hilog.info(0x0000, 'testTag', '用户已登录，ID: %{public}s', userId);
        targetPage = 'pages/second'; // 如果已登录，直接飞奔到你的四大功能 Tabs 主页！
      } else {
        hilog.info(0x0000, 'testTag', '用户未登录，前往登录页');
      }

      // 👉 6. 加载目标页面
      windowStage.loadContent(targetPage, (err) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });

    } catch (err) {
      hilog.error(0x0000, 'testTag', '读取首选项失败: %{public}s', JSON.stringify(err) ?? '');
      // 万一出错，作为兜底方案，加载 Index 页面
      windowStage.loadContent('pages/Index', (err) => {
        // ...
      });
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}