import { ChatOtherFunView } from '../component/ChatOtherFunView';
import { EmojiListView } from '../component/EmojiListView';
import { NavHeaderView } from '../component/NavHeaderView';
import SizeConstant from '../constants/SizeConstant';
import { JSON } from '@kit.ArkTS';
import hilog from '@ohos.hilog';
import { componentUtils, promptAction, router, window } from '@kit.ArkUI';
import { ChatItemView } from '../component/ChatItemView';
import { checkFileMimeType, fileToBase64 } from '../utils/FileUtil';
import { FileAIStreamRequestUtil } from '../utils/FileAIRequestUtil';
import { ItemInfo } from '@kit.MediaLibraryKit';
import { AudioRecordView } from '../component/AudioRecordView';
import { EventState, CustomTouchType } from '../bean/TouchType';
import { AudioParseTextView } from '../component/AudioParseTextView';
import { startVibrator } from '../utils/VibratorUtil';
import { ReferenceView } from '../component/ReferenceView';
import { checkPermissionGrant, requestPermissionForUser } from '../utils/PermissionUtil';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import itemClickManager from '../componentManager/PopupItemClickManager';
import { ModelStudioStreamClient } from '../utils/TextAiRequestUtil';

@Observed
export class Message {
  //0 时间、1 发送方、2接收方
  messageType: number = 0
  ownerName: string = ''
  //0 加载中 1 显示成功 2读取失败
  messageStatus: number = 0
  //消息类型 0 文字 1 图片 2视频 3 语音
  textType: number = 0
  text: string = ''
  //图片 uri
  imageUri: string = ''
  imageWidth: number = 0
  imageHeight: number = 0
  //视频 uri
  videoUri: string = ''
  videoCapWidth: number = 0
  videoCapHeight: number = 0
  videoTime: number = 0
  //语音
  audioUri: string = ''
  audioTime: number = 0
  //头像
  ownerIcon: Resource | undefined = $r('app.media.icon_default')
  //发送方 request_id是 send，接收方是真实 id
  id: string = ''
  //引用 id
  referId: string = ''
  referType: number = 0
  referText: string = ''
}

@Entry
@Component
struct AIChatPage {
  //
  @State messageArr: Message[] = [];
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
  //音频解析
  @State isAudioParsing: boolean = false
  //是否存在引用
  @State isRefer: boolean = false
  private referMessage: Message | undefined
  @State recordUI: ResourceColor = Color.White
  private textAreaController: TextAreaController = new TextAreaController()
  private timeId: number = 0
  @State eventAudio: EventState = new EventState()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  //事件回调
  onAudioTouch = async (event: TouchEvent) => {
    // const eventState: EventState = new EventState()
    if (event.type === TouchType.Down) {
      //校验录音权限
      let grant = await checkPermissionGrant('ohos.permission.MICROPHONE')
      if (grant === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this.startRecord()
      } else {
        requestPermissionForUser(['ohos.permission.MICROPHONE'], this.context, this.startRecord, this.deniedWarning)
      }

    } else if (event.type === TouchType.Up) {
      //抬起状态
      this.stopRecord()
    } else if (event.type === TouchType.Move) {
      this.eventAudio.type = CustomTouchType.Move
      this.eventAudio.x = event.touches[0].displayX
      this.eventAudio.y = event.touches[0].displayY
    } else if (event.type === TouchType.Cancel) {
      this.eventAudio.type = CustomTouchType.Cancel
    }
  }

  /**
   * 权限授权失败
   */
  deniedWarning() {
    promptAction.showToast({
      message: "麦克风授权失败"
    })
  }

  /**
   * 结束录音
   */
  stopRecord() {
    this.recordUI = Color.White
    this.eventAudio.type = CustomTouchType.Up
  }

  /**
   * 开始录音
   */
  startRecord() {
    //按下状态
    this.recordUI = Color.Grey
    this.isRecording = true
    this.eventAudio.type = CustomTouchType.Down
    //震动
    startVibrator()
  }

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
    //引用
    itemClickManager.onReferListener = (refItem) => {
      //引用回调
      this.referMessage = refItem
      this.isRefer = true
    }

