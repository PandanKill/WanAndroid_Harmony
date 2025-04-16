import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AISpeakBean } from './TextAiRequestUtil';
import util from '@ohos.util';

/**
 * Ai Request Config
 */
interface StreamRequestConfig {
  //模型域名
  endpoint: string
  //api key
  api_key: string
  //模型类型
  model: string
  //描述信息
  desText: string
}

interface MessageBean {
  role: string,
  content: Array<MessageBeanContent>
}

interface MessageBeanContent {
  type: string,
  text: string | null,
  image_url: ImageUrlContent | null,
  video_url: ImageUrlContent | null
}

interface ImageUrlContent {
  url: string
}

interface StreamOptions {
  include_usage: boolean
}

interface AIRequestBean {
  model: string,
  messages: Array<MessageBean>,
  stream: boolean,
  stream_options: StreamOptions,
  modalities: Array<string>
}


/**
 * 数据回调
 */
interface StreamResponseCallbacks {
  onDataReceived: (data: AISpeakBean) => void; // 收到数据块回调
  onError: (error: Error) => void; // 错误回调
  onComplete: () => void; // 流式结束回调
}

export class FileAIRequestUtil {
  private config: StreamRequestConfig

  constructor(config: StreamRequestConfig) {
    this.config = config
  }

  async sendStreamRequest(urlType: string, baseUri: string, callbacks: StreamResponseCallbacks) {
    const httpSession = http.createHttp()
    try {
      const url = `${this.config.endpoint}/compatible-mode/v1/chat/completions`
      let systemMessage: MessageBeanContent = {
        type: "text",
        text: "You are a helpful assistant.",
        image_url: null,
        video_url: null
      }
      let bean1: MessageBean = {
        role: "system",
        content: [systemMessage]
      }

      let userMessage1: MessageBeanContent
      if (urlType === "image_url") {
        userMessage1 = {
          type: urlType,
          image_url: { "url": baseUri },
          text: null,
          video_url: null
        }
      } else {
        userMessage1 = {
          type: urlType,
          image_url: null,
          text: null,
          video_url: { "url": baseUri }
        }
      }

      let userMessage2: MessageBeanContent = {
        type: "text",
        image_url: null,
        text: this.config.desText,
        video_url: null
      }

      let bean2: MessageBean = {
        role: "user",
        content: [userMessage1, userMessage2]
      }

      let streamOption: StreamOptions = {
        include_usage: true
      }

      let requestBean: AIRequestBean = {
        model: this.config.model,
        messages: [bean1, bean2],
        stream: true,
        stream_options: streamOption,
        modalities: ['text']
      }

      hilog.info(0x00, "lgww", JSON.stringify(requestBean))

      const response = await httpSession.request(url, {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.STRING,
        header: {
          "Authorization": this.config.api_key,
          "Content-Type": "application/json",
          // "X-DashScope-SSE": "enable"
        },
        extraData: JSON.stringify(requestBean)
      })

      // 5. 检查 HTTP 状态码
      if (response.responseCode !== http.ResponseCode.OK) {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
      hilog.info(0x00, "lgww", response.result.toString())

      // 6. 处理流式响应（模拟分块读取）
      this.processStreamResponse(response.result as string, callbacks);

      // 4. 通知流式结束
      callbacks.onComplete();
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x00, "lgww", err.message)
      callbacks.onError(new Error(`请求失败: ${err.code} - ${err.message}`));
    } finally {
      httpSession.destroy()
    }
  }

  processStreamResponse(responseText: string, callbacks: StreamResponseCallbacks) {
    hilog.info(0x00, "lgww", responseText)
    let lines = responseText.split(/\r?\n/)

    lines.forEach((line, index) => {
      if (line.trim() === '') {
        return;
      }

      if (line.trim().includes('[DONE]')) {
        //结束
        hilog.info(0x00, "lgwwww", 'end')
        return
      }
      let content = line.split("data: ")
      let aiSpeakBean = JSON.parse(content[1]) as AISpeakBean
      callbacks.onDataReceived(aiSpeakBean)
    })
  }
}

