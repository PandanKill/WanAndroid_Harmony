import { httpRequest } from 'utils/src/main/ets/http/HttpRequest'
import { requestPath } from 'utils/src/main/ets/http/RequestPath'
import { rcp } from '@kit.RemoteCommunicationKit'
import SizeConstant from '../constants/SizeConstant'
import { BusinessError } from '@kit.BasicServicesKit'
import { HomeListViewBean, TagBean } from '../bean/HomeListViewBean'
import { router } from '@kit.ArkUI'
import { ListAttr, ListView, RefreshController, RefreshDataSource } from '@abner/refresh'
import { ResponseBean } from '../bean/ResponseBean'
import { HomeBean, HomeListViewBeanInterface } from '../bean/HomeListViewBeanInterface'
import { logger } from 'utils'

@Component
export struct ProjectTabContentView {
  //当前页面id值，用于getRequest
  private contentId: number = 0
  //页码
  private currentIndex: number = 1
  //首次加载
  @State private isLoading: boolean = true
  //刷新controller
  refreshController: RefreshController = new RefreshController()
  //懒加载数据
  dataSource: RefreshDataSource = new RefreshDataSource()
  //初始化数据
  private intiData: Array<HomeListViewBean> = []

  aboutToAppear(): void {
    this.loadInitContent()
  }

  private loadInitContent(): void {
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + `/project/list/${this.currentIndex}/json?cid=${this.contentId}`)
      .then((response: rcp.Response) => {
        console.info(`Response succeeded: ${response}`);
        if (response !== undefined) {
          let responseBean: ResponseBean<HomeListViewBeanInterface> =
            JSON.parse(response.toString()!!) as ResponseBean<HomeListViewBeanInterface>
          if (responseBean.errorCode === 0) {
            //获取成功
            logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
            responseBean.data!.datas.forEach((homeBean: HomeBean) => {
              let bean = new HomeListViewBean()
              bean.author = homeBean.author
              bean.chapterName = homeBean.chapterName
              bean.id = homeBean.id
              bean.link = homeBean.link
              bean.niceDate = homeBean.niceDate
              bean.desc = homeBean.desc
              bean.envelopePic = homeBean.envelopePic
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
          this.dataSource.initData(this.intiData)
        }
      }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
  }

  private loadMoreContent(): void {
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + `/project/list/${this.currentIndex}/json?cid=${this.contentId}`)
      .then((response: rcp.Response) => {
        console.info(`Response succeeded: ${response}`);
        if (response !== undefined) {
          let responseBean: ResponseBean<HomeListViewBeanInterface> =
            JSON.parse(response.toString()!!) as ResponseBean<HomeListViewBeanInterface>
          let dataArr: Array<HomeListViewBean> = []
          if (responseBean.errorCode === 0) {
            //获取成功
            logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
            responseBean.data!.datas.forEach((homeBean: HomeBean) => {
              let bean = new HomeListViewBean()
              bean.author = homeBean.author
              bean.chapterName = homeBean.chapterName
              bean.id = homeBean.id
              bean.link = homeBean.link
              bean.niceDate = homeBean.niceDate
              bean.superChapterName = homeBean.superChapterName
              bean.desc = homeBean.desc
              bean.envelopePic = homeBean.envelopePic
              bean.isTop = false

              if (homeBean.tags !== undefined && homeBean.tags.length !== 0) {
                let tag = new TagBean()
                tag.name = homeBean.tags[0].name
                tag.url = homeBean.tags[0].url
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
    }).finally(()=>{
      session.close()
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.isLoading) {
        LoadingProgress()
          .color($r('app.color.color_0000FF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_40)
      } else {
        //内容
        ListView({
          lazyDataSource: this.dataSource,
          itemLayout: (item, index) => this.itemLayout(item as HomeListViewBean, index),
          controller: this.refreshController,
          onRefresh: () => {
            //下拉刷新
            //重置currentIndex
            this.intiData = []
            this.currentIndex = 0
            this.loadInitContent()
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
              //跳转公众号
              router.pushUrl({
                url: "pages/WeChatOfficialAccounts",
                params: {
                  officialAcc: item.tags!![0].url
                }
              })
            })
        }
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          //标题
          Text(item.title)
            .fontSize($r('app.float.font_15'))
            .fontColor($r('app.color.color_000000'))
            .margin({ top: SizeConstant.SIZE_10 })
            .maxLines(1)
            .width(SizeConstant.FULL_SIZE)
            .ellipsisMode(EllipsisMode.END)

          if (item.desc !== undefined) {
            //内容
            Text(item.desc)
              .fontSize($r('app.float.font_12'))
              .fontColor($r('app.color.color_000000'))
              .margin({ top: SizeConstant.SIZE_10 })
              .maxLines(3)
              .width(SizeConstant.FULL_SIZE)
              .ellipsisMode(EllipsisMode.END)
          }
        }.layoutWeight(1)

        if (item.envelopePic !== undefined) {
          Image(item.envelopePic)
            .objectFit(ImageFit.Auto)
            .width(SizeConstant.SIZE_50)
            .height(SizeConstant.SIZE_50)
            .margin({ right: SizeConstant.SIZE_5, left: SizeConstant.SIZE_5 })
        }
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)


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