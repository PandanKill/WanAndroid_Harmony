import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';

const TAG: string = '[CommonUtils]';

/**
 * Animate the execution of a function
 * @param fn：Callback functions to be executed within the animation, usually fn will change the state variable
 * @param duration：Animation duration
 * @param curve：Animation area line
 */
export function runWithAnimation(
  fn: Function,
  duration: number = 300, // Scale the duration of the animation
  curve: Curve = Curve.Smooth): void {
  animateTo({ duration: duration, curve: curve }, () => {
    fn();
  });
}

class WindowSizeManager {
  private size: window.Size = { width: 0, height: 0 };

  constructor() {
    window.getLastWindow(getContext()).then((value: window.Window) => {
      const rect: window.Rect = value.getWindowProperties().windowRect;
      this.size.width = px2vp(rect.width);
      this.size.height = px2vp(rect.height);
      hilog.info(0x0000, TAG, `[windowWidth]${this.size.width} [windowHeight]${this.size.height}`);
    });
  }

  get(): window.Size {
    return this.size;
  }
}

export const windowSizeManager: WindowSizeManager = new WindowSizeManager();

/**
 * 获取封面截图
 * @param time
 * @returns
 */
export async function getFetchFrameByTime(time: number, imageUri: string, width: number,
  height: number): Promise<image.PixelMap> {
  let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator()

  let file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY)
  avImageGenerator.fdSrc = {
    fd: file.fd
  }
  let pixMap = await avImageGenerator.fetchFrameByTime(time, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC, {
    width: width,
    height: height
  })

  avImageGenerator.release()
  return pixMap
}