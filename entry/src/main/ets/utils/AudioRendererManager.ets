import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import fileIO from '@ohos.fileio';

/**
 * 语音播放
 * AudioRenderer
 */
class Options {
  offset?: number;
  length?: number;
}

class AudioRendererManager {
  //音频播放实例
  private static audioRender: audio.AudioRenderer | null = null
  //是否正在播放
  private static isPlay: boolean = false

  /**
   * 播放语音
   * @param fileName
   */
  static async doPlay(fileName: string) {
    await AudioRendererManager.ready(fileName)
    AudioRendererManager.start()
  }

  /**
   * 初始化准备
   * @param fileName
   */
  private static async ready(fileName: string) {

    let file = fileIo.openSync(fileName, fileIo.OpenMode.READ_ONLY)
    try {
      let bufferSize: number = 0
      let audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
        channels: audio.AudioChannel.CHANNEL_1, // 通道
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
      }

      let audioRendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC, // 音频流使用类型
        rendererFlags: 0 // 音频渲染器标志
      }

      let audioRendererOptions: audio.AudioRendererOptions = {
        streamInfo: audioStreamInfo,
        rendererInfo: audioRendererInfo
      }

      const fileSize = fileIo.statSync(file.path).size
      let writeDataCallback: audio.AudioRendererWriteDataCallback = (buffer: ArrayBuffer) => {
        let options: Options = {
          offset: bufferSize,
          length: buffer.byteLength
        }
        fileIo.readSync(file.fd, buffer, options)
        bufferSize += buffer.byteLength
        //停止
        if (bufferSize >= fileSize) {
          AudioRendererManager.isPlay = false
          AudioRendererManager.stop()
            .then(() => {
              AudioRendererManager.release()
            })
        }
      }

      AudioRendererManager.audioRender = await audio.createAudioRenderer(audioRendererOptions)
      AudioRendererManager.audioRender.on("writeData", writeDataCallback)
    } catch (e) {
      console.log("e", e.message, e.code)
    }/* finally {
      if (file) {
        fileIo.closeSync(file)
      }
    }*/
  }

  //播放
  static async start() {
    AudioRendererManager.isPlay = true
    await AudioRendererManager.audioRender?.start()
  }

  /** 暂停播放*/
  static async pause() {
    AudioRendererManager.isPlay = false
    await AudioRendererManager.audioRender?.pause()
  }

  //结束播放
  static async stop() {
    AudioRendererManager.isPlay = false
    await AudioRendererManager.audioRender?.stop()
  }

  static async release() {
    AudioRendererManager.isPlay = false
    await AudioRendererManager.audioRender?.release()
  }

  /**
   * 是否正在播放
   * @returns
   */
  static getPlay(): boolean {
    return AudioRendererManager.isPlay
  }
}

export default AudioRendererManager