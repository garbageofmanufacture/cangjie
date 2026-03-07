// src/main/ets/pages/profile.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import router from '@ohos.router';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import cjlib from 'libohos_app_cangjie_entry.so'; // 引入互操作库

@Entry
@Component
struct ProfilePage {
  @State account: string = '';
  @State username: string = '';
  @State roleStr: string = '0';
  @State isDataReady: boolean = false;

  async aboutToAppear() {
    // 1. 读取用户信息
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');
    this.account = pref.getSync('logged_in_user_id', '未知账号') as string;
    this.username = pref.getSync('logged_in_username', '农友') as string;
    let roleInt = pref.getSync('logged_in_user_role', 0) as number;
    this.roleStr = roleInt.toString();

    // 2. 注册仓颉要调用的 JS 方法
    // 返回方法
    cjlib.registerJSFunc('ProfileGoBack', () => {
      router.back();
    });

    // 退出登录方法
    cjlib.registerJSFunc('LogoutUser', async () => {
      let pref2 = await preferences.getPreferences(context, 'LoginPrefs');
      await pref2.clear(); // 清空登录信息
      await pref2.flush();
      router.clear(); // 清空路由栈，防止用户按返回键回来
      router.replaceUrl({ url: 'pages/Index' }); // 回到登录页
    });

    this.isDataReady = true;
  }

  aboutToDisappear() {
    // 页面销毁时注销方法，防止内存泄漏
    cjlib.unregisterJSFunc('ProfileGoBack');
    cjlib.unregisterJSFunc('LogoutUser');
  }

  build() {
    Column() {
      if (this.isDataReady) {
        CJHybridComponent({
          library: "ohos_app_cangjie_entry",
          component: "ProfileView",
          parameter: {
            "account": this.account,
            "username": this.username,
            "roleStr": this.roleStr
          }
        })
          .width('100%')
          .height('100%')
          // 🌟 核心修复点：添加 .key() 绑定。
          // 这样当数据读取完成后，会强制触发仓颉组件重新加载并接收参数
          .key(this.account + this.roleStr)
      }
    }
  }
}