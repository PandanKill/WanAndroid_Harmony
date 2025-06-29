import { ChatPopupItem } from "../bean/ChatPopupItem";
import { Message } from "../pages/ChatPage";
import { pasteboard } from "@kit.BasicServicesKit";
import { common, Want } from "@kit.AbilityKit";
import speechRecognizerUtil from "../utils/SpeechRecognizerUtil";
import { CommonAiRequestUtil } from "../utils/CommonAiRequestUtil";
import { JSON } from "@kit.ArkTS";
import { fileToBase64 } from "../utils/FileUtil";
import { AISpeakBean } from "../bean/AIResponseBean";
import databaseUtil from "../utils/DatabaseUtil";

/**
 * 聊天 Item 点击
 */
@Observed
class PopupItemClickManager {
  /**
   * 使用回调可以
   * 或者使用 state 监听状态变化，然后 watch 处理
   */
  //引用
  onReferListener: (refItem: Message, refType: number) => void = (refItem, refType) => {
  }
  //删除
  onDeleteListener: (deleteItem: Message) => void = (deleteItem) => {

  }
  //重发
  onResendListener: (deleteItem: Message) => void = (deleteItem) => {

  }
  //转文字
  onTranToText: (item: Message) => void = (item) => {
  }
  //文字提取
  onPicToText: (item: Message) => void = (item) => {
  }

  /**
   * 点击Item
   * @param item
   */
  onClickItem(item: ChatPopupItem, message: Message) {
    switch (item.itemId) {
      case 1:
        //删除
        this.onDeleteListener(message)
        break
      case 2:
      case 3:
      case 5:
      case 6:
      case 8:
      case 14:
        //图片推理
        this.onReferListener(message, item.itemId)
        // this.onPicReasoning(message)
        //图片理解
        // this.onPicFollow(message)
        //视频理解
        // this.onVideoFollow(message)
        //视频推理
        // this.onVideoReasoning(message)
        //语音理解
        // this.onAudioFollow(message)
        //引用
        // this.onReferListener(message, item.itemId)
        break
      case 4:
        //文字提取
        // this.getTextForPic(message)
        this.onPicToText(message)
        break
      case 9:
        //转文字
        // this.recognizerData(message)
        this.onTranToText(message)
        break
      case 10:
        //语音整理
        break
      case 11:
        //翻译
        this.translateData(message)
        break
      case 12:
        this.searchData(message.text)
        break
      case 13:
        //复制
        this.savePasteboardData(message.text)
        break
      case 15:
        //重发
        this.onResendListener(message)
        break
    }
  }

