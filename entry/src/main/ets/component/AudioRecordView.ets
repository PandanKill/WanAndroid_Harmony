import SizeConstant from "../constants/SizeConstant";
import { componentUtils } from "@kit.ArkUI";

/**
 * 录音页面
 */
@Component
export struct AudioRecordView {
  //是否开启抗锯齿 true开启
  private setting: RenderingContextSettings = new RenderingContextSettings(true)
  //创建 context
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting)
  //定时器id
  private voiceTimeId: number = 0
  //取消位置
  private xLocalPosition: ScreenOffset = {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  }
  //录音状态
  @State
  voiceStatus: PressCancelVoicePostText = PressCancelVoicePostText.pressing
  //转文字位置
  private textLocalPosition: ScreenOffset = {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  }
  //录音
  private recordLocalPosition: ScreenOffset = {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  }

  build() {
    RelativeContainer() {
      //底部圆弧
      Row()
        .width(SizeConstant.SIZE_1000)
        .height(SizeConstant.SIZE_1000)
        .backgroundColor($r('app.color.color_D2D2D2'))
        .borderRadius("50%")
        .borderWidth(2)
        .borderColor($r('app.color.color_A9A9A9'))
        .margin({ bottom: "-850vp" })
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
        .id('circle')
        .onAppear(() => {
          let modePosition = componentUtils.getRectangleById('circle')
          this.recordLocalPosition.x = px2vp(modePosition.screenOffset.x)
          this.recordLocalPosition.y = px2vp(modePosition.screenOffset.y)
          this.recordLocalPosition.width = px2vp(modePosition.size.width)
          this.recordLocalPosition.height = px2vp(modePosition.size.height)
        })

      //松开 发送
      Text('松开 发送')
        .fontColor($r('app.color.color_DCDCDC'))
        .fontSize($r('app.float.font_15'))
        .alignRules({
          bottom: { anchor: "circle", align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({ bottom: SizeConstant.SIZE_10 })

      //转文字 发送
      Stack({ alignContent: Alignment.Center }) {
        Text('文')
          .fontSize($r('app.float.font_17'))
          .fontColor($r('app.color.color_DCDCDC'))
      }
      .width(SizeConstant.SIZE_70)
      .height(SizeConstant.SIZE_70)
      .backgroundColor($r('app.color.color_595959'))
      .borderRadius(SizeConstant.SIZE_PERCENT_50)
      .alignRules({
        bottom: { anchor: "circle", align: VerticalAlign.Top },
        right: { anchor: "__container__", align: HorizontalAlign.End }
      })
      .margin({ bottom: SizeConstant.SIZE_30, right: SizeConstant.SIZE_PERCENT_10 })
      .id("wen")
      .onAppear(() => {
        let modePosition = componentUtils.getRectangleById('wen')
        this.textLocalPosition.x = px2vp(modePosition.screenOffset.x)
        this.textLocalPosition.y = px2vp(modePosition.screenOffset.y)
        this.textLocalPosition.width = px2vp(modePosition.size.width)
        this.textLocalPosition.height = px2vp(modePosition.size.height)
      })


      Text("转文字 发送")
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_A1A1A1'))
        .alignRules({
          middle: { anchor: "wen", align: HorizontalAlign.Center },
          bottom: { anchor: "wen", align: VerticalAlign.Top }
        })
        .margin({ bottom: SizeConstant.SIZE_10 })

      //取消
      Stack({ alignContent: Alignment.Center }) {
        Text('X')
          .fontSize($r('app.float.font_17'))
          .fontColor($r('app.color.color_DCDCDC'))
      }
      .width(SizeConstant.SIZE_70)
      .height(SizeConstant.SIZE_70)
      .backgroundColor($r('app.color.color_595959'))
      .borderRadius(SizeConstant.SIZE_PERCENT_50)
      .alignRules({
        bottom: { anchor: "circle", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })
      .margin({ bottom: SizeConstant.SIZE_30, left: SizeConstant.SIZE_PERCENT_10 })
      .id("cha")
      .onAppear(() => {
        let modePosition = componentUtils.getRectangleById('cha')
        this.xLocalPosition.x = px2vp(modePosition.screenOffset.x)
        this.xLocalPosition.y = px2vp(modePosition.screenOffset.y)
        this.xLocalPosition.width = px2vp(modePosition.size.width)
        this.xLocalPosition.height = px2vp(modePosition.size.height)
      })

      Text("取消")
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_A1A1A1'))
        .alignRules({
          middle: { anchor: "cha", align: HorizontalAlign.Center },
          bottom: { anchor: "cha", align: VerticalAlign.Top }
        })
        .margin({ bottom: SizeConstant.SIZE_10 })

      Stack({ alignContent: Alignment.Center }) {
        this.vocalBuilderView()
      }
      .width(SizeConstant.SIZE_PERCENT_40)
      .height(SizeConstant.SIZE_80)
      .backgroundColor($r('app.color.color_95EC69'))
      .borderRadius(SizeConstant.SIZE_15)
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        center: { anchor: "__container__", align: VerticalAlign.Center }
      })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor("#80000000")
  }

  @Builder
  vocalBuilderView() {
    Canvas(this.canvasContext)
      .onDisAppear(() => {
        //关闭计时器
        clearInterval(this.voiceTimeId)
      })
      .width(SizeConstant.SIZE_PERCENT_50)
      .height(SizeConstant.SIZE_PERCENT_80)
      .onReady(() => {
        //绘制
        this.canvasContext.fillStyle = '#4E8F3D'
        clearInterval(this.voiceTimeId)
        this.voiceTimeId = setInterval(() => {
          this.canvasContext.clearRect(0, 0, this.canvasContext.width, this.canvasContext.height)
          for (let index = 0; index < 35; index++) {
            const random = Math.floor(Math.random() * 10)
            let height = 5 + random
            this.canvasContext.fillRect(0 + index * 3, 32 - height / 2, 2, height)
          }
        }, 150)
      })
  }
}

/**
 * 事件枚举
 */
enum PressCancelVoicePostText {
  //没有长按
  none = 0,
  //长按 转语音
  pressing = 1,
  //取消发送
  cancelVoice = 2,
  //转文字
  postText = 3
}

/**
 * 用于记录控件的位置宽高
 */
interface ScreenOffset {
  x: number;
  y: number;
  width: number;
  height: number;
}