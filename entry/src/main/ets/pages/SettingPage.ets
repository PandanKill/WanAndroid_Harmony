import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'

@Entry
@Component
struct SettingPage {
  @StorageProp('modeSystem') @Watch('modeSystem') isOnSystemMode: boolean = true
  @StorageProp('blackMode') @Watch('modeSystem') isOnBlackMode: boolean = true
  @StorageProp('screenRecord') @Watch('modeSystem') isScreenRecord: boolean = true

  modeSystem() {
    //更新模式
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.setting')
      })

      //跟随系统暗色模式
      Row() {
        Text($r('app.string.setting_blackmode'))
          .fontSize($r('app.float.font_20'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))

        Toggle({
          type: ToggleType.Switch,
          isOn: this.isOnSystemMode
        })
          .selectedColor($r('app.color.color_52D367'))
          .switchPointColor($r('app.color.color_FFFFFF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_30)
          .margin({ right: SizeConstant.SIZE_15 })
          .onChange((isOn) => {
            this.isOnSystemMode = isOn
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
          .fontSize($r('app.float.font_20'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))

        Toggle({
          type: ToggleType.Switch,
          isOn: this.isOnBlackMode
        })
          .selectedColor($r('app.color.color_52D367'))
          .switchPointColor($r('app.color.color_FFFFFF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_30)
          .margin({ right: SizeConstant.SIZE_15 })
          .onChange((isOn) => {
            this.isOnBlackMode = isOn
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
          .fontSize($r('app.float.font_20'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))

        Toggle({
          type: ToggleType.Switch,
          isOn: this.isScreenRecord
        })
          .selectedColor($r('app.color.color_52D367'))
          .switchPointColor($r('app.color.color_FFFFFF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_30)
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
          .fontSize($r('app.float.font_20'))
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
          .fontSize($r('app.float.font_20'))
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
          .fontSize($r('app.float.font_20'))
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
          .fontSize($r('app.float.font_20'))
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
          .fontSize($r('app.float.font_20'))
          .margin({ left: SizeConstant.SIZE_15 })
          .fontColor($r('app.color.color_6A6A6A'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_50)
      .margin({ top: SizeConstant.SIZE_1 })
      .backgroundColor($r('app.color.color_FFFFFF'))
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_F5F5F5'))
  }
}