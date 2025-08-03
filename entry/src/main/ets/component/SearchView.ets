/**
 * 搜索行
 */
import SizeConstant from '../constants/SizeConstant'
import { HotKeyBean } from '../bean/HotKeyBean'
import { JSON } from '@kit.ArkTS'
import { UserService } from '../service/UserService'

@Component
export struct SearchView {
  //热词
  @Prop hotKeys: HotKeyBean[] = []
  @StorageProp('topRectHeight') topRectHeight: number = 0
  //点击搜索
  onClicked: () => void = () => {
  }
  //轮播
  onSwiper: (index: number) => void = (index: number) => {
  }

  build() {
    //顶部
    Column() {
      Row() {
        //搜索
        Row() {
          //搜索图标
          Image($r('app.media.search'))
            .width(SizeConstant.SIZE_15)
            .height(SizeConstant.SIZE_15)
            .margin({ left: 5, right: 5 })
          //搜索文字
          //上下轮播滚动
          Swiper() {
            ForEach(this.hotKeys, (bean: HotKeyBean, index: number) => {
              Text(bean.name)
                .fontSize($r('app.float.font_12'))//默认fp
                .fontColor(Color.White)
                .height(SizeConstant.FULL_SIZE)
                .width(SizeConstant.FULL_SIZE)
            }, (bean: HotKeyBean, index: number) => JSON.stringify(bean) + index)
          }
          .autoPlay(true)
          .indicator(false)
          .interval(2000)
          .index(0)
          .loop(true)
          .duration(1000)
          .displayCount(1)
          .vertical(true)
          .height(SizeConstant.FULL_SIZE)
          .width(SizeConstant.FULL_SIZE)
          .itemSpace(0)
          .onChange((index: number) => {
            this.onSwiper(index)
          })
          .hitTestBehavior(HitTestMode.None)
        }
        .geometryTransition("search")
        .transition(TransitionEffect.OPACITY.animation({ duration: 350, curve: Curve.Friction }))
        .width(SizeConstant.SIZE_PERCENT_85)
        .alignItems(VerticalAlign.Center)
        .height(SizeConstant.SIZE_30)
        .backgroundColor($r('app.color.color_474954'))
        .borderRadius(20)
        .margin({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_10, left: SizeConstant.SIZE_10 })
        .onClick(() => {
          //进入搜索界面
          this.onClicked()
        })

        Blank()

        Image($r('app.media.login'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({ right: SizeConstant.SIZE_15 })
          .onClick(() => {
            if (UserService.get().isLogin()) {
              //跳转文章编辑界面
              this.getUIContext().getRouter().pushUrl({
                url: "pages/EditArticlePage"
              })
            } else {
              //跳转登录界面
              this.getUIContext().getRouter().pushUrl({
                url: "pages/LoginPage"
              })
            }
          })

      }
      .width(SizeConstant.FULL_SIZE)
      .backgroundColor($r('app.color.color_272A36'))
      .alignItems(VerticalAlign.Center)

      //沉浸式延伸到状态栏
    }.width(SizeConstant.FULL_SIZE)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}