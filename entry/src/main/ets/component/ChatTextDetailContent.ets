import SizeConstant from "../constants/SizeConstant";
import { LengthMetrics } from "@kit.ArkUI";

@Component
export struct ChatTextDetailContent {
  @Prop @Require detailMessageText: string
  @Link chatTextDetailContent: boolean

  build() {
    Column() {
      Scroll() {
        Text(this.detailMessageText)
          .fontSize($r('app.float.font_20'))
          .lineSpacing(LengthMetrics.vp(20))
      }
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
      .padding({
        left: SizeConstant.SIZE_30,
        right: SizeConstant.SIZE_30
      })
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Auto)
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor(Color.White)
    .onClick(() => {
      this.getUIContext().animateTo({
        duration: 150,
        curve: Curve.Linear
      }, () => {
        this.chatTextDetailContent = false
      })
    })
    .transition(TransitionEffect.OPACITY)
  }
}