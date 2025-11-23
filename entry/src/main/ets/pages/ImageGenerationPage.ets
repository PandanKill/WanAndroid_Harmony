import SizeConstant from '../constants/SizeConstant'
import ImageGenerationChatListViewModel from '../viewModel/ImageGenerationChatListViewModel'
import { NavHeaderView } from '../component/NavHeaderView'
import ImageGenerationChatViewModel from '../viewModel/ImageGenerationChatViewModel'
import { BottomChatView } from '../component/BottomChatView'
import { GeneralPopupItemConstant } from '../constants/GeneralPopupItemConstant'
import { ChatPopupItem } from '../bean/ChatPopupItem'
import { ImageChatItem } from '../component/ImageChatItem'
import { window } from '@kit.ArkUI'

@Entry
@ComponentV2
struct ImageGenerationPage {
  viewModel: ImageGenerationChatListViewModel = new ImageGenerationChatListViewModel()
  scroller: Scroller = new Scroller()
  @Local imageShowSheet: boolean = false
  @Local keyboardHeight: number = 0
  // @Local isPhoto: boolean = false

  // @Monitor('isPhoto')
  // isPhotoChange(monitor: IMonitor) {
  //   let isPhoto = monitor.value('isPhoto')?.now as boolean
  //   console.info(`isPhotoChange isPhoto = ${isPhoto}`)
  //   // if (isPhoto) {
  //   //   this.keyboardHeight = 100
  //   // } else {
  //   //   this.keyboardHeight = 0
  //   // }
  // }

  onPageShow(): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then((windows) => {
      try {
        windows.getUIContext().setKeyboardAvoidMode(4)
        windows.on('keyboardHeightChange', (height) => {
          console.info(`keyboardHeightChange height = ${height}`)
          if (height > 0) {
            //软键盘弹出
            this.getUIContext().animateTo({
              duration: 200,
              curve: Curve.Smooth
            }, () => {
              this.keyboardHeight = this.getUIContext().px2vp(height)
            })
          } else {
            //隐藏软键盘
            this.getUIContext().animateTo({
              duration: 200,
              curve: Curve.Smooth
            }, () => {
              this.keyboardHeight = 0
            })
          }
        })
      } catch (exception) {
        console.error(`Failed to enable the listener for keyboard height changes. Cause code: ${exception.code}, message: ${exception.message}`);
      }
    })
  }

  aboutToAppear(): void {
    this.viewModel.loadAllContent()
  }

  build() {
    Column() {
      //标题
      NavHeaderView({
        title: $r('app.string.ai_create')
      })

      Column() {
        //预览图
        // Image(this.viewModel.imageSrc)
        //   .width(SizeConstant.FULL_SIZE)
        //   .height(SizeConstant.SIZE_PERCENT_40)
        //   .objectFit(ImageFit.Contain)
        //   .onClick(() => {
        //     this.imageShowSheet = true
        //   })
        //   .bindSheet(this.imageShowSheet, this.buildImageSheet(this.viewModel.imageSrc!), {
        //     height: SheetSize.FIT_CONTENT,
        //     onWillDismiss: () => {
        //       this.imageShowSheet = false
        //     }
        //   })

        // 聊天列表
        List({
          initialIndex: this.viewModel.chatViewModelList.length > 0 ? this.viewModel.chatViewModelList.length - 1 : 0,
          scroller: this.scroller
        }) {
          ForEach(this.viewModel.chatViewModelList, (item: ImageGenerationChatViewModel, index: number) => {
            ListItem() {
              ImageChatItem({
                imageMsg: item
              })
            }.width(SizeConstant.FULL_SIZE)
            .height('auto')
          }, (item: ImageGenerationChatViewModel, index: number) => JSON.stringify(item) + index)
        }.layoutWeight(1)
        .width(SizeConstant.FULL_SIZE)

        //底部栏
        BottomChatView({
          onSendListener: (value) => {
            this.viewModel.toGetImageAi(value)
            this.scroller.scrollToIndex(this.viewModel.chatViewModelList.length - 1, true, ScrollAlign.END)
          },
          // isPhoto: this.isPhoto!!
        })
      }.layoutWeight(1)
      .width(SizeConstant.FULL_SIZE)
      .offset({
        bottom: this.keyboardHeight
      })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_EDEDED'))
  }

  @Builder
  buildImageSheet(pixelMap: PixelMap) {
    Column() {
      Grid() {
        ForEach(GeneralPopupItemConstant.ImagePopupItem, (item: ChatPopupItem, index: number) => {
          GridItem() {
            if (item.itemId == 16) {
              SaveButton({ text: SaveDescription.DOWNLOAD, buttonType: ButtonType.ROUNDED_RECTANGLE }).onClick(() => {
                this.imageShowSheet = false
                this.viewModel.downloadImage(this.getUIContext().getHostContext()!, pixelMap).then((res: boolean) => {
                  if (res) {
                    //保存成功
                    this.getUIContext().getPromptAction().showToast({
                      message: $r('app.string.save_success')
                    })
                  } else {
                    //保存成功
                    this.getUIContext().getPromptAction().showToast({
                      message: $r('app.string.save_fail')
                    })
                  }
                })

              })
            } else {
              Column() {
                Image(item.icon)
                  .width(SizeConstant.SIZE_40)
                  .padding(SizeConstant.SIZE_10)
                  .borderRadius(SizeConstant.SIZE_10)
                  .backgroundColor(Color.White)
                  .align(Alignment.Center)
                  .aspectRatio(1)

                Text(item.text)
                  .fontColor(Color.White)
                  .fontSize($r('app.float.font_12'))
                  .padding(SizeConstant.SIZE_5)

              }.alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.imageShowSheet = false
              })
            }
          }
        }, (item: ChatPopupItem, index: number) => JSON.stringify(item) + index)
      }

      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(5)
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.SIZE_80)
    .padding({
      top: SizeConstant.SIZE_15,
      bottom: SizeConstant.SIZE_15,
      left: SizeConstant.SIZE_10,
      right: SizeConstant.SIZE_10
    })
  }
}