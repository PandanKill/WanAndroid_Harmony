import { ChatPopupItem } from '../bean/ChatPopupItem'
import { GeneralPopupItemConstant } from '../constants/GeneralPopupItemConstant'
import SizeConstant from '../constants/SizeConstant'
import { Message } from '../pages/ChatPage'
import { ChatAudioView } from './ChatAudioView'
import { componentUtils, curves, inspector, promptAction } from '@kit.ArkUI'
import itemClickManager from '../componentManager/PopupItemClickManager'
import { TranslateView } from './TranslateView'
import { ReferenceChatView } from './ReferenceChatView'
import { ChatTextDetailContent } from './ChatTextDetailContent'
import { ChatPicDetailContent } from './ChatPicDetailContent'
import { image } from '@kit.ImageKit'
import { getFetchFrameByTime } from '../utils/CommonUtils'
import { BusinessError } from '@kit.BasicServicesKit'
import { ChatVideoDetailContent } from './ChatVideoDetailContent'
import { WindowUtils } from '../utils/WindowUtils'
import { ComponentAttrUtils, RectInfoInPx } from '../utils/ComponentAttrUtils'

/**
 * 聊天内容 View
 */
@Component
export struct ChatItemView {
  @ObjectLink item: Message
  //索引
  @Prop @Require index: number
  //图片的宽高
  @State picWidth: number = 0
  @State picHeight: number = 0
  //视频时长
  @State videoTime: string = ''
  //最大值
  static readonly maxHeight = 150
  static readonly maxWidth = 200
  //是否显示
  @State showPopup: boolean = false
  //是否显示全屏模态
  @State showTextContent: boolean = false
  @State showPicContent: boolean = false
  @State showVideoContent: boolean = false
  //引用内容
  @State popItem: ChatPopupItem[] = []
  //文字选中
  @State start: number = -1
  @State end: number = -1
  @State bgPixel: image.PixelMap | undefined | Resource = undefined
  // Capture the original location of the photo.
  @State scaleValue: number = 1;
  @State translateX: number = 0;
  @State clipWidth: Dimension = 0;
  @State clipHeight: Dimension = 0;
  @State translateY: number = 0;
  @State isAnimating: boolean = false;
  // Transparency of the artwork.
  @State opacityDegree: number = 1;
  //size 更新
  @Consume('itemSizeChange') itemSizeChange: boolean
  //监听模态页面
  listener: inspector.ComponentObserver = inspector.createComponentObserver('imageDetail');

  aboutToAppear() {
    this.initCoverListener()
    //配置图片信息
    if (this.item.textType === 1) {
      this.popItem = [...GeneralPopupItemConstant.CommonItem, ...GeneralPopupItemConstant.PicCommonItem]
      let widthScaleRatio = this.item.imageWidth / vp2px(ChatItemView.maxWidth);
      let heightScaleRatio = this.item.imageHeight / vp2px(ChatItemView.maxHeight);
      let isUseWidthScale = widthScaleRatio > heightScaleRatio;
      if (!isUseWidthScale) {
        //高大于宽
        this.picHeight = ChatItemView.maxHeight
        this.picWidth = ChatItemView.maxHeight * this.item.imageWidth / this.item.imageHeight
      } else {
        //宽大于高
        this.picWidth = ChatItemView.maxWidth
        this.picHeight = ChatItemView.maxWidth * this.item.imageHeight / this.item.imageWidth
      }
    } else if (this.item.textType === 2) {
      //视频
      this.popItem = [...GeneralPopupItemConstant.CommonItem, ...GeneralPopupItemConstant.VideoCommonItem]
      if (this.item.videoTime >= 60) {
        this.videoTime = `${(this.item.videoTime / 60).toString()}:${this.item.videoTime % 60}`
      } else {
        this.videoTime = `0:${this.item.videoTime % 60}`
      }

      if (this.item.videoCapHeight >= this.item.videoCapWidth) {
        //高大于宽
        this.picHeight = ChatItemView.maxHeight
        this.picWidth = ChatItemView.maxHeight * this.item.videoCapWidth / this.item.videoCapHeight
        console.info(`lgwww ${this.picWidth}`)
      } else {
        //宽大于高
        this.picWidth = ChatItemView.maxWidth
        this.picHeight = ChatItemView.maxWidth * this.item.videoCapHeight / this.item.videoCapWidth
        console.info(`lgwww ${this.picHeight}`)
      }

      //获取缩略图
      getFetchFrameByTime(0, this.item.videoUri, vp2px(this.picWidth), vp2px(this.picHeight))
        .then((pix: image.PixelMap) => {
          this.bgPixel = pix
        })
        .catch((err: BusinessError) => {
          if (err) {
            console.error(err.message)
            this.bgPixel = $r('app.media.pre')
          }
        })
    } else if (this.item.textType === 0) {
      //文字
      this.popItem = [...GeneralPopupItemConstant.CommonItem, ...GeneralPopupItemConstant.TextCommonItem]
    } else if (this.item.textType === 3) {
      //语音
      this.popItem = [...GeneralPopupItemConstant.CommonItem, ...GeneralPopupItemConstant.AudioCommonItem]
    }
  }

