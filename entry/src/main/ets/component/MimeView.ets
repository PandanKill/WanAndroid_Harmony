import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { CommonListItemView } from 'utils'

@Component
export struct MimeView {
  @StorageLink("isLogin") isLogin: boolean = false
  @StorageLink("username") username: string = ''

  build() {
    Column() {
      //头像
      Image($r('app.media.icon_person'))
        .width(SizeConstant.SIZE_50)
        .height(SizeConstant.SIZE_50)
        .margin({ top: SizeConstant.SIZE_40 })
        .sharedTransition("avater", {
          duration: 200,
          curve: Curve.Smooth
        })
        .onClick(() => {
          //头像详情，共享元素
          router.pushUrl({
            url: "pages/PersonAvater"
          })
        })

      //欢迎词
      Text(this.isLogin ? `欢迎回来！${this.username}` : "欢迎登录！")
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_000000'))
        .margin({ top: SizeConstant.SIZE_5 })

      //我的积分
      Row() {
        Text("我的积分")
          .fontSize($r('app.float.font_15'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_20, top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_5)
          .height(SizeConstant.SIZE_5)
          .margin({ right: SizeConstant.SIZE_20 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .margin({ top: SizeConstant.SIZE_20 })
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 积分
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))

      //我的收藏
      Row() {
        Text("我的收藏")
          .fontSize($r('app.float.font_15'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_20, top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_5)
          .height(SizeConstant.SIZE_5)
          .margin({ right: SizeConstant.SIZE_20 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 收藏
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))


      //我的分享
      Row() {
        Text("我的分享")
          .fontSize($r('app.float.font_15'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_20, top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_5)
          .height(SizeConstant.SIZE_5)
          .margin({ right: SizeConstant.SIZE_20 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 分享
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))


      //系统设置
      Row() {
        Text("系统设置")
          .fontSize($r('app.float.font_15'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_20, top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_5)
          .height(SizeConstant.SIZE_5)
          .margin({ right: SizeConstant.SIZE_20 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 系统设置
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.color_F5F5F5'))
  }
}