/**
 * 登录界面
 */
import SizeConstant from '../constants/SizeConstant'
import { promptAction, router } from '@kit.ArkUI'
import { httpRequest } from 'utils/src/main/ets/http/HttpRequest'
import { logger, requestPath } from 'utils'
import { BusinessError } from '@kit.BasicServicesKit'
import { JSON } from '@kit.ArkTS'
import { rcp } from '@kit.RemoteCommunicationKit'
import { LoginBean } from '../bean/LoginBean'
import { ResponseBean } from '../bean/ResponseBean'

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

  login() {
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

    let loginBean = new LoginBean(this.userName, this.pwd)
    //登录
    let session = rcp.createSession()
    session.post(requestPath.baseUrl + requestPath.PATH_LOGIN, JSON.stringify(loginBean)).then((response) => {
      console.info(`Response succeeded: ${response}`);
      if (response !== undefined) {
        let responseBean: ResponseBean<string> = JSON.parse(response.toString()) as ResponseBean<string>
        if (responseBean.errorCode !== 0) {
          promptAction.showToast({
            message: responseBean.errorMsg
          })
        } else {
          //登录成功
          promptAction.showToast({
            message: $r('app.string.login_succ')
          })
          //登录成功
          AppStorage.setOrCreate("isLogin", true)
        }
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
  }

  build() {
    Column() {
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
      .margin({ top: SizeConstant.SIZE_50 })
      .alignItems(VerticalAlign.Center)

      //去注册
      Text($r('app.string.to_register'))
        .fontColor($r('app.color.color_FFFFFF'))
        .fontSize($r('app.float.font_15'))
        .margin({ top: SizeConstant.SIZE_50 })
        .onClick(() => {
          //去注册
          router.pushUrl({
            url: 'pages/LoginPage'
            //增加参数：是否是登录还是注册
          })
        })

      //登录
      Button($r('app.string.to_login'))
        .width(SizeConstant.SIZE_PERCENT_80)
        .height(SizeConstant.SIZE_50)
        .margin({ top: SizeConstant.SIZE_50 })
        .fontSize($r('app.float.font_20'))
        .fontColor($r('app.color.color_FFFFFF'))
        .onClick(() => {
          this.login()
        })
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.color_666666'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}