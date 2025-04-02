import SizeConstant from '../constants/SizeConstant'

@Component
export struct ReferenceView {
  @State referenceOwner: string = ''
  @State referenceText: string = ''
  onCancel: () => void = () => {
  }

  build() {
    Row() {
      Text(`${this.referenceOwner}: ${this.referenceText}`)
        .fontColor($r('app.color.color_6B6B6B'))
        .fontSize($r('app.float.font_10'))
        .margin({
          left: SizeConstant.SIZE_8,
          top: SizeConstant.SIZE_5,
          bottom: SizeConstant.SIZE_5,
          right: SizeConstant.SIZE_2
        })
        .layoutWeight(1)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Image($r('app.media.icon_delete_a1'))
        .width(SizeConstant.SIZE_15)
        .margin({ right: SizeConstant.SIZE_8 })
        .onClick(() => {
          this.onCancel()
        })
    }.width(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_EAEAEA'))
    .borderRadius(SizeConstant.SIZE_5)
    .alignItems(VerticalAlign.Center)
  }
}