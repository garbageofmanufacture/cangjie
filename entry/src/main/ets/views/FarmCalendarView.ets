// src/main/ets/views/FarmCalendarView.ets
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { http } from '@kit.NetworkKit';

// 🌟 1. 严格模式要求：必须为发往网络的对象显式定义数据结构 (Interface)
interface MessageItem {
  role: string;
  content: string;
}

interface ChatRequest {
  model: string;
  messages: MessageItem[];
  temperature: number;
}

@Component
export struct FarmCalendarView {
  @State cropName: string = '';
  @State aiResponse: string = '';
  @State isGenerating: boolean = false;
  @State userAddress: string = '未知地区';

  private API_KEY: string = 'sk-b41e659ca7b54e38be8c28a447a7dd7e';

  async aboutToAppear(): Promise<void> {
    // 🌟 2. 严格模式要求：强制使用 try-catch 包裹可能抛出异常的 IO 操作
    try {
      let context = getContext(this) as common.UIAbilityContext;
      let pref = await preferences.getPreferences(context, 'LoginPrefs');
      this.userAddress = pref.getSync('logged_in_address', '中国 · 现代农业示范区') as string;
    } catch (err) {
      console.error("读取地址失败", JSON.stringify(err));
      this.userAddress = '中国 · 现代农业示范区'; // 兜底数据
    }
  }

  async generateAIAdvice(): Promise<void> {
    if (this.cropName.trim() === '') return;

    this.isGenerating = true;
    this.aiResponse = '';

    let month = new Date().getMonth() + 1;
    let promptStr = `我的常驻地区是：${this.userAddress}。现在是${month}月。我种植的作物是：${this.cropName}。请结合地区气候、时令特点，给出3条简短、专业的农事指导建议。`;

    let httpRequest = http.createHttp();
    let url = "https://api.deepseek.com/chat/completions";

    // 🌟 3. 严格模式要求：实例化之前定义的接口对象，而不是传匿名 {}
    let requestBody: ChatRequest = {
      model: "deepseek-chat",
      messages: [
        { role: "system", content: "你是一个专业的AI农业助手，回答精炼，直奔主题，不要废话。" },
        { role: "user", content: promptStr }
      ],
      temperature: 0.7
    };

    try {
      let response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.API_KEY}`
        },
        // 安全地转换为 JSON 字符串
        extraData: JSON.stringify(requestBody),
        readTimeout: 30000,
        connectTimeout: 30000
      });

      if (response.responseCode === 200) {
        // 🌟 4. 严格模式要求：拒绝 any，强制将 JSON 逐层解析为安全的字典 (Record) 结构
        let jsonObj = JSON.parse(response.result as string) as Record<string, Object>;
        let choicesArr = jsonObj['choices'] as Array<Record<string, Object>>;

        if (choicesArr && choicesArr.length > 0) {
          let msgObj = choicesArr[0]['message'] as Record<string, string>;
          this.aiResponse = msgObj['content'];
        } else {
          this.aiResponse = "❌ AI返回的数据格式异常";
        }
      } else {
        this.aiResponse = `❌ 请求失败，状态码：${response.responseCode}`;
      }
    } catch (err) {
      console.error('AI请求异常:', JSON.stringify(err));
      this.aiResponse = "❌ 网络请求超时或异常，请检查模拟器是否联网，以及 module.json5 网络权限。";
    } finally {
      httpRequest.destroy();
      this.isGenerating = false;
    }
  }

  build() {
    Column() {
      // 顶部：仓颉静态日历组件
      CJHybridComponent({ library: "ohos_app_cangjie_entry", component: "farm_calendar" })
        .width('100%').height(160)

      // 底部：ArkTS AI 交互区
      Column() {
        Row() {
          Text("✨ DeepSeek 智能农事分析").fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          Blank()
        }.width('100%').margin({ bottom: 15 })

        Row() {
          TextInput({ placeholder: '输入作物测试，如: 冬小麦', text: this.cropName })
            .onChange((v: string) => this.cropName = v)
            .layoutWeight(1).height(45).backgroundColor('#FFFFFF').borderRadius(8)
            .onSubmit(() => this.generateAIAdvice())

          Button("AI 诊断").height(45).margin({ left: 10 }).backgroundColor('#0D9FFB')
            .onClick(() => this.generateAIAdvice())
        }.width('100%').margin({ bottom: 20 })

        if (this.isGenerating) {
          Column({ space: 10 }) {
            LoadingProgress().width(40).height(40).color('#0D9FFB')
            Text("正在连接真实云端大模型思考中...").fontSize(14).fontColor('#888888')
          }.width('100%').margin({ top: 30 })
        } else if (this.aiResponse) {
          Scroll() {
            Text(this.aiResponse)
              .fontSize(16).lineHeight(28).fontColor('#333333')
              .padding(20).backgroundColor('#E6F7FF').borderRadius(15)
              .width('100%').textAlign(TextAlign.Start)
          }.layoutWeight(1)
        } else {
          Column() {
            Text("🤖 告诉 AI 您种植了什么，获取专属农事建议").fontSize(14).fontColor('#BBBBBB').margin({ top: 40 })
          }.width('100%').layoutWeight(1)
        }
      }
      .width('90%').layoutWeight(1).padding({ top: 20, bottom: 20 })
    }
    .width('100%').height('100%').backgroundColor('#F5F7FA')
  }
}