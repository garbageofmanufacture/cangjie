// entry/src/main/ets/pages/profile.ets
import { router, promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { DatabaseHelper, UserProfileInfo } from '../utils/DatabaseHelper';
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';

@CustomDialog
struct EditProfileDialog {
  controller: CustomDialogController
  @Link email: string
  @Link address: string
  confirmAction: () => void = () => {}

  build() {
    Column({ space: 15 }) {
      Text('修改个人信息').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
      TextInput({ text: this.email, placeholder: '请输入邮箱' }).onChange((v) => this.email = v).height(45).backgroundColor('#F5F5F5')
      TextInput({ text: this.address, placeholder: '请输入常驻地址' }).onChange((v) => this.address = v).height(45).backgroundColor('#F5F5F5')
      Row({ space: 20 }) {
        Button('取消').onClick(() => this.controller.close()).backgroundColor('#E0E0E0').fontColor('#333')
        Button('保存').onClick(() => { this.confirmAction(); this.controller.close(); }).backgroundColor('#0D9FFB')
      }.margin({ top: 10 })
    }.padding(20).backgroundColor('#FFFFFF').borderRadius(15)
  }
}

@Entry
@Component
struct ProfilePage {
  @State account: string = '';
  @State username: string = '';
  @State email: string = '';
  @State address: string = '';
  @State avatarChar: string = '农';
  @State isDataReady: boolean = false;
  @State refreshKey: number = 0;

  editDialogController: CustomDialogController = new CustomDialogController({
    builder: EditProfileDialog({
      email: $email, address: $address,
      confirmAction: () => { this.saveProfileData(); }
    }),
    alignment: DialogAlignment.Center
  })

  async aboutToAppear(): Promise<void> {
    try {
      let context = getContext(this) as common.UIAbilityContext;
      let pref = await preferences.getPreferences(context, 'LoginPrefs');

      this.account = pref.getSync('logged_in_user_id', '未知账号') as string;
      this.username = pref.getSync('logged_in_username', '农友') as string;
      this.avatarChar = this.username.length > 0 ? this.username.substring(0, 1) : '农';

      let dbProfile: UserProfileInfo | null = await DatabaseHelper.getUserProfile(this.account);
      if (dbProfile) {
        this.email = dbProfile.email && dbProfile.email !== '' ? dbProfile.email : '未填写邮箱';
        this.address = dbProfile.address && dbProfile.address !== '' ? dbProfile.address : '未填写地址';
      } else {
        this.email = '未填写邮箱';
        this.address = '未填写地址';
      }

      this.isDataReady = true;
    } catch(e) {}
  }

  async saveProfileData(): Promise<void> {
    try {
      let success = await DatabaseHelper.updateUserProfile(this.account, this.email, this.address);
      if (success) {
        this.refreshKey += 1;
        promptAction.showToast({ message: '资料保存成功' });
      } else {
        promptAction.showToast({ message: '数据库保存异常，请重试' });
      }
    } catch (err) { promptAction.showToast({ message: '保存失败' }); }
  }

  build() {
    Column() {
      // 🌟 顶部导航栏
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').onClick(() => { try{ router.back() }catch(e){} })
        Blank()
        Text("个人中心").fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text("        ").fontSize(18)
      }.width('100%').padding(15).backgroundColor('#FFFFFF')

      if (this.isDataReady) {
        Scroll() {
          Column() {
            // --- 1. 头像与身份区 ---
            Column() {
              Text(this.avatarChar)
                .fontSize(40).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
                .width(80).height(80).backgroundColor('#0D9FFB').borderRadius(40)
                .textAlign(TextAlign.Center).margin({ bottom: 15 })

              Row() {
                Text(this.username).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333333')
                Text("知农用户")
                  .fontSize(12).fontColor('#FFFFFF')
                  .backgroundColor('#0D9FFB')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(12).margin({ left: 10 })
              }.margin({ bottom: 10 })

              Text("用心种好地，科技助农，让丰收成为常态。").fontSize(14).fontColor('#666666').margin({ bottom: 8 })

              Text("账号: " + this.account).fontSize(14).fontColor('#999999')
            }.width('90%').padding(30).backgroundColor('#FFFFFF').borderRadius(15).margin({ top: 20, bottom: 20 })

            // ==========================================
            // 🌟 核心修复区：固定高度，消灭大片空白！
            // ==========================================
            CJHybridComponent({
              library: "ohos_app_cangjie_entry",
              component: "ProfileStatsView",
              parameter: {
                "account": this.account
              }
            })
              .width('100%')
              .height(110) // 🌟 就是这行代码，把白边彻底压死！
              .key(this.refreshKey.toString())
            // ==========================================

            // --- 2. 基础信息区 ---
            Column() {
              Row() {
                Text("基本信息").fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
                Blank()
                Text("✎ 编辑资料").fontSize(14).fontColor('#0D9FFB').onClick(() => { this.editDialogController.open(); })
              }.width('100%').margin({ bottom: 20 })

              Row() {
                Text("📧 邮箱：").fontSize(16).fontColor('#666666')
                Blank()
                Text(this.email).fontSize(16).fontColor('#333333')
              }.width('100%').margin({ bottom: 15 })

              Divider().color('#F0F0F0').margin({ bottom: 15 })

              Row() {
                Text("📍 地址：").fontSize(16).fontColor('#666666')
                Blank()
                Text(this.address).fontSize(16).fontColor('#333333')
              }.width('100%')
            }.width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15).margin({ bottom: 20 })

            // --- 3. 我的发布 & 我的收藏 ---
            Column() {
              Row() {
                Text("📝 我的发布").fontSize(16).fontColor('#333333')
                Blank()
                Text(">").fontSize(16).fontColor('#CCCCCC')
              }.width('100%').padding({ top: 15, bottom: 15 })
              .onClick(() => {
                // 🌟 探针 1：只要点到了，绝对会先弹这句话！
                promptAction.showToast({ message: '正在加载我的发布...' });

                router.pushUrl({ url: 'pages/my_published' }).catch((err: Error) => {
                  // 🌟 探针 2：如果跳转失败，强制把失败的具体原因弹在屏幕上！
                  promptAction.showToast({ message: `跳转失败，系统报错: ${err.message}` });
                  console.error("路由跳转失败: ", err);
                });
              })

              Divider().color('#F0F0F0')

              Row() {
                Text("⭐ 我的收藏").fontSize(16).fontColor('#333333')
                Blank()
                Text(">").fontSize(16).fontColor('#CCCCCC')
              }.width('100%').padding({ top: 15, bottom: 15 })
              .onClick(() => {
                promptAction.showToast({ message: '正在加载我的收藏...' });
                router.pushUrl({ url: 'pages/my_favorite' }).catch((err: Error) => {
                  promptAction.showToast({ message: `跳转失败，系统报错: ${err.message}` });
                });
              })
            }.width('90%').padding({ left: 20, right: 20 }).backgroundColor('#FFFFFF').borderRadius(15).margin({ bottom: 20 })

            // --- 4. 退出按钮 ---
            Button("退出登录").width('80%').height(50).backgroundColor('#F0F0F0').fontColor('#FF4D4F')
              .margin({ top: 20, bottom: 40 })
              .onClick(async () => {
                try {
                  let context = getContext(this) as common.UIAbilityContext;
                  let pref = await preferences.getPreferences(context, 'LoginPrefs');
                  await pref.clear();
                  await pref.flush();
                  router.clear();
                  router.replaceUrl({ url: 'pages/Index' }).catch(()=>{});
                }catch(e){}
              })
          }.width('100%')
        }.width('100%').layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}