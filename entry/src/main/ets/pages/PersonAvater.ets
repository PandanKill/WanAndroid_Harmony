import SizeConstant from '../constants/SizeConstant'

@Entry
@Component
struct PersonAvater {
  build() {
    Column() {
      Image($r('app.media.icon_person'))
        .width(SizeConstant.SIZE_PERCENT_80)
        .aspectRatio(1)
        .sharedTransition("avater", {
          duration: 200,
          curve: Curve.Smooth
        })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .alignItems(HorizontalAlign.Center)
  }
}