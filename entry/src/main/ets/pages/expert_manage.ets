// entry/src/main/ets/pages/expert_manage.ets
import { router, promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct ExpertManagePage {
  @State expertList: string[] = [];

  aboutToAppear() {
    this.loadAllExperts();
  }

  // 🌟 从底层缓存捞出所有专家账号
  async loadAllExperts() {
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');

    // 🌟 核心修复 1：明确告诉 ArkTS 编译器，这是一个“键是字符串，值是布尔值”的字典！
    let allPrefs = pref.getAllSync() as Record<string, boolean>;
    let temp: string[] = [];

    // 🌟 核心修复 2：在 ArkTS 中，推荐使用 Object.keys 配合数组遍历
    let keys = Object.keys(allPrefs);
    for (let i = 0; i < keys.length; i++) {
      let key = keys[i];

      // 现在可以光明正大地使用 allPrefs[key] 了，编辑器再也不会报错！
      if (key.startsWith('is_expert_') && allPrefs[key] === true) {
        let accountStr = key.replace('is_expert_', '');
        // 把管理员自己排除在列表外
        if (accountStr !== 'admin') {
          temp.push(accountStr);
        }
      }
    }

    this.expertList = temp;
  }

  // 🌟 剥夺专家权限
  async revokeExpertStatus(targetAccount: string) {
    let context = getContext(this) as common.UIAbilityContext;
    let pref = await preferences.getPreferences(context, 'LoginPrefs');

    // 强行把他的专家状态改为 false
    pref.putSync(`is_expert_${targetAccount}`, false);
    await pref.flush();

    promptAction.showToast({ message: `已成功取消账号 ${targetAccount} 的专家权限` });

    // 刷新列表让它消失
    this.loadAllExperts();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text("← 返回").fontSize(18).fontColor('#0D9FFB').padding(15).onClick(() => { try{ router.back() }catch(e){} })
        Text("专家权限管理").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width('100%').height(60).backgroundColor('#FFFFFF')

      if (this.expertList.length === 0) {
        Column() {
          Text("📭").fontSize(50).margin({ bottom: 15 })
          Text("当前系统暂无认证专家").fontColor('#999999').fontSize(16)
        }.width('100%').margin({ top: 150 }).alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 15 }) {
          ForEach(this.expertList, (account: string, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text("账号: " + account).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ bottom: 5 })
                  Text("认证专家").fontSize(12).fontColor('#FF9900').backgroundColor('#FFF2E8').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                Button("移除权限")
                  .fontSize(14).height(32).backgroundColor('#FF4D4F')
                  .onClick(() => {
                    this.revokeExpertStatus(account);
                  })
              }.width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(12).shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 3 })
            }
          }, (account: string) => account)
        }.padding({ left: 15, right: 15, top: 20, bottom: 20 }).layoutWeight(1).width('100%')
      }
    }.width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}