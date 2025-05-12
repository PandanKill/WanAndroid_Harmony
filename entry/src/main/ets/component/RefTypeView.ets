@Component
export struct RefTypeView {
  @State refType: string = ''

  build() {
    Text(this.refType)
      .fontSize($r('app.float.font_12'))
      .fontColor(Color.Black)
      .padding({
        left: 5,
        right: 5,
        top: 2,
        bottom: 2
      })
      .borderRadius('50%')
      .backgroundColor(Color.Gray)
      .textAlign(TextAlign.Center)
  }
}