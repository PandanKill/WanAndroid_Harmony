import SizeConstant from '../constants/SizeConstant'
import { ResponseBean } from '../bean/ResponseBean'
import Api from '../utils/net/Api'
import { LoadState } from '../bean/LoadState'
import { ArticleBean, ArticleListBean, ArticleTagBean } from '../bean/ArticleBean'
import { PageLoadingComponent } from './PageLoadingComponent'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { JSON } from '@kit.ArkTS'
import { ArticleContentComponent } from './ArticleContentComponent'

@Component
export struct AnsTabContentView {
  //当前页数,从1开始
  private nextPage: number = 2
  //初始化数据
  @State data: Array<ArticleBean> = []
  private scroller: Scroller = new Scroller()
  @State loadState: LoadState = LoadState.LOADING

  aboutToAppear(): void {
    //获取问答数据
    this.loadData()
  }

  /**
   * 加载数据
   */
  loadData() {
    this.loadState = LoadState.LOADING
    this.loadPageData(1).then((data) => {
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
    let responseBean: ResponseBean<ArticleListBean> = await Api.get().getWendaList(page)
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
            onCollectClick: async (article: ArticleBean) => {
              //收藏
              if (article.collect) {
                //取消收藏
                let coll: ResponseBean<undefined> = await Api.get().unCollectArticle(article.id)
                console.info(`collect ${JSON.stringify(coll)}}`)
                if (coll.isSuccess()) {
                  article.collect = !article.collect
                  this.data = this.data.map(data => data)
                }
              } else {
                //收藏
                let coll: ResponseBean<undefined> = await Api.get().collectArticle(article.id)
                console.info(`collect ${JSON.stringify(coll)}}`)
                if (coll.isSuccess()) {
                  article.collect = !article.collect
                  this.data = this.data.map(data => data)
                }
              }
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
  }
}