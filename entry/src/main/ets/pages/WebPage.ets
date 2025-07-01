import { router } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import SizeConstant from '../constants/SizeConstant'
import { logger } from "utils"
import { common, Want } from '@kit.AbilityKit'

@Entry
@Component
struct WebPage {
  pageSrc: string = (this.getUIContext().getRouter().getParams() as Record<string, string>).webUrl as string
  // pageSrc:string = "https://mp.weixin.qq.com/s/m38HWBzxInUf_hgAZ---bw"
  // pageSrc: string = "https://juejin.cn/post/7294638699417288714"
  private webController: webview.WebviewController = new webview.WebviewController()
  //加载进度
  @State progress: number = 0
  @State isLoading: boolean = true
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('navHeight') navHeight: number = 0

  aboutToAppear(): void {
    //初始化
    webview.WebviewController.initializeWebEngine()
  }

  build() {
    Column() {
      // webView
      Web({
        src: this.pageSrc,
        controller: this.webController
      })
        .cacheMode(CacheMode.Default)
        .darkMode(WebDarkMode.Auto)
        .overScrollMode(OverScrollMode.ALWAYS)
        .onProgressChange((newProgressEvent) => {
          this.progress = newProgressEvent.newProgress
        })//网页加载
        .onPageBegin(() => {
          this.isLoading = true
          //重置process
          this.progress = 0
        })
        .onPageEnd(() => {
          this.isLoading = false
        })
        .onErrorReceive((err) => {
          logger.info(`${err.request.getRequestUrl()} : ${err.error}`)
        })
        .onHttpErrorReceive((err) => {
          logger.info(`${err.request.getRequestUrl()} : ${err.response.getResponseCode()}`)

        })
        .onSslErrorEventReceive((err) => {
          logger.info(err.error)
        })
        .width(SizeConstant.FULL_SIZE)
        .layoutWeight(1)
        .darkMode(WebDarkMode.Off)

      if (this.isLoading) {
        //进度条
        Progress({
          value: this.progress,
          total: 100,
          style: ProgressStyle.Linear
        }).width(SizeConstant.FULL_SIZE)
          .height(SizeConstant.SIZE_2)
          .backgroundColor(Color.Gray)
      }

      //底部操作框
      Row() {
        Image($r('app.media.pre'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .onClick(() => {
            this.webController.backward()
          })

        Image($r('app.media.next'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .onClick(() => {
            this.webController.forward()
          })

        Image($r('app.media.refresh'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .onClick(() => {
            this.webController.refresh()
          })

        Image($r('app.media.brower'))
          .width(SizeConstant.SIZE_20)
          .height(SizeConstant.SIZE_20)
          .onClick(() => {
            //拉起浏览器
            this.startBrownerAbility()
          })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.SIZE_40)
      .backgroundColor(Color.White)
      .border({
        width: 1,
        color: Color.Gray
      })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight), bottom: this.getUIContext().px2vp(this.navHeight) })
  }

  /**
   * 拉起浏览器
   */
  private startBrownerAbility() {
    if (this.pageSrc === undefined || !this.pageSrc) {
      logger.error("pageSrc is null")
      return
    }
    let want: Want = {
      action: "ohos.want.action.viewData",
      entities: ['entity.system.browsable'],
      uri: this.pageSrc
    };

    (this.getUIContext().getHostContext() as common.UIAbilityContext).startAbility(want)
  }

  aboutToDisappear(): void {
    this.webController.clearHistory()
  }
}