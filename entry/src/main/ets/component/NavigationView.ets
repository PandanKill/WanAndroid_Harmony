import SizeConstant from '../constants/SizeConstant'
import { NavContentView } from './NavContentView'
import { TiXiContentView } from './TiXiContentView'

@Component
export struct NavigationView {
  //当前索引
  @State private currentIndex: number = 0
  //指示器长度
  @State private indicatorWidth: number = 0
  //间距
  @State private indicatorLeftMargin: number = 0
  private tabNames: string[] = ["导航", "体系"]

  @Builder
  tabBuilder(tabName: string, index: number) {
    Column() {
      Text(tabName)
        .fontColor(index === this.currentIndex ? $r('app.color.color_272A36') : $r('app.color.color_999999'))
        .fontSize($r('app.float.font_12'))
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .onAreaChange((oldValue: Area, newValue: Area) => {
          //区域响应变化

        })
    }.alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Tabs() {
        TabContent() {
          //导航
          NavContentView()
            .width(SizeConstant.FULL_SIZE)
            .height(SizeConstant.FULL_SIZE)
        }.tabBar(this.tabBuilder(this.tabNames[0], 0))

        TabContent() {
          //体系
          TiXiContentView()
            .width(SizeConstant.FULL_SIZE)
            .height(SizeConstant.FULL_SIZE)
        }.tabBar(this.tabBuilder(this.tabNames[1], 1))
      }
      .onAreaChange((oldValue: Area, newValue: Area) => {
        //区域响应变化
      })
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {

      })
      .onAnimationEnd((index: number, event: TabsAnimationEvent) => {

      })
      .onGestureSwipe((index: number, event: TabsAnimationEvent) => {

      })
      //顶部tabs
      .vertical(false)
      .barPosition(BarPosition.Start)
      .barMode(BarMode.Fixed, { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_AVERAGE_SPLIT })
      .width(SizeConstant.FULL_SIZE)
      .barHeight(40)
      .scrollable(true)
      .height(SizeConstant.FULL_SIZE)
      .backgroundColor($r('app.color.color_FFFFFF'))
      .onChange((index: number) => {
        this.currentIndex = index
      })

      Column()
        .height(2)
        .width(this.indicatorWidth)
        .margin({ left: this.indicatorLeftMargin, top: 48 })
        .backgroundColor($r('app.color.color_000000'))
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }
}