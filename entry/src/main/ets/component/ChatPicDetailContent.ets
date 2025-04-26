import SizeConstant from "../constants/SizeConstant"
import { Message } from "../pages/ChatPage"
import { matrix4 } from "@kit.ArkUI"
import { ImageModel } from "../model/ImageModel"

//
// import { BusinessError } from '@kit.BasicServicesKit';
// import { hilog } from '@kit.PerformanceAnalysisKit';
// import { common } from '@kit.AbilityKit';
// import { image } from '@kit.ImageKit';
// import { windowSizeManager } from '../utils/CommonUtils';
// import { ImageModel } from '../model/CommonModel';
//
// const TAG: string = '[ImageItemView]';
//
// @Reusable
// @Component
// export struct ImageItemView {
//   @State imageData: Resource = $r('app.media.ic_image1');
//   @State imageModel: ImageModel = new ImageModel();
//   // Whether to display the picture toolbar
//   @Link isOverlay: boolean;
//   // Swipe whether to switch
//   @Consume isDisableSwipe: boolean;
//   @Consume @Watch('onImageReset') isImageReset: boolean;
//   @Consume bgc: Color;
//   private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
//   // Image original aspect ratio
//   private imageWHRatio: number = 0;
//
//   aboutToAppear(): void {
//     this.imageModel.windowSize();
//     setTimeout(() => {
//       this.initCurrentImageInfo();
//     }, 10);
//   }
//
//   // When switching images, reset the previous image
//   onImageReset(): void {
//     if (this.isImageReset) {
//       this.imageModel.imageReset();
//     }
//   }
//
//   /**
//    * Set information about the current image: uri, whRatio, pixelMap, defaultSize, maxScaleValue
//    * Obtain the Image information in advance for the size setting of
//    * the image component and subsequent related calculations
//    */
//   initCurrentImageInfo(): void {
//     let img = this.context.resourceManager.getMediaContentSync(this.imageData?.id);
//     let imageSource = image.createImageSource(img.buffer.slice(0));
//     imageSource.getImageInfo(0).then((data: image.ImageInfo) => {
//       this.imageWHRatio = data.size.width / data.size.height;
//       this.imageModel.imageWidth = this.imageModel.componentWidth;
//       this.imageModel.imageHeight = this.imageModel.imageWidth / this.imageWHRatio;
//     }).catch((err: BusinessError) => {
//       hilog.error(0x0000, TAG, `[error][getImageInfo]${err.message}`);
//     });
//   }
//
//   build() {
//     Stack() {
//       Image(this.imageData)
//         .width(this.imageModel.imageWidth)
//         .height(this.imageModel.imageHeight)
//         .aspectRatio(this.imageWHRatio)
//         .objectFit(ImageFit.Cover)
//         .autoResize(false)
//         .defaultFocus(true)
//         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
//         .transform(this.imageModel.matrix)// Control picture scaling with matrix
//         .translate({
//           x: this.imageModel.curOffsetX,
//           y: this.imageModel.curOffsetY
//         })
//         .onComplete(() => {
//           this.imageModel.maxScale = this.imageModel.calcFitScaleRatio({
//             width: this.imageModel.imageWidth,
//             height: this.imageModel.imageHeight
//           }, windowSizeManager.get());
//         })
//     }
//     .backgroundColor(this.bgc)
//     .alignContent(Alignment.Center)
//     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
//     .width('100%')
//     .height('100%')
//     .parallelGesture(
//       GestureGroup(
//         GestureMode.Exclusive,
//         // Slide picture
//         // Swiping left and right under the default size should switch images
//         PanGesture({ fingers: 1, distance: this.isDisableSwipe ? 3 : 50 })
//           .onActionUpdate((event: GestureEvent) => {
//             this.isDisableSwipe = this.imageModel.panGestureUpdate(event);
//           })
//           .onActionEnd(() => {
//             this.imageModel.gestureEnd();
//           }),
//         // Two-finger scaling
//         PinchGesture({ fingers: 2, distance: 1 })
//           .onActionStart((event: GestureEvent) => {
//             this.imageModel.pinchGestureStart(event);
//           })
//           .onActionUpdate((event: GestureEvent) => {
//             this.isDisableSwipe = this.imageModel.pinchGestureUpdate(event);
//           })
//           .onActionEnd(() => {
//             this.imageModel.pinchGestureEnd();
//           }),
//         // Double click picture
//         TapGesture({ count: 2 })
//           .onAction((event: GestureEvent) => {
//             this.isDisableSwipe = this.imageModel.doubleTapGesture(event);
//           }),
//         // Click Switch picture toolbar
//         TapGesture({ count: 1 })
//           .onAction(() => {
//             this.isOverlay = !this.isOverlay;
//           })
//         // Pinching and scaling images with two fingers
//       ), GestureMask.Normal
//     )
//   }
// }

@Component
export struct ChatPicDetailContent {
  @Prop detailMessage: Message
  @Link chatPicDetailContent: boolean
  //图片详情
  @State picContentWidth: number = 0
  @State picContentHeight: number = 0
  //透明度
  @State opacityEx: number = 1
  //滑动偏移量
  @State curOffsetX: number = 0
  @State curOffsetY: number = 0
  //matrix
  @State matrix: matrix4.Matrix4Transit = matrix4.identity().copy()
  @State imageModel: ImageModel = new ImageModel()

  aboutToAppear(): void {

  }

  build() {
    Stack() {
      Image(this.detailMessage.imageUri)
        .width(this.picContentWidth)
        .height(this.picContentHeight)
        .objectFit(ImageFit.Cover)
        .translate({
          x: this.curOffsetX,
          y: this.curOffsetY
        })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor(Color.Black)
    .opacity(this.opacityEx)
  }
}