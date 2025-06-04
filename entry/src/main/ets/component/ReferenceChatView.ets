import SizeConstant from "../constants/SizeConstant";

@Component
export struct ReferenceChatView {
  @State referText: string = ''
  onClickItem: () => void = () => {
  }

  build() {
    Stack() {
      //加载成功
      Text(this.referText)
        .backgroundColor($r('app.color.color_e1e1e1'))
        .borderRadius(SizeConstant.SIZE_5)
        .fontColor($r('app.color.color_666666'))
        .padding(SizeConstant.SIZE_10)
        .margin({ top: SizeConstant.SIZE_5 })
        .height('auto')
        .fontSize($r('app.float.font_12'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
        .onClick(this.onClickItem)
    }.constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
  }
}