  async onAudioFollow(message: Message) {
    let base64Url = await fileToBase64(message.audioUri ?? "")
    const client = new CommonAiRequestUtil({
      model: "qwen-omni-turbo",
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d"
    })

    client.sendStreamRequest(client.getAudioJsonContent("input_audio", `data:audio/wav;base64,${base64Url}`, "pcm",
      "这段音频在说什么"), {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        console.info(`onAudioFollow data: ${JSON.stringify(aiSpeakBean)}`)
      },
      onComplete: () => {
        console.info(`translate data: onComplete`)
      },
      onError: (err) => {
        console.info(`translate data: onError`)
      }
    })
  }

  /**
   * 视频推理
   * @param message
   */
  async onVideoReasoning(message: Message) {
    let base64Url = await fileToBase64(message.videoUri ?? "")
    const client = new CommonAiRequestUtil({
      model: "qvq-max",
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d"
    })

    client.sendStreamRequest(client.getPicReasoningJsonContent("video_url", `data:video/mp4;base64,${base64Url}`,
      "这是视频的开头部分，请分析并猜测该视频在讲解什么知识。"), {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        console.info(`onVideoReasoning data: ${JSON.stringify(aiSpeakBean)}`)
      },
      onComplete: () => {
        console.info(`translate data: onComplete`)
      },
      onError: (err) => {
        console.info(`translate data: onError`)
      }
    })
  }

  /**
   * 视频理解
   * @param message
   */
  async onVideoFollow(message: Message) {
    let base64Url = await fileToBase64(message.videoUri ?? "")
    //获取到图片信息,全模态
    let fileAi = new CommonAiRequestUtil({
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d",
      model: 'qwen-omni-turbo'
    })

    fileAi.sendStreamRequest(fileAi.getFileJsonContent("video_url", `data:video/mp4;base64,${base64Url}`,
      "视频的内容是什么"), {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        //加载成功
        console.info(`onVideoFollow data: ${JSON.stringify(aiSpeakBean)}`)
        // receiverMessage.messageStatus = 1
        // let ch = aiSpeakBean.choices
        // if (ch !== undefined) {
        //   let delta = ch[0]
        //   if (delta && delta.delta) {
        //     if (delta.delta.reasoning_content) {
        //       let text = receiverMessage.text
        //       let newText = text + delta.delta.reasoning_content
        //       receiverMessage.text = newText
        //     }
        //     if (delta.delta.content) {
        //       let text = receiverMessage.text
        //       let newText = text + delta.delta.content
        //       receiverMessage.text = newText
        //     }
        //   }
        // }
      },
      onError: (err) => {
        // receiverMessage.messageStatus = 2
        // receiverMessage.errorMessage = err.message
      },
      onComplete: () => {

      }
    })
  }

  /**
   * 文字提取
   * @param message
   */
  async getTextForPic(message: Message) {
    const client = new CommonAiRequestUtil({
      model: "qwen-vl-ocr",
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d"
    })
    let base64Url = await fileToBase64(message.imageUri ?? "")

    client.sendStreamRequest(client.getPicForPicJsonContent(`data:image/png;base64,${base64Url}`,
      "Read all the text in the image.?"), {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        console.info(`getTextForPic data: ${JSON.stringify(aiSpeakBean)}`)
      },
      onComplete: () => {
        console.info(`translate data: onComplete`)
      },
      onError: (err) => {
        console.info(`translate data: onError`)
      }
    })
  }

  /**
   * 图片理解
   * @param message
   */
  async onPicFollow(message: Message) {
    let base64Url = await fileToBase64(message.imageUri ?? "")
    //获取到图片信息,全模态
    let fileAi = new CommonAiRequestUtil({
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d",
      model: 'qwen-omni-turbo'
    })

    fileAi.sendStreamRequest(fileAi.getFileJsonContent("image_url", `data:image/png;base64,${base64Url}`,
      "图中描绘的是什么景象？"), {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        //加载成功
        console.info(`onPicFollow data: ${JSON.stringify(aiSpeakBean)}`)

        // receiverMessage.messageStatus = 1
        // let ch = aiSpeakBean.choices
        // if (ch !== undefined) {
        //   let delta = ch[0]
        //   if (delta && delta.delta) {
        //     if (delta.delta.reasoning_content) {
        //       let text = receiverMessage.text
        //       let newText = text + delta.delta.reasoning_content
        //       receiverMessage.text = newText
        //     }
        //     if (delta.delta.content) {
        //       let text = receiverMessage.text
        //       let newText = text + delta.delta.content
        //       receiverMessage.text = newText
        //     }
        //   }
        // }
      },
      onError: (err) => {
        // receiverMessage.messageStatus = 2
        // receiverMessage.errorMessage = err.message
      },
      onComplete: () => {

      }
    })
  }

  /**
   * 图片推理
   * @param message
   */
  async onPicReasoning(message: Message) {
    let base64Url = await fileToBase64(message.imageUri ?? "")
    const client = new CommonAiRequestUtil({
      model: "qvq-max",
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d"
    })

    client.sendStreamRequest(client.getPicReasoningJsonContent("image_url", `data:image/png;base64,${base64Url}`,
      "这道题怎么解答？"), {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        console.info(`onPicReasoning data: ${JSON.stringify(aiSpeakBean)}`)
      },
      onComplete: () => {
        console.info(`translate data: onComplete`)
      },
      onError: (err) => {
        console.info(`translate data: onError`)
      }
    })
  }

  recognizerData(message: Message) {
    // speechRecognizerUtil.startSpeechEngine({}, message.audioUri)
  }

  /**
   * 翻译 -->中文
   * @param message
   */
  translateData(message: Message) {
    //显示翻译内容
    console.info(`translate data: ${JSON.stringify(message)}`)
    message.translateEnable = true
    message.translateLoading = true
    const client = new CommonAiRequestUtil({
      model: "qwen-mt-turbo",
      endpoint: 'https://dashscope.aliyuncs.com',
      api_key: "sk-c1d2d4ae26e44c61b098a719f98bc40d"
    })

    client.sendStreamRequest(client.getTranslateJsonContent(message.text), {
      onDataReceived: (aiSpeakBean: AISpeakBean) => {
        message.translateLoading = false
        console.info(`translate data: ${JSON.stringify(aiSpeakBean)}`)
        let ch = aiSpeakBean.choices
        if (ch !== undefined) {
          let delta = ch[0]
          if (delta && delta.delta) {
            if (delta.delta.content) {
              message.translateText = delta.delta.content
            }
          }
        }
      },
      onComplete: () => {
        console.info(`translate data: onComplete`)
        // databaseUtil.updateTranslate(message)
      },
      onError: (err) => {
        console.info(`translate data: onError`)
      }
    })
  }

  /**
   * 网页搜索
   * @param text
   */
  searchData(searchText: string) {
    // URL 编码文字（处理空格和特殊字符）
    let encodedText = encodeURIComponent(searchText);

    // 选择搜索引擎的 URL 格式（示例使用 Google）
    let searchUrl = `https://www.baidu.com/s?wd=${encodedText}`;
    let want: Want = {
      action: "ohos.want.action.viewData",
      entities: ['entity.system.browsable'],
      uri: searchUrl
    };

    (getContext(this) as common.UIAbilityContext).startAbility(want)
  }

  /**
   * 复制
   * @param text
   */
  async savePasteboardData(text: string) {
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    let systemPasteboard = pasteboard.getSystemPasteboard()
    await systemPasteboard.setData(pasteData)
  }
}

let itemClickManager: PopupItemClickManager = new PopupItemClickManager();

//单利
export default itemClickManager as PopupItemClickManager