import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { RefreshController } from '@abner/refresh/src/main/ets/controller/RefreshController'
import { ListAttr, ListView, RefreshDataSource } from '@abner/refresh'

@Entry
@Component
struct PointPage {
  @State point: number = 0
  initData: string[] = []
  //是否是首次加载
  @State isFirstLoading: boolean = true
  private currentIndex: number = 0
  //数据刷新
  dataSource: RefreshDataSource = new RefreshDataSource()
  //刷新 controller
  refreshController: RefreshController = new RefreshController()
  private pointEventRule: AlignRuleOption = {
    left: { anchor: "__container__", align: HorizontalAlign.Start },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }
  private pointRule: AlignRuleOption = {
    right: { anchor: "__container__", align: HorizontalAlign.End },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }

  aboutToAppear(): void {
    this.loadInitData()
  }

  //加载内容
  loadInitData() {
    setTimeout(() => {
      this.initData.push('积分1')
      this.initData.push('积分2')
      this.initData.push('积分3')
      this.isFirstLoading = false
      this.dataSource.initData(this.initData)
      this.refreshController.finishRefresh()
    }, 1000)
  }

  //加载更多
  loadMoreContent() {
    setTimeout(() => {
      let dataArr: Array<string> = []
      if (this.currentIndex < 7) {
        if (this.currentIndex === 6) {
          dataArr.push("")
        } else {
          dataArr.push('积分1')
          dataArr.push('积分2')
          dataArr.push('积分3')
        }
        this.dataSource.pushDataArray(dataArr)
      }
      this.refreshController.finishLoadMore()
    }, 1000)
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.mime_point'),
        isShowMenu: true,
        menu: $r('app.media.icon_rank'),
        onMenuClick: () => {
          //跳转积分排名
          router.pushUrl({
            url: "pages/PointRankPage"
          })
        }
      })

      Text(this.point.toString())
        .fontSize($r('app.float.font_60'))
        .fontColor($r('app.color.color_FFFFFF'))
        .textAlign(TextAlign.Center)
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_PERCENT_25)
        .backgroundColor($r('app.color.color_272A36'))

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
            itemLayout: (item, index) => this.itemLayout(item as string, index),
            controller: this.refreshController,
            onRefresh: () => {
              //下拉刷新
              //重置currentIndex
              this.initData = []
              this.currentIndex = 0
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
      .layoutWeight(1)

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_F5F5F5'))
  }

  @Builder
  itemLayout(item: string, index: number) {
    Column() {
      if (item === "") {
        //没有数据，最后补一个“没有更多了”
        Text("没有更多了")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_999999'))
          .alignSelf(ItemAlign.Center)
          .margin({ top: SizeConstant.SIZE_5 })
      } else {
        Column() {
          RelativeContainer() {
            Column() {
              Text(item)
                .fontSize($r('app.float.font_12'))
                .fontColor($r('app.color.color_666666'))
              Text(item)
                .fontSize($r('app.float.font_10'))
                .fontColor($r('app.color.color_999999'))
                .margin({ top: SizeConstant.SIZE_2 })
            }.id("pointEvent")
            .alignRules(this.pointEventRule)
            .margin({ left: SizeConstant.SIZE_15 })

            Text(item)
              .alignRules(this.pointRule)
              .fontColor($r('app.color.color_FF7800'))
              .fontSize($r('app.float.font_12'))
              .id("point")
              .margin({ right: SizeConstant.SIZE_15 })
          }.width(SizeConstant.FULL_SIZE)
          .height(60)

          Line()
            .width(SizeConstant.FULL_SIZE)
            .height(1)
            .backgroundColor($r('app.color.color_F0F0F0'))
        }
      }
    }.width(SizeConstant.FULL_SIZE)
  }
}