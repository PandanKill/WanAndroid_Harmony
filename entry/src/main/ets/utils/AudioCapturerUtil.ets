/**
 * 语音录制工具类：AudioCapturer
 */

import { audio } from "/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/ets/kits/@kit.AudioKit";
import { BusinessError } from "@kit.BasicServicesKit";
import fs from '@ohos.file.fs';

/**
 * 1、播放录制功能前，申请音频焦点；功能结束，释放音频焦点
 * 2、焦点监控
 * 注意点：
 * 1、启动功能前，设置对应的音频流类型
 * 2、过程中，监听音频焦点事件，并接收中断事件，处理措施
 * 3、主动管理音频焦点，使用AudioSession
 *
 * 申请音频焦点：
 * 申请焦点失败，将会在监听中收到焦点事件
 *
 * 特殊场景：
 * 短音播放SoundPool 设置Type为Music、Movie、AudioBook等，短音申请的焦点是并发
 * 静音播放：静音播放不影响其他音频，解除静音后，正常策略申请音频焦点
 *  AVPlayer setMediaMuted
 *  AudioRenderer setSilentModeAndMixWithOthers
 *  OHAudio OH_AudioRenderer_SetSilentModeAndMixWithOthers
 *
 * 释放音频焦点：
 *  调用stop、release、pause
 *  如果不希望在停止音频流后，立马释放音频焦点，使用AudioSession自行处理焦点释放延迟效果
 *
 *
 * 音频焦点策略：常见音频焦点场景，自定义使用AudioSession
 * 开始播放Movie音频流时，将导致正在播放的Music音频流暂停，但Movie播放停止后，Music不会收到恢复播放的通知。
 开始Navigation音频流时，会自动降低正在播放的Music音频流音量，Navigation停止后，Music音量将恢复至原样。
 Music音频流与Game音频流可并发混音播放，相互之间不会影响音量或播放状态。
 VoiceCommunication开始播放时，将暂停正在播放的Music音频流，VoiceCommunication停止后，Music将收到恢复播放的通知。
 开始录制VoiceMessage时，Music音频流会被暂停，VoiceMessage录制停止后，Music将收到恢复播放的通知。

 *
 * 同个应用创建多个音频流：设置焦点模式InterruptMode
 * 共享焦点模式：多个音频流共享一个焦点，音频之间的并发由应用自行决定，焦点不介入
 * 独立焦点模式：每个音频流单独音频焦点，多个音频同时播放，将触发音频焦点策略
 *
 * 焦点变化：
 *  AVPlayer arkts使用on
 *  AVPlayer c++ OH_AVPlayer_SetOnInfoCallback()
 *  AudioRenderer on
 *  OHAudio OH_AudioStreamBuilder_SetRendererCallback
 *  AudioCapture录制 on
 *  OHAudio录制 c++  OH_AudioStreamBuilder_SetCapturerCallback
 *  焦点类型：
 *  1、打断类型 InterruptForceType
 *    1、INTERRUPT_FORCE 系统操作强制执行，应用做界面更新
 *    2、INTERRUPT_SHARE 应用进行操作，应用自行选择处理
 *
 * 2、打断提示 InterruptHint
 *  1、继续 INTERRUPT_HINT_RESUME 音频流恢复播放录制，仅会在pause之后收到
 *  2、暂停 音频暂停，暂时失去焦点
 *  3、停止，彻底失去音频焦点
 *  4、降低音量
 *  5、恢复音量
 *
 * AudioSession自行管理，使用AudioSession时候，一定要监听音频会话停用事件
 *  1、应用激活音频会话，指定会话策略AudioSessionStrategy，应用内共享一个，案例：应用播放短视频，打断后台音乐，暂停视频，恢复音乐
 *  2、音频会话激活状态下，本应用音频流全部停止时，不会立即释放音频焦点，系统保持音频焦点，直到音频会话停用再释放，案例：应用连续播放音频，多个音频间隙不希望后台音频恢复
 *
 * AudioSessionStrategy：
 * 1、默认模式
 * 2、并发模式
 * 3、降低音量
 * 4、暂停模式：暂停其他音频流，待释放后通知
 *
 *
 * 麦克风：使用麦克风进行录制的时候，最好判断麦克风是否静音，静音无法获取音频数据
 *
 * 查看音频流状态变化
 * audioCapturer.state
 * audioCapturer.on('stateChange', (capturerState: audio.AudioState) => {
 console.info(`State change to: ${capturerState}`)
 });
 *
 * 管理全局音频输入设备，当设备同事链接多个音频输入设备，指定音频输入设备进行录制，AudioRoutingManager管理
 */

/**
 * 多数场景不用,使用系统的焦点策略就可以
 * 特殊场景：
 * 1、当有多段小音频，切换的时候不希望唤醒其他焦点，此时可以激活会话，在会话停用之前，不会被唤醒
 */
