import SizeConstant from '../constants/SizeConstant'
import { NavTabContentView } from './NavTabContentView'
import { httpRequest } from 'utils/src/main/ets/http/HttpRequest'
import { requestPath } from 'utils/src/main/ets/http/RequestPath'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { logger } from 'utils'
import { ResponseBean } from '../bean/ResponseBean'
import { ArticlesList, NavContentBean } from '../bean/NavContentBean'

@Component
export struct NavContentView {
  //value
  @State private tabContent: Map<string, Array<NavContentBean>> = new Map()
  //key值
  @State private tabKeys: Array<string> = []
  @State private currentIndex: number = 0
  //正在加载
  @State private isLoading: boolean = true

  aboutToAppear(): void {
    //获取导航数据
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + requestPath.PATH_NAV).then((response: rcp.Response) => {
      let bean = JSON.parse(response.toString()!!) as ResponseBean<ArticlesList[]>
      if (bean.errorCode === 0) {
        let tmpTabContent: Map<string, Array<NavContentBean>> = new Map()
        let tmpTabKeys: Array<string> = []
        //请求成功
        let artArr = bean.data
        artArr.forEach((bean: ArticlesList) => {
          tmpTabKeys.push(bean.name)
          let list: Array<NavContentBean> = []
          bean.articles.forEach((bean: NavContentBean) => {
            let navBean = new NavContentBean()
            navBean.chapterId = bean.chapterId
            navBean.chapterName = bean.chapterName
            navBean.link = bean.link
            navBean.title = bean.title
            list.push(navBean)
          })
          tmpTabContent.set(bean.name, list)
        })

        this.tabContent = tmpTabContent
        this.tabKeys = tmpTabKeys
        this.isLoading = false
      }
    }).catch((err: BusinessError) => {
      logger.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
  }

  @Builder
  tabBuilder(item: string, index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Text(item)
        .fontColor($r('app.color.color_000000'))
        .fontSize($r('app.float.font_15'))
        .padding({ top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })
    }.width(SizeConstant.FULL_SIZE)
    .backgroundColor(index == this.currentIndex ? $r('app.color.color_FFFFFF') : $r('app.color.color_F6F6F6'))
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.isLoading) {
        //显示loading动画
        LoadingProgress()
          .color($r('app.color.color_0000FF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_40)
      } else {
        Tabs({
          barPosition: BarPosition.Start,
          index: this.currentIndex
        }) {
          ForEach(this.tabKeys, (item: string, index: number) => {
            TabContent() {
              //体系
              NavTabContentView({ content: this.tabContent.get(item) })
                .width(SizeConstant.FULL_SIZE)
                .height(SizeConstant.FULL_SIZE)
            }.tabBar(this.tabBuilder(item, index))
          }, (item: string, index: number) => item + index)
        }
        .vertical(true)
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.FULL_SIZE)
        .barWidth(SizeConstant.SIZE_PERCENT_33)
        .barHeight(SizeConstant.FULL_SIZE)
        .scrollable(false)
        .divider({
          strokeWidth: 1,
          color: $r('app.color.color_F0F0F0')
        })
        .animationMode(AnimationMode.NO_ANIMATION)
        .barMode(BarMode.Scrollable, {
          nonScrollableLayoutStyle: LayoutStyle.SPACE_BETWEEN_OR_CENTER
        })
        .onChange((index: number) => {
          this.currentIndex = index
        })
      }
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }
}