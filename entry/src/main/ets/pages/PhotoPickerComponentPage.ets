import {
  BaseItemInfo,
  ClickType,
  DataType,
  ItemInfo,
  ItemType,
  PhotoBrowserInfo,
  PhotoBrowserRange,
  PhotoPickerComponent,
  PickerController,
  PickerOptions,
  ReminderMode
} from '@ohos.file.PhotoPickerComponent'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import SizeConstant from '../constants/SizeConstant';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct PhotoPickerComponentPage {
  private pickerOptions: PickerOptions = new PickerOptions()
  //组件行为
  @State pickerController: PickerController = new PickerController()
  // 已选择的图片
  @State selectUris: Array<ItemInfo> = new Array<ItemInfo>();
  //目前选择的图片
  @State currentUri: string = '';
  @State isBrowserShow: boolean = false
  @StorageProp('navHeight') navHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State sendText: string = '发送'

  aboutToAppear(): void {
    // 设置picker宫格页数据类型
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE // 图片和照片都显示;
    // 最大选择数量
    this.pickerOptions.maxSelectNumber = 1;
    // 超出最大选择数量时
    this.pickerOptions.maxSelectedReminderMode = ReminderMode.MASK;
    // 是否展示搜索框，默认false
    this.pickerOptions.isSearchSupported = false;
    // 是否支持拍照，默认false
    this.pickerOptions.isPhotoTakingSupported = false;
    //背景色
    this.pickerOptions.backgroundColor = "#191919"
  }

  onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if (!itemInfo) {
      return false
    }

    let type = itemInfo.itemType
    let uri = itemInfo.uri
    if (type === ItemType.CAMERA) {
      //点击相机
      return true //拉起系统相机，默认系统自己处理，false就是自行处理
    } else {
      if (clickType === ClickType.SELECTED) {
        //应用做处理
        if (uri) {
          this.selectUris.push(itemInfo)
          this.pickerOptions.preselectedUris = this.selectUris.map((itemInfo: ItemInfo, index: number) => {
            return itemInfo.uri ?? ""
          })
        }
      } else {
        if (uri) {
          //取消勾选
          this.selectUris = this.selectUris.filter((item: ItemInfo) => {
            return item.uri !== uri
          })
          this.pickerOptions.preselectedUris = this.selectUris.map((itemInfo: ItemInfo, index: number) => {
            return itemInfo.uri ?? ""
          })
        }
      }
      if (this.selectUris.length > 0) {
        this.sendText = '发送' + `(${this.selectUris.length})`
      } else {
        this.sendText = '发送'
      }
      return true
    }
  }

  build() {
    Column() {
      PhotoPickerComponent({
        pickerOptions: this.pickerOptions,
        onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => this.onItemClicked(itemInfo, clickType),
        onEnterPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onEnterPhotoBrowser(photoBrowserInfo),
        onExitPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onExitPhotoBrowser(photoBrowserInfo),
        onPickerControllerReady: (): void => this.onPickerControllerReady(),
        onPhotoBrowserChanged: (browserItemInfo: BaseItemInfo): boolean => this.onPhotoBrowserChanged(browserItemInfo),
        pickerController: this.pickerController
      }).layoutWeight(1)
        .width(SizeConstant.FULL_SIZE)

      // 这里模拟应用侧底部的选择栏
      if (this.isBrowserShow) {
        //已选择的图片缩影图
        Column() {
          Row() {
            ForEach(this.selectUris, (uri: string) => {
              if (uri === this.currentUri) {
                Image(uri)
                  .height(SizeConstant.SIZE_50)
                  .width(SizeConstant.SIZE_50)
                  .onClick(() => {
                  })
                  .borderWidth(SizeConstant.SIZE_3)
                  .borderColor($r('app.color.color_05C166'))
                  .margin({ left: SizeConstant.SIZE_5, right: SizeConstant.SIZE_5 })
              } else {
                Image(uri).height(SizeConstant.SIZE_50).width(SizeConstant.SIZE_50).onClick(() => {
                  this.pickerController.setData(DataType.SET_SELECTED_URIS, this.selectUris);
                  this.pickerController.setPhotoBrowserItem(uri, PhotoBrowserRange.ALL);
                }).margin({ left: SizeConstant.SIZE_5, right: SizeConstant.SIZE_5 })
              }
            }, (uri: string) => JSON.stringify(uri))
          }.alignSelf(ItemAlign.Start).margin({ top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10 })

          this.bottomNav('编辑', () => {
            //todo 编辑图片页面
            this.getUIContext().getPromptAction().showToast({
              message: "跳转编辑页面"
            })
          })
        }
      } else {
        // 进入大图，预览已选择的图片
        this.bottomNav('预览', () => {
          if (this.selectUris.length > 0) {
            this.pickerController.setPhotoBrowserItem(this.selectUris[0].uri ?? "", PhotoBrowserRange.SELECTED_ONLY);
          }
        })
      }
    }.width('100%')
    .height('100%')
    .padding({ bottom: this.getUIContext().px2vp(this.navHeight), top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.color_1A1A18'))
  }

  @Builder
  bottomNav(text: string, click: () => void) {
    Row() {
      Text(text)
        .alignSelf(ItemAlign.Start)
        .fontSize($r('app.float.font_15'))
        .fontColor(this.selectUris.length === 0 ? $r('app.color.color_5F5E5F') : $r('app.color.color_FDFDFD'))
        .margin({ top: SizeConstant.SIZE_10, bottom: SizeConstant.SIZE_10, left: SizeConstant.SIZE_15 })
        .onClick(() => {
          click()
        })

      Blank()

      Text(this.sendText)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.selectUris.length === 0 ? $r('app.color.color_343434') :
        $r('app.color.color_08C459'))
        .padding({
          left: SizeConstant.SIZE_10,
          right: SizeConstant.SIZE_10,
          top: SizeConstant.SIZE_5,
          bottom: SizeConstant.SIZE_5
        })
        .fontSize($r('app.float.font_15'))
        .fontColor(this.selectUris.length === 0 ? $r('app.color.color_555555') :
        $r('app.color.color_FFFFFF'))
        .borderRadius(SizeConstant.SIZE_5)
        .margin({ right: SizeConstant.SIZE_15 })
        .onClick(() => {
          //发送
          this.getUIContext().getRouter().back({
            url: "pages/ChatPage",
            params: {
              "selectUri": this.selectUris
            }
          })
        })
    }.alignItems(VerticalAlign.Center)
    .width(SizeConstant.FULL_SIZE)
    .margin({ top: SizeConstant.SIZE_10 })
  }

  onPhotoBrowserChanged(browserItemInfo: BaseItemInfo): boolean {
    //切换当前选择的 uri
    this.currentUri = browserItemInfo.uri ?? ""
    return true
  }

  onPickerControllerReady(): void {
    //在接收到回调之后，才能使用PickerController
  }

  onExitPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = false
    return true
  }

  onEnterPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = true
    return true
  }
}