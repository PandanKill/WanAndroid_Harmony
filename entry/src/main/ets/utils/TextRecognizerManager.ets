import { getPicToPixelMap } from "./CommonUtils"
import { textRecognition } from "@kit.CoreVisionKit"

/**
 * 图片中文字识别
 */
class TextRecognizerManager {
  static async recognizeText(picPath: string) {
    let pixelMap = await getPicToPixelMap(picPath)

    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: pixelMap
    }

    //是否进行屏幕方向检测
    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false
    };
    const result = await textRecognition.recognizeText(visionInfo, textConfiguration)
    return result
  }
}

export default TextRecognizerManager