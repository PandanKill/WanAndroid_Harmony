import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct PointPage {
  @State point: number = 0
  @State pointEvents: string[] = ['积分1', '积分2', '积分3', ""]
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
      NavHeaderView({
        title: $r('app.string.mime_point'),
        isShowMenu: true,
        menu: $r('app.media.icon_rank'),
        onMenuClick: () => {
          //跳转积分排名
          router.pushUrl({
            url: "pages/PointRankPage"
          })
        }
      })

      Text(this.point.toString())
        .fontSize($r('app.float.font_60'))
        .fontColor($r('app.color.color_FFFFFF'))
        .textAlign(TextAlign.Center)
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_PERCENT_25)
        .backgroundColor($r('app.color.color_272A36'))

      List() {
        ForEach(this.pointEvents, (item: string, index: number) => {
          ListItem() {
            Column() {
              if (item === "") {
                //没有数据，最后补一个“没有更多了”
                Text("没有更多了")
                  .fontSize($r('app.float.font_12'))
                  .fontColor($r('app.color.color_999999'))
                  .alignSelf(ItemAlign.Center)
                  .margin({ top: SizeConstant.SIZE_5 })
              } else {
                Column() {
                  RelativeContainer() {
                    Column() {
                      Text(item)
                        .fontSize($r('app.float.font_12'))
                        .fontColor($r('app.color.color_666666'))
                      Text(item)
                        .fontSize($r('app.float.font_10'))
                        .fontColor($r('app.color.color_999999'))
                        .margin({ top: SizeConstant.SIZE_2 })
                    }.id("pointEvent")
                    .alignRules(this.pointEventRule)
                    .margin({ left: SizeConstant.SIZE_15 })


                    Text(item)
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
                }
              }
            }.width(SizeConstant.FULL_SIZE)
          }
        })
      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_F5F5F5'))
  }
}