import { LoadState } from '../bean/LoadState'
import { ResponseBean } from '../bean/ResponseBean'
import { NavHeaderView } from '../component/NavHeaderView'
import { TextAreaComponent } from '../component/TextAreaComponent'
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

      TextAreaComponent({
        placeholder: "100字以内",
        inputText: this.titleEd
      })
        .margin({ top: SizeConstant.SIZE_10 })

      Text("文章链接")
        .fontColor($r('app.color.color_666666'))
        .alignSelf(ItemAlign.Start)
        .fontSize($r('app.float.font_12'))
        .margin({ top: SizeConstant.SIZE_10 })

      TextAreaComponent({
        placeholder: "记得点击右上角按钮检查链接哦",
        inputText: this.linkEd
      })
        .margin({ top: SizeConstant.SIZE_10 })

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
          if (this.titleEd === '' || this.linkEd === '') {
            this.getUIContext().getPromptAction().showToast({
              message: "参数为空"
            })
            return
          }

          let responseBean: ResponseBean<undefined> = await Api.get().shareArticle(this.titleEd, this.linkEd)
          if (responseBean.isSuccess()) {
            //分享成功
            this.getUIContext().getPromptAction().showToast({
              message: "分享成功"
            })
            this.getUIContext().getRouter().back()
          } else {
            //分享失败
            this.getUIContext().getPromptAction().showToast({
              message: `分享失败:${responseBean.getErrorMsg()}`
            })
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