import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'

@Component
export struct NavHeaderView {
  //标题
  private title: string | Resource = ''
  //菜单
  private menu: Resource | string = $r('app.media.login')
  //是否显示返回按键
  private isShowBack: boolean = true
  private isShowMenu: boolean = false
  private backRule: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
    'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
    'center': { 'anchor': '__container__', 'align': VerticalAlign.Center }
  }
  private titleRule: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
    'center': { 'anchor': '__container__', 'align': VerticalAlign.Center },
    'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
  }
  private menuRule: AlignRuleOption = {
    right: { 'anchor': '__container__', 'align': HorizontalAlign.End },
    center: { 'anchor': '__container__', 'align': VerticalAlign.Center }
  }
  //菜单点击
  private onMenuClick: () => void = () => {

  }

  build() {
    RelativeContainer() {
      if (this.isShowBack) {
        Image($r('app.media.icon_back'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({
            left: SizeConstant.SIZE_15
          })
          .alignRules(this.backRule)
          .onClick(() => {
            router.back()
          })
      }

      Text(this.title)
        .alignRules(this.titleRule)
        .fontColor($r('app.color.color_FFFFFF'))
        .fontSize($r('app.float.font_15'))

      if (this.isShowMenu) {
        Image(this.menu)
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({
            right: SizeConstant.SIZE_15
          })
          .alignRules(this.menuRule)
          .onClick(() => {
            this.onMenuClick()
          })
      }

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.SIZE_50)
    .backgroundColor($r('app.color.color_272A36'))
  }
}