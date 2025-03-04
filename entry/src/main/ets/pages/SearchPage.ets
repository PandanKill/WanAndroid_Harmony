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

@Entry
@Component
struct SearchPage {
  @StorageProp('hotKey') hotKeys: HotKeyBean[] = []
  @State historySearchData: string[] = []
  private currentHotData: string = (router.getParams() as Record<string, string>).currentHotKey as string
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext
  dataPreferences: preferences.Preferences | null = null
  @State isSearchView: boolean = false
  //搜索词
  @State searchStr: string = this.currentHotData
  @StorageProp('topRectHeight') topRectHeight: number = 0
  //搜索页面正在加载
  @State isLoadingView: boolean = false

  onPageShow(): void {
    let options: preferences.Options = { name: PreferenceKey.FILE_WANANDROID_STORE }
    this.dataPreferences = preferences.getPreferencesSync(this.context, options)
    let historyString: string = this.dataPreferences.getSync(PreferenceKey.PREFERENCE_KET_HISTORY, "") as string
    if (historyString !== "" && historyString.length > 0) {
      this.historySearchData = JSON.parse(historyString) as string[]
    }
  }

  searchData(): void {
    let httpSession = http.createHttp()
    // httpSession.request("https://www.wanandroid.com" + "/", )
    setTimeout(() => {
      this.isLoadingView = false
    }, 3000)
  }

  /**
   * 保存搜索数据
   * @param data
   */
  saveSearchHistoryData(data: string) {
    this.historySearchData.unshift(data)
    //判断长度
    if (this.historySearchData.length > 5) {
      let popData = this.historySearchData.pop()
    }
    this.dataPreferences?.put(PreferenceKey.PREFERENCE_KET_HISTORY, JSON.stringify(this.historySearchData))
    this.dataPreferences?.flush()
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
        Text("暂无数据")
      }
    }.width("100%")
    .height("100%")
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
                    this.dataPreferences?.put(PreferenceKey.PREFERENCE_KET_HISTORY,
                      JSON.stringify(this.historySearchData))
                    this.dataPreferences?.flush()
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
        .margin({ left: SizeConstant.SIZE_15, bottom:SizeConstant.SIZE_10 })

        Blank()

        Text("取消")
          .padding(SizeConstant.SIZE_5)
          .fontSize($r('app.float.font_12'))
          .margin({ right: SizeConstant.SIZE_5 })
          .fontColor(Color.White)
          .onClick(() => {
            router.back()
          })
      }.width(SizeConstant.FULL_SIZE)
      .backgroundColor($r('app.color.color_272A36'))
      .padding({ top: px2vp(this.topRectHeight) })

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