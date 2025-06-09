import SizeConstant from '../constants/SizeConstant'
import { Message } from '../pages/ChatPage'
import AudioRendererManager from '../utils/AudioRendererManager'

@Component
export struct ChatAudioView {
  @ObjectLink item: Message
  @Link showPopup: boolean

  build() {
    Row() {
      Blank()
      Text(`${this.item.audioTime}"`)
        .fontSize($r('app.float.font_12'))
        .fontColor(Color.Black)
        .margin({ right: SizeConstant.SIZE_10 })

      Image($r('app.media.icon_audio'))
        .width(SizeConstant.SIZE_15)
        .margin({ right: SizeConstant.SIZE_PERCENT_10 })
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.SIZE_35)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.color_95EC69'))
    .borderRadius(SizeConstant.SIZE_5)
    .gesture(GestureGroup(GestureMode.Exclusive,
      LongPressGesture().onAction((event) => {
        this.showPopup = !this.showPopup
      }),
      TapGesture().onAction((event) => {
        //语音播放
        if (AudioRendererManager.getPlay()) {
          AudioRendererManager.stop().then(() => {
            AudioRendererManager.release()
          })
        } else {
          AudioRendererManager.doPlay(this.item.audioUri)
        }
      })))
  }
}