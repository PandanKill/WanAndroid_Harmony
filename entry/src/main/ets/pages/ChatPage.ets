import { it } from '@ohos/hypium';
import { ChatOtherFunView } from '../component/ChatOtherFunView';
import { EmojiListView } from '../component/EmojiListView';
import { NavHeaderView } from '../component/NavHeaderView';
import SizeConstant from '../constants/SizeConstant';

class Message {
  text: string = ''
  //0 时间、1 发送方、2接收方
  messageType: number = 0
  ownerName: string = ''
  ownerIcon: Resource | undefined = $r('app.media.icon_default')
  id: string = ''
}

@Entry
@Component
struct AIChatPage {
  //sk-c1d2d4ae26e44c61b098a719f98bc40d
  @State textArr: Message[] = [];
  @State editValue: string = "";
  //在切换到录音之后，状态变化
  private isFirstShowUI: boolean = true
  @StorageProp('navHeight') navHeight: number = 0
  private lastSendMessage: number = 0
  //滚动布局
  private scroller: Scroller = new Scroller()
  //文本编辑模式
  @State @Watch('changeSpeekIcon') isSendText: boolean = true
  @State speekIconResource: Resource = $r('app.media.icon_speek')
  @State @Watch('changeEmojiIcon') isEmoji: boolean = false
  @State emojiIconResource: Resource = $r('app.media.icon_biaoqing')
  //相册、相机
  @State isPhoto: boolean = false
  //是否正在录音
  @State isRecording: boolean = false
  @State recordUI: ResourceColor = Color.White
  private textAreaController: TextAreaController = new TextAreaController()

