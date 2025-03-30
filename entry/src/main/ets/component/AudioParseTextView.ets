import SizeConstant from "../constants/SizeConstant";

/**
 * 语音解析成文字 View
 */
@Component
export struct AudioParseTextView {
  //解析状态
  @State errorStatus: boolean = false
  //正在解析
  @State isLoading: boolean = true
  @State msg: string = ''
  //返回
  @Link isParse: boolean

  aboutToAppear(): void {
    setTimeout(() => {
      this.msg = "你好世界，我是开始"
      this.errorStatus = true
      this.isLoading = false
    }, 3000)
  }

  build() {
    RelativeContainer() {
      Stack({ alignContent: Alignment.Center }) {
        Text(this.isLoading ? "..." : this.errorStatus ? "未识别到文字" : this.msg)
          .fontSize($r('app.float.font_20'))
          .fontColor(Color.Black)
          .width(SizeConstant.FULL_SIZE)
      }
      .padding(SizeConstant.SIZE_20)
      .width(SizeConstant.SIZE_PERCENT_90)
      .height('auto')
      .backgroundColor(this.errorStatus ? $r('app.color.color_FB5251') :
      $r('app.color.color_95EC69'))
      .borderRadius(SizeConstant.SIZE_15)
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        center: { anchor: "__container__", align: VerticalAlign.Center }
      })

      Row() {
        //取消
        Column() {
          Image($r('app.media.icon_back_e1e1e1'))
            .width(SizeConstant.SIZE_25)

          Text("取消")
            .fontSize($r('app.float.font_12'))
            .fontColor($r('app.color.color_e1e1e1'))
            .margin({ top: SizeConstant.SIZE_5 })
        }.alignItems(HorizontalAlign.Center)
        .onClick(() => {
          //取消
          this.isParse = false
        })

        //发送原语音
        Column() {
          Image($r('app.media.icon_audio_e1'))
            .width(SizeConstant.SIZE_25)

          Text("发送原语音")
            .fontSize($r('app.float.font_12'))
            .fontColor($r('app.color.color_e1e1e1'))
            .margin({ top: SizeConstant.SIZE_5 })
        }.alignItems(HorizontalAlign.Center)
        .onClick(() => {
          //原语音
          this.isParse = false
        })

        //转文字 发送
        Stack({ alignContent: Alignment.Center }) {
          Image(this.isLoading ? $r('app.media.icon_loading_green') :
            this.errorStatus ? $r('app.media.icon_right_grey') : $r('app.media.icon_right_gre'))
            .width(SizeConstant.SIZE_25)
        }
        .width(SizeConstant.SIZE_80)
        .height(SizeConstant.SIZE_80)
        .backgroundColor(this.errorStatus ? $r('app.color.color_505050') : $r('app.color.color_ECECEC'))
        .borderRadius(SizeConstant.SIZE_PERCENT_50)
        .onClick(()=>{
          if (this.errorStatus) {
            return
          }
          this.isParse = false
        })
      }
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: '180vp' })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor("#90000000")
  }
}