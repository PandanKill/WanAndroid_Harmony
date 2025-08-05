import { RichTextComponent, RichTextRepresentation } from 'rich_text_vista'
import { ArticleBean, TagRouterBean } from '../bean/ArticleBean'
import SizeConstant from '../constants/SizeConstant'

@Component
export struct ArticleContentComponent {
  item: ArticleBean = new ArticleBean()
  onCollectClick?: (articleBean: ArticleBean) => void

  build() {
    //ItemLayout
    Column() {
      Row() {
        //头像
        Image($r('app.media.icon_person'))
          .width(SizeConstant.SIZE_30)
          .height(SizeConstant.SIZE_30)

        Column() {
          Text(this.item.author === undefined || this.item.author === "" ? "匿名" : this.item.author)
            .fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_666666'))
            .margin({ bottom: SizeConstant.SIZE_2 })
          Text(this.item.niceDate).fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_999999'))
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: SizeConstant.SIZE_10 })

        if (this.item.tags !== undefined && this.item.tags.length !== 0) {
          //存在tag
          Text(this.item.tags[0].name)
            .padding(SizeConstant.SIZE_2)
            .fontSize($r('app.float.font_10'))
            .margin({ right: SizeConstant.SIZE_5 })
            .fontColor($r('app.color.color_228B22'))
            .border({
              width: SizeConstant.SIZE_1,
              color: $r('app.color.color_228B22'),
              radius: SizeConstant.SIZE_2,
              style: BorderStyle.Solid
            })
            .onClick(() => {
              let tagBean = new TagRouterBean()
              tagBean.type = "Home"
              tagBean.officialAcc = this.item.tags!![0].charptId!!

              //跳转公众号
              this.getUIContext().getRouter().pushUrl({
                url: "pages/TagDetailPage",
                params: tagBean
              })
            })
        }
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          //标题
          Text(this.item.title)
            .fontSize($r('app.float.font_15'))
            .fontColor($r('app.color.color_000000'))
            .margin({ top: SizeConstant.SIZE_10 })
            .maxLines(2)
            .width(SizeConstant.FULL_SIZE)
            .ellipsisMode(EllipsisMode.END)

          //描述
          if (this.item.desc !== undefined && this.item.desc != null) {
            RichTextComponent({
              richText: this.createRichTextFromMD(),
              fontSize: 10,
              fontColor: ($r('app.color.color_666666')),
              ellipsisMode: EllipsisMode.END,
              maxLines: 3
            })
              .margin({ top: SizeConstant.SIZE_10 })
              .width(SizeConstant.FULL_SIZE)
          }
        }.layoutWeight(1)

        if (this.item.envelopePic !== undefined && this.item.envelopePic !== null) {
          Image(this.item.envelopePic)
            .objectFit(ImageFit.Auto)
            .width(SizeConstant.SIZE_50)
            .height(SizeConstant.SIZE_50)
            .margin({ right: SizeConstant.SIZE_5, left: SizeConstant.SIZE_5 })
        }
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      Row() {
        //置顶
        if (this.item.isTop) {
          Text("置顶")
            .fontSize($r('app.float.font_11'))
            .fontColor(Color.Red)
            .margin({ right: SizeConstant.SIZE_10 })
        }

        //来源
        if (this.item.superChapterName !== undefined) {
          Text(`${this.item.superChapterName}·${this.item.chapterName}`)
            .fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_999999'))
            .layoutWeight(1)
        } else {
          Text(`${this.item.chapterName}`)
            .fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_999999'))
            .layoutWeight(1)
        }

        Image(this.item.collect ? $r('app.media.shixin_love') : $r('app.media.kongxin_love'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({ right: SizeConstant.SIZE_5 })
          .onClick(() => {
            if (this.onCollectClick) {
              this.onCollectClick(this.item)
            }
          })
      }.width(SizeConstant.FULL_SIZE)
      .margin({ top: SizeConstant.SIZE_10 })
      .alignItems(VerticalAlign.Center)

    }.width(SizeConstant.FULL_SIZE)
    .padding({
      top: SizeConstant.SIZE_10,
      bottom: SizeConstant.SIZE_10,
      left: SizeConstant.SIZE_10,
      right: SizeConstant.SIZE_10
    })
    .gesture(GestureGroup(GestureMode.Exclusive, TapGesture().onAction((event: GestureEvent) => {
      //点击跳转webView
      this.getUIContext().getRouter().pushUrl({
        url: "pages/WebPage",
        params: {
          webUrl: this.item.link
        }
      })
    })))
  }

  private createRichTextFromMD() {
    const richTextRepresentation = new RichTextRepresentation()
    richTextRepresentation.htmlString = this.item.desc
    return richTextRepresentation
  }
}