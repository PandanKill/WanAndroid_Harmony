import { ResponseBean } from '../bean/ResponseBean'
import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import Api from '../utils/net/Api'

@Entry
@Component
struct EditArticlePage {
  @StorageProp("navHeight") navHeight: number = 0
  @State titleEd: string = ""
  @State linkEd: string = ""

  build() {
    Column() {
      NavHeaderView({
        title: "分享文章",
        isShowMenu: true,
        menu: $r('app.media.icon_share'),
        onMenuClick: () => {
          //校验格式
        }
      })

      //内容
      this.contentBuilder()
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }

  @Builder
  contentBuilder() {
    Column() {
      Text("文章标题")
        .fontColor($r('app.color.color_666666'))
        .fontSize($r('app.float.font_12'))
        .alignSelf(ItemAlign.Start)
        .margin({ top: SizeConstant.SIZE_20 })

      TextArea({
        placeholder: "100字以内",
        text: $$this.titleEd
      })
        .width(SizeConstant.FULL_SIZE)
        .placeholderFont({
          size: $r('app.float.font_13')
        })
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('app.color.color_CCCCCC'))
        .fontColor($r('app.color.color_000000'))
        .padding({ top: SizeConstant.SIZE_10 })
        .fontSize($r('app.float.font_13'))

      Line()
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_1)
        .backgroundColor($r('app.color.color_F0F0F0'))

      Text("文章链接")
        .fontColor($r('app.color.color_666666'))
        .alignSelf(ItemAlign.Start)
        .fontSize($r('app.float.font_12'))
        .margin({ top: SizeConstant.SIZE_10 })

      TextArea({
        placeholder: "记得点击右上角按钮检查链接哦",
        text: $$this.linkEd
      })
        .width(SizeConstant.FULL_SIZE)
        .placeholderColor($r('app.color.color_CCCCCC'))
        .placeholderFont({
          size: $r('app.float.font_13')
        })
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.color_000000'))
        .margin({ top: SizeConstant.SIZE_10 })
        .fontSize($r('app.float.font_13'))

      Line()
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_1)
        .backgroundColor($r('app.color.color_F0F0F0'))

      Button("分享", {
        type: ButtonType.Normal,
        stateEffect: true,
      })
        .margin({ top: SizeConstant.SIZE_25 })
        .borderRadius(SizeConstant.SIZE_8)
        .fontColor(Color.White)
        .width(SizeConstant.SIZE_PERCENT_50)
        .backgroundColor($r('app.color.color_272A36'))
        .onClick(async () => {
          let responseBean: ResponseBean<undefined> = await Api.get().shareArticle(this.titleEd, this.linkEd)
          if (responseBean.isSuccess()) {
            //分享成功

          }
        })

      Blank()

      Text($r('app.string.share_des'))
        .fontSize($r('app.float.font_12'))
        .margin({
          bottom: this.getUIContext().px2vp(this.navHeight)
        })
        .fontColor($r('app.color.color_999999'))

    }.width(SizeConstant.FULL_SIZE)
    .padding({ left: SizeConstant.SIZE_10, right: SizeConstant.SIZE_10 })
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }
}