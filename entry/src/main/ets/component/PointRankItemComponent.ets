import { CoinRankContentBean } from '../bean/CoinBean'
import SizeConstant from '../constants/SizeConstant'

@Component
export struct PointRankItemComponent {
  index: number = 0
  item: CoinRankContentBean | undefined

  build() {
    Column() {
      Column() {
        Row() {
          Stack() {
            Text((this.index + 4).toString())
              .fontSize($r('app.float.font_15'))
              .fontColor(Color.Black)
              .margin(SizeConstant.SIZE_2)
          }.backgroundColor(Color.Orange)
          .borderRadius(SizeConstant.SIZE_10)
          .align(Alignment.Center)
          .margin({ left: SizeConstant.SIZE_15 })

          //姓名
          Text(`${this.item!.username}`)
            .fontSize($r('app.float.font_12'))
            .fontColor($r('app.color.color_666666'))
            .margin({ left: SizeConstant.SIZE_15 })

          Blank()

          //积分
          Text(this.item!.coinCount.toString())
            .fontColor($r('app.color.color_FF7800'))
            .fontSize($r('app.float.font_12'))
            .margin({ right: SizeConstant.SIZE_15 })

        }.width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_60)
        .alignItems(VerticalAlign.Center)

        Line()
          .width(SizeConstant.FULL_SIZE)
          .height(1)
          .backgroundColor($r('app.color.color_F0F0F0'))
      }
    }.width(SizeConstant.FULL_SIZE)
  }
}