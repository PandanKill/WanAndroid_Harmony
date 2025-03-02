import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct PointRankPage {
  @State pointEvents: string[] = ['积分1', '积分2', '积分3', ""]

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.mime_point'),
        isShowMenu: true,
        menu: $r('app.media.icon_doubt'),
        onMenuClick: () => {
          //跳转积分说明
          router.pushUrl({
            url: "pages/WebPage", params: {
              "webUrl": "https://www.wanandroid.com/blog/show/2653"
            }
          })
        }
      })

      //前三排名
      RelativeContainer() {

      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_PERCENT_25)
      .backgroundColor($r('app.color.color_272A36'))

      //非前三排名
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
                  Row() {
                    Image($r('app.media.icon_doubt'))
                      .width(SizeConstant.SIZE_25)
                      .height(SizeConstant.SIZE_25)
                      .margin({ left: SizeConstant.SIZE_15 })

                    //姓名
                    Text(item)
                      .fontSize($r('app.float.font_12'))
                      .fontColor($r('app.color.color_666666'))
                      .margin({ left: SizeConstant.SIZE_15 })

                    Blank()

                    //积分
                    Text(item)
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
              }
            }.width(SizeConstant.FULL_SIZE)
          }
        })
      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }
}