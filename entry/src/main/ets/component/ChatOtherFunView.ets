import { it } from '@ohos/hypium'
import SizeConstant from '../constants/SizeConstant'
import { camera, cameraPicker } from '@kit.CameraKit'
import { PickerOptions, ReminderMode } from '@ohos.file.PhotoPickerComponent'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { router } from '@kit.ArkUI'

interface ChatFunBean {
  name: string,
  icon: Resource,
  id: string
}

@Component
export struct ChatOtherFunView {
  private funNames: ChatFunBean[] = [{
    name: "照片", icon: $r('app.media.icon_pic'), id: "image"
  }, {
    name: "拍照", icon: $r('app.media.icon_photo'), id: "photo"
  }]

  build() {
    Stack() {
      Grid() {
        ForEach(this.funNames, (item: ChatFunBean, index: number) => {
          GridItem() {
            Column() {
              Stack() {
                Image(item.icon)
                  .width(SizeConstant.SIZE_25)
                  .objectFit(ImageFit.Cover)
              }
              .align(Alignment.Center)
              .backgroundColor($r('app.color.color_FFFFFF'))
              .borderRadius(SizeConstant.SIZE_5)
              .width(SizeConstant.SIZE_50)
              .margin({ top: SizeConstant.SIZE_10 })
              .height(SizeConstant.SIZE_50)
              .onClick(() => {
                this.clickFun(item.id)
              })

              Text(item.name)
                .fontColor($r('app.color.color_7C7C7C'))
                .fontSize($r('app.float.font_8'))
                .margin({ top: SizeConstant.SIZE_5 })
            }.alignItems(HorizontalAlign.Center)
          }
        })
      }
      .layoutDirection(GridDirection.Row)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(SizeConstant.SIZE_10)
      // .rowsGap(SizeConstant.SIZE_5)
      .rowsTemplate('1fr 1fr')
      .width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
    }.width(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_F6F6F6'))
    .height(SizeConstant.SIZE_PERCENT_20)
  }

  clickFun(id: string) {
    switch (id) {
      case "image":
        this.openPhoto()
        break
      case "photo":
        this.openCamera()
        break
    }
  }

  openPhoto() {
    this.getUIContext().getRouter().pushUrl({
      url: "pages/PhotoPickerComponentPage"
    })
  }

  /**
   * 打开相机
   */
  async openCamera() {
    let pickerProfile: cameraPicker.PickerProfile = {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
    }
    let pickerResult: cameraPicker.PickerResult =
      await cameraPicker.pick(this.getUIContext().getHostContext(),
        [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO], pickerProfile)

    let selectUri: Array<string> = []
    selectUri.push(pickerResult.resultUri)
    this.getUIContext().getRouter().back({
      url: "pages/ChatPage",
      params: {
        "selectUri": selectUri
      }
    })
  }
}