    itemClickManager.onDeleteListener = (deleteMessage) => {
      // 从后向前遍历，避免索引错乱
      for (let i = this.messageArr.length - 1; i >= 0; i--) {
        if (this.messageArr[i].id === deleteMessage.id) {
          this.messageArr.splice(i, 1); // 删除符合条件的对象
        }
      }
    }

    itemClickManager.onResendListener = (message) => {
      this.toGetAi(message.text)
    }
  }

  async onPageShow(): Promise<void> {
    //获取 pageParam
    let recordParam = (router.getParams() as Record<string, object>)
    if (recordParam !== undefined) {
      let uriArr = recordParam.selectUri
      if (uriArr !== undefined) {
        let selectArr = uriArr as Array<ItemInfo>
        console.info(`dsads`, JSON.stringify(selectArr))
        let itemInfo: ItemInfo = selectArr[0]
        //接收
        let mimeType = await checkFileMimeType(itemInfo.uri ?? "")
        console.info(`mimeType`, mimeType)
        if (mimeType === "image") {
          this.sendImageDataRequest(itemInfo)
        } else if (mimeType === "video") {
          this.sendVideoDataRequest(itemInfo)
        }
      }
    }
  }

  /**
   * 发送图片Ai 回复
   * @param itemInfo
   */
  async sendVideoDataRequest(itemInfo: ItemInfo) {
    let base64Url = await fileToBase64(itemInfo.uri ?? "")
    //获取到图片信息,全模态
    let fileAi = new FileAIStreamRequestUtil({
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d",
      model: 'qwen-omni-turbo',
      desText: "视频的内容是什么"
    })
    const sendMessage = this.getSendVideoMessage(itemInfo)
    this.messageArr.push(sendMessage)
    //接收
    const receiverMessage = this.getReceiverMessage()
    receiverMessage.messageStatus = 0
    this.messageArr.push(receiverMessage)

    fileAi.sendStreamRequest("video_url", `data:video/mp4;base64,${base64Url}`, {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        //加载成功
        receiverMessage.messageStatus = 1
        let ch = aiSpeakBean.choices
        if (ch !== undefined) {
          let delta = ch[0]
          if (delta && delta.delta) {
            if (delta.delta.reasoning_content) {
              let text = receiverMessage.text
              let newText = text + delta.delta.reasoning_content
              receiverMessage.text = newText
            }
            if (delta.delta.content) {
              let text = receiverMessage.text
              let newText = text + delta.delta.content
              receiverMessage.text = newText
            }
          }
        }
      },
      onError: (err) => {
        receiverMessage.messageStatus = 2
      },
      onComplete: () => {

      }
    })
  }

  /**
   * 发送图片Ai 回复
   * @param itemInfo
   */
  async sendImageDataRequest(itemInfo: ItemInfo) {
    let base64Url = await fileToBase64(itemInfo.uri ?? "")
    //获取到图片信息,全模态
    let fileAi = new FileAIStreamRequestUtil({
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d",
      model: 'qwen-omni-turbo',
      desText: "图中描绘的是什么景象？"
    })
    const sendMessage = this.getSendPicMessage(itemInfo)
    this.messageArr.push(sendMessage)
    //接收
    const receiverMessage = this.getReceiverMessage()
    receiverMessage.messageStatus = 0
    this.messageArr.push(receiverMessage)

    fileAi.sendStreamRequest("image_url", `data:image/png;base64,${base64Url}`, {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        //加载成功
        receiverMessage.messageStatus = 1
        let ch = aiSpeakBean.choices
        if (ch !== undefined) {
          let delta = ch[0]
          if (delta && delta.delta) {
            if (delta.delta.reasoning_content) {
              let text = receiverMessage.text
              let newText = text + delta.delta.reasoning_content
              receiverMessage.text = newText
            }
            if (delta.delta.content) {
              let text = receiverMessage.text
              let newText = text + delta.delta.content
              receiverMessage.text = newText
            }
          }
        }
      },
      onError: (err) => {
        receiverMessage.messageStatus = 2
      },
      onComplete: () => {

      }
    })
  }

  /**
   * 获取接收 message
   * @returns
   */
  getReceiverMessage(): Message {
    let message = new Message()
    message.messageType = 2;
    message.ownerName = "DeepSeek"
    message.id = new Date().getTime().toString()
    return message
  }

  /**
   * 获取发送文字 message
   * @returns
   */
  getSendMessage(sendText: string): Message {
    let message = new Message()
    message.text = sendText
    message.messageType = 1
    message.textType = 0
    message.ownerName = "Owner"
    message.id = new Date().getTime().toString()

    return message
  }

  /**
   * 获取发送图片 message
   * @returns
   */
  getSendPicMessage(itemInfo: ItemInfo): Message {
    let message = new Message()
    message.imageUri = itemInfo.uri ?? ""
    message.messageType = 1
    message.imageWidth = itemInfo.width ?? 0
    message.imageHeight = itemInfo.height ?? 0
    message.textType = 1
    message.ownerName = "Owner"
    message.id = new Date().getTime().toString()

    return message
  }

  /**
   * 获取发送视频 message
   * @returns
   */
  getSendVideoMessage(itemInfo: ItemInfo): Message {
    let message = new Message()
    message.videoUri = itemInfo.uri ?? ""
    message.messageType = 1
    message.textType = 2
    message.videoCapWidth = itemInfo.width ?? 0
    message.videoCapHeight = itemInfo.height ?? 0
    message.videoTime = Math.floor((itemInfo.duration ?? 0) / 1000)
    message.ownerName = "Owner"
    message.id = new Date().getTime().toString()

    return message
  }

  getSendAudioMessage(): Message {
    let message = new Message()
    message.audioUri = ''
    message.audioTime = 15
    message.messageType = 1
    message.textType = 3
    message.ownerName = "Owner"
    message.id = new Date().getTime().toString()
    return message
  }

  /**
   * 获取时间 message
   * @returns
   */
  getDateMessage(): Message {
    //加载数据库 AI 聊天内容
    let message = new Message()
    message.text = this.getMMSS()
    message.messageType = 0
    message.id = 'date'
    return message
  }

  build() {
    Column() {
      Navigation() {
        Column() {
          //标题
          NavHeaderView({
            title: $r('app.string.ai')
          })

          Stack() {
            //聊天列表
            Column() {
              List({
                scroller: this.scroller
              }) {
                ForEach(this.messageArr, (item: Message, index: number) => {
                  ListItem() {
                    ChatItemView({
                      item: item
                    })
                  }.width(SizeConstant.FULL_SIZE)
                  .height('auto')
                }, (item: Message, index: number) => item.id + index)
              }.width(SizeConstant.FULL_SIZE)
              .layoutWeight(1)
              .onClick(() => {
                //收起 emoji
                this.getUIContext().animateTo({
                  duration: 100,
                  curve: Curve.Linear
                }, () => {
                  this.isEmoji = false
                  this.isPhoto = false
                })
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
                      this.getUIContext().animateTo({
                        duration: 100,
                        curve: Curve.Linear
                      }, () => {
                        this.isEmoji = false
                        this.isPhoto = false
                      })
                    })

                  //输入框
                  Column() {
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
                        .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_3 })
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
                          this.getUIContext().animateTo({
                            duration: 100,
                            curve: Curve.Linear
                          }, () => {
                            this.isEmoji = false
                            this.isPhoto = false
                          })
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
                        .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_3 })
                        .onTouch((event: TouchEvent) => {
                          this.onAudioTouch(event)
                        })
                    }

                    if (this.isRefer) {
                      ReferenceView({
                        referenceOwner: this.referMessage?.ownerName,
                        referenceText: this.getShowReferText(this.referMessage),
                        onCancel: () => {
                          this.isRefer = false
                        }
                      }).width(SizeConstant.SIZE_PERCENT_65)
                        .margin({ left: SizeConstant.SIZE_10 })
                    }
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
                        if (this.editValue.length > 0) {
                          hilog.info(0x01, "lgwww", `lgwww ${this.editValue}}`)
                          hilog.info(0x01, "lgwww", `lgwww ${this.editValue.length}}`)
                          this.editValue = this.editValue.substring(0, this.editValue.length - 1)
                          hilog.info(0x01, "lgwww", `lgwww ${this.editValue}}`)
                          hilog.info(0x01, "lgwww", `lgwww ${this.editValue.length}}`)
                        }
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

            //语音
            if (this.isRecording) {
              //开启录音
              AudioRecordView({
                event: this.eventAudio,
                audioRecord: this.isRecording,
                audioParse: this.isAudioParsing,
                onDataSend: (textType: number) => {
                  this.isRecording = false
                  if (textType === 0) {
                    let message = this.getSendMessage("文字发送")
                    this.messageArr.push(message)
                  } else if (textType === 3) {
                    let message = this.getSendAudioMessage()
                    this.messageArr.push(message)
                  }
                }
              })
                .width(SizeConstant.FULL_SIZE)
                .height(SizeConstant.FULL_SIZE)
            }

            if (this.isAudioParsing) {
              AudioParseTextView({
                isParse: this.isAudioParsing
              })
                .width(SizeConstant.FULL_SIZE)
                .height(SizeConstant.FULL_SIZE)
            }

          }.width(SizeConstant.FULL_SIZE)
          .layoutWeight(1)
        }.width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.FULL_SIZE)
      }.mode(NavigationMode.Stack)

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_EDEDED'))
  }

  /**
   * 展示引用内容
   * @param text
   * @returns
   */
  getShowReferText(refMsg: Message | undefined): string | undefined {
    if (refMsg === undefined) {
      return undefined
    }
    let tempRef: string | undefined
    switch (refMsg.textType) {
      case 0:
        tempRef = refMsg.text
        break
      case 1:
        tempRef = "[图片]"
        break
      case 2:
        tempRef = "[视频]"
        break
      case 3:
        tempRef = `[语音] ${refMsg.audioTime}"`
        break
      default:
        tempRef = undefined
        break
    }

    return tempRef
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
    if (currentMill - this.lastSendMessage > 5 * 60 * 1000) {
      this.messageArr.push(this.getDateMessage())
    }
    //""
    this.messageArr.push(this.getSendMessage(editValue))

    //请求
    const client = new ModelStudioStreamClient({
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d",
      model: 'deepseek-r1'
    });

    //接收
    const receiverMessage = this.getReceiverMessage()
    receiverMessage.messageStatus = 0
    this.messageArr.push(receiverMessage)

    client.sendStreamRequest(this.editValue, {
      onDataReceived: (aiSpeakBean: AISpeakBean): void => {
        //加载成功
        receiverMessage.messageStatus = 1
        let ch = aiSpeakBean.choices
        if (ch !== undefined) {
          let delta = ch[0]
          if (delta && delta.delta) {
            if (delta.delta.reasoning_content) {
              let text = receiverMessage.text
              let newText = text + delta.delta.reasoning_content
              receiverMessage.text = newText
            }
            if (delta.delta.content) {
              let text = receiverMessage.text
              let newText = text + delta.delta.content
              receiverMessage.text = newText
            }
          }
        }
      },
      onError: (error: Error): void => {
        receiverMessage.messageStatus = 2
      },
      onComplete: (): void => {
        //写到数据库

      }
    })
  }

  onPageHide(): void {
    //销毁请求
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

interface AIRequestBean {
  model: string,
  messages: Array<MessageBean>,
  stream: boolean,
  stream_options: StreamOptions
}

interface StreamOptions {
  include_usage: boolean
}

interface MessageBean {
  role: string,
  content: string
}

export interface AISpeakBean {
  choices: Array<DeltaBean | null> | undefined,
  model: string,

  //speek id
  id: string
}

interface DeltaBean {
  delta: DeltaContentBean
}

interface DeltaContentBean {
  content: string | null,
  reasoning_content: string | null
}


export { EventState };
