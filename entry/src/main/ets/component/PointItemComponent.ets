import { MineCoinContentBean } from '../bean/CoinBean'
import SizeConstant from '../constants/SizeConstant'
import { timestampToDateTime } from '../utils/DateUtil'

@Component
export struct PointItemComponent {
  item: MineCoinContentBean | undefined
  // private maxCount
  private pointEventRule: AlignRuleOption = {
    left: { anchor: "__container__", align: HorizontalAlign.Start },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }
  private pointRule: AlignRuleOption = {
    right: { anchor: "__container__", align: HorizontalAlign.End },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }

  build() {
    Column() {
      if (!this.item!.isLast) {
        //是内容
        RelativeContainer() {
          Column() {
            Text(this.item!.reason)
              .fontSize($r('app.float.font_12'))
              .fontColor($r('app.color.color_666666'))
            Text(timestampToDateTime(this.item!.date))
              .fontSize($r('app.float.font_10'))
              .fontColor($r('app.color.color_999999'))
              .margin({ top: SizeConstant.SIZE_2 })
          }.id("pointEvent")
          .alignRules(this.pointEventRule)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: SizeConstant.SIZE_15 })

          Text(this.item!.coinCount.toString())
            .alignRules(this.pointRule)
            .fontColor($r('app.color.color_FF7800'))
            .fontSize($r('app.float.font_12'))
            .id("point")
            .margin({ right: SizeConstant.SIZE_15 })
        }.width(SizeConstant.FULL_SIZE)
        .height(60)

        Line()
          .width(SizeConstant.FULL_SIZE)
          .height(1)
          .backgroundColor($r('app.color.color_F0F0F0'))
      } else {
        //没有数据，最后补一个“没有更多了”
        Text("没有更多了")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_999999'))
          .alignSelf(ItemAlign.Center)
          .margin({ top: SizeConstant.SIZE_5 })
      }
    }.width(SizeConstant.FULL_SIZE)
  }
}