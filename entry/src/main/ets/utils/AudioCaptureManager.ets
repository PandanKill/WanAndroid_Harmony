import { audio } from "@kit.AudioKit"
import fileIo from "@ohos.file.fs"
import { BusinessError } from "@kit.BasicServicesKit"

/**
 * 录音管理类
 */
export interface RecordFile {
  recordFilePath?: string //保存的文件路径
  startRecordTime?: number // 开始时间戳
  endRecordTime?: number // 结束时间戳
  recordText?: string //转文字内容
}

export class AudioCaptureManager {
  //音频
  static audioCapture: audio.AudioCapturer | null = null
  //录音文件路径
  private static recordFilePath: string = ''
  //开始时间戳
  private static startRecordTime: number = 0
  //结束时间戳
  private static endRecordTime: number = 0

  //创建音频捕获器
  static async createAudioCapture(): Promise<audio.AudioCapturer> {
    if (AudioCaptureManager.audioCapture) {
      //不为空，直接 返回
      return AudioCaptureManager.audioCapture
    }

    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
      channels: audio.AudioChannel.CHANNEL_1,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    }

    let audioCapture: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      //什么意思
      capturerFlags: 0
    }

    // 创建音频捕获选项对象
    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: audioStreamInfo, // 使用上面定义的音频流信息
      capturerInfo: audioCapture // 使用上面定义的音频捕获信息
    };

    AudioCaptureManager.audioCapture = await audio.createAudioCapturer(audioCapturerOptions)

    return AudioCaptureManager.audioCapture
  }

  //开始录音
  static async startRecord(fileName: string) {
    await AudioCaptureManager.createAudioCapture()

    //记录开始时间戳
    AudioCaptureManager.startRecordTime = Date.now()

    try {
      let bufferSize: number = 0

      class Options {
        offset?: number //文件偏移量
        length?: number //写入数据的长度
      }

      //文件路径
      let path = getContext().filesDir

      let filePath = `${path}/${fileName}.wav`
      AudioCaptureManager.recordFilePath = filePath

      //打开或创建录音文件
      let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)

      //读取回调
      let readDataCallback = (buffer: ArrayBuffer) => {
        //创建协议文件的选项对象
        let options: Options = {
          offset: bufferSize,
          length: buffer.byteLength
        }

        //写入文件
        fileIo.writeSync(file.fd, buffer, options)
        //更新缓冲区大小
        bufferSize += buffer.byteLength
      }

      //注册读取回调
      AudioCaptureManager.audioCapture?.on('readData', readDataCallback)

      //开始录音
      AudioCaptureManager.audioCapture?.start()

      return filePath
    } catch (e) {
      let err = e as BusinessError
      console.error(`startRecord ${err.message}`)
      return ''
    }
  }

  //停止录音
  static async stopRecord() {
    AudioCaptureManager.audioCapture?.stop()
    AudioCaptureManager.audioCapture?.release()
    AudioCaptureManager.audioCapture = null
    AudioCaptureManager.endRecordTime = Date.now()

    //创建并返回包含录音文件信息的对象
    const recordFile: RecordFile = {
      recordFilePath: AudioCaptureManager.recordFilePath,
      startRecordTime: AudioCaptureManager.startRecordTime,
      endRecordTime: AudioCaptureManager.endRecordTime
    }

    return recordFile
  }
}