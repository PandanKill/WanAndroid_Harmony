import { ResponseBean } from '../bean/ResponseBean'
import Api from '../utils/net/Api'
import { LoadState } from '../bean/LoadState'
import { ArticleBean, ArticleListBean } from '../bean/ArticleBean'
import { PageLoadingComponent } from './PageLoadingComponent'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { ArticleContentComponent } from './ArticleContentComponent'
import SizeConstant from '../constants/SizeConstant'

@Component
export struct TabContentView {
  //当前页面id值，用于getRequest
  contentId: number = 0
  //类型
  type: string = "Home"
  //页码
  private currentIndex: number = 1
  //首次加载
  @State loadState: LoadState = LoadState.LOADING
  //初始化数据
  @State data: Array<ArticleBean> = []
  private path: string = ""
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.loadData()
  }

  /**
   * 加载数据
   */
  loadData() {
    this.loadState = LoadState.LOADING
    this.loadPageData().then((data) => {
      if (data.length > 0) {
        this.loadState = LoadState.SUCCESS
        this.data = data
      } else {
        this.loadState = LoadState.EMPTY
      }
    }, () => {
      this.loadState = LoadState.FAILURE
    })
  }

  /**
   * 加载页面数据
   * @param page
   * @returns
   */
  private async loadPageData(): Promise<ArticleBean[]> {
    if (this.type === "Home") {
      this.path = `/wxarticle/list/${this.contentId}/${this.currentIndex}/json`
    } else if (this.type === "TiXi") {
      this.path = `/article/list/${this.currentIndex}/json?cid=${this.contentId}`
    }
    let responseBean: ResponseBean<ArticleListBean> = await Api.get().getCommonPath(this.path)
    if (responseBean.isSuccessWithData()) {
      let bean = responseBean.getDataOrThrow()
      let artArr: ArticleBean[] = []
      if (bean.datas.length > 0) {
        artArr.push(...bean.datas)
        return Promise.resolve(artArr)
      } else {
        return Promise.resolve(artArr)
      }
    } else {
      //空数据
      return Promise.reject()
    }
  }

  @Builder
  listItemBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (data: ArticleBean, index: number) => {
        ListItem() {
          ArticleContentComponent({
            item: data,
            onCollectClick: (item: ArticleBean) => {

            }
          })
        }
      }, (data: ArticleBean, index: number) => JSON.stringify(data) + index)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .edgeEffect(EdgeEffect.None)
    .divider({
      strokeWidth: SizeConstant.SIZE_1,
      color: $r('app.color.color_969696')
    })
  }

  build() {
    PageLoadingComponent({
      loadState: this.loadState,
      onReload: () => {
        this.loadData()
      }
    }) {
      PullToRefresh({
        data: $data,
        scroller: this.scroller,
        customList: this.listItemBuilder,
        onRefresh: () => {
          this.currentIndex = 1
          return new Promise<string>((resolve, reject) => {
            this.loadPageData().then((data) => {
              this.data = data
              resolve("刷新成功")
            }, () => {
              resolve("刷新失败")

            })
          })
        },
        onLoadMore: () => {
          this.currentIndex++
          return new Promise<string>((resolve, reject) => {
            this.loadPageData().then((data) => {
              this.data = this.data.concat(data)
              resolve("刷新成功")
            }, () => {
              resolve("刷新失败")
            })
          })
        }
      })
    }

  }
}