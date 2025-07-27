import SizeConstant from '../constants/SizeConstant'
import { logger } from 'utils'
import { ResponseBean } from '../bean/ResponseBean'
import Api from '../utils/net/Api'
import { PageLoadingComponent } from './PageLoadingComponent'
import { LoadState } from '../bean/LoadState'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { BannerBean } from '../bean/BannerBean'
import { JSON } from '@kit.ArkTS'
import { SwiperView } from './SwiperView'
import { ArticleBean, ArticleListBean, ArticleTagBean } from '../bean/ArticleBean'
import { ArticleContentComponent } from './ArticleContentComponent'

//复合类型
declare type HomeItemData = BannerBean[] | ArticleBean

@Component
export struct HomeListView {
  @State loadState: LoadState = LoadState.LOADING
  //初始化数据
  @State data: Array<HomeItemData> = []
  //滚动器
  private scroller: Scroller = new Scroller()
  //当前加载到那一页了
  private nextPage: number = 1

  aboutToAppear(): void {
    //首次加载数据
    logger.info("HomeListView: aboutToAppear")
    //获取数据
    this.loadData()
  }

  getChartpId(url: string | undefined): number | undefined {
    let idStr = url?.substring("/wxarticle/list/".length, url!!.length - 2)
    return parseInt(idStr!!)
  }

  build() {
    PageLoadingComponent({
      loadState: this.loadState,
      onReload: () => {
        //重载数据
        console.info(`HomeListView onReload`)
        this.loadData()
      }
    }) {
      //页面内容
      PullToRefresh({
        data: $data,
        scroller: this.scroller,
        customList: this.listViewBuilder,
        onRefresh: () => {
          return new Promise<string>((resolve, reject) => {
            this.loadDataPage(0).then((data) => {
              this.nextPage = 1
              this.data = data
              resolve("刷新成功")
            },
              () => {
                //加载失败
                resolve("刷新失败")
              })
          })
        },
        onLoadMore: () => {
          return new Promise<string>((resolve, reject) => {
            this.loadDataPage(this.nextPage).then((data) => {
              if (data.length > 0) {
                this.nextPage++
                this.data = this.data.concat(data);
                resolve('加载成功');
              } else {
                resolve('没有更多了')
              }
            }, () => {
              resolve('加载失败');
            })
          })
        }
      })
    }

  }

  /**
   * 加载数据
   */
  loadData() {
    //首次加载
    this.loadState = LoadState.LOADING
    this.loadDataPage(0).then((data) => {
      if (data.length > 0) {
        this.loadState = LoadState.SUCCESS
        this.data = data
      } else {
        //空数据
        this.loadState = LoadState.EMPTY
      }
    },
      () => {
        //加载失败
        this.loadState = LoadState.FAILURE
      })
  }

  /**
   * 加载列表数据
   * @param page 页面
   */
  async loadDataPage(page: number): Promise<HomeItemData[]> {
    if (page === 0) {
      //首页
      let bannerBean: ResponseBean<BannerBean[]> = await Api.get().getSwiperArt()
      let topBean: ResponseBean<ArticleBean[]> = await Api.get().getTopArt()
      let articleList: ResponseBean<ArticleListBean> = await Api.get().getArticleList(page)
      if (bannerBean.isSuccessWithData() && topBean.isSuccessWithData() && articleList.isSuccessWithData()) {
        let homeItemDataArr: HomeItemData[] = []
        //轮播器
        let banner = bannerBean.getDataOrThrow()
        console.info(`HomeListView ==> banner : ${JSON.stringify(banner)}`)
        homeItemDataArr.push(banner)

        //置顶文章
        let top = topBean.getDataOrThrow()
        top.forEach((data: ArticleBean) => {
          //修改 top 值
          data.isTop = true
          if (data.tags !== undefined && data.tags.length !== 0) {
            let articleTag = new ArticleTagBean()
            articleTag.name = data.tags[0].name
            articleTag.url = data.tags[0].url
            articleTag.charptId = this.getChartpId(data.tags[0].url)
            data.tags = [articleTag]
          }
        })
        console.info(`HomeListView ==>top : ${JSON.stringify(top)}`)
        homeItemDataArr.push(...top)

        //文章列表
        let article = articleList.getDataOrThrow()
        article.datas.forEach((data: ArticleBean) => {
          if (data.tags !== undefined && data.tags.length !== 0) {
            let articleTag = new ArticleTagBean()
            articleTag.name = data.tags[0].name
            articleTag.url = data.tags[0].url
            articleTag.charptId = this.getChartpId(data.tags[0].url)
            data.tags = [articleTag]
          }
        })
        console.info(`HomeListView ==>article : ${JSON.stringify(article)}`)
        homeItemDataArr.push(...article.datas)
        console.info(`HomeListView ==>article : ${JSON.stringify(homeItemDataArr)}`)
        return Promise.resolve(homeItemDataArr)
      } else {
        return Promise.reject()
      }
    } else {
      //加载更多
      let articleList: ResponseBean<ArticleListBean> = await Api.get().getArticleList(page)
      if (articleList.isSuccessWithData()) {
        let article = articleList.getDataOrThrow()
        return Promise.resolve(article.datas)
      } else {
        return Promise.reject()
      }
    }
  }

  @Builder
  listViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (data: HomeItemData, index: number) => {
        ListItem() {
          if (data instanceof Array) {
            //轮播器
            SwiperView({
              swiperPics: data
            }).width(SizeConstant.FULL_SIZE)
              .height(SizeConstant.SIZE_PERCENT_25)
          } else {
            //文章列表
            ArticleContentComponent({
              item: data as ArticleBean,
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
        }
      }, (data: HomeItemData, index: number) => JSON.stringify(data) + index)
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