import { AnswerContentView } from '../component/AnswerContentView';
import { HomeView } from '../component/HomeView';
import { MimeView } from '../component/MimeView';
import { NavigationView } from '../component/NavigationView';
import { ProjectContentView } from '../component/ProjectContentView';
import { SearchView } from '../component/SearchView';
import SizeConstant from '../constants/SizeConstant';
import { FooterTab, FooterTabViewModel } from '../viewModel/FooterTabViewModel';
import systemTime from '@ohos.systemTime';
import systemDateTime from '@ohos.systemDateTime';
import { promptAction } from '@kit.ArkUI';
import { httpRequest, logger, requestPath } from 'utils';
import { rcp } from '@kit.RemoteCommunicationKit';
import { JSON } from '@kit.ArkTS';
import { ResponseBean } from '../bean/ResponseBean';
import { HotKeyBean } from '../bean/HotKeyBean';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import http from '@ohos.net.http';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @StorageLink('isLogin') isLogin: boolean = false
  //tab
  private tabList: FooterTab[] = new FooterTabViewModel().getTabList()
  //选中index,初始0
  @State private selectIndex: number = 0
  //controller
  private controller: TabsController = new TabsController()
  //导航栏高度
  bottomRectHeight: string = AppStorage.get<number>('navHeight') + 'px';
  //最后一次返回时间
  private lastPressMill: number = 0
  //热词
  @StorageProp('hotKey') hotKeys: HotKeyBean[] = []

  @Builder
  tabBuilder(item: FooterTab, index: number) {
    Column() {
      Image(index === this.selectIndex ? item.getIconSelected() : item.getIcon())
        .width(SizeConstant.SIZE_20)
        .height(SizeConstant.SIZE_20)
      Text(item.getName())
        .fontSize($r('app.float.font_10'))
        .padding({
          top: SizeConstant.SIZE_5,
          left: SizeConstant.SIZE_5,
          bottom: SizeConstant.SIZE_5,
          right: SizeConstant.SIZE_5
        })
        .fontColor(index === this.selectIndex ? $r('app.color.color_FF9912') : $r('app.color.color_FFFFFF'))
    }.padding({ top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_5 })
    .justifyContent(FlexAlign.Center)
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }

  aboutToAppear(): void {
    //获取热词
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + requestPath.PATH_HOTKEY_JSON).then((response: rcp.Response) => {
      console.info(`Response succeeded: ${response}`);
      if (response !== undefined) {
        let bean = JSON.parse(response.toString()) as ResponseBean<HotKeyBean[]>
        if (bean.errorCode === 0) {
          this.hotKeys = bean.data
        }
      }
    }).catch((err: BusinessError) => {

    }).finally(()=>{
      session.close()
    })
  }

  build() {
    Column() {
      //搜索栏
      SearchView({ hotKeys: this.hotKeys })
        .width(SizeConstant.FULL_SIZE)
      Tabs({
        //底部
        barPosition: BarPosition.End,
        controller: this.controller,
        index: this.selectIndex
      }) {
        //首页
        TabContent() {
          HomeView().width(SizeConstant.FULL_SIZE)
            .height(SizeConstant.FULL_SIZE)
            .backgroundColor($r('app.color.color_FFFFFF'))
        }.tabBar(this.tabBuilder(this.tabList[0], 0))

        //导航
        TabContent() {
          NavigationView()
            .width(SizeConstant.FULL_SIZE)
            .height(SizeConstant.FULL_SIZE)
            .backgroundColor($r('app.color.color_FFFFFF'))
        }.tabBar(this.tabBuilder(this.tabList[1], 1))

        //问答
        TabContent() {
          AnswerContentView()
            .width(SizeConstant.FULL_SIZE)
            .height(SizeConstant.FULL_SIZE)
            .backgroundColor($r('app.color.color_FFFFFF'))
        }.tabBar(this.tabBuilder(this.tabList[2], 2))

        //项目
        TabContent() {
          ProjectContentView()
            .width(SizeConstant.FULL_SIZE)
            .height(SizeConstant.FULL_SIZE)
            .backgroundColor($r('app.color.color_FFFFFF'))
        }.tabBar(this.tabBuilder(this.tabList[3], 3))

        //我的
        TabContent() {
          MimeView()
            .width(SizeConstant.FULL_SIZE)
            .height(SizeConstant.FULL_SIZE)
        }.tabBar(this.tabBuilder(this.tabList[4], 4))
      }
      .vertical(false)
      .barWidth(SizeConstant.FULL_SIZE)
      .barHeight(SizeConstant.SIZE_50)
      .barBackgroundColor($r('app.color.color_272A36'))
      .margin({ bottom: this.bottomRectHeight })
      .width(SizeConstant.FULL_SIZE)
      .scrollable(false)
      .animationMode(AnimationMode.NO_ANIMATION)
      .onChange((index) => {
        this.selectIndex = index
      })
      .barMode(BarMode.Fixed,
        { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
    }.width(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_272A36'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  onBackPress(): boolean | void {
    let nowMill = systemDateTime.getTime(false)

    if (nowMill - this.lastPressMill < 2000) {
      return false
    }
    this.lastPressMill = nowMill
    promptAction.showToast({
      message: $r('app.string.press_again')
    })
    return true
  }
}