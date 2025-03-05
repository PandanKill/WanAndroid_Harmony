import SizeConstant from '../constants/SizeConstant';

class Message {
  text: string = ''
  isSend: boolean = false
  id: string = ''
}

@Entry
@Component
struct AIChatPage {
  //sk-c1d2d4ae26e44c61b098a719f98bc40d
  @State textArr: Message[] = [];
  private editValue: string = "";
  @StorageProp('navHeight') navHeight: number = 0

  aboutToAppear(): void {
    let message1 = new Message()
    message1.text = "fasong"
    message1.isSend = true

    let message2 = new Message()
    message2.text = "jieshou"
    message2.isSend = false;

    this.textArr.push(message1, message2)
  }

  build() {
    Column() {
      Navigation() {
        Column() {
          List() {
            ForEach(this.textArr, (item: Message, index: number) => {
              ListItem() {
                Column() {
                  Text(item.text)
                }
              }
            })
          }.width(SizeConstant.FULL_SIZE)
          .layoutWeight(1)

          //对比文字框
          Row() {
            //语音文字转换
            Image($r('app.media.icon_speek'))
              .width(SizeConstant.SIZE_30)
              .height(SizeConstant.SIZE_30)
              .margin({ left: SizeConstant.SIZE_10 })

            TextArea()
              .backgroundColor(Color.White)
              .borderRadius(SizeConstant.SIZE_5)
              .width(SizeConstant.SIZE_PERCENT_65)
              .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_10 })
              .enterKeyType(EnterKeyType.Send)
              .onSubmit((eventType: EnterKeyType) => {
                //发送
                // this.toGetAi(this.editValue)
                let message1 = new Message()
                message1.text = this.editValue
                message1.isSend = true
                this.textArr.push(message1)

                let message2 = new Message()
                message2.text = this.editValue
                message2.isSend = false
                this.textArr.push(message2)
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
          .backgroundColor("#FFFFF0")
          .padding({ bottom: px2vp(this.navHeight) })
        }.width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.FULL_SIZE)
      }.title("你好Harmony")
      .mode(NavigationMode.Stack)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }

  //调用AI
  toGetAi(editValue: string) {
    //""

  }
}

