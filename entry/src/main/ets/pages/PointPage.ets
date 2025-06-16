import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { RefreshController } from '@abner/refresh/src/main/ets/controller/RefreshController'
import { ListAttr, ListView, RefreshDataSource } from '@abner/refresh'
import Api from '../utils/net/Api'
import { ResponseBean } from '../bean/ResponseBean'
import { MineCoinBean, MineCoinContentBean } from '../bean/CoinBean'
import { UserService } from '../service/UserService'
import { User } from '../bean/LoginResponse'
import { timestampToDateTime } from '../utils/DateUtil'

@Entry
@Component
struct PointPage {
  @State point: number = 0
  initData: MineCoinContentBean[] = []
  //是否是首次加载
  @State isFirstLoading: boolean = true
  private currentIndex: number = 0
  //数据刷新
  dataSource: RefreshDataSource = new RefreshDataSource()
  //刷新 controller
  refreshController: RefreshController = new RefreshController()
  // private maxCount
  private pointEventRule: AlignRuleOption = {
    left: { anchor: "__container__", align: HorizontalAlign.Start },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }
  private pointRule: AlignRuleOption = {
    right: { anchor: "__container__", align: HorizontalAlign.End },
    center: { anchor: "__container__", align: VerticalAlign.Center }
  }
  private observer: (user?: User) => void = (user) => {
    if (user) {
      animateTo({
        duration: 500,
        curve: Curve.Linear
      }, () => {
        this.point = (user as User).coinCount
      })
    }
  }

  aboutToAppear(): void {
    this.loadMineCoin()
    this.loadInitData()
  }

  /**
   * 个人积分
   */
  loadMineCoin() {
    let user = UserService.get().getUser()
    if (user) {
      animateTo({
        duration: 500,
        curve: Curve.Linear
      }, () => {
        this.point = (user as User).coinCount
      })
    }
    UserService.get().addUserObserver(this.observer)
  }

  //加载内容
  async loadInitData() {
    let responseBean: ResponseBean<MineCoinBean> = await Api.get().getMineCoin(this.currentIndex)
    this.isFirstLoading = false
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      this.initData.push(...data.datas)
      this.dataSource.initData(this.initData)
      this.refreshController.finishRefresh()
    }
  }

  //加载更多
  async loadMoreContent() {
    let responseBean: ResponseBean<MineCoinBean> = await Api.get().getMineCoin(this.currentIndex)
    if (responseBean.isSuccessWithData()) {
      let dataArr: Array<MineCoinContentBean> = []
      let data = responseBean.getDataOrThrow()
      dataArr.push(...data.datas)
      this.dataSource.pushDataArray(dataArr)
      this.refreshController.finishRefresh()
    }
  }

  aboutToDisappear(): void {
    UserService.get().removeUserObserver(this.observer)
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
            itemLayout: (item, index) => this.itemLayout(item as MineCoinContentBean, index),
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
  itemLayout(item: MineCoinContentBean, index: number) {
    Column() {
      RelativeContainer() {
        Column() {
          Text(item.reason)
            .fontSize($r('app.float.font_12'))
            .fontColor($r('app.color.color_666666'))
          Text(timestampToDateTime(item.date))
            .fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_999999'))
            .margin({ top: SizeConstant.SIZE_2 })
        }.id("pointEvent")
        .alignRules(this.pointEventRule)
        .margin({ left: SizeConstant.SIZE_15 })

        Text(item.coinCount.toString())
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
    }.width(SizeConstant.FULL_SIZE)
  }
}