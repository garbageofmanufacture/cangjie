import { CJHybridComponent } from '@cangjie/cjhybridcomponent';

@Entry
@Component
struct LoginManager {
  @State message: string = 'Hello World';

  build() {
    Column() {
      CJHybridComponent({
        library: 'ohos_app_cangjie_entry',
        component: 'LoginManager'
      })
    }
    .height('100%')
    .width('100%')
  }
}
