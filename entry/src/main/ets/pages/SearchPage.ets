/**
 * 1、热搜词
 * 2、历史记录
 */
import { HotKeyBean } from '../bean/HotKeyBean'
import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { PreferenceKey } from '../constants/PreferenceKey'
import { promptAction, router } from '@kit.ArkUI'
import { JSON } from '@kit.ArkTS'
import { http } from '@kit.NetworkKit'
import SizeConstant from '../constants/SizeConstant'
import Preference from '../utils/Preference'
import Api from '../utils/net/Api'
import { HomeBean, HomeListViewBeanInterface } from '../bean/HomeListViewBeanInterface'
import { ResponseBean } from '../bean/ResponseBean'
import { ListAttr, ListView, RefreshController, RefreshDataSource } from '@abner/refresh'
import { HomeListViewBean, TagBean } from '../bean/HomeListViewBean'
import { TagRouterBean } from '../bean/TagRouterBean'

@Entry
@Component
struct SearchPage {
  @StorageProp('hotKey') hotKeys: HotKeyBean[] = []
  @State historySearchData: string[] = []
  private currentHotData: string = (this.getUIContext().getRouter().getParams() as Record<string, string>).currentHotKey as string
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @State isSearchView: boolean = false
  //搜索词
  @State searchStr: string = this.currentHotData
  @StorageProp('topRectHeight') topRectHeight: number = 0
  //搜索页面正在加载
  @State isLoadingView: boolean = false
  //当前索引
  private currentIndex: number = 0
  initData: HomeListViewBean[] = []
  //数据刷新
  dataSource: RefreshDataSource = new RefreshDataSource()
  //刷新 controller
  refreshController: RefreshController = new RefreshController()

  onPageShow(): void {
    let options: preferences.Options = { name: PreferenceKey.FILE_WANANDROID_STORE }
    let historyString: string = Preference.get(this.context).getSearchHistory()
    if (historyString !== "" && historyString.length > 0) {
      this.historySearchData = JSON.parse(historyString) as string[]
    }
  }

  /**
   * 搜索数据
   */
  async searchData() {
    //初始化索引
    this.currentIndex = 0
    this.initData = []
    let responseBean: ResponseBean<HomeListViewBeanInterface> =
      await Api.get().search(this.searchStr, this.currentIndex)
    this.isLoadingView = false
    if (responseBean.isSuccessWithData()) {
      let data = responseBean.getDataOrThrow()
      if (data.datas && data.datas.length !== 0) {
        data.datas.forEach((homeBean: HomeBean) => {
          let bean = new HomeListViewBean()
          bean.author = homeBean.author
          bean.chapterName = homeBean.chapterName
          bean.id = homeBean.id
          bean.link = homeBean.link
          bean.niceDate = homeBean.niceDate
          bean.superChapterId = homeBean.superChapterId
          bean.collect = homeBean.collect
          bean.superChapterName = homeBean.superChapterName
          bean.isTop = false

          if (homeBean.tags !== undefined && homeBean.tags.length !== 0) {
            let tag = new TagBean()
            tag.name = homeBean.tags[0].name
            tag.url = homeBean.tags[0].url
            tag.charptId = this.getChartpId(homeBean.tags[0].url)
            bean.tags = [tag]
          }

          bean.title = homeBean.title
          this.initData.push(bean)
        })
        this.dataSource.initData(this.initData)
      }
    }
    this.refreshController.finishRefresh()
  }

  getChartpId(url: string | undefined): number | undefined {
    let idStr = url?.substring("/wxarticle/list/".length, url!!.length - 2)
    return parseInt(idStr!!)
  }

