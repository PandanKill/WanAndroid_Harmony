import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AISpeakBean } from './TextAiRequestUtil';

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
  image_url: ImageUrlContent | null
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

  async sendPicStreamRequest(baseUri: string, callbacks: StreamResponseCallbacks) {
    const httpSession = http.createHttp()
    try {
      const url = `${this.config.endpoint}/compatible-mode/v1/chat/completions`
      let systemMessage: MessageBeanContent = {
        type: "text",
        text: "You are a helpful assistant.",
        image_url: null
      }
      let bean1: MessageBean = {
        role: "system",
        content: [systemMessage]
      }

      let userMessage1: MessageBeanContent = {
        type: "image_url",
        image_url: { "url": baseUri },
        text: null
      }

      let userMessage2: MessageBeanContent = {
        type: "text",
        image_url: null,
        text: this.config.desText
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