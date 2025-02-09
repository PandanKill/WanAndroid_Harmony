import { ListView } from '@abner/refresh/src/main/ets/ListView'
import SizeConstant from '../constants/SizeConstant'
import { ListAttr, RefreshController, RefreshDataSource } from '@abner/refresh'
import { httpRequest, logger, requestPath } from 'utils'
import { HomeListViewBean, TagBean } from '../bean/HomeListViewBean'
import { router } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { HomeBean, HomeListViewBeanInterface } from '../bean/HomeListViewBeanInterface'
import { ResponseBean } from '../bean/ResponseBean'
import { TopBean } from '../bean/TopBean'
import { TagRouterBean } from '../bean/TagRouterBean'
import { rcp } from '@kit.RemoteCommunicationKit'

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
  loadTop() {
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + requestPath.PATH_TOP).then((response) => {
      console.info(`Response succeeded: ${response}`);
      if (response !== undefined) {
        let responseBean: ResponseBean<TopBean[]> =
          JSON.parse(response.toString()!!) as ResponseBean<TopBean[]>
        if (responseBean.errorCode === 0) {
          //获取成功
          logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
          responseBean.data.forEach((homeBean: TopBean) => {
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
            bean.zan = homeBean.zan !== 0
            this.intiData.push(bean)
          })
        }
        //加载内容
        //显示
        this.loadContent()
      }
    }).catch((err: BusinessError) => {
      logger.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
  }

  //加载内容
  loadContent() {
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + `/article/list/${this.currentIndex}/json`).then((response) => {
      console.info(`Response succeeded: ${response}`);
      if (response !== undefined) {
        let responseBean: ResponseBean<HomeListViewBeanInterface> =
          JSON.parse(response.toString()!!) as ResponseBean<HomeListViewBeanInterface>
        if (responseBean.errorCode === 0) {
          //获取成功
          logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
          responseBean.data.datas.forEach((homeBean: HomeBean) => {
            let bean = new HomeListViewBean()
            bean.author = homeBean.author
            bean.chapterName = homeBean.chapterName
            bean.id = homeBean.id
            bean.link = homeBean.link
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
            bean.zan = homeBean.zan !== 0
            this.intiData.push(bean)
          })
        }
        //显示
        this.isFirstLoading = false
        this.dataSource.initData(this.intiData)
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
  }

  getChartpId(url: string | undefined): number | undefined {
    let idStr = url?.substring("/wxarticle/list/".length, url!!.length - 2)
    return parseInt(idStr!!)
  }

  //加载内容
  loadMoreContent() {
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + `/article/list/${this.currentIndex}/json`).then((response) => {
      console.info(`Response succeeded: ${response}`);
      if (response !== undefined) {
        let responseBean: ResponseBean<HomeListViewBeanInterface> =
          JSON.parse(response.toString()!!) as ResponseBean<HomeListViewBeanInterface>
        let dataArr: Array<HomeListViewBean> = []
        if (responseBean.errorCode === 0) {
          //获取成功
          logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
          responseBean.data.datas.forEach((homeBean: HomeBean) => {
            let bean = new HomeListViewBean()
            bean.author = homeBean.author
            bean.chapterName = homeBean.chapterName
            bean.id = homeBean.id
            bean.link = homeBean.link
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
            bean.zan = homeBean.zan !== 0
            dataArr.push(bean)
          })
        }
        //显示
        this.dataSource.pushDataArray(dataArr)
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
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
              router.pushUrl({
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

        Image(item.zan ? $r('app.media.shixin_love') : $r('app.media.kongxin_love'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({ right: SizeConstant.SIZE_5 })
          .onClick(() => {
            //点赞
            item.zan = !item.zan
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
      router.pushUrl({
        url: "pages/WebPage",
        params: {
          webUrl: item.link
        }
      })
    })
  }
}