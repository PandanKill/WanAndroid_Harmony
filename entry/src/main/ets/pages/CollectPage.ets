import { ResponseBean } from '../bean/ResponseBean'
import { NavHeaderView } from '../component/NavHeaderView'
import SizeConstant from '../constants/SizeConstant'
import Api from '../utils/net/Api'
import { router } from '@kit.ArkUI'
import { LoadState } from '../bean/LoadState'
import { ArticleBean, ArticleListBean } from '../bean/ArticleBean'
import { PageLoadingComponent } from '../component/PageLoadingComponent'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { ArticleContentComponent } from '../component/ArticleContentComponent'
import { JSON } from '@kit.ArkTS'

@Entry
@Component
struct CollectPage {
  //是否是首次加载
  @State loadState: LoadState = LoadState.LOADING
  private nextPage: number = 1
  private scroller: Scroller = new Scroller()
  @State data: Array<ArticleBean> = []

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载数据
   */
  loadData() {
    this.loadState = LoadState.LOADING
    this.loadPageData(0).then((data) => {
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

  private async loadPageData(page: number): Promise<ArticleBean[]> {
    let responseBean: ResponseBean<ArticleListBean> = await Api.get().getMineCollect(page)
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      let daArr: ArticleBean[] = []
      if (data.datas && data.datas!.length > 0) {
        daArr.push(...data.datas)
      }
      //所有都是收藏的
      daArr.forEach((data: ArticleBean, index: number) => {
        data.collect = true
      })
      return Promise.resolve(daArr)
    } else {
      return Promise.reject()
    }
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.collect_content')
      })

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
          this.loadPageData(0).then((data) => {
            this.nextPage = 1
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
      ForEach(this.data, (data: ArticleBean, index: number) => {
        ListItem() {
          //文章列表
          ArticleContentComponent({
            item: data as ArticleBean,
            onCollectClick: async (article: ArticleBean) => {
              //取消收藏
              let coll: ResponseBean<undefined> = await Api.get().unCollectArticle(article.originId)
              if (coll.isSuccess()) {
                article.collect = !article.collect
                this.data.splice(index, 1)
              }
            }
          })
        }
      }, (data: ArticleBean, index: number) => JSON.stringify(data) + index)
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .divider({
      strokeWidth: SizeConstant.SIZE_1,
      color: $r('app.color.color_969696')
    })
    .edgeEffect(EdgeEffect.None)
    .listDirection(Axis.Vertical)
  }
}