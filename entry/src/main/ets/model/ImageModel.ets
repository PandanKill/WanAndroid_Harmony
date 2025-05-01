import { matrix4, window } from "@kit.ArkUI";
import image from "@ohos.multimedia.image";
import { runWithAnimation, windowSizeManager } from "../utils/CommonUtils";

@Observed
export class ImageModel {
  //Matrix copy
  public matrix: matrix4.Matrix4Transit = matrix4.identity().copy()
  //当前缩放值
  public curScale: number = 1
  //当前 x、y
  public curOffsetX: number = 0
  public curOffsetY: number = 0
  //last zoom
  public lastScale: number = 1
  //last x
  public lastOffsetX: number = 0
  public lastOffsetY: number = 0
  //min scale
  public minScale: number = 0.5
  //max scale
  public maxScale: number = 2
  //default zoom
  public defaultScaleValue: number = 1
  //max offset x\y
  // Maximum deviation of the X-axis
  public maxOffsetX: number = 999;
  // Minimum deviation of the X-axis
  public minOffsetX: number = -999;
  // Maximum deviation of the Y-axis
  public maxOffsetY: number = 999;
  // Minimum deviation of Y-axis
  public minOffsetY: number = -999;
  public centerX: number = 0.5;
  public centerY: number = 0.5;
  public center: number[] = [0.5, 0.5];
  public componentHeight: number = 0;
  public componentWidth: number = 0;
  // Picture Width
  public imageWidth: number = 100;
  // Picture Height
  public imageHeight: number = 100;
  // Whether to allow swiper components to slide
  public isDisableSwipe: boolean = false;

  /**
   * pan end
   */
  gestureEnd(): void {
    this.lastScale = this.curScale
    this.lastOffsetX = this.curOffsetX
    this.lastOffsetY = this.curOffsetY
  }

  imageReset(): void {
    setTimeout(() => {
      this.matrix = matrix4.identity().scale({
        x: this.defaultScaleValue
      }).copy()
      this.lastScale = this.defaultScaleValue
      this.offsetReset()
    }, 200)
  }

  // Offset reset.
  offsetReset(): void {
    this.curOffsetX = 0;
    this.curOffsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
  }

  windowSize() {
    window.getLastWindow(getContext()).then((window: window.Window) => {
      this.componentWidth = px2vp(window.getWindowProperties().windowRect.width)
      this.componentHeight = px2vp(window.getWindowProperties().windowRect.height)
    })
  }

  pictureScaling(scale: number): void {
    this.matrix = matrix4.identity().scale({
      x: scale,
      y: scale
    }).copy()
  }

  calcFitScaleRatio(imageSize: image.Size, windowSize: window.Size): number {
    let radio: number = 1.0
    if (windowSize.width > imageSize.width) {
      radio = windowSize.width / imageSize.width
    } else {
      radio = windowSize.height / imageSize.height
    }

    return radio + 0.5
  }

  panGestureUpdate(event: GestureEvent): boolean {
    this.onScale(event.scale, event.offsetX, event.offsetY)
    this.pictureBoundaryRestriction()
    return this.isDisableSwipe
  }

  onScale(scale: number, offX: number, offY: number): void {
    if (this.lastScale * scale > this.maxScale) {
      this.curScale = this.maxScale
    } else if (this.lastScale * scale < this.minScale) {
      this.curScale = this.minScale
    } else {
      this.curScale = this.lastScale * scale
    }

    this.evaluateOffsetRange()

    if (this.curScale < this.maxScale) {
      this.curOffsetX =
        (this.lastOffsetX + offX) + (0.5 - this.centerX) * this.imageWidth * (1 - scale) * this.lastScale
      this.curOffsetY =
        (this.lastOffsetY + offY) + (0.5 - this.centerY) * this.imageHeight * (1 - scale) * this.lastScale;
    }
  }

