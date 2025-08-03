import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import { CoinRankBean, CoinRankContentBean } from '../bean/CoinBean'
import Api from '../utils/net/Api'
import { ResponseBean } from '../bean/ResponseBean'
import { PageLoadingComponent } from '../component/PageLoadingComponent'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { LoadState } from '../bean/LoadState'
import { animatorNumber } from '../utils/AnimatorUtil'
import { PointRankItemComponent } from '../component/PointRankItemComponent'

@Entry
@Component
struct PointRankPage {
  @State data: CoinRankContentBean[] = []
  //是否是首次加载
  @State loadState: LoadState = LoadState.LOADING
  private scroller: Scroller = new Scroller()
  private nextPage: number = 2
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
  //初始化数据
  private initRankData: CoinRankContentBean = {
    coinCount: 0,
    level: 0,
    nickname: '暂无上榜',
    rank: 0,
    userId: 0,
    username: '暂无上榜'
  }
  //金、银、铜牌
  @State firstRank: CoinRankContentBean = this.initRankData
  @State firstRankNum: number = 0
  @State secondRank: CoinRankContentBean = this.initRankData
  @State secondRankNum: number = 0
  @State thirdRank: CoinRankContentBean = this.initRankData
  @State thirdRankNum: number = 0

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载数据
   */
  loadData() {
    this.loadState = LoadState.LOADING
    this.loadPageData(1).then((data) => {
      if (data.length > 0) {
        this.setBeforeTData(data)

        this.data = data
        this.loadState = LoadState.SUCCESS
      } else {
        this.loadState = LoadState.EMPTY
      }
    }, () => {
      this.loadState = LoadState.FAILURE

    })
  }

  private setBeforeTData(data: CoinRankContentBean[]) {
    //金牌
    this.firstRank = data.shift()!
    animatorNumber(this.firstRankNum, this.firstRank.coinCount, (cu: number) => {
      this.firstRankNum = cu
    })

    //银牌
    this.secondRank = data.shift()!
    animatorNumber(this.secondRankNum, this.secondRank.coinCount, (cu: number) => {
      this.secondRankNum = cu
    })

    //铜牌
    this.thirdRank = data.shift()!
    animatorNumber(this.thirdRankNum, this.thirdRank.coinCount, (cu: number) => {
      this.thirdRankNum = cu
    })
  }

  /**
   * 加载页面数据
   * @param arg0
   */
  private async loadPageData(page: number): Promise<CoinRankContentBean[]> {
    let responseBean: ResponseBean<CoinRankBean> = await Api.get().getCoinRank(page)
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      let daArr: CoinRankContentBean[] = []
      if (data.datas && data.datas!.length > 0) {
        daArr.push(...data.datas)
      }
      return Promise.resolve(daArr)
    } else {
      return Promise.reject()
    }
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.point_rank'),
        isShowMenu: true,
        menu: $r('app.media.icon_doubt'),
        onMenuClick: () => {
          //跳转积分说明
          this.getUIContext().getRouter().pushUrl({
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

          Text(`${this.secondRank.username}`)
            .fontColor(Color.White)
            .fontSize($r('app.float.font_15'))
            .margin({ top: SizeConstant.SIZE_10 })

          Text(`${Math.floor(this.secondRankNum)}`)
            .fontColor(Color.White)
            .fontSize($r('app.float.font_15'))
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

          Text(`${this.firstRank.username}`)
            .fontColor(Color.White)
            .fontSize($r('app.float.font_15'))
            .margin({ top: SizeConstant.SIZE_10 })

          Text(`${Math.floor(this.firstRankNum)}`)
            .fontColor(Color.White)
            .fontSize($r('app.float.font_15'))
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

          Text(`${this.thirdRank.username}`)
            .fontColor(Color.White)
            .fontSize($r('app.float.font_15'))
            .margin({ top: SizeConstant.SIZE_10 })

          Text(`${Math.floor(this.thirdRankNum)}`)
            .fontColor(Color.White)
            .fontSize($r('app.float.font_15'))
            .margin({ top: SizeConstant.SIZE_5 })
        }
        .alignItems(HorizontalAlign.Center)
        .alignRules(this.rightRule)

      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_PERCENT_20)
      .backgroundColor($r('app.color.color_272A36'))

      PageLoadingComponent({
        loadState: this.loadState,
        onReload: () => {
          this.loadData()
        },
        content: () => {
          this.refreshLayout()
        }
      }).layoutWeight(1)

    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }

  @Builder
  refreshLayout() {
    PullToRefresh({
      scroller: this.scroller,
      data: $data,
      customList: this.listViewBuilder,
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadPageData(1).then((data) => {
            this.nextPage = 2
            this.setBeforeTData(data)
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

  @Builder
  listViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (data: CoinRankContentBean, index: number) => {
        ListItem() {
          PointRankItemComponent({
            item: data,
            index: index
          })
        }
      }, (data: CoinRankContentBean, index: number) => JSON.stringify(data) + index)
    }.width(SizeConstant.FULL_SIZE)
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.None)

  }
}