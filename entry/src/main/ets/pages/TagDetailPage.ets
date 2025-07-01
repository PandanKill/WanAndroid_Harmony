import { requestPath } from 'utils/src/main/ets/http/RequestPath'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { logger } from 'utils'
import { JSON } from '@kit.ArkTS'
import { TabDetailBean } from '../bean/TabDetailBean'
import { ResponseBean } from '../bean/ResponseBean'
import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { TabContentView } from '../component/TabContentView'
import { TagRouterBean } from '../bean/TagRouterBean'
import Api from '../utils/net/Api'

@Entry
@Component
struct TagDetailPage {
  @State private tabs: TabDetailBean[] = []
  @State private currentIndex: number = 0
  private tagBean: TagRouterBean = this.getUIContext().getRouter().getParams() as TagRouterBean
  @StorageProp('topRectHeight') topRectHeight: number = 0

  aboutToAppear(): void {
    if (this.tagBean.type === "Home") {
      Api.get().getWXArticle().then((responseBean: ResponseBean<TabDetailBean[]>) => {
        if (responseBean.errorCode === 0) {
          //获取成功
          logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
          this.tabs = responseBean.getDataOrThrow()
          responseBean.getDataOrThrow().forEach((item: TabDetailBean, index: number) => {
            if (item.id === this.tagBean.officialAcc) {
              this.currentIndex = index
            }
          })
        }
      })
    } else if (this.tagBean.type === "TiXi") {
      //体系
      this.tabs = this.tagBean.tags
      this.tagBean.tags.forEach((item: TabDetailBean, index: number) => {
        if (item.id === this.tagBean.officialAcc) {
          this.currentIndex = index
        }
      })
    }
  }

  @Builder
  tabBuilder(name: string, index: number) {
    Text(name)
      .fontColor(index === this.currentIndex ? $r('app.color.color_272A36') : $r('app.color.color_999999'))
      .fontSize($r('app.float.font_12'))
      .padding({ right: SizeConstant.SIZE_10, left: SizeConstant.SIZE_10 })
      .height(SizeConstant.FULL_SIZE)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
          ForEach(this.tabs, (item: TabDetailBean, index: number) => {
            TabContent() {
              TabContentView({ contentId: item.id, type: this.tagBean.type })
                .width(SizeConstant.FULL_SIZE)
                .height(SizeConstant.FULL_SIZE)
            }.tabBar(this.tabBuilder(item.name, index))
          }, (item: TabDetailBean, index: number) => JSON.stringify(item) + index)
        }
        .vertical(false)
        .height(SizeConstant.FULL_SIZE)
        .width(SizeConstant.FULL_SIZE)
        .barMode(BarMode.Scrollable, {
          nonScrollableLayoutStyle: LayoutStyle.ALWAYS_AVERAGE_SPLIT
        })
        .scrollable(true)
        .onChange((index: number) => {
          this.currentIndex = index
        })
      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
    }.width(SizeConstant.FULL_SIZE)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}