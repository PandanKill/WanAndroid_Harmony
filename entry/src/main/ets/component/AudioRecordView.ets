import SizeConstant from "../constants/SizeConstant";
import { componentUtils } from "@kit.ArkUI";
import { EventState } from "../pages/ChatPage";
import { CustomTouchType } from "../bean/TouchType";
import { AudioParseTextView } from "./AudioParseTextView";

/**
 * 录音页面
 */
@Component
export struct AudioRecordView {
  //事件传递
  @ObjectLink @Watch('touchEvent') event: EventState
  //是否开启抗锯齿 true开启
  private setting: RenderingContextSettings = new RenderingContextSettings(true)
  //创建 context
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting)
  //定时器id
  private voiceTimeId: number = 0
  @State vocalWidth: string = SizeConstant.SIZE_PERCENT_40
  @State vocalHeight: string = SizeConstant.SIZE_80
  @State vocalContentWidth: string = SizeConstant.SIZE_PERCENT_50
  @State vocalContentMargin: string = SizeConstant.SIZE_0
  //录音配置
  @State vocalAlignment: Alignment = Alignment.Center
  //居中显示
  private centerRule: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }
  //居左显示
  private leftRule: AlignRuleOption = {
    middle: { anchor: "cha", align: HorizontalAlign.Center },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }
  @State vocalPositionCenterRule: AlignRuleOption = this.centerRule
  //正在解析语音
  @Link audioParse: boolean
  @Link audioRecord: boolean
  //数据发送(转文字或语音)
  onDataSend: (textType: number) => void = () => {
  }
  //取消位置
  private xLocalPosition: ScreenOffset = {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  }
  //录音状态
  @State
  @Watch('voiceChange') voiceStatus: PressCancelVoicePostText = PressCancelVoicePostText.pressing
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

  /**
   * 状态变化
   */
  voiceChange() {
    if (this.voiceStatus === PressCancelVoicePostText.pressing) {
      //发送语音
      this.getUIContext().animateTo({
        duration: 100,
        curve: Curve.Linear
      }, () => {
        this.vocalPositionCenterRule = this.centerRule
        this.vocalWidth = SizeConstant.SIZE_PERCENT_40
        this.vocalHeight = SizeConstant.SIZE_80
        this.vocalAlignment = Alignment.Center
        this.vocalContentWidth = SizeConstant.SIZE_PERCENT_50
        this.vocalContentMargin = SizeConstant.SIZE_0
      })
    } else if (this.voiceStatus === PressCancelVoicePostText.postText) {
      //转文字
      this.getUIContext().animateTo({
        duration: 100,
        curve: Curve.Linear
      }, () => {
        this.vocalPositionCenterRule = this.centerRule
        this.vocalWidth = SizeConstant.SIZE_PERCENT_90
        this.vocalHeight = 'auto'
        this.vocalAlignment = Alignment.BottomEnd
        this.vocalContentWidth = SizeConstant.SIZE_PERCENT_10
        this.vocalContentMargin = SizeConstant.SIZE_10
      })
    } else if (this.voiceStatus === PressCancelVoicePostText.cancelVoice) {
      //取消
      this.getUIContext().animateTo({
        duration: 100,
        curve: Curve.Linear
      }, () => {
        this.vocalPositionCenterRule = this.leftRule
        this.vocalWidth = SizeConstant.SIZE_PERCENT_20
        this.vocalHeight = SizeConstant.SIZE_80
        this.vocalAlignment = Alignment.Center
        this.vocalContentWidth = SizeConstant.SIZE_PERCENT_50
        this.vocalContentMargin = SizeConstant.SIZE_0
      })
    }
  }

  /**
   * 事件更新
   */
  touchEvent() {
    if (this.event.type !== undefined) {
      if (this.event.type === CustomTouchType.Down) {
        //手指按下
        this.voiceStatus = PressCancelVoicePostText.pressing
      } else if (this.event.type === CustomTouchType.Move) {
        const x = this.event.x
        const y = this.event.y
        let isTouchRecord =
          this.recordLocalPosition.x <= x && this.recordLocalPosition.x + this.recordLocalPosition.width >= x
            && this.recordLocalPosition.y <= y && this.recordLocalPosition.y + this.recordLocalPosition.height >= y

        let isTouchX = this.xLocalPosition.x <= x && this.xLocalPosition.x + this.xLocalPosition.width >= x
          && this.xLocalPosition.y <= y && this.xLocalPosition.y + this.xLocalPosition.height >= y

        let isTouchText = this.textLocalPosition.x <= x && this.textLocalPosition.x + this.textLocalPosition.width >= x
          && this.textLocalPosition.y <= y && this.textLocalPosition.y + this.textLocalPosition.height >= y
        if (isTouchRecord) {
          //录音
          this.voiceStatus = PressCancelVoicePostText.pressing
        } else if (isTouchText) {
          //转文字
          this.voiceStatus = PressCancelVoicePostText.postText
        } else if (isTouchX) {
          //取消
          this.voiceStatus = PressCancelVoicePostText.cancelVoice
        }
      } else if (this.event.type === CustomTouchType.Up) {
        if (this.voiceStatus === PressCancelVoicePostText.pressing) {
          //发送语音
          this.onDataSend(3)
        } else if (this.voiceStatus === PressCancelVoicePostText.postText) {
          //语音解析成文字
          this.audioRecord = false
          this.audioParse = true
        } else if (this.voiceStatus === PressCancelVoicePostText.cancelVoice) {
          //取消
          this.audioRecord = false
        }
      }

    }
  }

  build() {
    RelativeContainer() {
      //底部圆弧
      Row()
        .width(SizeConstant.SIZE_1000)
        .height(SizeConstant.SIZE_1000)
        .backgroundColor(this.voiceStatus === PressCancelVoicePostText.pressing ? $r('app.color.color_D2D2D2') :
        $r('app.color.color_595959'))
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
      if (this.voiceStatus === PressCancelVoicePostText.pressing) {
        Text('松开 发送')
          .fontColor($r('app.color.color_DCDCDC'))
          .fontSize($r('app.float.font_15'))
          .alignRules({
            bottom: { anchor: "circle", align: VerticalAlign.Top },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .margin({ bottom: SizeConstant.SIZE_10 })
      }

      //转文字 发送
      Stack({ alignContent: Alignment.Center }) {
        Text('文')
          .fontSize($r('app.float.font_17'))
          .fontColor(this.voiceStatus === PressCancelVoicePostText.postText ? $r('app.color.color_181818') :
          $r('app.color.color_DCDCDC'))
      }
      .width(this.voiceStatus === PressCancelVoicePostText.postText ? SizeConstant.SIZE_80 : SizeConstant.SIZE_70)
      .height(this.voiceStatus === PressCancelVoicePostText.postText ? SizeConstant.SIZE_80 : SizeConstant.SIZE_70)
      .backgroundColor(this.voiceStatus === PressCancelVoicePostText.postText ? $r('app.color.color_ECECEC') :
      $r('app.color.color_595959'))
      .borderRadius(this.voiceStatus === PressCancelVoicePostText.postText ? SizeConstant.SIZE_40 :
      SizeConstant.SIZE_35)
      .alignRules({
        bottom: { anchor: "circle", align: VerticalAlign.Top },
        right: { anchor: "__container__", align: HorizontalAlign.End }
      })
      .margin({ bottom: SizeConstant.SIZE_30, right: SizeConstant.SIZE_PERCENT_10 })
      .id("wen")
      .onAppear(() => {
        // let modePosition = componentUtils.getRectangleById('wen')
        // this.textLocalPosition.x = px2vp(modePosition.screenOffset.x)
        // this.textLocalPosition.y = px2vp(modePosition.screenOffset.y)
        // this.textLocalPosition.width = px2vp(modePosition.size.width)
        // this.textLocalPosition.height = px2vp(modePosition.size.height)
      })

      Text("转文字 发送")
        .fontSize($r('app.float.font_15'))
        .fontColor(this.voiceStatus === PressCancelVoicePostText.postText ? $r('app.color.color_DBDBDB') :
        $r('app.color.color_A1A1A1'))
        .alignRules({
          middle: { anchor: "wen", align: HorizontalAlign.Center },
          bottom: { anchor: "wen", align: VerticalAlign.Top }
        })
        .margin({ bottom: SizeConstant.SIZE_10 })


      //取消
      Stack({ alignContent: Alignment.Center }) {
        Text('X')
          .fontSize($r('app.float.font_17'))
          .fontColor(this.voiceStatus === PressCancelVoicePostText.cancelVoice ? $r('app.color.color_181818') :
          $r('app.color.color_DCDCDC'))
      }
      .width(this.voiceStatus === PressCancelVoicePostText.cancelVoice ? SizeConstant.SIZE_80 : SizeConstant.SIZE_70)
      .height(this.voiceStatus === PressCancelVoicePostText.cancelVoice ? SizeConstant.SIZE_80 : SizeConstant.SIZE_70)
      .backgroundColor(this.voiceStatus === PressCancelVoicePostText.cancelVoice ? $r('app.color.color_ECECEC') :
      $r('app.color.color_595959'))
      .borderRadius(this.voiceStatus === PressCancelVoicePostText.cancelVoice ? SizeConstant.SIZE_40 :
      SizeConstant.SIZE_35)
      .alignRules({
        bottom: { anchor: "circle", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })
      .margin({ bottom: SizeConstant.SIZE_30, left: SizeConstant.SIZE_PERCENT_10 })
      .id("cha")
      .onAppear(() => {
        // let modePosition = componentUtils.getRectangleById('cha')
        // this.xLocalPosition.x = px2vp(modePosition.screenOffset.x)
        // this.xLocalPosition.y = px2vp(modePosition.screenOffset.y)
        // this.xLocalPosition.width = px2vp(modePosition.size.width)
        // this.xLocalPosition.height = px2vp(modePosition.size.height)
      })

      Text("取消")
        .fontSize($r('app.float.font_15'))
        .fontColor(this.voiceStatus === PressCancelVoicePostText.cancelVoice ? $r('app.color.color_DBDBDB') :
        $r('app.color.color_A1A1A1'))
        .alignRules({
          middle: { anchor: "cha", align: HorizontalAlign.Center },
          bottom: { anchor: "cha", align: VerticalAlign.Top }
        })
        .margin({ bottom: SizeConstant.SIZE_10 })

      Stack({ alignContent: this.vocalAlignment }) {
        this.vocalBuilderView()
      }
      .width(this.vocalWidth)
      .height(this.vocalHeight)
      .backgroundColor(this.voiceStatus === PressCancelVoicePostText.cancelVoice ? $r('app.color.color_FB5251') :
      $r('app.color.color_95EC69'))
      .borderRadius(SizeConstant.SIZE_15)
      .alignRules(this.vocalPositionCenterRule)

      //录音图标
      Image(this.voiceStatus !== PressCancelVoicePostText.pressing ? $r('app.media.icon_audio_e1') :
      $r('app.media.icon_audio_5b'))
        .width(SizeConstant.SIZE_30)
        .alignRules({
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
        .margin({ bottom: SizeConstant.SIZE_20 })
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .id('mainContent')
    .onAppear(() => {
      let modePosition = componentUtils.getRectangleById('mainContent')
      this.xLocalPosition.x = px2vp(modePosition.screenOffset.x)
      this.xLocalPosition.y = px2vp(modePosition.screenOffset.y)
      this.xLocalPosition.width = px2vp(modePosition.size.width / 2)
      this.xLocalPosition.height = px2vp(modePosition.size.height)

      this.textLocalPosition.x = px2vp(modePosition.size.width / 2)
      this.textLocalPosition.y = px2vp(modePosition.screenOffset.y)
      this.textLocalPosition.width = px2vp(modePosition.size.width / 2)
      this.textLocalPosition.height = px2vp(modePosition.size.height)
    })
    .backgroundColor("#90000000")
  }

  @Builder
  vocalBuilderView() {
    Canvas(this.canvasContext)
      .onDisAppear(() => {
        //关闭计时器
        clearInterval(this.voiceTimeId)
      })
      .width(this.vocalContentWidth)
      .height(SizeConstant.SIZE_64)
      .margin({ right: this.vocalContentMargin })
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