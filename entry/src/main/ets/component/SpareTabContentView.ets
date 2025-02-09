import { ListAttr, ListView, RefreshController, RefreshDataSource } from '@abner/refresh'
import SizeConstant from '../constants/SizeConstant'
import { HomeListViewBean, TagBean } from '../bean/HomeListViewBean'
import { rcp } from '@kit.RemoteCommunicationKit'
import { ResponseBean } from '../bean/ResponseBean'
import { HomeBean, HomeListViewBeanInterface } from '../bean/HomeListViewBeanInterface'
import { httpRequest, logger, requestPath } from 'utils'
import { BusinessError } from '@kit.BasicServicesKit'
import { router } from '@kit.ArkUI'

@Component
export struct SpareTabContentView {
  private refreshDataSource: RefreshDataSource = new RefreshDataSource()
  @State private isLoading: boolean = true
  //当前页数,从0开始
  private currentPage: number = 0
  //初始化数据
  private intiData: Array<HomeListViewBean> = []
  //刷新controller
  refreshController: RefreshController = new RefreshController()

  aboutToAppear(): void {
    //获取问答数据
    this.loadInitData()
  }

  private loadInitData() {
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + `/user_article/list/${this.currentPage}/json`).then((response: rcp.Response) => {
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
            bean.desc = homeBean.desc
            bean.superChapterName = homeBean.superChapterName
            bean.isTop = false

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
        //显示
        this.isLoading = false
        this.refreshDataSource.initData(this.intiData)
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
  }

  private loadMoreData() {
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + `/user_article/list/${this.currentPage}/json`).then((response: rcp.Response) => {
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
            bean.desc = homeBean.desc
            bean.superChapterName = homeBean.superChapterName
            bean.isTop = false

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
        //显示
        this.refreshDataSource.pushDataArray(dataArr)
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
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
        ListView({
          lazyDataSource: this.refreshDataSource,
          controller: this.refreshController,
          itemLayout: (item, index) => this.itemLayout(item as HomeListViewBean, index),
          onRefresh: () => {
            //下拉刷新
            //重置currentIndex
            this.intiData = []
            this.currentPage = 0
            this.loadInitData()
            this.refreshController.finishRefresh()
          },
          onLoadMore: () => {
            this.currentPage++
            this.loadMoreData()
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
              //跳转tab专栏
            })
        }
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      //标题
      Text(item.title)
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_333333'))
        .margin({ top: SizeConstant.SIZE_10 })
        .maxLines(2)
        .width(SizeConstant.FULL_SIZE)
        .ellipsisMode(EllipsisMode.END)

      //描述
      if (item.desc !== undefined) {
        Text(item.desc)
          .fontSize($r('app.float.font_10'))
          .fontColor($r('app.color.color_666666'))
          .margin({ top: SizeConstant.SIZE_10 })
          .maxLines(3)
          .width(SizeConstant.FULL_SIZE)
          .ellipsisMode(EllipsisMode.END)
      }

      Row() {
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
    .stateStyles({
      pressed: {
        .backgroundColor($r('app.color.color_F5F5F5'))
      },
      normal: {
        .backgroundColor($r('app.color.color_FFFFFF'))
      }
    })
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