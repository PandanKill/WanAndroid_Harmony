import { it } from '@ohos/hypium';
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
  @StorageProp('navHeight') navHeight: number = 0
  private lastSendMessage: number = 0
  //滚动布局
  private scroller: Scroller = new Scroller()

  getMMSS(): string {
    let date = new Date()
    let hours = date.getHours().toString().padStart(2, '0');
    let min = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${min}`
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

          //对比文字框
          Row() {
            //语音文字转换
            Image($r('app.media.icon_speek'))
              .width(SizeConstant.SIZE_30)
              .height(SizeConstant.SIZE_30)
              .margin({ left: SizeConstant.SIZE_10 })

            TextArea({
              text: this.editValue
            })
              .backgroundColor(Color.White)
              .borderRadius(SizeConstant.SIZE_5)
              .width(SizeConstant.SIZE_PERCENT_65)
              .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_10 })
              .enterKeyType(EnterKeyType.Send)
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

            //表情
            Image($r('app.media.icon_biaoqing'))
              .width(SizeConstant.SIZE_30)
              .height(SizeConstant.SIZE_30)
              .margin({ left: SizeConstant.SIZE_10 })

            Blank()

            //加
            Image($r('app.media.icon_add'))
              .width(SizeConstant.SIZE_30)
              .height(SizeConstant.SIZE_30)
              .margin({ right: SizeConstant.SIZE_10 })

          }.width(SizeConstant.FULL_SIZE)
          .backgroundColor($r('app.color.color_F6F6F6'))
          .padding({ bottom: px2vp(this.navHeight) })
        }.width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.FULL_SIZE)
      }.title("你好Harmony")
      .mode(NavigationMode.Stack)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_EDEDED'))
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
}

