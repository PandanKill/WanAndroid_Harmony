import SizeConstant from '../constants/SizeConstant'
import { ResponseBean } from '../bean/ResponseBean'
import { logger } from 'utils'
import Api from '../utils/net/Api'
import { ArticleBean, ArticleListBean } from '../bean/ArticleBean'
import { LoadState } from '../bean/LoadState'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { PageLoadingComponent } from './PageLoadingComponent'
import { ArticleContentComponent } from './ArticleContentComponent'

@Component
export struct SpareTabContentView {
  //当前页数,从0开始
  private nextPage: number = 1
  //初始化数据
  @State data: Array<ArticleBean> = []
  @State loadState: LoadState = LoadState.LOADING
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    //获取问答数据
    this.loadData()
  }

  /**
   * 加载数据
   */
  loadData() {
    this.loadState = LoadState.LOADING
    this.loadPageData(0).then((data) => {
      if (data.length > 0) {
        this.loadState = LoadState.SUCCESS
        this.data = data
        console.info(`AnsTabContentView data:${JSON.stringify(data)}`)
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
  private async loadPageData(page: number): Promise<ArticleBean[]> {
    let responseBean: ResponseBean<ArticleListBean> = await Api.get().getUserArticle(page)
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
}