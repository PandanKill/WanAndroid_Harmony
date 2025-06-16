/**
 * 登录界面
 */
import SizeConstant from '../constants/SizeConstant'
import { promptAction, router } from '@kit.ArkUI'
import { logger, requestPath } from 'utils'
import { BusinessError } from '@kit.BasicServicesKit'
import { JSON } from '@kit.ArkTS'
import { rcp } from '@kit.RemoteCommunicationKit'
import { LoginBean } from '../bean/LoginBean'
import { ResponseBean } from '../bean/ResponseBean'
import { NavHeaderView } from '../component/NavHeaderView'
import { http } from '@kit.NetworkKit'
import { User } from '../bean/LoginResponse'
import Api from '../utils/net/Api'
import { UserService } from '../service/UserService'

@Entry
@Component
struct LoginPage {
  @State @Watch('changeUsername') private userName: string = ''
  @State @Watch('changePwd') private pwd: string = ''
  //是否展示清空按钮
  @State isShowUserNameClean: boolean = false
  //是否展示清空密码
  @State isShowPwdClean: boolean = false

  onPageShow(): void {
    //页面展示
  }

  changeUsername() {
    if (this.userName !== '' && this.userName !== undefined) {
      //不为空,展示清空按钮
      this.isShowUserNameClean = true
    } else {
      //为空,不展示清空按钮
      this.isShowUserNameClean = false
    }
  }

  changePwd() {
    if (this.pwd !== '' && this.pwd !== undefined) {
      //不为空,展示清空按钮
      this.isShowPwdClean = true
    } else {
      //为空,不展示清空按钮
      this.isShowPwdClean = false
    }
  }

  async login() {
    if (this.userName === '' || this.userName === undefined) {
      promptAction.showToast({
        message: $r('app.string.please_input_username')
      })
      return
    }

    if (this.pwd === '' || this.pwd === undefined) {
      promptAction.showToast({
        message: $r('app.string.please_input_pwd')
      })
      return
    }

    const logBean: ResponseBean<User> = await Api.get().login(this.userName, this.pwd)
    if (logBean.isSuccessWithData()) {
      promptAction.showToast({
        message: $r('app.string.login_succ')
      })
      UserService.get().setUser(logBean.getDataOrThrow())
      const user = await UserService.get().updateUser()
      if (user) {
        router.back()
      }
    } else {
      promptAction.showToast({
        message: logBean.errorMsg
      })
    }
  }

  build() {
    Column() {
      NavHeaderView({
        title: ""
      })

      //头像
      Row() {
        Image($r('app.media.icon_person'))
          .width('50%')
          .aspectRatio(1)
          .onClick(() => {
            //跳转相册
            promptAction.showToast({
              message: "跳转相册"
            })
          })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width(SizeConstant.FULL_SIZE)
      .height('30%')

      //用户名
      Row() {
        //请输入用户名
        TextInput({
          placeholder: $r('app.string.please_input_username'),
          text: $$this.userName
        })
          .fontColor($r('app.color.color_FFFFFF'))
          .fontSize($r('app.float.font_15'))
          .layoutWeight(1)
          .enterKeyType(EnterKeyType.Next)
          .height(SizeConstant.FULL_SIZE)

        if (this.isShowUserNameClean) {
          //清空号
          Image($r('app.media.clean'))
            .width(SizeConstant.SIZE_20)
            .height(SizeConstant.SIZE_20)
            .margin({ left: SizeConstant.SIZE_5 })
            .onClick(() => {
              //清空
              this.userName = ''
            })
        }
      }.width(SizeConstant.SIZE_PERCENT_80)
      .margin({ top: SizeConstant.SIZE_50 })
      .height(SizeConstant.SIZE_50)
      .alignItems(VerticalAlign.Center)

      //密码
      Row() {
        //请输入密码
        TextInput({
          placeholder: $r('app.string.please_input_pwd'),
          text: $$this.pwd
        })
          .enterKeyType(EnterKeyType.Done)
          .fontColor($r('app.color.color_FFFFFF'))
          .fontSize($r('app.float.font_15'))
          .layoutWeight(1)
          .showPasswordIcon(false)
          .type(InputType.Password)
          .height(SizeConstant.FULL_SIZE)

        if (this.isShowPwdClean) {
          //清空号
          Image($r('app.media.clean'))
            .width(SizeConstant.SIZE_20)
            .height(SizeConstant.SIZE_20)
            .margin({ left: SizeConstant.SIZE_5 })
            .onClick(() => {
              //清空
              this.pwd = ''
            })
        }
      }.width(SizeConstant.SIZE_PERCENT_80)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_20 })
      .alignItems(VerticalAlign.Center)

      //登录
      Button($r('app.string.to_login'))
        .width(SizeConstant.SIZE_PERCENT_50)
        .height(SizeConstant.SIZE_50)
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_FFFFFF'))
        .borderWidth(1)
        .borderRadius(5)
        .margin({ top: SizeConstant.SIZE_50 })
        .borderColor($r('app.color.color_FFFFFF'))
        .onClick(() => {
          this.login()
        })
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.color_272A36'))
  }
}