  initCoverListener() {
    let onLayoutComplete = () => {
      let targetInfo = ComponentAttrUtils.getRectInfoById(this.getUIContext(), 'imageDetail')
      // Only half modes are correctly laid out and a mirror is triggered when there is no animation at this time.
      if (!this.isAnimating) {
        this.isAnimating = true;
        // Property animation for a mirror to the bottom of a modal page.
        animateTo({
          duration: 1000,
          curve: Curve.Friction,
        }, () => {
          // this.scaleValue = 2;
          this.translateX = px2vp(WindowUtils.windowWidth_px / 2);
          this.clipWidth = '100%';
          this.clipHeight = '100%';
          // Fixed height differences due to half-mode height and scaling.
          this.translateY = px2vp(WindowUtils.windowHeight_px / 2);
          console.info(`lgwwww animEnd::::scale: ${this.scaleValue}, translateX:${this.translateX}, translateY:${this.translateY}, clipWidth:${this.clipWidth}, clipHeight:${this.clipHeight}`)
        })
      }
    }

    // this.listener.on('layout', onLayoutComplete)
  }

  build() {
    Column() {
      if (this.item.messageType === 1) {
        //发送方
        this.sendMessageItem()
      } else if (this.item.messageType === 2) {
        //接收方
        this.receiverMessageItem()
      } else {
        //时间
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

  /**
   * 发送方消息
   */
  @Builder
  sendMessageItem() {
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
          this.sendTextMessage()
        } else if (this.item.textType === 1) {
          this.sendPicMessage()
        } else if (this.item.textType === 2) {
          this.sendVideoMessage()
        } else if (this.item.textType === 3) {
          this.sendAudioMessage()
        }

        //翻译
        if (this.item.translateEnable) {
          //展示翻译内容
          TranslateView({
            isLoading: this.item.translateLoading,
            translateText: this.item.translateText
          })
        }
        if (this.item.referEnable) {
          //展示引用信息
          ReferenceChatView({
            referText: this.item.referText
          })
        }
      }
      .alignItems(HorizontalAlign.End)
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
  }

  @Builder
  sendAudioMessage() {
    //语音
    ChatAudioView({
      item: this.item,
      showPopup: this.showPopup
    })
      .margin({ top: SizeConstant.SIZE_5 })
      .width(SizeConstant.SIZE_PERCENT_40)
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
  }

  /**
   * 发送视频
   */
  @Builder
  sendVideoMessage() {
    //视频
    RelativeContainer() {
      Image($r('app.media.icon_play'))
        .width(SizeConstant.SIZE_50)
        .aspectRatio(1)
        .align(Alignment.Center)
        .alignRules({
          middle: {
            anchor: "__container__", align: HorizontalAlign.Center
          },
          center: {
            anchor: "__container__", align: VerticalAlign.Center
          }
        })

      Text(this.videoTime)
        .fontSize($r('app.float.font_8'))
        .fontColor(Color.White)
        .margin({ bottom: SizeConstant.SIZE_2, right: SizeConstant.SIZE_2 })
        .alignRules({
          bottom: {
            anchor: "__container__", align: VerticalAlign.Bottom
          },
          end: {
            anchor: "__container__", align: HorizontalAlign.End
          }
        })
    }
    .width(this.picWidth)
    .height(this.picHeight)
    .backgroundImage(this.bgPixel)
    .backgroundImageSize({
      width: this.picWidth,
      height: this.picHeight
    })
    .backgroundImagePosition(Alignment.Center)
    .borderRadius(SizeConstant.SIZE_5)
    .borderColor(Color.Gray)
    .borderWidth(1)
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture().onAction((event) => {
          this.showPopup = !this.showPopup
        }),
        TapGesture({ count: 1 }).onAction((event) => {
          this.showVideoContent = true
        })
      )
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
    .bindContentCover(this.showVideoContent, this.contentVideoCover(this.item), {
      onDisappear: () => {
        this.showVideoContent = false
      }
    })
  }