  // Calculate the range of the picture boundary.
  evaluateOffsetRange(): void {
    this.maxOffsetX = Math.abs(Math.min(((1 - this.curScale) * this.componentWidth) / 2, 0));
    this.minOffsetX = -Math.abs(Math.max((this.componentWidth * (this.curScale - 1)) / 2, 0));
    this.maxOffsetY = Math.abs(Math.min((this.componentHeight -
      this.curScale * this.imageHeight * this.componentWidth / this.imageWidth) / 2, 0));
    this.minOffsetY = -Math.abs(Math.max((this.curScale * this.imageHeight * this.componentWidth / this.imageWidth -
    this.componentHeight) / 2, 0));
  }

  // Picture Boundary Restriction
  pictureBoundaryRestriction(): void {
    if (this.curOffsetX >= this.maxOffsetX) {
      this.curOffsetX = this.maxOffsetX;
      this.isDisableSwipe = false;
    }
    if (this.curOffsetX <= this.minOffsetX) {
      this.curOffsetX = this.minOffsetX;
      this.isDisableSwipe = false;
    }
    if (this.curOffsetY >= this.maxOffsetY) {
      this.curOffsetY = this.maxOffsetY;
    }
    if (this.curOffsetY <= this.minOffsetY) {
      this.curOffsetY = this.minOffsetY;
    }
  }

  // Pinch gesture recognition successful callback.
  pinchGestureStart(event: GestureEvent): void {
    this.center = this.evaluateCenter(event.pinchCenterX, event.pinchCenterY);
    this.centerX = 1 - this.center[0];
    this.centerY = 1 - this.center[1];
  }

  // Calculates the percentage position of the current zoom center relative to the picture
  evaluateCenter(centerX: number, centerY: number): [number, number] {
    let imgDisplayWidth = this.imageWidth * this.lastScale;
    let imgDisplayHeight = this.imageHeight * this.lastScale;
    let imgX = (this.componentWidth - imgDisplayWidth) / 2 + this.lastOffsetX;
    let imgY = (this.componentHeight - imgDisplayWidth) / 2 + this.lastOffsetY;
    let cX = Math.max((centerX - imgX) / imgDisplayWidth, 0);
    let cY = Math.max((centerY - imgY) / imgDisplayHeight, 0);
    return [cX, cY];
  }

  // Pinch gestures callback during a move.
  pinchGestureUpdate(event: GestureEvent): boolean {
    this.onScale(event.scale, event.offsetX, event.offsetY);
    this.pictureScaling(this.curScale);
    if (this.curScale > this.defaultScaleValue) {
      this.isDisableSwipe = true;
    }
    this.pictureBoundaryRestriction();
    return this.isDisableSwipe;
  }

  // The Pinch gesture is recognized successfully, and the callback is triggered when the finger is lifted.
  pinchGestureEnd(): void {
    runWithAnimation(() => {
      // When the scale is less than 1
      if (this.curScale <= this.defaultScaleValue) {
        this.pictureScaling(this.defaultScaleValue);
        this.imageReset();
      } else if (this.curScale >= this.maxScale) {
        this.curScale -= 0.1;
        this.pictureScaling(this.curScale);
      }
      this.gestureEnd();
    });
  }

  // Tap gesture recognition callback succeeded.
  doubleTapGesture(event: GestureEvent): boolean {
    let curRatio: number = 1;
    this.center = this.evaluateCenter(event.fingerList[0].displayX, event.fingerList[0].displayY);
    this.centerX = 1 - this.center[0];
    this.centerY = 1 - this.center[1];
    // When the last scale is greater than 1, the default scale is restored
    if (this.lastScale > this.defaultScaleValue) {
      runWithAnimation(() => {
        windowSizeManager.get();
        this.pictureScaling(this.defaultScaleValue);
        this.offsetReset();
      });
      curRatio = this.defaultScaleValue;
      this.isDisableSwipe = false;
    } else {
      runWithAnimation(() => {
        this.onScale(event.scale, event.offsetX, event.offsetY);
        windowSizeManager.get();
        this.pictureScaling(this.maxScale);
        this.offsetReset();
      });
      curRatio = this.maxScale;
      this.isDisableSwipe = true;
    }
    this.lastScale = curRatio;
    return this.isDisableSwipe;
  }
}