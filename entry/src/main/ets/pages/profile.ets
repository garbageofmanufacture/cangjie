// entry/src/main/ets/pages/profile.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import router from '@ohos.router';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import cjlib from 'libohos_app_cangjie_entry.so';
import { promptAction } from '@kit.ArkUI';

@CustomDialog
struct EditProfileDialog {
  controller: CustomDialogController
  @Link email: string
  @Link address: string
  confirmAction: () => void = () => {}

  build() {
    Column({ space: 15 }) {
      Text('修改个人信息').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 10 })

      TextInput({ text: this.email, placeholder: '请输入邮箱' })
        .onChange((v: string) => this.email = v).height(45).backgroundColor('#F5F5F5')

      TextInput({ text: this.address, placeholder: '请输入常驻地址' })
        .onChange((v: string) => this.address = v).height(45).backgroundColor('#F5F5F5')

      Row({ space: 20 }) {
        Button('取消').onClick(() => this.controller.close()).backgroundColor('#E0E0E0').fontColor('#333')
        Button('保存').onClick(() => {
          this.confirmAction();
          this.controller.close();
        }).backgroundColor('#0D9FFB')
      }.margin({ top: 10 })
    }.padding(20).backgroundColor('#FFFFFF').borderRadius(15)
  }
}

@Entry
@Component
struct ProfilePage {
  @State account: string = '';
  @State username: string = '';
  @State roleStr: string = '0';
  @State email: string = '';
  @State address: string = '';
  @State bio: string = '';
  @State avatarChar: string = '农';
  @State isDataReady: boolean = false;
  @State refreshKey: number = 0;

  editDialogController: CustomDialogController = new CustomDialogController({
    builder: EditProfileDialog({
      email: $email,
      address: $address,
      confirmAction: () => { this.saveProfileData(); }
    }),
    alignment: DialogAlignment.Center
  })

  async aboutToAppear(): Promise<void> {
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');

    // 👇 🌟 核心修改区：优先从上一个页面(second.ets)接收路由参数
    let params = router.getParams() as Record<string, string>;
    if (params && params['roleStr'] !== undefined) {
      this.roleStr = params['roleStr']; // 接住 second.ets 传来的参数
    } else {
      this.roleStr = (pref.getSync('logged_in_user_role', 0) as number).toString(); // 没有传参再从缓存读
    }
    // 👆 核心修改区结束

    if (this.roleStr === '1') {
      this.username = '超级管理员';
      this.account = 'admin';
      this.avatarChar = '超';
      this.bio = '系统最高权限管理员，负责维护社区秩序与内容审核。';
    } else {
      this.account = pref.getSync('logged_in_user_id', '未知账号') as string;
      this.username = pref.getSync('logged_in_username', '农友') as string;
      this.avatarChar = this.username.length > 0 ? this.username.substring(0, 1) : '农';
      this.bio = '用心种好地，科技助农，让丰收成为常态。';
    }

    this.email = pref.getSync('logged_in_email', `${this.account}@zhinong.com`) as string;
    this.address = pref.getSync('logged_in_address', '中国 · 现代农业示范区') as string;

    cjlib.registerJSFunc('ProfileGoBack', () => { router.back(); });
    cjlib.registerJSFunc('OpenEditDialog', () => { this.editDialogController.open(); });

    // 👇 🌟 之前新增的：向仓颉注册“打开审核页”的跨端能力
    cjlib.registerJSFunc('OpenAuditPage', () => {
      router.pushUrl({ url: 'pages/audit_list' });
    });

    cjlib.registerJSFunc('LogoutUser', async () => {
      let pref2 = await preferences.getPreferences(context, 'LoginPrefs');
      await pref2.clear();
      await pref2.flush();
      router.clear();
      router.replaceUrl({ url: 'pages/Index' });
    });

    this.isDataReady = true;
  }

  aboutToDisappear(): void {
    cjlib.unregisterJSFunc('ProfileGoBack');
    cjlib.unregisterJSFunc('OpenEditDialog');
    cjlib.unregisterJSFunc('OpenAuditPage');
    cjlib.unregisterJSFunc('LogoutUser');
  }

  async saveProfileData(): Promise<void> {
    try {
      let context = getContext(this) as common.UIAbilityContext;
      let pref = await preferences.getPreferences(context, 'LoginPrefs');
      pref.putSync('logged_in_email', this.email);
      pref.putSync('logged_in_address', this.address);
      await pref.flush();
      this.refreshKey += 1;
      promptAction.showToast({ message: '资料保存成功' });
    } catch (err) {
      promptAction.showToast({ message: '保存失败' });
    }
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
            "roleStr": this.roleStr,
            "email": this.email,
            "address": this.address,
            "bio": this.bio,
            "avatarChar": this.avatarChar
          }
        })
          .width('100%').height('100%')
          .key(this.account + this.roleStr + this.refreshKey.toString())
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}