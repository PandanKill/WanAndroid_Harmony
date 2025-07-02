import { ListView } from '@abner/refresh/src/main/ets/ListView'
import SizeConstant from '../constants/SizeConstant'
import { ListAttr, RefreshController, RefreshDataSource } from '@abner/refresh'
import { logger, requestPath } from 'utils'
import { HomeListViewBean, TagBean } from '../bean/HomeListViewBean'
import { router } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { HomeBean, HomeListViewBeanInterface } from '../bean/HomeListViewBeanInterface'
import { ResponseBean } from '../bean/ResponseBean'
import { TopBean } from '../bean/TopBean'
import { TagRouterBean } from '../bean/TagRouterBean'
import { rcp } from '@kit.RemoteCommunicationKit'
import Api from '../utils/net/Api'

@Component
export struct HomeListView {
  //首次加载需要加载loading界面
  @State private isFirstLoading: boolean = true
  //刷新controller
  refreshController: RefreshController = new RefreshController()
  //懒加载数据
  dataSource: RefreshDataSource = new RefreshDataSource()
  //初始化数据
  private intiData: Array<HomeListViewBean> = []
  //当前加载到那一页了
  private currentIndex: number = 0

  aboutToAppear(): void {
    //首次加载数据
    logger.info("HomeListView: aboutToAppear")
    //获取数据
    this.loadTop()
  }

  //加载置顶内容
  async loadTop() {
    let responseBean: ResponseBean<TopBean[]> = await Api.get().getTopArt()
    if (responseBean.isSuccessWithData()) {
      //获取成功
      logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
      responseBean.getDataOrThrow().forEach((homeBean: TopBean) => {
        let bean = new HomeListViewBean()
        bean.author = homeBean.author
        bean.chapterName = homeBean.chapterName
        bean.id = homeBean.id
        bean.link = homeBean.link
        bean.niceDate = homeBean.niceDate
        bean.superChapterName = homeBean.superChapterName
        bean.isTop = true

        if (homeBean.tags !== undefined && homeBean.tags.length !== 0) {
          let tag = new TagBean()
          tag.name = homeBean.tags[0].name
          tag.url = homeBean.tags[0].url
          bean.tags = [tag]
        }

        bean.title = homeBean.title
        this.intiData.push(bean)
      })
    }
    //加载内容
    //显示
    this.loadContent()
  }

  //加载内容
  async loadContent() {
    let responseBean: ResponseBean<HomeListViewBeanInterface> = await Api.get().getArticleList(this.currentIndex)
    if (responseBean.isSuccessWithData()) {
      //获取成功
      logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
      responseBean.getDataOrThrow().datas.forEach((homeBean: HomeBean) => {
        let bean = new HomeListViewBean()
        bean.author = homeBean.author
        bean.chapterName = homeBean.chapterName
        bean.id = homeBean.id
        bean.link = homeBean.link
        bean.collect = homeBean.collect
        bean.niceDate = homeBean.niceDate
        bean.superChapterId = homeBean.superChapterId
        bean.superChapterName = homeBean.superChapterName
        bean.isTop = false

        if (homeBean.tags !== undefined && homeBean.tags.length !== 0) {
          let tag = new TagBean()
          tag.name = homeBean.tags[0].name
          tag.url = homeBean.tags[0].url
          tag.charptId = this.getChartpId(homeBean.tags[0].url)
          bean.tags = [tag]
        }

        bean.title = homeBean.title
        this.intiData.push(bean)
      })
    }
    //显示
    this.isFirstLoading = false
    this.dataSource.initData(this.intiData)
  }

  getChartpId(url: string | undefined): number | undefined {
    let idStr = url?.substring("/wxarticle/list/".length, url!!.length - 2)
    return parseInt(idStr!!)
  }

  //加载内容
  async loadMoreContent() {
    let responseBean: ResponseBean<HomeListViewBeanInterface> = await Api.get().getArticleList(this.currentIndex)
    let dataArr: Array<HomeListViewBean> = []
    if (responseBean.isSuccessWithData()) {
      //获取成功
      logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
      responseBean.getDataOrThrow().datas.forEach((homeBean: HomeBean) => {
        let bean = new HomeListViewBean()
        bean.author = homeBean.author
        bean.chapterName = homeBean.chapterName
        bean.id = homeBean.id
        bean.link = homeBean.link
        bean.collect = homeBean.collect
        bean.niceDate = homeBean.niceDate
        bean.superChapterId = homeBean.superChapterId
        bean.superChapterName = homeBean.superChapterName
        bean.isTop = false

        if (homeBean.tags !== undefined && homeBean.tags.length !== 0) {
          let tag = new TagBean()
          tag.name = homeBean.tags[0].name
          tag.url = homeBean.tags[0].url
          tag.charptId = this.getChartpId(homeBean.tags[0].url)
          bean.tags = [tag]
        }

        bean.title = homeBean.title
        dataArr.push(bean)
      })
    }
    //显示
    this.dataSource.pushDataArray(dataArr)
  }