/**
 * 流式返回
 */
export class FileAIStreamRequestUtil {
  private config: StreamRequestConfig

  constructor(config: StreamRequestConfig) {
    this.config = config
  }

  sendStreamRequest(urlType: string, baseUri: string, callback: StreamResponseCallbacks) {
    const httpSession = http.createHttp()
    try {
      const url = `${this.config.endpoint}/compatible-mode/v1/chat/completions`
      let systemMessage: MessageBeanContent = {
        type: "text",
        text: "You are a helpful assistant.",
        image_url: null,
        video_url: null
      }
      let bean1: MessageBean = {
        role: "system",
        content: [systemMessage]
      }

      let userMessage1: MessageBeanContent
      if (urlType === "image_url") {
        userMessage1 = {
          type: urlType,
          image_url: { "url": baseUri },
          text: null,
          video_url: null
        }
      } else {
        userMessage1 = {
          type: urlType,
          image_url: null,
          text: null,
          video_url: { "url": baseUri }
        }
      }

      let userMessage2: MessageBeanContent = {
        type: "text",
        image_url: null,
        text: this.config.desText,
        video_url: null
      }

      let bean2: MessageBean = {
        role: "user",
        content: [userMessage1, userMessage2]
      }

      let streamOption: StreamOptions = {
        include_usage: true
      }

      let requestBean: AIRequestBean = {
        model: this.config.model,
        messages: [bean1, bean2],
        stream: true,
        stream_options: streamOption,
        modalities: ['text']
      }

      httpSession.on('dataReceive', (data: ArrayBuffer) => {
        let uint8Array: Uint8Array = new Uint8Array(data, 0, data.byteLength)
        // 使用 TextDecoder 转换为字符串
        let decoder = new util.TextDecoder(); // 指定编码格式（如 utf-8、gbk 等）
        let str = decoder.decodeToString(uint8Array);
        console.info('dataReceive str: ' + str);
        let lines = str.split(/\r?\n/)

        lines.forEach((line, index) => {
          if (line.trim() === '') {
            return;
          }

          if (line.trim().includes('[DONE]')) {
            //结束
            hilog.info(0x00, "lgwwww", 'end')
            return
          }
          let content = line.split("data: ")
          let aiSpeakBean = JSON.parse(content[1]) as AISpeakBean
          callback.onDataReceived(aiSpeakBean)
        })
      })

      // 用于订阅HTTP流式响应数据接收完毕事件
      httpSession.on('dataEnd', () => {
        console.info('No more data in response, data receive end');
        callback.onComplete()
      });

      let streamInfo: http.HttpRequestOptions = {
        method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
        // 开发者根据自身业务需要添加header字段
        header: {
          "Authorization": `Bearer ${this.config.api_key}`,
          "Content-Type": "application/json"
        },
        // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
        extraData: JSON.stringify(requestBean),
        expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
        usingCache: true, // 可选，默认为true
        priority: 1, // 可选，默认为1
        connectTimeout: 60000, // 可选，默认为60000ms
        readTimeout: 60000, // 可选，默认为60000ms。若传输的数据较大，需要较长的时间，建议增大该参数以保证数据传输正常终止
        usingProtocol: http.HttpProtocol.HTTP1_1 // 可选，协议类型默认值由系统自动指定
      }

      //流式请求
      httpSession.requestInStream(url, streamInfo).then((data: number) => {
        console.info("requestInStream OK!");
        console.info('ResponseCode :' + JSON.stringify(data));
        // 取消订阅HTTP流式响应数据接收事件
        httpSession.off('dataReceive');
        // 取消订阅HTTP流式响应数据接收完毕事件
        httpSession.off('dataEnd');
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpSession.destroy();
      }).catch((err: Error) => {
        console.info("requestInStream ERROR : err = " + JSON.stringify(err));
      });

    } catch (err) {
      let e = err as BusinessError
      callback.onError(new Error(`请求失败: ${e.code} - ${e.message}`))
    }
  }
}