  getMMSS(): string {
    let date = new Date()
    let hours = date.getHours().toString().padStart(2, '0');
    let min = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${min}`
  }

  //更新语音表情包
  changeSpeekIcon() {
    if (this.isSendText) {
      this.speekIconResource = $r('app.media.icon_speek')
    } else {
      this.speekIconResource = $r('app.media.icon_keyboard')
    }
  }

  //更新表情包样式
  changeEmojiIcon() {
    if (this.isEmoji) {
      this.emojiIconResource = $r('app.media.icon_keyboard')
    } else {
      this.emojiIconResource = $r('app.media.icon_biaoqing')
    }
  }

  aboutToAppear(): void {
    let message0 = new Message()
    message0.text = this.getMMSS()
    message0.messageType = 0

    let message1 = new Message()
    message1.text =
      "fasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasongfasong"
    message1.messageType = 1
    message1.ownerName = "Owner"

    let message2 = new Message()
    message2.text =
      "jieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshoujieshou"
    message2.messageType = 2;
    message2.ownerName = "DeepSeek"

    this.textArr.push(message0, message1, message2)
  }

  build() {
    Column() {
      Navigation() {
        Column() {
          //标题
          NavHeaderView({
            title: $r('app.string.ai')
          })

          List({
            scroller: this.scroller
          }) {
            ForEach(this.textArr, (item: Message, index: number) => {
              ListItem() {

                if (item.messageType === 1) {
                  //横向布局
                  Row() {
                    Blank()
                    //内容
                    Column() {
                      if (item.ownerName !== '') {
                        Text(item.ownerName)
                          .fontColor($r('app.color.color_7B7B7B'))
                          .fontSize($r('app.float.font_10'))
                          .alignSelf(ItemAlign.End)
                      }
                      Text(item.text)
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
                      // .gesture(
                      //   LongPressGesture().onAction((event) => {
                      //
                      //   })
                      // )
                    }

                    Shape() {
                      Path()
                        .commands('M0 100 L15 115 L0 130 Z')
                        .fill($r('app.color.color_95EC69'))
                        .strokeOpacity(0)
                    }.margin({ right: SizeConstant.SIZE_10 })

                    Image(item.ownerIcon)
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
                } else if (item.messageType === 2) {

                  Row() {
                    Image(item.ownerIcon)
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
                      if (item.ownerName !== '') {
                        Text(item.ownerName)
                          .fontColor($r('app.color.color_7B7B7B'))
                          .fontSize($r('app.float.font_10'))
                          .alignSelf(ItemAlign.Start)
                      }
                      Text(item.text)
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

                  }.width(SizeConstant.FULL_SIZE)
                  .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
                  .alignItems(VerticalAlign.Top)
                  .height('auto')
                } else {
                  Column() {
                    Text(item.text)
                      .fontColor($r('app.color.color_A5A5A5'))
                      .fontSize($r('app.float.font_10'))
                  }.alignItems(HorizontalAlign.Center)
                  .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
                  .width(SizeConstant.FULL_SIZE)
                }

              }.width(SizeConstant.FULL_SIZE)
              .height('auto')
            }, (item: Message, index: number) => item.id + index)
          }.width(SizeConstant.FULL_SIZE)
          .layoutWeight(1)
          .onClick(() => {
            //收起 emoji
            this.isEmoji = false
            this.isPhoto = false
            this.getUIContext().getFocusController().clearFocus()
          })

          //底部栏
          Column() {
            //输入框
            Row() {
              //语音文字转换
              Image(this.speekIconResource)
                .width(SizeConstant.SIZE_30)
                .height(SizeConstant.SIZE_30)
                .margin({ left: SizeConstant.SIZE_10 })
                .onClick(() => {
                  //切换语音文字
                  this.isFirstShowUI = false
                  this.isSendText = !this.isSendText
                  this.isEmoji = false
                  this.isPhoto = false
                })

              if (this.isSendText) {
                //编写文字
                TextArea({
                  text: this.editValue,
                  controller: this.textAreaController
                })
                  .id('sendText')
                  .backgroundColor(Color.White)
                  .borderRadius(SizeConstant.SIZE_5)
                  .width(SizeConstant.SIZE_PERCENT_65)
                  .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_10 })
                  .enterKeyType(EnterKeyType.Send)
                  .onAppear(() => {
                    //首次不需要弹软键盘
                    if (!this.isFirstShowUI && !this.isEmoji && !this.isPhoto) {
                      //非首次 Appear 的时候，才需要弹出软件盘
                      this.getUIContext().getFocusController().requestFocus('sendText')
                    }
                  })
                  .onSubmit((eventType: EnterKeyType) => {
                    //发送
                    this.toGetAi(this.editValue)
                    this.editValue = ''
                  })
                  .onChange((value: string) => {
                    //获取输入框内容
                    console.info(value)
                    this.editValue = value
                  })
                  .onFocus(() => {
                    this.isEmoji = false
                    this.isPhoto = false
                  })

              } else {
                //编写语音
                Text(this.isRecording ? $r('app.string.recording') : $r('app.string.start_record'))
                  .backgroundColor(this.recordUI)
                  .borderRadius(SizeConstant.SIZE_5)
                  .width(SizeConstant.SIZE_PERCENT_65)
                  .height(SizeConstant.SIZE_35)
                  .textAlign(TextAlign.Center)
                  .fontSize($r('app.float.font_15'))
                  .fontColor(Color.Black)
                  .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_10 })
                  .onTouch((event: TouchEvent) => {
                    if (event.type === TouchType.Down) {
                      //按下状态
                      this.recordUI = Color.Grey
                      this.isRecording = true
                    } else if (event.type === TouchType.Up) {
                      //抬起状态
                      this.recordUI = Color.White
                      this.isRecording = false
                    }
                  })
              }
              //表情
              Image(this.emojiIconResource)
                .width(SizeConstant.SIZE_30)
                .height(SizeConstant.SIZE_30)
                .margin({ left: SizeConstant.SIZE_10 })
                .onClick(() => {
                  this.isSendText = true
                  this.isPhoto = false
                  this.isEmoji = !this.isEmoji
                  if (this.isEmoji) {
                    //收起软键盘
                    this.getUIContext().getFocusController().clearFocus()
                  } else {
                    //弹出软键盘
                    setTimeout(() => {
                      //需要延迟50ms，避免无法无法获取到焦点
                      this.getUIContext().getFocusController().requestFocus('sendText')
                    }, 50)
                  }
                })

              Blank()

              //图片、相机
              Image($r('app.media.icon_add'))
                .width(SizeConstant.SIZE_30)
                .height(SizeConstant.SIZE_30)
                .margin({ right: SizeConstant.SIZE_10 })
                .onClick(() => {
                  this.isSendText = true
                  this.isEmoji = false
                  this.isPhoto = !this.isPhoto
                  if (this.isPhoto) {
                    this.getUIContext().getFocusController().clearFocus()
                    //获取最近一张图片
                    this.getRecentlyImage()
                  } else {
                    //弹出软键盘
                    setTimeout(() => {
                      //需要延迟50ms，避免无法无法获取到焦点
                      this.getUIContext().getFocusController().requestFocus('sendText')
                    }, 50)
                  }
                })

            }.width(SizeConstant.FULL_SIZE)

            //显示表情包
            if (this.isEmoji) {
              Stack() {
                EmojiListView({
                  emojiClick: (item: string) => {
                    this.editValue = this.editValue + item
                  }
                })

                Row() {
                  Stack() {
                    Image(this.editValue.length === 0 ? $r('app.media.icon_recall_normal') :
                    $r('app.media.icon_recall_clickable'))
                      .width(SizeConstant.SIZE_20)
                      .height(SizeConstant.SIZE_15)
                  }
                  .width(SizeConstant.SIZE_45)
                  .height(SizeConstant.SIZE_35)
                  .align(Alignment.Center)
                  .backgroundColor($r('app.color.color_E0E0E0'))
                  .borderRadius(SizeConstant.SIZE_5)
                  .onClick(() => {
                    //todo 删除字符、表情包字符
                    // if ()
                    // if (this.editValue.length > 0) {
                    //   console.info(`lgwww ${this.editValue}}`)
                    //   console.info(`lgwww ${this.editValue.length}}`)
                    //   this.editValue = this.editValue.slice(0, -1)
                    // }
                  })

                  Text($r('app.string.send'))
                    .width(SizeConstant.SIZE_45)
                    .height(SizeConstant.SIZE_35)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(this.editValue.length === 0 ? $r('app.color.color_E0E0E0') :
                    $r('app.color.color_09C060'))
                    .fontSize($r('app.float.font_15'))
                    .fontColor(this.editValue.length === 0 ? $r('app.color.color_BEBEBE') :
                    $r('app.color.color_FFFFFF'))
                    .borderRadius(SizeConstant.SIZE_5)
                    .margin({ left: SizeConstant.SIZE_10 })
                    .onClick(() => {
                      //发送
                      this.toGetAi(this.editValue)
                      this.editValue = ''
                    })
                }
                .margin({ right: SizeConstant.SIZE_20 })
              }.width(SizeConstant.FULL_SIZE)
              .height(SizeConstant.SIZE_PERCENT_25)
              .align(Alignment.BottomEnd)
            } else if (this.isPhoto) {
              //相机、相册
              ChatOtherFunView()
            }
          }.backgroundColor($r('app.color.color_F6F6F6'))
          .padding({ bottom: px2vp(this.navHeight) })
          .width(SizeConstant.FULL_SIZE)
        }.width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.FULL_SIZE)
      }.mode(NavigationMode.Stack)

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_EDEDED'))
  }

  /**
   * 获取最新的图片
   */
  getRecentlyImage() {
    //RecentPhoto
    //https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/component-guidelines-recentphoto-V5
  }

  //调用AI
  toGetAi(editValue: string) {
    //判断上一次聊天时间小于
    let currentMill = Date.now()
    if (currentMill - this.lastSendMessage > 10 * 1000) {
      this.lastSendMessage = currentMill
      let message0 = new Message()
      message0.text = this.getMMSS()
      message0.messageType = 0
      this.textArr.push(message0)
    }
    //""
    let message1 = new Message()
    message1.text = editValue
    message1.messageType = 1
    message1.ownerName = "Owner"
    this.textArr.push(message1)

    let message2 = new Message()
    message2.text = editValue
    message2.ownerName = "DeepSeek"
    message2.messageType = 2
    this.textArr.push(message2)
  }

  // 精准删除逻辑
  // private deleteEmojiAtCursor() {
  //   let cursorPos = this.textAreaController.caretPosition;
  //   if (cursorPos === 0) {
  //     return;
  //   }
  //
  //   // 使用字素簇分割器
  //   let segmenter = new Intl.Segmenter('en', { granularity: 'grapheme' });
  //   let segments = Array.from(segmenter.segment(this.text));
  //
  //   // 找到光标所在字素簇
  //   let targetSegment: Intl.SegmentData | null = null;
  //   for (const seg of segments) {
  //     if (seg.index <= cursorPos - 1 && cursorPos - 1 < seg.index + seg.segment.length) {
  //       targetSegment = seg;
  //       break;
  //     }
  //   }
  //
  //   if (targetSegment) {
  //     // 删除目标字素簇
  //     const newText =
  //       this.text.slice(0, targetSegment.index) +
  //       this.text.slice(targetSegment.index + targetSegment.segment.length);
  //
  //     this.text = newText;
  //     this.controller.caretPosition(targetSegment.index); // 调整光标位置
  //   }
  // }
}
