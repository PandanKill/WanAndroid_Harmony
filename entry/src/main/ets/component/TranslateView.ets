import SizeConstant from "../constants/SizeConstant"

/**
 * 聊天翻译
 */
@Component
export struct TranslateView {
  @State isLoading: boolean = false
  @State translateText: string = ""

  build() {
    Stack() {
      if (this.isLoading) {
        Image($r('app.media.icon_loading_green'))
          .width(SizeConstant.SIZE_10)
      } else {
        //加载成功
        Text(this.translateText)
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