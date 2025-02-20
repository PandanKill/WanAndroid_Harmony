import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'

@Component
export struct NavHeaderView {
  //标题
  private title: string | Resource = ''
  //是否显示返回按键
  private isShowBack: boolean = true

  build() {
    Row() {
      if (this.isShowBack) {
        Image($r('app.media.icon_back'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({
            left: SizeConstant.SIZE_15
          })
          .onClick(() => {
            router.back()
          })
      }

      Text(this.title)
        .alignSelf(ItemAlign.Center)
        .fontColor($r('app.color.color_FFFFFF'))
        .fontSize($r('app.float.font_20'))

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.SIZE_50)
  }
}