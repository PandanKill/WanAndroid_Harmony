import { ChatPopupItem } from '../bean/ChatPopupItem'
import { GeneralPopupItemConstant } from '../constants/GeneralPopupItemConstant'
import SizeConstant from '../constants/SizeConstant'
import { Message } from '../pages/ChatPage'
import { ChatAudioView } from './ChatAudioView'
import { promptAction } from '@kit.ArkUI'

/**
 * 聊天内容 View
 */
@Component
export struct ChatTextView {
  @ObjectLink item: Message
  //图片的宽高
  @State picWidth: number = 0
  @State picHeight: number = 0
  @State videoTime: string = ''
  //最大值
  static readonly maxHeight = 150
  static readonly maxWidth = 100
  //是否显示
  @State showPopup: boolean = false

  aboutToAppear(): void {
    //配置图片信息
    if (this.item.textType === 1) {
      if (this.item.imageHeight >= this.item.imageWidth) {
        //高大于宽
        this.picHeight = ChatTextView.maxHeight
        this.picWidth = ChatTextView.maxHeight * this.item.imageWidth / this.item.imageHeight
        console.info(`lgwww ${this.picWidth}`)
      } else {
        //宽大于高
        this.picWidth = ChatTextView.maxWidth
        this.picHeight = ChatTextView.maxWidth * this.item.imageHeight / this.item.imageWidth
        console.info(`lgwww ${this.picHeight}`)
      }
    } else if (this.item.textType === 2) {
      if (this.item.videoTime >= 60) {
        this.videoTime = `${(this.item.videoTime / 60).toString()}:${this.item.videoTime % 60}`
      } else {
        this.videoTime = `0:${this.item.videoTime % 60}`
      }

      if (this.item.videoCapHeight >= this.item.videoCapWidth) {
        //高大于宽
        this.picHeight = ChatTextView.maxHeight
        this.picWidth = ChatTextView.maxHeight * this.item.videoCapWidth / this.item.videoCapHeight
        console.info(`lgwww ${this.picWidth}`)
      } else {
        //宽大于高
        this.picWidth = ChatTextView.maxWidth
        this.picHeight = ChatTextView.maxWidth * this.item.videoCapHeight / this.item.videoCapWidth
        console.info(`lgwww ${this.picHeight}`)
      }
    }
  }

