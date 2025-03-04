import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { ListAttr, ListView, RefreshController, RefreshDataSource } from '@abner/refresh'

@Entry
@Component
struct PointRankPage {
  initData: string[] = []
  //是否是首次加载
  @State isFirstLoading: boolean = true
  private currentIndex: number = 0
  //数据刷新
  dataSource: RefreshDataSource = new RefreshDataSource()
  //刷新 controller
  refreshController: RefreshController = new RefreshController()
  private centerRule: AlignRuleOption = {
    center: { anchor: "__container__", align: VerticalAlign.Center },
    middle: { anchor: "__container__", align: HorizontalAlign.Center }
  }
  private leftRule: AlignRuleOption = {
    bottom: { anchor: "col_gold", align: VerticalAlign.Bottom },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
    right: { anchor: "col_gold", align: HorizontalAlign.Start }
  }
  private rightRule: AlignRuleOption = {
    bottom: { anchor: "col_gold", align: VerticalAlign.Bottom },
    left: { anchor: "col_gold", align: HorizontalAlign.End },
    right: { anchor: "__container__", align: HorizontalAlign.End }
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
        title: $r('app.string.point_rank'),
        isShowMenu: true,
        menu: $r('app.media.icon_doubt'),
        onMenuClick: () => {
          //跳转积分说明
          router.pushUrl({
            url: "pages/WebPage", params: {
              "webUrl": "https://www.wanandroid.com/blog/show/2653"
            }
          })
        }
      })

      //前三排名
      RelativeContainer() {
        //银牌
        Column() {
          Image($r('app.media.icon_silver'))
            .width(SizeConstant.SIZE_20)

          Image($r('app.media.icon_default'))
            .width(SizeConstant.SIZE_30)
            .margin({ top: SizeConstant.SIZE_5 })

          Text('nihao')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_20'))
            .margin({ top: SizeConstant.SIZE_10 })

          Text('132321')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_20'))
            .margin({ top: SizeConstant.SIZE_5 })
        }
        .alignItems(HorizontalAlign.Center)
        .alignRules(this.leftRule)

        //金牌
        Column() {
          Image($r('app.media.icon_gold'))
            .width(SizeConstant.SIZE_30)

          Image($r('app.media.icon_default'))
            .width(SizeConstant.SIZE_45)
            .margin({ top: SizeConstant.SIZE_5 })

          Text('nihao')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_20'))
            .margin({ top: SizeConstant.SIZE_10 })

          Text('132321')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_20'))
            .margin({ top: SizeConstant.SIZE_5 })
        }
        .alignItems(HorizontalAlign.Center)
        .id("col_gold")
        .alignRules(this.centerRule)

        //铜牌
        Column() {
          Image($r('app.media.icon_copper'))
            .width(SizeConstant.SIZE_20)
            .margin({ top: SizeConstant.SIZE_10 })

          Image($r('app.media.icon_default'))
            .width(SizeConstant.SIZE_30)
            .margin({ top: SizeConstant.SIZE_5 })

          Text('nihao')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_20'))
            .margin({ top: SizeConstant.SIZE_10 })

          Text('132321')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_20'))
            .margin({ top: SizeConstant.SIZE_5 })
        }
        .alignItems(HorizontalAlign.Center)
        .alignRules(this.rightRule)

      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_PERCENT_20)
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
          Row() {
            Stack() {
              Text((index + 4).toString())
                .fontSize($r('app.float.font_15'))
                .fontColor(Color.Black)
                .margin(SizeConstant.SIZE_2)
            }.backgroundColor(Color.Orange)
            .borderRadius(SizeConstant.SIZE_10)
            .align(Alignment.Center)
            .margin({ left: SizeConstant.SIZE_15 })

            //姓名
            Text(item)
              .fontSize($r('app.float.font_12'))
              .fontColor($r('app.color.color_666666'))
              .margin({ left: SizeConstant.SIZE_15 })

            Blank()

            //积分
            Text(item)
              .fontColor($r('app.color.color_FF7800'))
              .fontSize($r('app.float.font_12'))
              .margin({ right: SizeConstant.SIZE_15 })

          }.width(SizeConstant.FULL_SIZE)
          .height(SizeConstant.SIZE_60)
          .alignItems(VerticalAlign.Center)

          Line()
            .width(SizeConstant.FULL_SIZE)
            .height(1)
            .backgroundColor($r('app.color.color_F0F0F0'))
        }
      }
    }.width(SizeConstant.FULL_SIZE)
  }
}