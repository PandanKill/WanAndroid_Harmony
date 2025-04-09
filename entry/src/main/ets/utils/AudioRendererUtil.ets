/**
 * 语音播放
 */
import { audio } from '@kit.AudioKit';
import fs from '@ohos.file.fs';

let streamInfo: audio.AudioStreamInfo = {
  samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 采样率
  channels: audio.AudioChannel.CHANNEL_2, // 通道
  sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
  encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
}

let rendererInfo: audio.AudioRendererInfo = {
  usage: audio.StreamUsage.STREAM_USAGE_VOICE_MESSAGE,
  rendererFlags: 0
}

let audioRendererOptions: audio.AudioRendererOptions = {
  streamInfo: streamInfo,
  rendererInfo: rendererInfo,
  privacyType: audio.AudioPrivacyType.PRIVACY_TYPE_PRIVATE
}

let audioRenderer: audio.AudioRenderer

let path = getContext().filesDir + "/test.pcm"
let file: fs.File = fs.openSync(path, fs.OpenMode.READ_ONLY)
let bufferSize = 0
/**
 * 写入
 * @param data
 */
let writeCallback: audio.AudioRendererWriteDataCallback = (data: ArrayBuffer) => {
  try {
    fs.readSync(file.fd, data, {
      offset: bufferSize,
      length: data.byteLength
    })
    bufferSize += data.byteLength
    return audio.AudioDataCallbackResult.VALID
  } catch (error) {
    console.error('Error reading file:', error);
    // API version 11 不支持返回回调结果，从 API version 12 开始支持返回回调结果
    return audio.AudioDataCallbackResult.INVALID;
  }
}

/**
 * 终端回调
 */
let interruptCallback = (event: audio.InterruptEvent) => {
  console.info(`InterruptEvent#eventType: ${event.eventType}`)
  console.info(`InterruptEvent#forceType: ${event.forceType}`)
  console.info(`InterruptEvent#hintType: ${event.hintType}`)
}

/**
 * 状态监听
 * @param state
 */
let stateCallback = (state: audio.AudioState) => {
  console.info(`AudioState: ${state.valueOf()}`)
}

export function init() {
  audio.createAudioRenderer(audioRendererOptions, (err, renderer) => {
    if (!err) {
      audioRenderer = renderer
      //读取数据
      audioRenderer.on('writeData', writeCallback);
      //焦点中断
      audioRenderer.on('audioInterrupt', interruptCallback);
      //状态更新
      audioRenderer.on('stateChange', stateCallback)
    }
  })
}

/**
 * 开始
 */
export function start() {
  let state = audioRenderer.state.valueOf()
  let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
  if (stateGroup.indexOf(state) === -1) {
    console.error('start failed');
    return
  }

  audioRenderer.start((err) => {
    if (err) {
      console.error('Renderer start failed.');
    } else {
      console.info('Renderer start success.');
    }
  })
}

/**
 * 暂停
 */
export function pause() {
  let state = audioRenderer.state.valueOf()
  if (state !== audio.AudioState.STATE_RUNNING) {
    console.error('pause failed');
    return
  }

  audioRenderer.pause((err) => {
    if (err) {
      console.error('Renderer pause failed.');
    } else {
      console.info('Renderer pause success.');
    }
  })
}

/**
 * 停止
 */
export function stop() {
  let state = audioRenderer.state.valueOf()
  if (state !== audio.AudioState.STATE_RUNNING && state !== audio.AudioState.STATE_PAUSED) {
    console.error('stop failed');
    return
  }

  audioRenderer.stop((err) => {
    if (err) {
      console.error('Renderer stop failed.');
    } else {
      console.info('Renderer stop success.');
    }
  })
}

/**
 * 释放
 */
export function release() {
  let state = audioRenderer.state.valueOf()
  if (state === audio.AudioState.STATE_RELEASED) {
    console.error('release failed');
    return
  }

  audioRenderer.release((err) => {
    if (err) {
      console.error('Renderer release failed.');
    } else {
      console.info('Renderer release success.');
    }
  })
}