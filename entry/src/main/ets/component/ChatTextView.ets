import SizeConstant from '../constants/SizeConstant'
import { Message } from '../pages/ChatPage'

/**
 * 聊天内容 View
 */
@Component
export struct ChatTextView {
  @ObjectLink item: Message

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
          }

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
}