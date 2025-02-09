@Component
export struct CommonListItemView {
  //contentClick
  private contentClick?: (() => void)
  //tag click
  private tagClick?: (() => void)

  build() {
    // //ItemLayout
    // Column() {
    //   Row() {
    //     //头像
    //     Image($r('app.media.icon_person'))
    //       .width(SizeConstant.SIZE_30)
    //       .height(SizeConstant.SIZE_30)
    //
    //     Column() {
    //       Text(item.author === undefined || item.author === "" ? "匿名" : item.author)
    //         .fontSize($r('app.float.font_10'))
    //         .fontColor($r('app.color.color_666666'))
    //         .background()
    //         .margin({ bottom: SizeConstant.SIZE_2 })
    //       Text(item.niceDate).fontSize($r('app.float.font_10'))
    //         .fontColor($r('app.color.color_999999'))
    //     }.layoutWeight(1)
    //     .alignItems(HorizontalAlign.Start)
    //     .margin({ left: SizeConstant.SIZE_10 })
    //
    //     if (item.tags !== undefined && item.tags.length !== 0) {
    //       //存在tag
    //       Text(item.tags[0].name)
    //         .padding(SizeConstant.SIZE_2)
    //         .fontSize($r('app.float.font_10'))
    //         .margin({ right: SizeConstant.SIZE_5 })
    //         .fontColor($r('app.color.color_228B22'))
    //         .border({
    //           width: SizeConstant.SIZE_1,
    //           color: $r('app.color.color_228B22'),
    //           radius: SizeConstant.SIZE_2,
    //           style: BorderStyle.Solid
    //         })
    //         .onClick(() => {
    //           //跳转公众号
    //           //点击跳转webView
    //           if (this.tagClick !== undefined) {
    //             this.tagClick!!()
    //           }
    //         })
    //     }
    //   }.width(SizeConstant.FULL_SIZE)
    //   .alignItems(VerticalAlign.Center)
    //
    //   Row() {
    //     Column() {
    //       //标题
    //       Text(item.title)
    //         .fontSize($r('app.float.font_15'))
    //         .fontColor($r('app.color.color_000000'))
    //         .margin({ top: SizeConstant.SIZE_10 })
    //         .maxLines(1)
    //         .width(SizeConstant.FULL_SIZE)
    //         .ellipsisMode(EllipsisMode.END)
    //
    //       if (item.desc !== undefined) {
    //         //内容
    //         Text(item.desc)
    //           .fontSize($r('app.float.font_12'))
    //           .fontColor($r('app.color.color_000000'))
    //           .margin({ top: SizeConstant.SIZE_10 })
    //           .maxLines(3)
    //           .width(SizeConstant.FULL_SIZE)
    //           .ellipsisMode(EllipsisMode.END)
    //       }
    //     }.layoutWeight(1)
    //
    //     if (item.envelopePic !== undefined) {
    //       Image(item.envelopePic)
    //         .objectFit(ImageFit.Auto)
    //         .width(SizeConstant.SIZE_50)
    //         .height(SizeConstant.SIZE_50)
    //         .margin({ right: SizeConstant.SIZE_5, left: SizeConstant.SIZE_5 })
    //     }
    //   }.width(SizeConstant.FULL_SIZE)
    //   .alignItems(VerticalAlign.Center)
    //
    //
    //   Row() {
    //     //来源
    //     Text(`${item.superChapterName}·${item.chapterName}`)
    //       .fontSize($r('app.float.font_10'))
    //       .fontColor($r('app.color.color_999999'))
    //       .layoutWeight(1)
    //
    //     Image(item.zan ? $r('app.media.shixin_love') : $r('app.media.kongxin_love'))
    //       .width(SizeConstant.SIZE_20)
    //       .height(SizeConstant.SIZE_20)
    //       .margin({ right: SizeConstant.SIZE_5 })
    //       .onClick(() => {
    //         //点赞
    //         item.zan = !item.zan
    //       })
    //   }.width(SizeConstant.FULL_SIZE)
    //   .margin({ top: SizeConstant.SIZE_10 })
    //   .alignItems(VerticalAlign.Center)
    //
    // }.width(SizeConstant.FULL_SIZE)
    // .padding({
    //   top: SizeConstant.SIZE_10,
    //   bottom: SizeConstant.SIZE_10,
    //   left: SizeConstant.SIZE_10,
    //   right: SizeConstant.SIZE_10
    // })
    // .onClick(() => {
    //   //点击跳转webView
    //   if (this.contentClick !== undefined) {
    //     this.contentClick!!()
    //   }
    // })
  }
}