  build() {
    Column() {
      if (this.item.messageType === 1) {
        //横向布局
        Row() {
          Blank()
          //内容
          Column() {
            if (this.item.ownerName !== '') {
              Text(this.item.ownerName)
                .fontColor($r('app.color.color_7B7B7B'))
                .fontSize($r('app.float.font_10'))
                .alignSelf(ItemAlign.End)
            }
            if (this.item.textType === 0) {
              //发送方是文字
              Text(this.item.text)
                .backgroundColor($r('app.color.color_95EC69'))
                .constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
                .borderRadius(SizeConstant.SIZE_5)
                .fontColor(Color.Black)
                .margin({ top: SizeConstant.SIZE_5 })
                .height('auto')
                .padding(SizeConstant.SIZE_10)
                .fontSize($r('app.float.font_15'))
                .textAlign(TextAlign.Start)
                .copyOption(CopyOptions.InApp)
                .gesture(
                  LongPressGesture().onAction((event) => {
                    this.showPopup = !this.showPopup
                  })
                )
                .bindPopup(this.showPopup, {
                  builder: this.popupCustomView(),
                  popupColor: $r('app.color.color_4C4C4C'),
                  backgroundBlurStyle: BlurStyle.NONE,
                  radius: SizeConstant.SIZE_10,
                  onStateChange: (e) => {
                    if (!e.isVisible) {
                      //气泡状态
                      this.showPopup = false
                    }
                  }
                })
            } else if (this.item.textType === 1) {
              //图片
              Image(this.item.imageUri)
                .borderRadius(SizeConstant.SIZE_5)
                .backgroundColor($r('app.color.color_95EC69'))
                .borderWidth(1)
                .borderColor(Color.Gray)
                .objectFit(ImageFit.Contain)
                .width(this.picWidth)
                .height(this.picHeight)//移除自带的拖拽事件
                .draggable(false)
                .gesture(
                  LongPressGesture({ repeat: false }).onAction((event) => {
                    this.showPopup = !this.showPopup
                  })
                )
                .bindPopup(this.showPopup, {
                  builder: this.popupCustomView(),
                  popupColor: Color.Black,
                  backgroundBlurStyle: BlurStyle.NONE,
                  radius: SizeConstant.SIZE_10,
                  onStateChange: (e) => {
                    if (!e.isVisible) {
                      //气泡状态
                      this.showPopup = false
                    }
                  }
                })
            } else if (this.item.textType === 2) {
              //视频
              Stack() {
                Image($r('app.media.icon_play'))
                  .width(SizeConstant.SIZE_50)
                  .aspectRatio(1)
                  .align(Alignment.Center)

                Text(this.videoTime)
                  .fontSize($r('app.float.font_8'))
                  .fontColor(Color.White)
                  .align(Alignment.BottomEnd)
                  .margin({ bottom: SizeConstant.SIZE_2, right: SizeConstant.SIZE_2 })
              }
              .width(this.picWidth)
              .height(this.picHeight)
              .backgroundColor(Color.Black)
              .borderRadius(SizeConstant.SIZE_5)
              .borderColor(Color.Gray)
              .borderWidth(1)
              .gesture(
                LongPressGesture().onAction((event) => {
                  this.showPopup = !this.showPopup
                })
              )
              .bindPopup(this.showPopup, {
                builder: this.popupCustomView(),
                popupColor: Color.Black,
                backgroundBlurStyle: BlurStyle.NONE,
                radius: SizeConstant.SIZE_10,
                onStateChange: (e) => {
                  if (!e.isVisible) {
                    //气泡状态
                    this.showPopup = false
                  }
                }
              })
            } else if (this.item.textType === 3) {
              //语音
              ChatAudioView({
                item: this.item
              })
                .margin({ top: SizeConstant.SIZE_5 })
                .width(SizeConstant.SIZE_PERCENT_40)
            }
          }
          .margin({ right: this.item.textType === 0 || this.item.textType === 3 ? 0 : SizeConstant.SIZE_10 })

          if (this.item.textType === 0 || this.item.textType === 3) {
            Shape() {
              Path()
                .commands('M0 100 L15 115 L0 130 Z')
                .fill($r('app.color.color_95EC69'))
                .strokeOpacity(0)
            }.margin({ right: SizeConstant.SIZE_10 })
          }

          Image(this.item.ownerIcon)
            .width(SizeConstant.SIZE_40)
            .height(SizeConstant.SIZE_40)
            .objectFit(ImageFit.Cover)
            .borderRadius(SizeConstant.SIZE_5)
            .margin({ right: SizeConstant.SIZE_15 })
            .id("sendIconId")
            .backgroundColor(Color.Black)
        }.width(SizeConstant.FULL_SIZE)
        .alignItems(VerticalAlign.Top)
        .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
        .height('auto')
      } else if (this.item.messageType === 2) {

        Row() {
          Image(this.item.ownerIcon)
            .width(SizeConstant.SIZE_40)
            .height(SizeConstant.SIZE_40)
            .borderRadius(SizeConstant.SIZE_5)
            .objectFit(ImageFit.Cover)
            .margin({ left: SizeConstant.SIZE_15 })
            .id("receiverIconId")
            .backgroundColor(Color.Black)

          Shape() {
            Path()
              .commands('M15 100 L0 115 L15 130 Z')
              .fill($r('app.color.color_FFFFFF'))
              .strokeOpacity(0)
          }.margin({ left: SizeConstant.SIZE_10 })

          Column() {
            if (this.item.ownerName !== '') {
              Text(this.item.ownerName)
                .fontColor($r('app.color.color_7B7B7B'))
                .fontSize($r('app.float.font_10'))
                .alignSelf(ItemAlign.Start)
            }
            if (this.item.messageStatus == 0) {
              //加载中
              Text("数据加载中。")
                .backgroundColor($r('app.color.color_FFFFFF'))
                .constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
                .borderRadius(SizeConstant.SIZE_5)
                .fontColor(Color.Black)
                .padding(SizeConstant.SIZE_10)
                .margin({ top: SizeConstant.SIZE_5 })
                .height('auto')
                .fontSize($r('app.float.font_15'))
                .textAlign(TextAlign.Start)
                .copyOption(CopyOptions.InApp)
            } else if (this.item.messageStatus == 1) {
              //加载成功
              Text(this.item.text)
                .backgroundColor($r('app.color.color_FFFFFF'))
                .constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
                .borderRadius(SizeConstant.SIZE_5)
                .fontColor(Color.Black)
                .padding(SizeConstant.SIZE_10)
                .margin({ top: SizeConstant.SIZE_5 })
                .height('auto')
                .fontSize($r('app.float.font_15'))
                .textAlign(TextAlign.Start)
                .copyOption(CopyOptions.InApp)
            } else {
              //加载失败
              Text("服务器繁忙，请稍后再试。")
                .backgroundColor($r('app.color.color_FFFFFF'))
                .constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
                .borderRadius(SizeConstant.SIZE_5)
                .fontColor(Color.Black)
                .padding(SizeConstant.SIZE_10)
                .margin({ top: SizeConstant.SIZE_5 })
                .height('auto')
                .fontSize($r('app.float.font_15'))
                .textAlign(TextAlign.Start)
                .copyOption(CopyOptions.InApp)
            }

          }.alignItems(HorizontalAlign.Start)

        }.width(SizeConstant.FULL_SIZE)
        .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
        .alignItems(VerticalAlign.Top)
        .height('auto')
      } else {
        Column() {
          Text(this.item.text)
            .fontColor($r('app.color.color_A5A5A5'))
            .fontSize($r('app.float.font_10'))
        }.alignItems(HorizontalAlign.Center)
        .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
        .width(SizeConstant.FULL_SIZE)
      }
    }
  }

  @Builder
  popupCustomView() {
    Stack({ alignContent: Alignment.Center }) {
      Grid() {
        ForEach(GeneralPopupItemConstant.CommonItem, (item: ChatPopupItem, index: number) => {
          GridItem() {
            Column() {
              Image(item.icon)
                .width(SizeConstant.SIZE_15)
                .aspectRatio(1)

              Text(item.text)
                .fontColor(Color.White)
                .fontSize($r('app.float.font_12'))
                .padding(SizeConstant.SIZE_5)

            }.alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.showPopup = false
              promptAction.showToast({
                message: item.text
              })
            })
          }
        }, (item: ChatPopupItem, index: number) => JSON.stringify(item) + index)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }.width('auto')
    .constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
    .padding({
      top: SizeConstant.SIZE_15,
      bottom: SizeConstant.SIZE_15,
      left: SizeConstant.SIZE_10,
      right: SizeConstant.SIZE_10
    })
  }
}