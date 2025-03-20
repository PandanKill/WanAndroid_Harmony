import { it } from '@ohos/hypium';
import { ChatOtherFunView } from '../component/ChatOtherFunView';
import { EmojiListView } from '../component/EmojiListView';
import { NavHeaderView } from '../component/NavHeaderView';
import SizeConstant from '../constants/SizeConstant';
import { http } from '@kit.NetworkKit';
import {
  AIRequestBean,
  AISpeakBean,
  InputBean,
  MessageBean,
  ParametersBean,
  StreamOptions
} from '../bean/AIRequestBean';
import { JSON } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import hilog from '@ohos.hilog';
import { router } from '@kit.ArkUI';
import { ChatTextView } from '../component/ChatTextView';

@Observed
export class Message {
  text: string = ''
  //0 时间、1 发送方、2接收方
  messageType: number = 0
  ownerName: string = ''
  ownerIcon: Resource | undefined = $r('app.media.icon_default')
  //发送方 request_id是 send，接收方是真实 id
  id: string = ''
}

@Entry
@Component
struct AIChatPage {
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
  @State recordUI: ResourceColor = Color.White
  private textAreaController: TextAreaController = new TextAreaController()
  private timeId: number = 0

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
    this.messageArr.push(this.getDateMessage(), this.getSendMessage("nihao"))
  }

  onPageShow(): void {
    //获取 pageParam
    let recordParam = (router.getParams() as Record<string, object>)
    if (recordParam !== undefined) {
      let uriArr = recordParam.selectUri
      if (uriArr !== undefined) {
        let selectArr = uriArr as Array<string>
        console.info(`dsads`, JSON.stringify(selectArr))
      }
    }
  }

  /**
   * 获取接收 message
   * @returns
   */
  getReceiverMessage(): Message {
    let message = new Message()
    message.messageType = 2;
    message.ownerName = "DeepSeek"
    return message
  }

  /**
   * 获取发送 message
   * @returns
   */
  getSendMessage(sendText: string): Message {
    let message = new Message()
    message.text = sendText
    message.messageType = 1
    message.ownerName = "Owner"
    message.id = 'send'

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

          List({
            scroller: this.scroller
          }) {
            ForEach(this.messageArr, (item: Message, index: number) => {
              ListItem() {
                ChatTextView({ item: item })
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
    // this.messageArr[this.messageArr.length - 1].text = "nihaosijia"
    let currentMill = Date.now()
    if (currentMill - this.lastSendMessage > 10 * 1000) {
      this.messageArr.push(this.getDateMessage())
    }
    //""
    this.messageArr.push(this.getSendMessage(editValue))

    //调用 API 获取
    let param: ParametersBean = {
      result_format: "message",
      incremental_output: true
    }
    let bean: MessageBean = {
      role: "user",
      content: this.editValue
    }

    let inputBean: InputBean = {
      messages: [bean]
    }

    let streamOption: StreamOptions = {
      include_usage: true
    }

    let requestBean: AIRequestBean = {
      model: "deepseek-r1",
      messages: [bean],
      stream: true,
      stream_options: streamOption
      // input: inputBean,
      // parameters: param
    }
    let httpSession = http.createHttp()
    httpSession.request("https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions", {
      method: http.RequestMethod.POST,
      expectDataType: http.HttpDataType.STRING,
      header: {
        "Authorization": `Bearer `,
        "Content-Type": "application/json"
        // "X-DashScope-SSE": "enable"
      },
      extraData: JSON.stringify(requestBean)
    }, (err: BusinessError, response: http.HttpResponse) => {
      if (err) {
        //异常
        console.error(`request ${err.message}`)
        return
      }

      if (response.responseCode === http.ResponseCode.OK) {
        //流式返回
        try {
          let responseStr = response.result as string
          let lines = responseStr.split(/\r?\n/)

          lines.forEach((line, index) => {
            if (line.trim() === '') {
              return;
            }

            if (line.trim().includes('[DONE]')) {
              //结束
              hilog.info(0x00, "lgwwww", 'end')
              return
            }
            let content = line.split("data: ")
            let aiSpeakBean = JSON.parse(content[1]) as AISpeakBean

            let lastMessage = this.messageArr[this.messageArr.length - 1]
            if (lastMessage.id !== aiSpeakBean.id) {
              //首次接收
              let receiverMessage = this.getReceiverMessage()
              receiverMessage.id = aiSpeakBean.id
              this.messageArr.push(receiverMessage)
            }
            let realLastMessage = this.messageArr[this.messageArr.length - 1]

            let ch = aiSpeakBean.choices
            if (ch !== undefined) {
              let delta = ch[0]
              if (delta && delta.delta && delta.delta.reasoning_content) {
                realLastMessage.text = realLastMessage.text.concat(delta.delta.reasoning_content)
              }
            }
          })
        } catch (e) {
          hilog.error(0x00, "lgwww", e)
        } finally {
          httpSession.destroy()
        }
      }
    })
  }

  onPageHide(): void {
    //销毁请求
  }

  /**
   03-19 20:18:51.652   61606-61606   A00000/com.lgw...ndroid/lgwwww  com.lgw.wanandroid    I     {"content-type":"text/event-stream;charset=UTF-8","date":"Wed, 19 Mar 2025 12:18:47 GMT","req-arrive-time":"1742386727444","req-cost-time":"477","resp-start-time":"1742386727921","server":"istio-envoy","vary":"Origin,Access-Control-Request-Method,Access-Control-Request-Headers","x-dashscope-call-gateway":"true","x-dashscope-finished":"false","x-dashscope-timeout":"180","x-envoy-upstream-service-time":"470","x-request-id":"67b20699-48c4-9a36-a1f1-4d30e6fed828","set-cookie":["acw_tc=67b20699-48c4-9a36-a1f1-4d30e6fed8280be2c55fe3966f4de28d01f91d1898b7;path=/;HttpOnly;Max-Age=1800"]}
   03-19 20:18:51.653   61606-61606   A00000/com.lgw...ndroid/lgwwww  com.lgw.wanandroid    I     "id:1\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"您好\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":7,\"input_tokens\":4,\"output_tokens\":3},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:2\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"！\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":8,\"input_tokens\":4,\"output_tokens\":4},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:3\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"我是\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":9,\"input_tokens\":4,\"output_tokens\":5},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:4\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"由\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":10,\"input_tokens\":4,\"output_tokens\":6},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:5\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"中国的\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":11,\"input_tokens\":4,\"output_tokens\":7},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:6\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"深度\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":12,\"input_tokens\":4,\"output_tokens\":8},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:7\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"求\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":13,\"input_tokens\":4,\"output_tokens\":9},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:8\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"索\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":14,\"input_tokens\":4,\"output_tokens\":10},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:9\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"（\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":15,\"input_tokens\":4,\"output_tokens\":11},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:10\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"Deep\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":16,\"input_tokens\":4,\"output_tokens\":12},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:11\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\",\"reasoning_content\":\"Se\",\"role\":\"assistant\"},\"finish_reason\":\"null\"}]},\"usage\":{\"total_tokens\":17,\"input_tokens\":4,\"output_tokens\":13},\"request_id\":\"67b20699-48c4-9a36-a1f1-4d30e6fed828\"}\n\nid:12\nevent:result\n:HTTP_STATUS/200\ndata:{\"output\":{\"choices\":[{\"message\":{\"content\":\"\
   *
   */

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
