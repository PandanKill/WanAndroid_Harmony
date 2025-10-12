import { RichTextComponent, RichTextRepresentation } from "rich_text_vista"
import SizeConstant from "../constants/SizeConstant"
import ImageGenerationChatViewModel from "../viewModel/ImageGenerationChatViewModel"

@ComponentV2
export struct ImageChatItem {
  @Param @Require imageMsg: ImageGenerationChatViewModel

  build() {
    Column() {
      if (this.imageMsg.messageOwner === 0) {
        //发送方
        this.sendMessageItem()
      } else if (this.imageMsg.messageOwner === 1) {
        //接受方
        this.receiverMessageItem()
      }
    }
  }

  /**
   * 接收方文字
   */
  @Builder
  receiverMessageItem() {
    Row() {

      Column() {
        //加载成功
        RichTextComponent({
          richText: this.createRichTextFromMD(),
          fontColor: (Color.Black),
          fontSize: 15,
          textAlign: TextAlign.Start,
          canCopyMessage: false,
          onAnchorClick: (url?: string) => {

          }
        })
          .backgroundColor($r('app.color.color_FFFFFF'))
          .constraintSize({ maxWidth: SizeConstant.SIZE_PERCENT_60 })
          .borderRadius(SizeConstant.SIZE_5)
          .padding(SizeConstant.SIZE_10)
          .margin({ top: SizeConstant.SIZE_5 })
          .height('auto')
          .onSizeChange((oldVal, newVal) => {
          })
          .gesture(
            TapGesture({ count: 2 }).onAction((event) => {
            })
          )
      }.alignItems(HorizontalAlign.Start)

    }.width(SizeConstant.FULL_SIZE)
    .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
    .alignItems(VerticalAlign.Top)
    .height('auto')
  }

  @Builder
  sendMessageItem() {
    //横向布局
    Row() {
      Blank()
      //内容
      Column() {
        if (this.imageMsg.messageType === 0) {
          //文字
          this.sendTextMessage()
        } else if (this.imageMsg.messageType === 1) {
          //图片
        }
      }.alignItems(HorizontalAlign.End)

    }.width(SizeConstant.FULL_SIZE)
    .alignItems(VerticalAlign.Top)
    .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
    .height('auto')
  }

  /**
   * 发送方文字
   */
  @Builder
  sendTextMessage() {
    //发送方是文字
    Text(this.imageMsg.messageContent)
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
  }

  private createRichTextFromMD() {
    const richTextRepresentation = new RichTextRepresentation()
    richTextRepresentation.markdownString = this.imageMsg.messageContent
    return richTextRepresentation
  }
}