  /**
   * 发送方图片
   */
  @Builder
  sendPicMessage() {
    //图片
    Image(this.item.imageUri)
      .borderRadius(SizeConstant.SIZE_5)
      .backgroundColor($r('app.color.color_95EC69'))
      .borderWidth(1)
      .borderColor(Color.Gray)
      .objectFit(ImageFit.Contain)
      .width(this.picWidth)
      .opacity(this.opacityDegree)
      .height(this.picHeight)//移除自带的拖拽事件
      .draggable(false)
      .id('imageChat')
      .gesture(
        GestureGroup(
          GestureMode.Exclusive,
          LongPressGesture({ repeat: false }).onAction((event) => {
            this.showPopup = !this.showPopup
          }),
          TapGesture({ count: 1 }).onAction((event) => {
            // let originInfo = ComponentAttrUtils.getRectInfoById(this.getUIContext(), "imageChat")
            // this.translateX = px2vp(originInfo.left - (WindowUtils.windowWidth_px - originInfo.width) / 2) - px2vp(WindowUtils.windowWidth_px / 2);
            // this.translateY = px2vp(originInfo.top + originInfo.height / 2) - px2vp(WindowUtils.windowHeight_px / 2)
            // this.clipWidth = this.picWidth
            // this.clipHeight = this.picHeight
            // this.opacityDegree = 0
            this.showPicContent = true
          })
        )
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
      .bindContentCover(this.showPicContent, this.contentPicCover(this.item, this.index), {
        transition: TransitionEffect.IDENTITY,
        onDisappear: () => {
          this.showPicContent = false
          this.opacityDegree = 1
        }
      })
  }

  /**
   * 发送方文字
   */
  @Builder
  sendTextMessage() {
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
      .copyOption(CopyOptions.None)
      .draggable(true)
      .gesture(
        GestureGroup(
          GestureMode.Exclusive,
          LongPressGesture().onAction((event) => {
            this.start = 0
            this.end = this.item.text.length - 1
            this.showPopup = !this.showPopup
          }),
          TapGesture({ count: 2 }).onAction((event) => {
            //双击,展示详情页
            this.showTextContent = true
          })
        )

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
      .bindContentCover(this.showTextContent, this.contentTextCover(this.item), {
        onDisappear: () => {
          this.showTextContent = false
        }
      })
  }

  /**
   * 接收方文字
   */
  @Builder
  receiverMessageItem() {
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
            .copyOption(CopyOptions.None)// .onAreaChange((oldVal, newVal) => {
              //   this.itemSizeChange = oldVal.height !== newVal.height
              //   console.info(`onAreaChange oldVal height: ${oldVal.height}, newVal: ${newVal.height}`)
              // })
            .onSizeChange((oldVal, newVal) => {
              let changeVal = oldVal.height?.valueOf() !== newVal.height?.valueOf()
              if (changeVal) {
                this.itemSizeChange = !this.itemSizeChange
              }
              console.info(`onSizeChange oldVal height: ${oldVal.height}, newVal: ${newVal.height}`)
            })
            .onTextSelectionChange((start, end) => {

            })
            .gesture(
              TapGesture({ count: 2 }).onAction((event) => {
                this.showTextContent = true
              })
            )
            .bindContentCover(this.showTextContent, this.contentTextCover(this.item), {
              onDisappear: () => {
                this.showTextContent = false
              }
            })
        } else {
          //加载失败
          Text(this.item.errorMessage)
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
  }

  @Builder
  popupCustomView() {
    Column() {
      Grid() {
        ForEach(this.popItem, (item: ChatPopupItem, index: number) => {
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
              itemClickManager.onClickItem(item, this.item)
            })
          }
        }, (item: ChatPopupItem, index: number) => JSON.stringify(item) + index)
      }

      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(5)
    }
    .width(SizeConstant.SIZE_PERCENT_60)
    .padding({
      top: SizeConstant.SIZE_15,
      bottom: SizeConstant.SIZE_15,
      left: SizeConstant.SIZE_10,
      right: SizeConstant.SIZE_10
    })
  }

  /**
   * 文字模态页面
   */
  @Builder
  contentTextCover(message:
    Message
  ) {
    //文字详情页
    ChatTextDetailContent({
      detailMessage: message,
      chatTextDetailContent: this.showTextContent
    }).width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
  }

  /**
   * 图片模态页面
   */
  @Builder
  contentPicCover(message: Message, selectIndex: number) {
    // Stack() {
    // ImageNode()
    ChatPicDetailContent({
      detailMessage: message,
      chatPicDetailContent: this.showPicContent
    }).width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
    // }
    // .id('imageDetail')
    // .translate({
    //   x: this.translateX,
    //   y: this.translateY
    // })
    // .scale({
    //   x: this.scaleValue,
    //   y: this.scaleValue,
    //   centerX: '50%',
    //   centerY: '50%'
    // })
    // .clip(true)
  }

  /**
   * 视频模态页面
   */
  @Builder
  contentVideoCover(message:
    Message
  ) {
    ChatVideoDetailContent({
      detailMessage: message,
      chatVideoDetailContent: this.showVideoContent
    }).width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
  }
}