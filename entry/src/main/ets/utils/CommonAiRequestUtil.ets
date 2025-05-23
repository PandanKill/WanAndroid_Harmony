/**
 * 通用网络请求
 */

import { AISpeakBean, ErrorBean } from "../bean/AIResponseBean";
import { http } from "@kit.NetworkKit";
import { BusinessError } from "@kit.BasicServicesKit";
import util from "@ohos.util";
import { AIRequestBean, MessageBean, MessageBeanContent, StreamOptions } from "../bean/AIRequestBean";
import { JSON } from "@kit.ArkTS";

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
}

/**
 * 数据回调
 */
interface StreamResponseCallbacks {
  onDataReceived: (data: AISpeakBean) => void; // 收到数据块回调
  onError: (error: Error) => void; // 错误回调
  onComplete: () => void; // 流式结束回调
}


export class CommonAiRequestUtil {
  private config: StreamRequestConfig

  constructor(config: StreamRequestConfig) {
    this.config = config
  }

  /**
   * 非流式请求
   * @param jsonContent
   * @param callback
   */
  async sendOnceRequest(jsonContent: string, callback: StreamResponseCallbacks) {
    const httpSession = http.createHttp()
    try {
      const url = `${this.config.endpoint}/compatible-mode/v1/chat/completions`

      const response = await httpSession.request(url, {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.STRING,
        header: {
          "Authorization": `Bearer ${this.config.api_key}`,
          "Content-Type": "application/json",
          "X-DashScope-SSE": "enable"
        },
        extraData: jsonContent
      })

      // 5. 检查 HTTP 状态码
      if (response.responseCode !== http.ResponseCode.OK) {
        callback.onError(new Error(`code: ${response.responseCode}, result: ${response.result}`))
        return
      }

      // 6. 处理流式响应（模拟分块读取）
      this.processStreamResponse(response.result as string, callback);

      // 4. 通知流式结束
      callback.onComplete();
    } catch (error) {
      const err = error as BusinessError;
      callback.onError(new Error(`请求失败: ${err.code} - ${err.message}`));
    } finally {
      httpSession.destroy()
    }
  }

  /**
   * 处理数据
   * @param arg0
   * @param callback
   */
  processStreamResponse(responseText: string, callback: StreamResponseCallbacks) {
    let lines = responseText.split(/\r?\n/)

    lines.forEach((line, index) => {
      if (line.trim() === '') {
        return;
      }

      if (line.trim().includes('[DONE]')) {
        //结束
        console.info(`request end`)
        return
      }
      let content = line.split("data: ")
      let aiSpeakBean = JSON.parse(content[1]) as AISpeakBean
      callback.onDataReceived(aiSpeakBean)
    })
  }


  /**
   * 流式请求
   * @param content
   * @param callback
   */
  sendStreamRequest(jsonContent: string, callback: StreamResponseCallbacks) {
    const httpSession = http.createHttp()
    try {
      const url = `${this.config.endpoint}/compatible-mode/v1/chat/completions`

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
            console.info(`request stream end`)
            return
          }

          if (line.trim().includes("error")) {
            //异常
            let errorBean = JSON.parse(line) as ErrorBean
            callback.onError(new Error(errorBean.error.message))
            console.error(`request error`)
            return
          }

          if (line.trim().includes("data: ")) {
            let content = line.split("data: ")
            if (content.length > 1) {
              let aiSpeakBean = JSON.parse(content[1]) as AISpeakBean
              callback.onDataReceived(aiSpeakBean)
            }
          }
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
          "Content-Type": "application/json",
          "X-DashScope-SSE": "enable"
        },
        // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
        extraData: jsonContent,
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

  /**
   * 获取TextAI的json数据
   * @param content
   * @returns
   */
  getTextJsonContent(content: string): string {
    let bean: MessageBean = {
      role: "user",
      content: content
    }

    let streamOption: StreamOptions = {
      include_usage: true
    }

    let requestBean: AIRequestBean = {
      model: this.config.model,
      messages: [bean],
      stream: true,
      stream_options: streamOption
    }

    return JSON.stringify(requestBean)
  }

