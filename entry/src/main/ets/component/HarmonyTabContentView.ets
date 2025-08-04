import { PullToRefresh } from "@ohos/pulltorefresh";
import { ArticleBean } from "../bean/ArticleBean";
import { HarmonyListArticle } from "../bean/HarmonyListArticle";
import { LoadState } from "../bean/LoadState";
import { ResponseBean } from "../bean/ResponseBean";
import SizeConstant from "../constants/SizeConstant";
import Api from "../utils/net/Api";
import { ArticleContentComponent } from "./ArticleContentComponent";
import { PageLoadingComponent } from "./PageLoadingComponent";

@Component
export struct HarmonyTabContentView {
  @State loadState: LoadState = LoadState.LOADING
  @State data: ArticleBean[] = []
  private scroll: Scroller = new Scroller()
  private nextPage = 1

  aboutToAppear(): void {
    this.initData()
  }

  initData() {
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

  private async loadPageData(page: number): Promise<ArticleBean[]> {
    let responseBean: ResponseBean<HarmonyListArticle> = await Api.get().getHarmonyArticle();
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      let artArr: ArticleBean[] = []
      if (data.links.articleList.length > 0) {
        artArr.push(...data.links.articleList)
        return Promise.resolve(artArr)
      } else {
        return Promise.resolve(artArr)
      }
    } else {
      return Promise.reject()
    }
  }

  build() {
    PageLoadingComponent({
      loadState: this.loadState,
      onReload: () => {

      },
      content: this.refreshLayout
    })
  }

  /**
   * 刷新
   */
  @Builder
  refreshLayout() {
    PullToRefresh({
      data: $data,
      scroller: this.scroll,
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

  @Builder
  listItemBuilder() {
    List({ scroller: this.scroll }) {
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
}