export function doAudioSession() {
  let audioManager = audio.getAudioManager()
  //创建会话管理器
  let audioSessionManager: audio.AudioSessionManager = audioManager.getSessionManager();
  //激活音频会话
  audioSessionManager.activateAudioSession({
    concurrencyMode: audio.AudioConcurrencyMode.CONCURRENCY_PAUSE_OTHERS
  })

  //查询音频会话是否激活
  let active = audioSessionManager.isAudioSessionActivated()
  //停用音频会话
  audioSessionManager.deactivateAudioSession()
  //监听会话停用事件
  audioSessionManager.on('audioSessionDeactivated', (au: audio.AudioSessionDeactivatedEvent) => {
    //非主动停止会话，应用自行处理，重启会话还是干啥
  })

  //取消监听音频会啊话停用事件
  audioSessionManager.off('audioSessionDeactivated')
}

/**
 * 音频录制：
 * 1、申请权限ohos.permission.MICROPHONE
 */
let audioStreamInfo: audio.AudioStreamInfo = {
  samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000,
  channels: audio.AudioChannel.CHANNEL_2,
  sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
  encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
}

let audioCapture: audio.AudioCapturerInfo = {
  source: audio.SourceType.SOURCE_TYPE_VOICE_MESSAGE,
  //什么意思
  capturerFlags: 0
}

let audioCaptureInfo: audio.AudioCapturerOptions = {
  streamInfo: audioStreamInfo,
  capturerInfo: audioCapture
}
let bufferSize = 0
let readDataCallback = (data: ArrayBuffer) => {
  //数据读取
  fs.writeSync(file.fd, data, {
    offset: bufferSize,
    length: data.byteLength
  })

  bufferSize += data.byteLength
}

//焦点切换
let interruptEventCallback = (event: audio.InterruptEvent) => {
  if (event.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
    //系统强制中断焦点
    switch (event.hintType) {
      case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
      case audio.InterruptHint.INTERRUPT_HINT_STOP:
        //失去焦点，更新状态
        break
      case audio.InterruptHint.INTERRUPT_HINT_DUCK:
        //音量降低
        break
      case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
        //音量恢复
        break
      default:
        break
    }
  } else if (event.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
    //共享焦点
    switch (event.hintType) {
      case audio.InterruptHint.INTERRUPT_HINT_RESUME:
        //唤醒
        break
    }
  }
}

//状态监听
let stateCallback = (state: audio.AudioState) => {
  console.info(`state: ${state.valueOf()}`)
}

let audioCapturer: audio.AudioCapturer | undefined = undefined

//文件
let path = getContext().filesDir + "/test.pcm"
let file: fs.File = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)

/**
 * 初始化AudioCapturer
 */
export function init() {
  audio.createAudioCapturer(audioCaptureInfo, (err: BusinessError, audioCap: audio.AudioCapturer) => {
    if (err) {
      console.error(`Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`)
      return
    }
    audioCapturer = audioCap
    if (audioCapturer !== undefined) {
      //监听数据
      (audioCapturer as audio.AudioCapturer).on('readData', readDataCallback);
      //监听焦点异常
      (audioCapturer as audio.AudioCapturer).on('audioInterrupt', interruptEventCallback);
      //监听状态
      (audioCapturer as audio.AudioCapturer).on('stateChange', stateCallback)
    }
  })
}


/**
 * 开始录制
 */
export function start() {
  if (audioCapture !== undefined) {
    let state = (audioCapturer as audio.AudioCapturer).state
    let statusGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED]
    if (statusGroup.indexOf(state.valueOf()) === -1) {
      console.error(`start failed status:${state}}`)
      return
    }

    (audioCapturer as audio.AudioCapturer).start((err: BusinessError) => {
      if (err) {
        console.error('Capturer start failed.');
      } else {
        console.info('Capturer start success.');
      }
    })
  }
}

/**
 * 停止录制
 */
export function stop() {
  if (audioCapturer !== undefined) {
    let state = (audioCapturer as audio.AudioCapturer).state
    if (state.valueOf() !== audio.AudioState.STATE_RUNNING && state.valueOf() !== audio.AudioState.STATE_PAUSED) {
      console.error(`stop failed status:${state}}`)
      return
    }

    (audioCapturer as audio.AudioCapturer).stop((err: BusinessError) => {
      if (err) {
        console.error('Capturer stop failed.');
      } else {
        fs.close(file);
        console.info('Capturer stop success.');
      }
    })
  }
}


/**
 * 释放资源
 */
export function release() {
  if (audioCapturer !== undefined) {
    if ((audioCapturer as audio.AudioCapturer).state.valueOf() === audio.AudioState.STATE_RELEASED ||
      (audioCapturer as audio.AudioCapturer).state.valueOf() === audio.AudioState.STATE_NEW) {
      console.info('Capturer already released');
      return;
    }

    (audioCapturer as audio.AudioCapturer).release((err: BusinessError) => {
      if (err) {
        console.error('Capturer release failed.');
      } else {
        audioCapturer = undefined
        console.info('Capturer release success.');
      }
    })
  }
}

let audioVolumeGroupManager: audio.AudioVolumeGroupManager

/**
 * 创建audioVolumeGroupManager对象
 */
async function loadVolumeGroupManager() {
  const groupId = audio.DEFAULT_VOLUME_GROUP_ID
  audioVolumeGroupManager = await audio.getAudioManager().getVolumeManager().getVolumeGroupManager(groupId)
}

async function isMicrophoneMute(): Promise<boolean> {
  return await audioVolumeGroupManager.isMicrophoneMute()
}

