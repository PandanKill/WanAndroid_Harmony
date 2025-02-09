import { NavContentBean } from '../bean/NavContentBean'
import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'

@Component
export struct NavTabContentView {
  private content: Array<NavContentBean> = []

  build() {
    Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
      ForEach(this.content, (item: NavContentBean, index: number) => {
        Text(item.title)
          .fontColor($r('app.color.color_666666'))
          .fontSize($r('app.float.font_12'))
          .padding({
            top: SizeConstant.SIZE_5,
            bottom: SizeConstant.SIZE_5,
            left: SizeConstant.SIZE_10,
            right: SizeConstant.SIZE_10
          })
          .backgroundColor($r('app.color.color_F6F6F6'))
          .borderRadius(SizeConstant.SIZE_20)
          .margin({ top: SizeConstant.SIZE_10, left: SizeConstant.SIZE_10, right: SizeConstant.SIZE_10 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/WebPage',
              params: {
                webUrl: item.link
              }
            })
          })
      }, (item: string, index: number) => item + index)
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_FFFFFF'))
  }
}