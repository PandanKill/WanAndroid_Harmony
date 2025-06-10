import { speechRecognizer } from '@kit.CoreSpeechKit'
import call from '@ohos.telephony.call'
import { fileIo } from '@kit.CoreFileKit'

/**
 * 语音转文字
 */
class SpeechRecognizerManager {
  /**
   * 语种信息
   * 语音识别语言
   * 语音模式：长
   */
  private static extraParams: Record<string, Object> = {
    "locate": "CN", "recognizerMode": "long"
  }
  //识别 sessionId
  private static sessionId: string = "asr" + Date.now()
  private static initParamInfo: speechRecognizer.CreateEngineParams = {
    //地区
    language: 'zh-CN',
    //离线模式
    online: 1,
    extraParams: this.extraParams
  }
  private static asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null
  /**
   * 录音结果
   */
  static speechResult: speechRecognizer.SpeechRecognitionResult | null = null

  //创建引擎
  private static async createEngine() {
    //设置常见引擎参数
    SpeechRecognizerManager.asrEngine = await speechRecognizer.createEngine(SpeechRecognizerManager.initParamInfo)
  }

  /**
   * 初始化 ai 语音转文字引擎，实现一键开启语音识别
   */
  static async audioBufToText(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {
  }) {
    await SpeechRecognizerManager.createEngine()
    SpeechRecognizerManager.setListener(callback)
    SpeechRecognizerManager.startListening(0)
  }

  /**
   * 语音转文字，非实时
   */
  static async audioToText(audioUri: string, callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {
  }) {
    await SpeechRecognizerManager.createEngine()
    SpeechRecognizerManager.setListener(callback)
    SpeechRecognizerManager.startListening(1)
    SpeechRecognizerManager.writeAudio(audioUri)
  }

  /**
   * 语音文件转文字
   * @param audioUri
   */
  private static async writeAudio(audioUri: string) {
    let file = fileIo.openSync(audioUri, fileIo.OpenMode.READ_ONLY)
    try {
      let buf: ArrayBuffer = new ArrayBuffer(1024)
      let offset: number = 0
      let len: number = fileIo.readSync(file.fd, buf, { offset: offset });
      while (len > 0) {

        let uintArr: Uint8Array = new Uint8Array(buf)
        SpeechRecognizerManager.asrEngine?.writeAudio(SpeechRecognizerManager.sessionId, uintArr)
        //延迟40ms
        await SpeechRecognizerManager.countDownLatch(1)
        offset += len
        len = fileIo.readSync(file.fd, buf, { offset: offset })
      }

    } catch (e) {
      console.log("e", e.message, e.code)
    } finally {
      if (file) {
        fileIo.closeSync(file)
      }
    }
  }

  // 计时
  private static async countDownLatch(count: number) {
    while (count > 0) {
      await SpeechRecognizerManager.sleep(40);
      count--;
    }
  }

  // 睡眠
  private static sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * 开始识别
   */
  static startListening(mode: number) {
    let listenerParam: speechRecognizer.StartParams = {
      sessionId: SpeechRecognizerManager.sessionId,
      audioInfo: {
        //音频类型 pcm
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      },
      extraParams: {
        //实时录制识别
        "recognitionMode": mode,
        //最大录制时长
        "maxAudioDuration": 60000
      }
    };
    SpeechRecognizerManager.asrEngine?.startListening(listenerParam)
  }

  /**
   * 设置语音转文字回调
   * @param callback
   */
  private static setListener(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void) {
    let listener: speechRecognizer.RecognitionListener = {
      //开始识别成功回调
      onStart(sessionId: string, eventMessage: string) {
        console.info(`SpeechRecognizerManager setListener onStart:sessionId:${sessionId}, eventMessage:${eventMessage}`)
      },
      //事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info(`SpeechRecognizerManager setListener onEvent:sessionId:${sessionId}, eventCode:${eventCode}, eventMessage:${eventMessage}`)

      },
      onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        console.info(`SpeechRecognizerManager setListener onResult:sessionId:${sessionId}, result:${result.result +
        result.isFinal + result.isLast}`)
        SpeechRecognizerManager.speechResult = result
        callback && callback(result)
      },
      onComplete(sessionId: string, eventMessage: string) {
        console.info(`SpeechRecognizerManager setListener onComplete:sessionId:${sessionId}, eventMessage:${eventMessage}`)

      },
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.info(`SpeechRecognizerManager setListener onError:sessionId:${sessionId}, errorCode:${errorCode}, errorMessage:${errorMessage}}`)
      }
    }

    SpeechRecognizerManager.asrEngine?.setListener(listener)
  }

  /**
   * 取消识别
   */
  static cancel() {
    SpeechRecognizerManager.asrEngine?.cancel(SpeechRecognizerManager.sessionId)
  }

  /**
   * 结束识别
   */
  static finish() {
    SpeechRecognizerManager.asrEngine?.finish(SpeechRecognizerManager.sessionId)
  }

  /**
   * 释放ai语音转文字引擎
   */
  static shutDown() {
    SpeechRecognizerManager.asrEngine?.shutdown()
  }

  /**
   * 停止并且释放资源
   */
  static async release() {
    SpeechRecognizerManager.cancel()
    SpeechRecognizerManager.shutDown()

  }
}

export default SpeechRecognizerManager