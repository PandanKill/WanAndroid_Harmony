import { speechRecognizer } from '@kit.CoreSpeechKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileIo, statfs } from '@kit.CoreFileKit'

interface SpeechRecognitionListener {
  onResult: (data: string) => void,
  onComplete: () => void,
  onError: (errMsg: string) => void
}

class SpeechRecognizerUtil {
  asrEngine: speechRecognizer.SpeechRecognitionEngine | undefined = undefined
  sessionId: string = ""

  async startSpeechEngine(listener: SpeechRecognitionListener, audioPath: string) {
    try {
      this.asrEngine = await speechRecognizer.createEngine({
        language: "zh-CN",
        online: 1,
        extraParams: {
          "locate": "CN",
          "recognizerMode": "short"
        }
      })

      //监听
      this.asrEngine.setListener({
        onStart: (sessionId: string, eventMessage: string): void => {
          this.sessionId = sessionId
          console.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
        },
        onEvent: (sessionId: string, eventCode: number, eventMessage: string): void => {
          console.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
        },
        onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult): void => {
          console.info(`onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
          listener.onResult(result.result)
        },
        onComplete: (sessionId: string, eventMessage: string): void => {
          console.info(`onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
          listener.onComplete()
        },
        onError: (sessionId: string, errorCode: number, errorMessage: string): void => {
          console.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
          listener.onError(errorMessage)
        }
      })


      //读取音频文件，非实时流解析
      this.asrEngine.startListening({
        sessionId: this.sessionId,
        audioInfo: {
          audioType: 'pcm',
          sampleRate: 48000,
          soundChannel: 2,
          sampleBit: 16
        }
      })

      //写音频流
      let file = fileIo.openSync(audioPath, fileIo.OpenMode.READ_ONLY)
      try {
        let buf: ArrayBuffer = new ArrayBuffer(1024)
        let offset: number = 0
        let len: number = fileIo.readSync(file.fd, buf, { offset: offset });
        while (len > 0) {
          //写入Recognize
          let uint8Array: Uint8Array = new Uint8Array(buf)
          this.asrEngine.writeAudio(this.sessionId, uint8Array)
          //延迟40ms
          await this.countDownLatch(1)
          offset += len
          len = fileIo.readSync(file.fd, buf, { offset: offset })
        }
      } catch (e) {
        let error: BusinessError = e as BusinessError
        console.error(`Failed to create engine. Code: ${error.code}, message: ${error.message}.`)
      } finally {
        if (file != null) {
          fileIo.closeSync(file)
        }
      }

    } catch (err) {
      let error: BusinessError = err as BusinessError
      console.error(`Failed to create engine. Code: ${error.code}, message: ${error.message}.`)
    }
  }

  // 计时
  public async countDownLatch(count: number) {
    while (count > 0) {
      await this.sleep(40);
      count--;
    }
  }

  // 睡眠
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  //释放
  releaseSpeechEngine() {
    if (this.asrEngine !== undefined) {
      this.asrEngine.finish(this.sessionId)
      this.asrEngine.shutdown()
    }
  }
}

const speechRecognizerUtil: SpeechRecognizerUtil = new SpeechRecognizerUtil()

export default speechRecognizerUtil as SpeechRecognizerUtil