  /**
   * 获取文件 json数据
   * @param urlType
   * @param baseUri
   * @returns
   */
  getFileJsonContent(urlType: string, baseUri: string, desText: string): string {
    let systemMessage: MessageBeanContent = {
      type: "text",
      text: "You are a helpful assistant.",
    }
    let bean1: MessageBean = {
      role: "system",
      content: [systemMessage]
    }

    let userMessage1: MessageBeanContent
    if (urlType === "image_url") {
      userMessage1 = {
        type: urlType,
        image_url: { "url": baseUri }
      }
    } else {
      userMessage1 = {
        type: urlType,
        video_url: { "url": baseUri }
      }
    }

    let userMessage2: MessageBeanContent = {
      type: "text",
      text: desText
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

    return JSON.stringify(requestBean)
  }

  /**
   * 获取翻译数据 json
   * @returns
   */
  getTranslateJsonContent(text: string): string {
    let data: AIRequestBean = {
      model: this.config.model,
      messages: [
        {
          role: "user",
          content: text
        }
      ],
      stream: true,
      stream_options: {
        include_usage: true
      },
      translation_options: {
        source_lang: "auto",
        target_lang: "Chinese"
      }
    }
    return JSON.stringify(data)
  }

  /**
   * 获取文字提取的 json 数据
   * @param baseUri
   * @param desText
   * @returns
   */
  getPicForPicJsonContent(baseUri: string, desText: string): string {

    let userMessage1: MessageBeanContent
    userMessage1 = {
      type: "image_url",
      image_url: { "url": baseUri }
    }

    let userMessage2: MessageBeanContent = {
      type: "text",
      text: desText,
    }

    let bean1: MessageBean = {
      role: "user",
      content: [userMessage1, userMessage2]
    }

    let streamOption: StreamOptions = {
      include_usage: true
    }

    let requestBean: AIRequestBean = {
      model: this.config.model,
      messages: [bean1],
      stream: true,
      stream_options: streamOption,
      modalities: ['text']
    }

    return JSON.stringify(requestBean)
  }


  /**
   * 图片推理
   * @param urlType
   * @param baseUri
   * @returns
   */
  getPicReasoningJsonContent(urlType: string, baseUri: string, desText: string): string {
    let userMessage1: MessageBeanContent
    if (urlType === "image_url") {
      userMessage1 = {
        type: urlType,
        image_url: { "url": baseUri }
      }
    } else {
      userMessage1 = {
        type: urlType,
        video_url: { "url": baseUri }
      }
    }

    let userMessage2: MessageBeanContent = {
      type: "text",
      text: desText
    }

    let bean1: MessageBean = {
      role: "user",
      content: [userMessage1, userMessage2]
    }

    let streamOption: StreamOptions = {
      include_usage: true
    }

    let requestBean: AIRequestBean = {
      model: this.config.model,
      messages: [bean1],
      stream: true,
      stream_options: streamOption
    }

    return JSON.stringify(requestBean)
  }


  /**
   * 获取文件 json数据
   * @param urlType
   * @param baseUri
   * @returns
   */
  getAudioJsonContent(type:string, baseUri: string, format: string, desText: string): string {

    let userMessage1: MessageBeanContent = {
      type: type,
      input_audio: {
        data: baseUri,
        format: format
      }
    }

    let userMessage2: MessageBeanContent = {
      type: "text",
      text: desText
    }

    let bean1: MessageBean = {
      role: "user",
      content: [userMessage1, userMessage2]
    }

    let streamOption: StreamOptions = {
      include_usage: true
    }

    let requestBean: AIRequestBean = {
      model: this.config.model,
      messages: [bean1],
      stream: true,
      stream_options: streamOption,
      modalities: ['text']
    }

    return JSON.stringify(requestBean)
  }
}