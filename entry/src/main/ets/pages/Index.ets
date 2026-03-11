// pages/Index.ets
import { router, promptAction } from '@kit.ArkUI';
import { preferences, relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { DatabaseHelper } from '../utils/DatabaseHelper';

// 🌟 核心修复 1：专门为水波纹定义一个标准类，满足 ArkTS 的严格类型要求
class RippleData {
  id: number = 0;
  x: number = 0;
  y: number = 0;

  constructor(id: number, x: number, y: number) {
    this.id = id;
    this.x = x;
    this.y = y;
  }
}

// 独立的水波纹动画组件
@Component
struct RippleEffect {
  @Prop x: number;
  @Prop y: number;
  @State scaleVal: number = 0.1;
  @State opacityVal: number = 0.6;

  aboutToAppear() {
    // 组件挂载时立刻触发扩散和渐隐动画
    animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
      this.scaleVal = 4.0;
      this.opacityVal = 0;
    });
  }

  build() {
    Circle()
      .width(100)
      .height(100)
      .fill('#FFFFFF') // 纯白色的涟漪
      .position({ x: this.x - 50, y: this.y - 50 }) // 让圆心对准点击位置
      .scale({ x: this.scaleVal, y: this.scaleVal })
      .opacity(this.opacityVal)
      // 穿透点击事件，防止波纹挡住下方的输入框和按钮
      .hitTestBehavior(HitTestMode.None)
  }
}

@Entry
@Component
struct Index {
  @State account: string = '';
  @State pass: string = '';
  @State isRegisterMode: boolean = false;

  // 🌟 核心修复 2：将数组类型指定为刚刚定义的类
  @State ripples: RippleData[] = [];
  private rippleIdCounter: number = 0;

  build() {
    Stack() {
      // --- 1. 最底层：清新农业风的渐变背景 ---
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#E0F7FA', 0.0], ['#A5D6A7', 1.0]] // 从清澈浅蓝渐变到生机嫩绿
        })

      // --- 2. 中间层：根据用户的点击动态渲染水波纹 ---
      // 🌟 核心修复 3：ForEach 里的参数类型也替换为标准的 RippleData
      ForEach(this.ripples, (item: RippleData) => {
        RippleEffect({ x: item.x, y: item.y })
      }, (item: RippleData) => item.id.toString())

      // --- 3. 最顶层：毛玻璃高颜值登录面板 ---
      Column() {
        Image($r('app.media.applogo'))
          .width(80)
          .height(80)
          .margin({ bottom: 15 })
          .borderRadius(20)

        Text(this.isRegisterMode ? "加入知农" : "欢迎回来")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E3A8A')
          .margin({ bottom: 40 })

        TextInput({ text: this.account, placeholder: '请输入账号' })
          .onChange((value: string) => this.account = value)
          .backgroundColor('rgba(255, 255, 255, 0.8)')
          .margin({ bottom: 20 })
          .width('100%')
          .height(50)
          .borderRadius(25)
          .padding({ left: 20 })

        TextInput({ text: this.pass, placeholder: '请输入密码' })
          .type(InputType.Password)
          .showPasswordIcon(true)
          .onChange((value: string) => this.pass = value)
          .backgroundColor('rgba(255, 255, 255, 0.8)')
          .margin({ bottom: 40 })
          .width('100%')
          .height(50)
          .borderRadius(25)
          .padding({ left: 20 })

        Button(this.isRegisterMode ? "注 册" : "登 录")
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(this.isRegisterMode ? '#4CAF50' : '#0D9FFB')
          .borderRadius(25)
          .shadow({ radius: 10, color: this.isRegisterMode ? 'rgba(76, 175, 80, 0.4)' : 'rgba(13, 159, 251, 0.4)', offsetY: 5 })
          .onClick(() => {
            if (this.isRegisterMode) { this.handleRegister(); } else { this.handleLogin(); }
          })

        Row() {
          Text(this.isRegisterMode ? "已有账号？" : "没有账号？")
            .fontColor('#666666')
            .fontSize(14)
          Text(this.isRegisterMode ? "立即登录" : "去注册")
            .fontColor('#0D9FFB')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
        }
        .margin({ top: 25 })
        .padding(10)
        .onClick(() => {
          this.isRegisterMode = !this.isRegisterMode;
          this.account = '';
          this.pass = '';
        })
      }
      .width('85%')
      .padding(30)
      .backgroundColor('rgba(255, 255, 255, 0.45)')
      .backgroundBlurStyle(BlurStyle.Thin)
      .borderRadius(25)
      .shadow({ radius: 30, color: 'rgba(0, 0, 0, 0.1)', offsetY: 15 })
    }
    .width('100%')
    .height('100%')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        let touch = event.touches[0];
        let id = this.rippleIdCounter++;

        // 🌟 核心修复 4：使用 new 关键字实例化类，而不是抛个匿名对象
        this.ripples.push(new RippleData(id, touch.x, touch.y));

        setTimeout(() => {
          this.ripples = this.ripples.filter(r => r.id !== id);
        }, 800);
      }
    })
  }

  // === 业务逻辑保持不变 ===
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
      "role": 0
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
      resultSet.goToFirstRow();
      let role = resultSet.getLong(resultSet.getColumnIndex("role"));
      let username = resultSet.getString(resultSet.getColumnIndex("username"));
      resultSet.close();

      let context = getContext(this) as common.UIAbilityContext;
      let pref = await preferences.getPreferences(context, 'LoginPrefs');
      pref.putSync('logged_in_user_id', this.account);
      pref.putSync('logged_in_username', username);
      pref.putSync('logged_in_user_role', role);
      await pref.flush();

      promptAction.showToast({ message: '登录成功！' });
      router.replaceUrl({ url: 'pages/second' });
    } else {
      resultSet.close();
      promptAction.showToast({ message: '账号或密码错误' });
    }
  }
}