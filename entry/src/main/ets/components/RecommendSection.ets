// entry/src/main/ets/components/RecommendSection.ets
package ohos_app_cangjie_entry.components

import { router } from '@kit.ArkUI'
import { EdgeRecService } from './edge_recModels/ EdgeRecModels'

export interface RecommendCallback {
  onClick: (itemId: string, actionType: string): void
  refresh(): void
}