  /**
   * 加载更多
   */
  async loadMore() {
    this.currentIndex++
    let responseBean: ResponseBean<HomeListViewBeanInterface> =
      await Api.get().search(this.searchStr, this.currentIndex)
    if (responseBean.isSuccessWithData()) {
      let dataArr: HomeListViewBean[] = []
      let data = responseBean.getDataOrThrow()
      if (data.datas && data.datas.length !== 0) {
        data.datas.forEach((homeBean: HomeBean) => {
          let bean = new HomeListViewBean()
          bean.author = homeBean.author
          bean.chapterName = homeBean.chapterName
          bean.id = homeBean.id
          bean.link = homeBean.link
          bean.niceDate = homeBean.niceDate
          bean.superChapterId = homeBean.superChapterId
          bean.collect = homeBean.collect
          bean.superChapterName = homeBean.superChapterName
          bean.isTop = false

          if (homeBean.tags !== undefined && homeBean.tags.length !== 0) {
            let tag = new TagBean()
            tag.name = homeBean.tags[0].name
            tag.url = homeBean.tags[0].url
            tag.charptId = this.getChartpId(homeBean.tags[0].url)
            bean.tags = [tag]
          }

          bean.title = homeBean.title
          dataArr.push(bean)
        })
        this.dataSource.pushDataArray(dataArr)
      }
    }
    this.refreshController.finishLoadMore()
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
  searchView(): void {
    Stack({ alignContent: Alignment.Center }) {
      if (this.isLoadingView) {
        LoadingProgress()
          .color($r('app.color.color_0000FF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_40)
      } else {
        //显示listView
        ListView({
          lazyDataSource: this.dataSource,
          itemLayout: (item, index) => this.itemLayout(item as HomeListViewBean, index),
          controller: this.refreshController,
          onRefresh: () => {
            //下拉刷新
            //重置currentIndex
            this.searchData()
          },
          onLoadMore: () => {
            //上划加载
            this.loadMore()
          },
          listAttribute: (listAttr: ListAttr) => {
            listAttr.divider = {
              strokeWidth: SizeConstant.SIZE_1,
              color: $r('app.color.color_969696')
            }
            listAttr.scrollBar = BarState.Off
          }
        }).width(SizeConstant.FULL_SIZE)
          .height(SizeConstant.FULL_SIZE)
      }
    }.width("100%")
    .height("100%")
  }

  @Builder
  itemLayout(item: HomeListViewBean, index: number) {
    //ItemLayout
    Column() {
      Row() {
        //头像
        Image($r('app.media.icon_person'))
          .width(SizeConstant.SIZE_30)
          .height(SizeConstant.SIZE_30)

        Column() {
          Text(item.author === undefined || item.author === "" ? "匿名" : item.author)
            .fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_666666'))
            .margin({ bottom: SizeConstant.SIZE_2 })
          Text(item.niceDate).fontSize($r('app.float.font_10'))
            .fontColor($r('app.color.color_999999'))
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: SizeConstant.SIZE_10 })

        if (item.tags !== undefined && item.tags.length !== 0) {
          //存在tag
          Text(item.tags[0].name)
            .padding(SizeConstant.SIZE_2)
            .fontSize($r('app.float.font_10'))
            .margin({ right: SizeConstant.SIZE_5 })
            .fontColor($r('app.color.color_228B22'))
            .border({
              width: SizeConstant.SIZE_1,
              color: $r('app.color.color_228B22'),
              radius: SizeConstant.SIZE_2,
              style: BorderStyle.Solid
            })
            .onClick(() => {
              let tagBean = new TagRouterBean()
              tagBean.type = "Home"
              tagBean.officialAcc = item.tags!![0].charptId!!

              //跳转公众号
              this.getUIContext().getRouter().pushUrl({
                url: "pages/TagDetailPage",
                params: tagBean
              })
            })
        }
      }.width(SizeConstant.FULL_SIZE)
      .alignItems(VerticalAlign.Center)

      //标题
      Text(item.title)
        .fontSize($r('app.float.font_15'))
        .fontColor($r('app.color.color_000000'))
        .margin({ top: SizeConstant.SIZE_10 })
        .maxLines(2)
        .width(SizeConstant.FULL_SIZE)
        .ellipsisMode(EllipsisMode.END)

      Row() {
        //置顶
        if (item.isTop) {
          Text("置顶")
            .fontSize($r('app.float.font_11'))
            .fontColor(Color.Red)
            .margin({ right: SizeConstant.SIZE_10 })
        }

        //来源
        Text(`${item.superChapterName}·${item.chapterName}`)
          .fontSize($r('app.float.font_10'))
          .fontColor($r('app.color.color_999999'))
          .layoutWeight(1)

        Image(item.collect ? $r('app.media.shixin_love') : $r('app.media.kongxin_love'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .margin({ right: SizeConstant.SIZE_5 })
          .onClick(async () => {
            //收藏
            let collTmp = item.collect
            item.collect = !item.collect
            if (collTmp) {
              //取消收藏
              let coll: ResponseBean<undefined> = await Api.get().unCollectArticle(item.id)
              console.info(`collect ${JSON.stringify(coll)}}`)
              if (!coll.isSuccess()) {
                //更新失败
                item.collect = collTmp
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.opt_fail')
                })
              }
            } else {
              //收藏
              let coll: ResponseBean<undefined> = await Api.get().collectArticle(item.id)
              console.info(`collect ${JSON.stringify(coll)}}`)
              if (!coll.isSuccess()) {
                //更新失败
                item.collect = collTmp
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.opt_fail')
                })
              }
            }
          })
      }.width(SizeConstant.FULL_SIZE)
      .margin({ top: SizeConstant.SIZE_10 })
      .alignItems(VerticalAlign.Center)

    }.width(SizeConstant.FULL_SIZE)
    .padding({
      top: SizeConstant.SIZE_10,
      bottom: SizeConstant.SIZE_10,
      left: SizeConstant.SIZE_10,
      right: SizeConstant.SIZE_10
    })
    .onClick(() => {
      //点击跳转webView
      this.getUIContext().getRouter().pushUrl({
        url: "pages/WebPage",
        params: {
          webUrl: item.link
        }
      })
    })
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