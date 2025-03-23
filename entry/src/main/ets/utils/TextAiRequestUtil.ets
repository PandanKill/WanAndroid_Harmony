import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface AIRequestBean {
  model: string,
  messages: Array<MessageBean>,
  stream: boolean,
  stream_options: StreamOptions
}

interface StreamOptions {
  include_usage: boolean
}

interface MessageBean {
  role: string,
  content: string
}

export interface AISpeakBean {
  choices: Array<DeltaBean | null> | undefined,
  model: string,

  //speek id
  id: string
}

interface DeltaBean {
  delta: DeltaContentBean
}

interface DeltaContentBean {
  content: string | null,
  reasoning_content: string | null
}

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

export class ModelStudioStreamClient {
  private config: StreamRequestConfig

  constructor(config: StreamRequestConfig) {
    this.config = config
  }

  //请求
  async sendStreamRequest(content: string, callback: StreamResponseCallbacks) {
    const httpSession = http.createHttp()
    try {
      const url = `${this.config.endpoint}/compatible-mode/v1/chat/completions`
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
        stream_options: streamOption,
      }

      const response = await httpSession.request(url, {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.STRING,
        header: {
          "Authorization": `Bearer ${this.config.api_key}`,
          "Content-Type": "application/json",
          "X-DashScope-SSE": "enable"
        },
        extraData: JSON.stringify(requestBean)
      })

      // 5. 检查 HTTP 状态码
      if (response.responseCode !== http.ResponseCode.OK) {
        throw new Error(`HTTP Error: ${response.responseCode}`);
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
    hilog.info(0x00, "lgwwww", responseText)
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
      callback.onDataReceived(aiSpeakBean)
    })
  }
}