  build() {
    Stack() {
      if (this.isFirstLoading) {
        //显示loading动画
        LoadingProgress()
          .color($r('app.color.color_0000FF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_40)
      } else {
        //显示listView
        ListView({
          lazyDataSource: this.dataSource,
          itemLayout: (item, index) => this.itemLayout(item as HomeListViewBean, index),
          controller: this.refreshController,
          onRefresh: () => {
            //下拉刷新
            //重置currentIndex
            this.intiData = []
            this.currentIndex = 0
            this.loadTop()
            this.refreshController.finishRefresh()
          },
          onLoadMore: () => {
            //上划加载
            this.currentIndex++
            this.loadMoreContent()
            this.refreshController.finishLoadMore()
          },
          listAttribute: (listAttr: ListAttr) => {
            listAttr.divider = {
              strokeWidth: SizeConstant.SIZE_1,
              color: $r('app.color.color_969696')
            }
            listAttr.scrollBar = BarState.Off
          }
        }).width(SizeConstant.FULL_SIZE)
          .height(SizeConstant.FULL_SIZE)
      }

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_FFFFFF'))

  }

  @Builder
  itemLayout(item: HomeListViewBean, index: number) {
    //ItemLayout
    Column() {
      Row() {
        //头像
        Image($r('app.media.icon_person'))
          .width(SizeConstant.SIZE_30)
          .height(SizeConstant.SIZE_30)

        Column() {
          Text(item.author === undefined || item.author === "" ? "匿名" : item.author)
            .fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_666666'))
            .margin({ bottom: SizeConstant.SIZE_2 })
          Text(item.niceDate).fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_999999'))
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: SizeConstant.SIZE_10 })

        if (item.tags !== undefined && item.tags.length !== 0) {
          //存在tag
          Text(item.tags[0].name)
            .padding(SizeConstant.SIZE_2)
            .fontSize($r('app.float.font_10'))
            .margin({ right: SizeConstant.SIZE_5 })
            .fontColor($r('app.color.color_228B22'))
            .border({
              width: SizeConstant.SIZE_1,
              color: $r('app.color.color_228B22'),
              radius: SizeConstant.SIZE_2,
              style: BorderStyle.Solid
            })
            .onClick(() => {
              let tagBean = new TagRouterBean()
              tagBean.type = "Home"
              tagBean.officialAcc = item.tags!![0].charptId!!

              //跳转公众号
              this.getUIContext().getRouter().pushUrl({
                url: "pages/TagDetailPage",
                params: tagBean
              })
            })
        }
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      //标题
      Text(item.title)
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_000000'))
        .margin({ top: SizeConstant.SIZE_10 })
        .maxLines(2)
        .width(SizeConstant.FULL_SIZE)
        .ellipsisMode(EllipsisMode.END)

      Row() {
        //置顶
        if (item.isTop) {
          Text("置顶")
            .fontSize($r('app.float.font_11'))
            .fontColor(Color.Red)
            .margin({ right: SizeConstant.SIZE_10 })
        }

        //来源
        Text(`${item.superChapterName}·${item.chapterName}`)
          .fontSize($r('app.float.font_10'))
          .fontColor($r('app.color.color_999999'))
          .layoutWeight(1)

        Image(item.collect ? $r('app.media.shixin_love') : $r('app.media.kongxin_love'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({ right: SizeConstant.SIZE_5 })
          .onClick(async () => {
            //收藏
            let collTmp = item.collect
            item.collect = !item.collect
            if (collTmp) {
              //取消收藏
              let coll: ResponseBean<undefined> = await Api.get().unCollectArticle(item.id)
              console.info(`collect ${JSON.stringify(coll)}}`)
              if (!coll.isSuccess()) {
                //更新失败
                item.collect = collTmp
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.opt_fail')
                })
              }
            } else {
              //收藏
              let coll: ResponseBean<undefined> = await Api.get().collectArticle(item.id)
              console.info(`collect ${JSON.stringify(coll)}}`)
              if (!coll.isSuccess()) {
                //更新失败
                item.collect = collTmp
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.opt_fail')
                })
              }
            }
          })
      }.width(SizeConstant.FULL_SIZE)
      .margin({ top: SizeConstant.SIZE_10 })
      .alignItems(VerticalAlign.Center)

    }.width(SizeConstant.FULL_SIZE)
    .padding({
      top: SizeConstant.SIZE_10,
      bottom: SizeConstant.SIZE_10,
      left: SizeConstant.SIZE_10,
      right: SizeConstant.SIZE_10
    })
    .onClick(() => {
      //点击跳转webView
      this.getUIContext().getRouter().pushUrl({
        url: "pages/WebPage",
        params: {
          webUrl: item.link
        }
      })
    })
  }
}