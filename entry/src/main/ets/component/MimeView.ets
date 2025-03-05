import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { CommonListItemView } from 'utils'

@Component
export struct MimeView {
  @StorageProp("isLogin") isLogin: boolean = false
  @StorageProp("nickname") nickname: string = ''

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
          if (this.isLogin) {
            router.pushUrl({
              url: "pages/PersonAvater"
            })
          } else {
            router.pushUrl({
              url: "pages/LoginPage"
            })
          }
        })

      //欢迎词
      Text(this.isLogin ? `欢迎回来！${this.nickname}` : "欢迎登录！")
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_000000'))
        .margin({ top: SizeConstant.SIZE_5 })

      //我的积分
      Row() {
        Text("我的积分")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_15, bottom: SizeConstant.SIZE_15 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_15)
          .height(SizeConstant.SIZE_15)
          .margin({ right: SizeConstant.SIZE_15 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .margin({ top: SizeConstant.SIZE_20 })
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 积分
        // if (this.isLogin) {
        router.pushUrl({
          url: "pages/PointPage"
        })
        // } else {
        //   router.pushUrl({
        //     url: "pages/LoginPage"
        //   })
        // }
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))

      //我的收藏
      Row() {
        Text("我的收藏")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_15, bottom: SizeConstant.SIZE_15 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_15)
          .height(SizeConstant.SIZE_15)
          .margin({ right: SizeConstant.SIZE_15 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 收藏
        // if (this.isLogin) {
        router.pushUrl({
          url: "pages/CollectPage"
        })
        // } else {
        //   router.pushUrl({
        //     url: "pages/LoginPage"
        //   })
        // }
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))


      //我的分享
      Row() {
        Text("我的分享")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_15, bottom: SizeConstant.SIZE_15 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_15)
          .height(SizeConstant.SIZE_15)
          .margin({ right: SizeConstant.SIZE_15 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 分享
        if (this.isLogin) {

        } else {
          router.pushUrl({
            url: "pages/LoginPage"
          })
        }
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))


      //系统设置
      Row() {
        Text("系统设置")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_15, bottom: SizeConstant.SIZE_15 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_15)
          .height(SizeConstant.SIZE_15)
          .margin({ right: SizeConstant.SIZE_15 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to 系统设置
        router.pushUrl({
          url: "pages/SettingPage"
        })
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))

      //AI 聊天
      Row() {
        Text("你好 Harmony")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_000000'))
          .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_15, bottom: SizeConstant.SIZE_15 })
          .layoutWeight(1)

        Image($r('app.media.to_right'))
          .width(SizeConstant.SIZE_15)
          .height(SizeConstant.SIZE_15)
          .margin({ right: SizeConstant.SIZE_15 })

      }
      .width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //to AI 聊天
        router.pushUrl({
          url: "pages/ChatPage"
        })
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