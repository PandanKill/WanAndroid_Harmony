import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { common, ConfigurationConstant } from '@kit.AbilityKit'
import { faceDetector } from '@kit.CoreVisionKit'
import { setAutoColorMode, setDarkColorMode, setLightColorMode } from '../utils/ColorModeChangeFunctions'
import { http } from '@kit.NetworkKit'
import { requestPath } from 'utils/src/main/ets/http/RequestPath'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction, router } from '@kit.ArkUI'

@Entry
@Component
struct SettingPage {
  @StorageProp('colorModel') isOnSystemMode: number = 0
  @StorageProp('enableDarkMode') enableDarkMode: boolean = false
  @StorageProp('isFollowSystemSetting') isFollowSystemSetting: boolean = true
  @StorageProp('screenRecord') isScreenRecord: boolean = false
  @StorageProp('isLogin') isLogin: boolean = false
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode);
    AppStorage.setOrCreate('isFollowSystemSetting', this.isFollowSystemSetting);
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.setting')
      })

      //跟随系统暗色模式
      Row() {
        Text($r('app.string.setting_blackmode'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))

        Toggle({
          type: ToggleType.Switch,
          isOn: this.isFollowSystemSetting
        })
          .selectedColor($r('app.color.color_52D367'))
          .switchPointColor($r('app.color.color_FFFFFF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_25)
          .margin({ right: SizeConstant.SIZE_15 })
          .onChange((isOn) => {
            if (isOn) {
              this.isFollowSystemSetting = true
              this.enableDarkMode = false
              setAutoColorMode(this.context)
            } else {
              this.isFollowSystemSetting = false
              if (this.enableDarkMode) {
                setDarkColorMode(this.context)
              } else {
                setLightColorMode(this.context)
              }
            }
          })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .backgroundColor($r('app.color.color_FFFFFF'))

      //暗黑模式
      Row() {
        Text($r('app.string.setting_black'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))

        Toggle({
          type: ToggleType.Switch,
          isOn: this.enableDarkMode
        })
          .selectedColor($r('app.color.color_52D367'))
          .switchPointColor($r('app.color.color_FFFFFF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_25)
          .margin({ right: SizeConstant.SIZE_15 })
          .onChange((isOn) => {
            this.enableDarkMode = isOn
            if (isOn) {
              this.isFollowSystemSetting = false
              setDarkColorMode(this.context)
            } else if (!this.isFollowSystemSetting) {
              setLightColorMode(this.context)
            }
          })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))

      //屏幕录制
      Row() {
        Text($r('app.string.setting_screenrecord'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))

        Toggle({
          type: ToggleType.Switch,
          isOn: this.isScreenRecord
        })
          .selectedColor($r('app.color.color_52D367'))
          .switchPointColor($r('app.color.color_FFFFFF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_25)
          .margin({ right: SizeConstant.SIZE_15 })
          .onChange((isOn) => {
            this.isScreenRecord = isOn
          })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))

      //隐私政策
      Row() {
        Text($r('app.string.setting_privaty'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))

      //问题反馈
      Row() {
        Text($r('app.string.setting_question'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))

      //关于 WanAndroid
      Row() {
        Text($r('app.string.setting_wanandroid'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))

      //清除缓存
      Row() {
        Text($r('app.string.setting_clearcache'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))

      //版本更新
      Row() {
        Text($r('app.string.setting_update'))
          .fontSize($r('app.float.font_15'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))

      //退出登录
      if (this.isLogin) {
        Button($r('app.string.logout'))
          .width('60%')
          .height(SizeConstant.SIZE_50)
          .margin({ top: SizeConstant.SIZE_10 })
          .backgroundColor($r('app.color.color_FFFFFF'))
          .borderWidth(2)
          .borderRadius(15)
          .onClick(() => {
            this.toLogout()
          })
      }

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_F5F5F5'))
  }

  toLogout() {
    let httpSession = http.createHttp()
    httpSession.request(requestPath.baseUrl + requestPath.PATH_LOGOUT, {
      method: http.RequestMethod.GET
    }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        if (data.responseCode === 200) {
          AppStorage.setOrCreate('nickname', "")
          AppStorage.setOrCreate('isLogin', false)
          //登出成功
          promptAction.showToast({
            message: $r('app.string.logout_succ')
          })
          router.back()
        } else {
          //登出成功
          promptAction.showToast({
            message: $r('app.string.logout_fail')
          })
        }
      } else {
        promptAction.showToast({
          message: err.message
        })
      }

      httpSession.destroy()
    })
  }
}