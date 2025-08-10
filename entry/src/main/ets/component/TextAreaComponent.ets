import SizeConstant from '../constants/SizeConstant'

/**
 * 文本输入，带一键清空
 */
@Component
export struct TextAreaComponent {
  @Require placeholder: string
  @Link inputText: string

  build() {
    Column() {
      Row() {
        TextArea({
          placeholder: this.placeholder,
          text: $$this.inputText
        })
          .layoutWeight(1)
          .placeholderColor($r('app.color.color_CCCCCC'))
          .placeholderFont({
            size: $r('app.float.font_13')
          })
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding({ left: 0, right: 0 })
          .fontColor($r('app.color.color_000000'))
          .fontSize($r('app.float.font_13'))

        //清空
        if (this.inputText !== '') {
          Image($r('app.media.icon_clear'))
            .width(SizeConstant.SIZE_20)
            .height(SizeConstant.SIZE_20)
            .margin({ left: SizeConstant.SIZE_5, right: SizeConstant.SIZE_5 })
            .onClick(() => {
              this.inputText = ''
            })
        }

      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      Line()
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_1)
        .backgroundColor($r('app.color.color_F0F0F0'))
    }.width(SizeConstant.FULL_SIZE)
  }
}