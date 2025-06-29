import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { CommonListItemView } from 'utils'
import { UserService } from '../service/UserService'
import { User } from '../bean/LoginResponse'

class UserInfo {
  name: string = ""
  level: string = ""
  rank: string = ""
  point: string = ""
}

@Component
export struct MimeView {
  private unLoginInfo: UserInfo = {
    name: "未登录",
    level: "",
    rank: "",
    point: ""
  }
  @State userInfo: UserInfo = this.unLoginInfo;
  @State isLogin: boolean = false;
  //登录、登出回调
  private userObserver = (user?: User) => {
    if (user) {
      this.isLogin = true;
      this.userInfo = {
        name: user.nickname,
        level: user.level,
        rank: user.rank,
        point: user.coinCount.toString()
      }
    } else {
      this.isLogin = false;
      this.userInfo = this.unLoginInfo
    }
  }

  aboutToAppear(): void {
    UserService.get().addUserObserver(this.userObserver)
    const user = UserService.get().getUser()
    this.userObserver(user)
  }

  aboutToDisappear(): void {
    UserService.get().removeUserObserver(this.userObserver)
  }

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
          UserService.get().checkLogin(() => {
            router.pushUrl({
              url: "pages/PersonAvater"
            })
          })
        })

      //欢迎词
      Text(this.userInfo.name)
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
        UserService.get().checkLogin(() => {
          router.pushUrl({
            url: "pages/PointPage"
          })
        })
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
        UserService.get().checkLogin(() => {
          router.pushUrl({
            url: "pages/CollectPage"
          })
        })
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
        UserService.get().checkLogin(() => {
          router.pushUrl({
            url: "pages/SharePage"
          })
        })
      })

      //线
      Divider()
        .width(SizeConstant.FULL_SIZE)
        .height(1)
        .color($r('app.color.color_979797'))

      //TODO
      Row() {
        Text("TODO")
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
        UserService.get().checkLogin(() => {
          router.pushUrl({
            url: "pages/SharePage"
          })
        })
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
        Text("百炼模型库")
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

      //图像生成
      Row() {
        Text("图像生成")
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