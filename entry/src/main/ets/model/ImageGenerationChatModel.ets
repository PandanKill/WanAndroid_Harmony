/**
 * ImageGeneration 聊天Bean
 */

export default class ImageGenerationChatModel {
  //消息类型：发送方 0，接收方 1
  messageOwner: number = 0
  //消息类型：文字 0， 图片 1
  messageType: number = 0
  //消息内容
  messageContent: string = ''
}
