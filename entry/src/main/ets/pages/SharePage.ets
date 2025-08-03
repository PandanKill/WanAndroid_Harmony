/**
 *分享页面
 */
import { PullToRefresh } from '@ohos/pulltorefresh'
import SizeConstant from '../constants/SizeConstant'
import { JSON } from '@kit.ArkTS'
import { NavHeaderView } from '../component/NavHeaderView'
import { PageLoadingComponent } from '../component/PageLoadingComponent'
import { LoadState } from '../bean/LoadState'
import { ArticleBean, ShareArticleListBean } from '../bean/ArticleBean'
import Api from '../utils/net/Api'
import { ResponseBean } from '../bean/ResponseBean'
import { ArticleContentComponent } from '../component/ArticleContentComponent'
import { ChatPopupItem } from '../bean/ChatPopupItem'

@Entry
@Component
struct SharePage {
  @State data: Array<ArticleBean> = []
  private scroller: Scroller = new Scroller()
  @State loadState: LoadState = LoadState.LOADING
  private next: number = 2
  //删除分享
  @State showPopup: boolean = false
  popupItem: ChatPopupItem[] = [{
    icon: $r('app.media.icon_delete'),
    text: "删除",
    itemId: 0
  }]

  aboutToAppear(): void {
    this.initData()
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.title_share')
      })

      PageLoadingComponent({
        loadState: this.loadState,
        onReload: () => {
          this.initData()
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
      data: $data,
      scroller: this.scroller,
      customList: this.itemListLayout,
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadPageData(1).then((data) => {
            this.next = 2
            this.data = data
            resolve("success")
          }, () => {
            resolve("fail")
          })
        })
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadPageData(this.next).then((data) => {

            this.next++
            this.data = this.data.concat(data)
            resolve("success")
          }, () => {
            resolve("fail")
          })
        })
      }
    })
  }

  /**
   * 初次加载
   */
  initData() {
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

  private async loadPageData(page: number): Promise<ArticleBean[]> {
    let responseBean: ResponseBean<ShareArticleListBean> = await Api.get().getShareArticle(page)
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      let daArr: ArticleBean[] = []
      if (data.shareArticles && data.shareArticles.datas.length > 0) {
        daArr.push(...data.shareArticles.datas)
      }
      return Promise.resolve(daArr)
    } else {
      return Promise.reject()
    }
  }

  /**
   * 列表
   */
  @Builder
  itemListLayout() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (item: ArticleBean, index: number) => {
        ListItem() {
          ArticleContentComponent({
            item: item,
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
      }, (item: ArticleBean, index: number) => JSON.stringify(item) + index)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .divider({
      strokeWidth: SizeConstant.SIZE_1,
      color: $r('app.color.color_969696')
    })
    .edgeEffect(EdgeEffect.None)
  }

  /**
   * 编辑
   */
  @Builder
  editPopup() {
    Column() {
      Grid() {
        ForEach(this.popupItem, (popupItem: ChatPopupItem, index: number) => {
          GridItem() {
            Column() {
              // Image(popupItem.icon)
              //   .width(SizeConstant.SIZE_15)
              //   .aspectRatio(1)

              Text("popupItem.text")
                .fontColor(Color.White)
                .fontSize($r('app.float.font_12'))
                .padding(SizeConstant.SIZE_5)

            }.alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.showPopup = false
              //删除分享
              // this.deleteArticle(item, indexN)
            })
          }
        }, (item: ChatPopupItem, index: number) => JSON.stringify(item) + index)
      }
      .columnsTemplate('1fr')
    }
    .padding({
      top: SizeConstant.SIZE_15,
      bottom: SizeConstant.SIZE_15,
      left: SizeConstant.SIZE_10,
      right: SizeConstant.SIZE_10
    })
  }

  async deleteArticle(item: ArticleBean, index: number) {
    let responseBean: ResponseBean<undefined> = await Api.get().deleteShareArticle(item.id)
    if (responseBean.isSuccess()) {
      //删除成功
      this.data.splice(index, 1)
    }
  }
}