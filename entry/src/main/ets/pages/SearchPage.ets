/**
 * 1、热搜词
 * 2、历史记录
 */
import { HotKeyBean } from '../bean/HotKeyBean'
import { common } from '@kit.AbilityKit'
import { JSON } from '@kit.ArkTS'
import SizeConstant from '../constants/SizeConstant'
import Preference from '../utils/Preference'
import Api from '../utils/net/Api'
import { ResponseBean } from '../bean/ResponseBean'
import { ArticleBean, ArticleListBean, ArticleTagBean } from '../bean/ArticleBean'
import { LoadState } from '../bean/LoadState'
import { PageLoadingComponent } from '../component/PageLoadingComponent'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { ArticleContentComponent } from '../component/ArticleContentComponent'

@Entry
@Component
struct SearchPage {
  @StorageProp('hotKey') hotKeys: HotKeyBean[] = []
  @State historySearchData: string[] = []
  private currentHotData: string =
    (this.getUIContext().getRouter().getParams() as Record<string, string>).currentHotKey as string
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @State isSearchView: boolean = false
  //搜索词
  @State searchStr: string = this.currentHotData
  @StorageProp('topRectHeight') topRectHeight: number = 0
  //搜索页面正在加载
  @State isLoadingView: boolean = false
  //当前索引
  private nextPage: number = 1
  @State data: ArticleBean[] = []
  @State loadState: LoadState = LoadState.LOADING
  private scroller: Scroller = new Scroller()

  onPageShow(): void {
    let historyString: string = Preference.get(this.context).getSearchHistory()
    if (historyString !== "" && historyString.length > 0) {
      this.historySearchData = JSON.parse(historyString) as string[]
    }
  }

