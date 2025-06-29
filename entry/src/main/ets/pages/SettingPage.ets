import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { bundleManager, common, ConfigurationConstant } from '@kit.AbilityKit'
import { setAutoColorMode, setDarkColorMode, setLightColorMode } from '../utils/ColorModeChangeFunctions'
import { UserService } from '../service/UserService'
import Api from '../utils/net/Api'
import { User } from '../bean/LoginResponse'
import { promptAction, router } from '@kit.ArkUI'
import { Constants } from '../constants/Constants'
import Preference from '../utils/Preference'

@Entry
@Component
struct SettingPage {
  @StorageProp('colorModel') isOnSystemMode: number = 0
  @StorageProp('enableDarkMode') enableDarkMode: boolean = false
  @StorageProp('isFollowSystemSetting') isFollowSystemSetting: boolean = true
  @StorageProp('screenRecord') isScreenRecord: boolean = false
  //是否指纹登录
  @State fingureLogin: boolean = false
  @State isLogin: boolean = false
  //应用版本
  @State versionName: string = ""
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode);
    AppStorage.setOrCreate('isFollowSystemSetting', this.isFollowSystemSetting);
    this.isLogin = UserService.get().isLogin()

    let bundleFlag2 = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
    bundleManager.getBundleInfoForSelf(bundleFlag2).then((info: bundleManager.BundleInfo) => {
      this.versionName = info.versionName
    })

    this.fingureLogin = Preference.get(this.context).getFingureLogin()
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.setting')
      })

      //跟随系统暗色模式
      Row() {
        Text($r('app.string.setting_blackmode'))
          .leftTextStyle()

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
          .leftTextStyle()

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
          .leftTextStyle()

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

      //指纹登录
      Row() {
        Text($r('app.string.figure_login'))
          .leftTextStyle()

        Toggle({
          type: ToggleType.Switch,
          isOn: this.fingureLogin
        })
          .selectedColor($r('app.color.color_52D367'))
          .switchPointColor($r('app.color.color_FFFFFF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_25)
          .margin({ right: SizeConstant.SIZE_15 })
          .onChange((isOn) => {
            //指纹认证
            
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
          .leftTextStyle()
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        router.pushUrl({
          url: "pages/WebPage",
          params: {
            webUrl: Constants.WAN_ANDROID
          }
        })
      })

      //问题反馈
      Row() {
        Text($r('app.string.setting_question'))
          .leftTextStyle()
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        router.pushUrl({
          url: "pages/WebPage",
          params: {
            webUrl: Constants.QUESTION_WEB
          }
        })
      })

      //关于 WanAndroid
      Row() {
        Text($r('app.string.setting_wanandroid'))
          .leftTextStyle()
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        router.pushUrl({
          url: "pages/WebPage",
          params: {
            webUrl: Constants.WAN_ANDROID
          }
        })
      })

      //清除缓存
      Row() {
        Text($r('app.string.setting_clearcache'))
          .leftTextStyle()
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
          .leftTextStyle()

        Blank()

        Text(this.versionName)
          .rightTextStyle()
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onClick(() => {
        //版本检测
      })

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

  async toLogout() {
    await Api.get().logout()
    UserService.get().clearUser()
    promptAction.showToast({
      message: $r('app.string.logout_succ')
    })
    router.back()
  }
}

@Extend(Text)
function leftTextStyle() {
  .fontSize($r('app.float.font_15'))
  .margin({ left: SizeConstant.SIZE_15 })
  .fontColor($r('app.color.color_6A6A6A'))
}

@Extend(Text)
function rightTextStyle() {
  .fontSize($r('app.float.font_15'))
  .margin({ right: SizeConstant.SIZE_15 })
  .fontColor($r('app.color.color_6A6A6A'))
}