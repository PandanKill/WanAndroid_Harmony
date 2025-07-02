import { ListAttr, ListView, RefreshController, RefreshDataSource } from '@abner/refresh'
import { HomeBean, HomeListViewBeanInterface } from '../bean/HomeListViewBeanInterface'
import { ResponseBean } from '../bean/ResponseBean'
import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import Api from '../utils/net/Api'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct CollectPage {
  //是否是首次加载
  @State isFirstLoading: boolean = true
  private currentIndex: number = 0
  //数据刷新
  dataSource: RefreshDataSource = new RefreshDataSource()
  //刷新 controller
  refreshController: RefreshController = new RefreshController()

  aboutToAppear(): void {
    this.loadInitData()
  }

  //加载内容
  async loadInitData() {
    this.currentIndex = 0
    let responseBean: ResponseBean<HomeListViewBeanInterface> = await Api.get().getMineCollect(this.currentIndex)
    this.isFirstLoading = false
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      this.dataSource.initData(data.datas)
    }
    this.refreshController.finishRefresh()
  }

  //加载更多
  async loadMoreContent() {
    let responseBean: ResponseBean<HomeListViewBeanInterface> = await Api.get().getMineCollect(this.currentIndex)
    if (responseBean.isSuccessWithData()) {
      let dataArr: Array<HomeBean> = []
      let data = responseBean.getDataOrThrow()
      dataArr.push(...data.datas)
      this.dataSource.pushDataArray(dataArr)
    }
    this.refreshController.finishLoadMore()
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.collect_content')
      })

      Stack() {
        if (this.isFirstLoading) {
          //显示loading动画
          LoadingProgress()
            .color($r('app.color.color_0000FF'))
            .width(SizeConstant.SIZE_40)
            .height(SizeConstant.SIZE_40)
        } else {
          ListView({
            lazyDataSource: this.dataSource,
            itemLayout: (item, index) => this.itemLayout(item as HomeBean, index),
            controller: this.refreshController,
            onRefresh: () => {
              //下拉刷新
              //重置currentIndex
              this.loadInitData()
            },
            onLoadMore: () => {
              //上划加载
              this.currentIndex++
              this.loadMoreContent()
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
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }

  @Builder
  itemLayout(item: HomeBean, index: number) {
    Column() {
      Row() {
        Image($r('app.media.icon_person'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({ left: SizeConstant.SIZE_15 })

        Column() {
          Text(item.author === undefined || item.author === "" ? "匿名" : item.author)
            .width(SizeConstant.FULL_SIZE)
            .fontSize($r('app.float.font_10'))

          Text(item.niceDate)
            .width(SizeConstant.FULL_SIZE)
            .fontSize($r('app.float.font_10'))
            .margin({ top: SizeConstant.SIZE_1 })

        }.layoutWeight(1)
        .margin({ left: SizeConstant.SIZE_5, right: SizeConstant.SIZE_15 })
      }.alignItems(VerticalAlign.Center)
      .width(SizeConstant.FULL_SIZE)
      .margin({ top: SizeConstant.SIZE_10 })

      Text(item.title)
        .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_10, right: SizeConstant.SIZE_15 })
        .width(SizeConstant.FULL_SIZE)
        .maxLines(3)
        .ellipsisMode(EllipsisMode.END)
        .fontSize($r('app.float.font_12'))


      Row() {
        Text(item.chapterName)
          .fontSize($r('app.float.font_10'))
          .margin({ left: SizeConstant.SIZE_15 })

        Blank()

        Image($r('app.media.shixin_love'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({ right: SizeConstant.SIZE_15 })
          .onClick(async () => {
            //取消收藏
            let collTmp = item.collect
              //取消收藏
            console.info(`item.id ${item.id}`)
              let coll: ResponseBean<undefined> = await Api.get().unCollectArticle(item.id)
              console.info(`collect ${JSON.stringify(coll)}}`)
              if (!coll.isSuccess()) {
                //更新失败
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.opt_fail')
                })
              } else {
                //取消成功
                this.dataSource.deleteData(index)
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.cancel_succ')
                })
              }
          })
      }.margin({ top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })
      .alignItems(VerticalAlign.Center)
      .width(SizeConstant.FULL_SIZE)
    }.alignItems(HorizontalAlign.Start)
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