  /**
   * 搜索
   */
  private searchData() {
    this.loadState = LoadState.LOADING
    this.searchPageData(this.searchStr, 0).then((data) => {
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

  /**
   * 页面数据
   * @param page
   * @returns
   */
  private async searchPageData(searchData: string, page: number): Promise<ArticleBean[]> {
    let responseBean: ResponseBean<ArticleListBean> =
      await Api.get().search(searchData, page)
    if (responseBean.isSuccessWithData()) {
      let da = responseBean.getDataOrThrow()
      let artArr: ArticleBean[] = []
      if (da.datas.length > 0) {
        da.datas.forEach((data: ArticleBean) => {
          if (data.tags !== undefined && data.tags.length !== 0) {
            let tag = new ArticleTagBean()
            tag.name = data.tags[0].name
            tag.url = data.tags[0].url
            tag.charptId = this.getChartpId(data.tags[0].url)
            data.tags = [tag]
          }
        })
        artArr.push(...da.datas)
        return Promise.resolve(artArr)
      } else {
        return Promise.resolve(artArr)
      }
    } else {
      //异常数据
      return Promise.reject()
    }
  }

  getChartpId(url: string | undefined): number | undefined {
    let idStr = url?.substring("/wxarticle/list/".length, url!!.length - 2)
    return parseInt(idStr!!)
  }

  /**
   * 保存搜索数据
   * @param data
   */
  saveSearchHistoryData(data: string) {
    this.historySearchData = this.historySearchData.filter(item => item !== data)

    this.historySearchData.unshift(data)
    //判断长度
    if (this.historySearchData.length > 5) {
      let popData = this.historySearchData.pop()
    }
    Preference.get(this.context).putSearchHistory(this.historySearchData)
  }

  @Builder
  listViewBuilder() {
    List({
      scroller: this.scroller
    }) {
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
    .divider({
      strokeWidth: SizeConstant.SIZE_1,
      color: $r('app.color.color_969696')
    })
    .edgeEffect(EdgeEffect.None)
  }

  @Builder
  searchView(): void {
    PageLoadingComponent({
      loadState: this.loadState,
      onReload: () => {
        this.searchData()
      }
    }) {
      PullToRefresh({
        data: $data,
        scroller: this.scroller,
        customList: this.listViewBuilder,
        onRefresh: () => {
          return new Promise<string>((resolve, reject) => {
            this.searchPageData(this.searchStr, 0).then((data) => {
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
            this.searchPageData(this.searchStr, this.nextPage).then((data) => {
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
  normalView() {
    Column() {
      Text("大家在搜")
        .fontSize($r('app.float.font_15'))
        .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_20 })
        .fontColor("#333333")

      //流式布局实现热词
      Flex({
        direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start
      }) {
        ForEach(this.hotKeys, (item: HotKeyBean, index: number) => {
          Text(item.name)
            .padding({
              left: SizeConstant.SIZE_10,
              right: SizeConstant.SIZE_10,
              top: SizeConstant.SIZE_5,
              bottom: SizeConstant.SIZE_5
            })
            .fontSize($r('app.float.font_12'))
            .fontColor("#333333")
            .backgroundColor("#F6F6F6")
            .borderRadius(SizeConstant.SIZE_20)
            .margin({ right: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })
            .onClick(() => {
              //搜索
              this.saveSearchHistoryData(item.name)
              this.searchStr = item.name
              this.isSearchView = true
              this.isLoadingView = true
              this.getUIContext().getFocusController().clearFocus()
              this.searchData()
            })
        })
      }.width(SizeConstant.FULL_SIZE)
      .margin({ top: SizeConstant.SIZE_20, left: SizeConstant.SIZE_15, right: SizeConstant.SIZE_15 })

      Text("历史搜索")
        .fontSize(SizeConstant.SIZE_15)
        .fontColor($r('app.color.color_333333'))
        .margin({ left: SizeConstant.SIZE_15, top: SizeConstant.SIZE_20 })


      List() {
        ForEach(this.historySearchData, (item: string, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Text(item)
                  .width(SizeConstant.SIZE_PERCENT_60)
                  .maxLines(1)
                  .ellipsisMode(EllipsisMode.END)
                  .fontSize($r('app.float.font_12'))
                  .fontColor($r('app.color.color_666666'))
                  .margin({ left: SizeConstant.SIZE_15 })

                Blank()

                Image($r('app.media.icon_delete'))
                  .width(SizeConstant.SIZE_20)
                  .height(SizeConstant.SIZE_20)
                  .margin({ right: SizeConstant.SIZE_15 })
                  .onClick(() => {
                    this.historySearchData.splice(index, 1)
                    Preference.get(this.context).putSearchHistory(this.historySearchData)
                  })
              }
              .alignItems(VerticalAlign.Center)
              .height(SizeConstant.SIZE_45)
              .width(SizeConstant.FULL_SIZE)
              .onClick(() => {
                //搜索
                this.saveSearchHistoryData(item)
                this.searchStr = item
                this.isSearchView = true
                this.isLoadingView = true
                this.getUIContext().getFocusController().clearFocus()
                this.searchData()
              })

              Line()
                .width(SizeConstant.FULL_SIZE)
                .height(1)
                .backgroundColor($r('app.color.color_F0F0F0'))
            }
          }
        })
      }.margin({ top: SizeConstant.SIZE_20 })
    }.alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      Row() {
        //搜索
        Row() {
          //搜索图标
          Image($r('app.media.search'))
            .width(SizeConstant.SIZE_15)
            .height(SizeConstant.SIZE_15)
            .margin({ left: 5, right: 5 })
          //搜索文字
          TextInput({
            text: this.searchStr
          })
            .height(SizeConstant.FULL_SIZE)
            .width(SizeConstant.FULL_SIZE)
            .fontSize($r('app.float.font_12'))
            .fontColor(Color.White)
            .onFocus(() => {
              //获取焦点
              this.isSearchView = false
              this.isLoadingView = false
              //取消请求

            })
            .onBlur(() => {
              //失去焦点
            })
            .enterKeyType(EnterKeyType.Search)
            .onSubmit((type: EnterKeyType, event: SubmitEvent) => {
              if (type === EnterKeyType.Search) {
                this.saveSearchHistoryData(event.text)
                //搜索
                this.searchStr = event.text
                this.isSearchView = true
                this.isLoadingView = true
                this.searchData()
              }
            })
        }
        .width(SizeConstant.SIZE_PERCENT_85)
        .alignItems(VerticalAlign.Center)
        .height(SizeConstant.SIZE_30)
        .backgroundColor($r('app.color.color_474954'))
        .borderRadius(20)
        .margin({ left: SizeConstant.SIZE_15, bottom: SizeConstant.SIZE_10 })

        Blank()

        Text("取消")
          .padding(SizeConstant.SIZE_5)
          .fontSize($r('app.float.font_12'))
          .margin({ right: SizeConstant.SIZE_5 })
          .fontColor(Color.White)
          .onClick(() => {
            this.getUIContext().getRouter().back()
          })
      }.width(SizeConstant.FULL_SIZE)
      .backgroundColor($r('app.color.color_272A36'))
      .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })

      if (this.isSearchView) {
        //搜索页面
        this.searchView()
      } else {
        //非搜索页面
        this.normalView()
      }

    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      //点击空白区域隐藏键盘
      this.getUIContext().getFocusController().clearFocus()
    })
    .backgroundColor($r('app.color.color_FFFFFF'))
  }
}