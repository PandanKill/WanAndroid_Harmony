import SizeConstant from "../constants/SizeConstant"
import { Message } from "../pages/ChatPage"

@Component
export struct ChatVideoDetailContent {
  @Prop detailMessage: Message
  @Link chatVideoDetailContent: boolean
  controller: VideoController = new VideoController()
  //播放状态
  @State @Watch('playInvoke') playState: boolean = true
  @State showSlider: boolean = true
  //视频总时长
  @State totalDurationStr: string = '00:00'
  @State curDurationStr: string = '00:00'
  @State totalDuration: number = 0
  @State curDuration: number = 0
  //倍速
  @State speedText: string | Resource = $r('app.string.speed1')
  @State curSpeed: number = PlaybackSpeed.Speed_Forward_1_00_X

  playInvoke() {
    if (this.playState) {
      this.controller.start()
    } else {
      this.controller.pause()
    }
  }

  build() {
    Stack({
      alignContent: Alignment.Bottom
    }) {
      //视频
      Video({
        src: this.detailMessage.videoUri,
        currentProgressRate: this.curSpeed,
        controller: this.controller
      })
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.FULL_SIZE)
        .backgroundColor(Color.Black)
        .controls(false)
        .autoPlay(true)
        .objectFit(ImageFit.Contain)
        .onFinish(() => {
          this.playState = false
        })
        .onPrepared((e) => {
          console.info('VideoPage_onPrepared:' + e.duration);
          this.totalDuration = e.duration
          let min = Math.floor(e.duration / 60)
          let second = e.duration % 60
          this.totalDurationStr = `${min}:${second}`
        })
        .onUpdate((e) => {
          console.info('VideoPage_onPrepared:' + e.time);
          this.curDuration = e.time
          let min = Math.floor(e.time / 60)
          let second = e.time % 60
          this.curDurationStr = `${min}:${second}`
        })
        .onClick(() => {
          //点击
          // this.showSlider = !this.showSlider
          this.chatVideoDetailContent = false
        })

      if (this.showSlider) {
        Row() {
          //状态
          Image(this.playState ? $r('app.media.icon_pause') : $r('app.media.icon_video_play'))
            .width(SizeConstant.SIZE_30)
            .onClick(() => {
              this.playState = !this.playState
            })

          Column() {

            Row() {
              //当前时间
              Text(this.curDurationStr)
                .fontColor($r('app.color.color_A6B4BF'))
                .fontWeight(500)
                .fontSize($r('app.float.font_12'))

              Text("/")
                .fontColor($r('app.color.color_A6B4BF'))
                .fontSize($r('app.float.font_12'))
                .fontWeight(500)
                .margin({ left: SizeConstant.SIZE_3 })

              //总时间
              Text(this.totalDurationStr)
                .fontColor($r('app.color.color_A6B4BF'))
                .fontSize($r('app.float.font_12'))
                .fontWeight(500)
                .margin({ left: SizeConstant.SIZE_3 })

              Blank()

              //倍速
              Text(this.speedText)
                .fontColor($r('app.color.color_A6B4BF'))
                .fontSize($r('app.float.font_12'))
                .fontWeight(500)
                .onClick(() => {
                  this.changeRate()
                })
            }.width(SizeConstant.FULL_SIZE)
            .padding({ left: SizeConstant.SIZE_10, right: SizeConstant.SIZE_10 })

            Slider({
              value: this.curDuration,
              min: 0,
              max: this.totalDuration
            })
              .selectedColor(Color.White)
              .trackColor($r('app.color.color_79898F'))
              .width(SizeConstant.FULL_SIZE)
              .onChange((value: number, mode: SliderChangeMode) => {
                if (mode === SliderChangeMode.End) {
                  this.playState = true
                  this.controller.setCurrentTime(value)
                } else if (mode === SliderChangeMode.Begin) {
                  //不播放
                  this.playState = false
                }
              })

          }.layoutWeight(1)
          .justifyContent(FlexAlign.SpaceBetween)

        }.width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_50)
        .alignItems(VerticalAlign.Center)
        .margin({
          left: SizeConstant.SIZE_50,
          right: SizeConstant.SIZE_50,
          bottom: SizeConstant.SIZE_50
        })
      }
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }

  /**
   * 更新倍速
   */
  changeRate() {
    if (this.curSpeed == PlaybackSpeed.Speed_Forward_1_00_X) {
      this.curSpeed = PlaybackSpeed.Speed_Forward_1_25_X
      this.speedText = $r('app.string.speed125')
    } else if (this.curSpeed == PlaybackSpeed.Speed_Forward_1_25_X) {
      this.curSpeed = PlaybackSpeed.Speed_Forward_2_00_X
      this.speedText = $r('app.string.speed2')
    } else {
      this.curSpeed = PlaybackSpeed.Speed_Forward_1_00_X
      this.speedText = $r('app.string.speed1')
    }
  }

  aboutToDisappear(): void {
    //销毁

  }
}