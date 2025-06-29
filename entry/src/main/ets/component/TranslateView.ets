import SizeConstant from "../constants/SizeConstant"
import { Message } from "../pages/ChatPage"

/**
 * 聊天翻译
 */
@Component
export struct TranslateView {
  @ObjectLink item: Message

  build() {
    Stack() {
      if (this.item.translateLoading) {
        Image($r('app.media.icon_loading_green'))
          .width(SizeConstant.SIZE_10)
      } else {
        //加载成功
        Text(this.item.translateText)
          .backgroundColor($r('app.color.color_FFFFFF'))
          .borderRadius(SizeConstant.SIZE_5)
          .fontColor(Color.Black)
          .padding(SizeConstant.SIZE_10)
          .margin({ top: SizeConstant.SIZE_5 })
          .height('auto')
          .fontSize($r('app.float.font_12'))
          .textAlign(TextAlign.Start)
      }
    }.constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
  }
}