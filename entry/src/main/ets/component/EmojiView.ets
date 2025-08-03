import SizeConstant from "../constants/SizeConstant"
import { EmojiListView } from "./EmojiListView"
import hilog from "@ohos.hilog"

/**
 * 表情 View
 */
@Component
export struct EmojiView {
  @Link editValue: string
  //asc、cat
  @State currentEmojiType: string = "asc"
  onSend: VoidCallback = () => {

  }

  build() {
    Column() {
      //tab
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.emoji'))
            .width(SizeConstant.SIZE_20)
            .aspectRatio(1)
        }
        .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
        .width(SizeConstant.SIZE_35)
        .height(SizeConstant.SIZE_35)
        .backgroundColor(this.currentEmojiType === "asc" ? $r('app.color.color_FFFFFF') : $r('app.color.color_F6F6F6'))
        .borderRadius(SizeConstant.SIZE_5)
        .onClick(() => {
          this.currentEmojiType = "asc"
        })

        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.catEmoji'))
            .height(SizeConstant.SIZE_20)
        }
        .margin({ left: SizeConstant.SIZE_10 })
        .width(SizeConstant.SIZE_35)
        .height(SizeConstant.SIZE_35)
        .backgroundColor(this.currentEmojiType === "cat" ? $r('app.color.color_FFFFFF') : $r('app.color.color_F6F6F6'))
        .borderRadius(SizeConstant.SIZE_5)
        .onClick(() => {
          this.currentEmojiType = "cat"
        })
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      //emoji
      Stack() {
        if (this.currentEmojiType === 'asc') {
          EmojiListView({
            emojiClick: (item: string) => {
              this.editValue = this.editValue + item
            }
          })
        } else if (this.currentEmojiType === 'cat') {

        }

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
              this.onSend()
            })
        }
        .margin({ right: SizeConstant.SIZE_20 })
      }.width(SizeConstant.FULL_SIZE)
      .backgroundColor($r('app.color.color_EDEDED'))
      .layoutWeight(1)
      .align(Alignment.BottomEnd)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }
}