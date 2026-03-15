// entry/src/main/cangjie/AgriRichText.cj
package ohos_app_cangjie_entry

import ohos.base.*
import ohos.arkui.component.*
import ohos.arkui.state_macro_manage.*
import ohos.arkui.state_management.*

@HybridComponentEntry
@Component
class AgriRichText {
    @State var content: String = ""

    public func build() {
        Text(this.content)
            .fontSize(16)
            .fontColor(Color(0xFF333333))
            .width(100.percent)
    }
}
