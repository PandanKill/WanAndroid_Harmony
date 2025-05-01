import SizeConstant from "../constants/SizeConstant"
import { Message } from "../pages/ChatPage"
import { matrix4 } from "@kit.ArkUI"
import { ImageModel } from "../model/ImageModel"
import { common } from "@kit.AbilityKit"
import image from "@ohos.multimedia.image"
import { BusinessError } from "@kit.BasicServicesKit"
import { windowSizeManager } from "../utils/CommonUtils"
import { hilog } from "@kit.PerformanceAnalysisKit"

const TAG: string = '[ImageItemView]';

@Component
export struct ChatPicDetailContent {
  @Prop detailMessage: Message
  @Link chatPicDetailContent: boolean
  @State imageModel: ImageModel = new ImageModel()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private imageWHRatio: number = 0
  //是否支持滑动，边界考虑
  @State isDisableSwipe: boolean = true

  aboutToAppear(): void {
    //窗口大小
    this.imageModel.windowSize()
    setTimeout(() => {
      this.initCurrentImageInfo()
    }, 10)
  }

  /**
   * 获取当前图片信息
   */
  initCurrentImageInfo() {
    // let imageSource = image.createImageSource(this.detailMessage.imageUri)
    // imageSource.getImageInfo().then((data: image.ImageInfo) => {
    this.imageWHRatio = this.detailMessage.imageWidth / this.detailMessage.imageHeight;
    this.imageModel.imageWidth = this.imageModel.componentWidth
    this.imageModel.imageHeight = this.imageModel.imageWidth / this.imageWHRatio
    // }).catch((err: BusinessError) => {
    //   hilog.error(0x0000, TAG, `[error][getImageInfo]${err.message}`);
    // })
  }

  build() {
    Stack() {
      Image(this.detailMessage.imageUri)
        .width(this.imageModel.imageWidth)
        .height(this.imageModel.imageHeight)
        .aspectRatio(this.imageWHRatio)
        .objectFit(ImageFit.Cover)
        .autoResize(true)
        .defaultFocus(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .transform(this.imageModel.matrix)
        .translate({
          x: this.imageModel.curOffsetX,
          y: this.imageModel.curOffsetY
        })
        .onComplete(() => {
          this.imageModel.maxScale = this.imageModel.calcFitScaleRatio({
            width: this.imageModel.imageWidth,
            height: this.imageModel.imageHeight
          }, windowSizeManager.get())
        })
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor(Color.Black)
    .alignContent(Alignment.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .parallelGesture(
      GestureGroup(
        GestureMode.Exclusive,
        PanGesture({ fingers: 1, distance: this.isDisableSwipe ? 3 : 50 })
          .onActionUpdate((event: GestureEvent) => {
            this.isDisableSwipe = this.imageModel.panGestureUpdate(event)
          })
          .onActionEnd(() => {
            this.imageModel.gestureEnd()
          }),
        PinchGesture({ fingers: 2, distance: 1 })
          .onActionStart((event: GestureEvent) => {
            this.imageModel.pinchGestureStart(event)
          }).onActionUpdate((event: GestureEvent) => {
          this.imageModel.pinchGestureUpdate(event)
        }).onActionEnd(() => {
          this.imageModel.pinchGestureEnd()
        }),
        TapGesture({ count: 2 }).onAction((event: GestureEvent) => {
          this.isDisableSwipe = this.imageModel.doubleTapGesture(event);
        }),
        TapGesture({ count: 1 }).onAction((event: GestureEvent) => {
          //关闭 close
          this.chatPicDetailContent = false
        })
      ), GestureMask.Normal
    )
  }
}