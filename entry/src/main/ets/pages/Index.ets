// pages/Index.ets
import { router, promptAction } from '@kit.ArkUI';
import { preferences, relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { DatabaseHelper } from '../utils/DatabaseHelper';

@Entry
@Component
struct Index {
  @State account: string = '';
  @State pass: string = '';
  @State isRegisterMode: boolean = false;

  build() {
    Column() {
      Text(this.isRegisterMode ? "农业论坛注册" : "农业论坛登录")
        .fontSize(36).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 120, bottom: 60 })

      TextInput({ text: this.account, placeholder: '请输入账号' })
        .onChange((value: string) => this.account = value)
        .backgroundColor('#F5F5F5').margin({ bottom: 20 }).width('80%').height(50).borderRadius(25).padding({ left: 20 })

      TextInput({ text: this.pass, placeholder: '请输入密码' })
        .type(InputType.Password).showPasswordIcon(true)
        .onChange((value: string) => this.pass = value)
        .backgroundColor('#F5F5F5').margin({ bottom: 40 }).width('80%').height(50).borderRadius(25).padding({ left: 20 })

      Button(this.isRegisterMode ? "注册" : "登录")
        .width('80%').height(50).fontSize(20).fontWeight(FontWeight.Bold).backgroundColor('#0D9FFB').borderRadius(25)
        .onClick(() => {
          if (this.isRegisterMode) { this.handleRegister(); } else { this.handleLogin(); }
        })

      Text(this.isRegisterMode ? "已有账号？点此登录" : "没有账号？去注册")
        .fontColor('#0D9FFB').fontSize(16).margin({ top: 20 }).padding(10)
        .onClick(() => {
          this.isRegisterMode = !this.isRegisterMode;
          this.account = '';
          this.pass = '';
        })
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }

  async handleRegister() {
    if (this.account.trim() === '' || this.pass.trim() === '') {
      promptAction.showToast({ message: '账号或密码不能为空' });
      return;
    }
    let store = DatabaseHelper.getStore();
    if (!store) return;

    let predicates = new relationalStore.RdbPredicates("User");
    predicates.equalTo("user_id", this.account);
    let resultSet = await store.query(predicates);
    if (resultSet.rowCount > 0) {
      promptAction.showToast({ message: '该账号已存在' });
      resultSet.close();
      return;
    }
    resultSet.close();

    let values: relationalStore.ValuesBucket = {
      "user_id": this.account,
      "password": this.pass,
      "username": `农友_${this.account.substring(0, 4)}`,
      "role": 0 // 默认注册为普通用户
    };
    try {
      await store.insert("User", values);
      promptAction.showToast({ message: '注册成功！' });
      this.isRegisterMode = false;
    } catch (err) { promptAction.showToast({ message: '注册失败' }); }
  }

  async handleLogin() {
    if (this.account.trim() === '' || this.pass.trim() === '') {
      promptAction.showToast({ message: '请输入账号和密码' });
      return;
    }
    let store = DatabaseHelper.getStore();
    if (!store) return;

    let predicates = new relationalStore.RdbPredicates("User");
    predicates.equalTo("user_id", this.account).and().equalTo("password", this.pass);
    let resultSet = await store.query(predicates);

    if (resultSet.rowCount > 0) {
      // 🌟 核心改进：获取用户信息并存入持久化存储
      resultSet.goToFirstRow();
      let role = resultSet.getLong(resultSet.getColumnIndex("role"));
      let username = resultSet.getString(resultSet.getColumnIndex("username"));
      resultSet.close();

      let context = getContext(this) as common.UIAbilityContext;
      let pref = await preferences.getPreferences(context, 'LoginPrefs');
      pref.putSync('logged_in_user_id', this.account);
      pref.putSync('logged_in_username', username);
      pref.putSync('logged_in_user_role', role); // 存储角色
      await pref.flush();

      promptAction.showToast({ message: '登录成功！' });
      router.replaceUrl({ url: 'pages/second' });
    } else {
      resultSet.close();
      promptAction.showToast({ message: '账号或密码错误' });
    }
  }
}