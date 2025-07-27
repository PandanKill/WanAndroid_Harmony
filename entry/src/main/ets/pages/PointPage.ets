import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import Api from '../utils/net/Api'
import { ResponseBean } from '../bean/ResponseBean'
import { MineCoinBean, MineCoinContentBean } from '../bean/CoinBean'
import { UserService } from '../service/UserService'
import { User } from '../bean/LoginResponse'
import { timestampToDateTime } from '../utils/DateUtil'
import { animatorNumber } from '../utils/AnimatorUtil'
import { LoadState } from '../bean/LoadState'
import { PageLoadingComponent } from '../component/PageLoadingComponent'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { JSON } from '@kit.ArkTS'

@Entry
@Component
struct PointPage {
  @State point: number = 0
  @State data: MineCoinContentBean[] = []
  //是否是首次加载
  @State loadState: LoadState = LoadState.LOADING
  private nextPage: number = 2
  private scroller: Scroller = new Scroller()
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
      animatorNumber(this.point, (user as User).coinCount, (to: number) => {
        this.point = to
      })
    }
  }

  aboutToAppear(): void {
    this.loadMineCoin()
    this.loadData()
  }

  /**
   * 个人积分
   */
  loadMineCoin() {
    let user = UserService.get().getUser()
    if (user) {
      animatorNumber(this.point, (user as User).coinCount, (to: number) => {
        this.point = to
      })
    }
    UserService.get().addUserObserver(this.observer)
  }

  loadData() {
    this.loadState = LoadState.LOADING
    this.loadPageData(1).then((data) => {
      if (data.length > 0) {
        this.data = data
        this.loadState = LoadState.SUCCESS
      } else {
        this.loadState = LoadState.EMPTY
      }
    }, () => {
      this.loadState = LoadState.FAILURE

    })
  }

  private async loadPageData(page: number): Promise<MineCoinContentBean[]> {
    let responseBean: ResponseBean<MineCoinBean> = await Api.get().getMineCoin(page)
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      let daArr: MineCoinContentBean[] = []
      if (data.datas && data.datas!.length > 0) {
        daArr.push(...data.datas)
      }
      return Promise.resolve(daArr)
    } else {
      return Promise.reject()
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
          this.getUIContext().getRouter().pushUrl({
            url: "pages/PointRankPage"
          })
        }
      })

      //必须取整
      Text(`${Math.floor(this.point)}`)
        .fontSize($r('app.float.font_60'))
        .fontColor($r('app.color.color_FFFFFF'))
        .textAlign(TextAlign.Center)
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_PERCENT_25)
        .backgroundColor($r('app.color.color_272A36'))

      PageLoadingComponent({
        loadState: this.loadState,
        onReload: () => {
          this.loadData()
        }
      }) {
        PullToRefresh({
          scroller: this.scroller,
          data: $data,
          customList: this.listViewBuilder,
          onRefresh: () => {
            return new Promise<string>((resolve, reject) => {
              this.loadPageData(1).then((data) => {
                this.nextPage = 2
                this.data = data
                resolve("刷新成功")

              }, () => {
                resolve("刷新失败")
              })
            })
          },
          onLoadMore: () => {
            return new Promise<string>((resolve, reject) => {
              this.loadPageData(this.nextPage).then((data) => {
                this.nextPage++
                this.data = this.data.concat(data)
                resolve("刷新成功")
              }, () => {
                resolve("刷新失败")
              })
            })
          }
        })
      }

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_F5F5F5'))
  }

  @Builder
  listViewBuilder() {
    List() {
      ForEach(this.data, (data: MineCoinContentBean, index: number) => {
        ListItem() {
          this.itemLayout(data, index)
        }
      }, (data: MineCoinContentBean, index: number) => JSON.stringify(data) + index)
    }.width(SizeConstant.FULL_SIZE)
    .layoutWeight(1)

  }

  @Builder
  itemLayout(item: MineCoinContentBean, index: number) {
    Column() {
      if (!item.isLast) {
        //是内容
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
          .alignItems(HorizontalAlign.Start)
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
      } else {
        //没有数据，最后补一个“没有更多了”
        Text("没有更多了")
          .fontSize($r('app.float.font_12'))
          .fontColor($r('app.color.color_999999'))
          .alignSelf(ItemAlign.Center)
          .margin({ top: SizeConstant.SIZE_5 })
      }
    }.width(SizeConstant.FULL_SIZE)
  }
}