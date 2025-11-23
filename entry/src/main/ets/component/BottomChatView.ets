import SizeConstant from "../constants/SizeConstant"
import { AppStorageV2 } from "@kit.ArkUI"
import { ChatOtherFunView } from "./ChatOtherFunView"
import hilog from "@ohos.hilog"
import ImageGenerationChatListViewModel from "../viewModel/ImageGenerationChatListViewModel"

@ComponentV2
export struct BottomChatView {
  @Once @Param onSendListener: (value: string) => void = () => {
  }
  @Local editValue: string = ''
  @Local isPhoto: boolean = false
  // @Event $isPhoto: (val: boolean) => void = (val: boolean) => {
  // }
  private textAreaController: TextAreaController = new TextAreaController()
  navHeight: number = AppStorage.get('navHeight') as number

  build() {
    //底部栏
    Column() {
      //输入框
      Row() {
        //输入框
        TextArea({
          text: this.editValue,
          controller: this.textAreaController
        })
          .backgroundColor(Color.White)
          .id('sendText')
          .layoutWeight(1)
          .enterKeyType(EnterKeyType.Send)
          .margin({ left: SizeConstant.SIZE_10, top: SizeConstant.SIZE_5, bottom: SizeConstant.SIZE_3 })
          .onSubmit((eventType: EnterKeyType) => {
            if (this.editValue && this.editValue.trim().length > 0) {
              //发送
              console.info("BottomChatView", "send %s", this.editValue)
              this.onSendListener(this.editValue)
              this.editValue = ''
            }
          })
          .onChange((value) => {
            this.editValue = value
          })
          .enableKeyboardOnFocus(false)
          .onFocus(() => {
            this.getUIContext().animateTo({
              duration: 100,
              curve: Curve.Linear
            }, () => {
              this.isPhoto = false
            })
          })

        //图片、相机
        Image($r('app.media.icon_add'))
          .width(SizeConstant.SIZE_30)
          .height(SizeConstant.SIZE_30)
          .margin({ right: SizeConstant.SIZE_10, left: SizeConstant.SIZE_20 })
          .onClick(() => {
            this.getUIContext().animateTo({
              duration: 100,
              curve: Curve.Linear
            }, () => {
              this.isPhoto = !this.isPhoto
              if (this.isPhoto) {
                this.getUIContext().getFocusController().clearFocus()
              }
            })
          })
      }.width(SizeConstant.FULL_SIZE)

      //显示表情包
      if (this.isPhoto) {
        //相机、相册
        ChatOtherFunView()
      }
    }.backgroundColor($r('app.color.color_F6F6F6'))
    .padding({ bottom: this.getUIContext().px2vp(this.navHeight) })
    .width(SizeConstant.FULL_SIZE)
  }
}