/**
 * AI请求Bean
 */
export interface AIRequestBean {
  model: string,
  messages: Array<MessageBean>,

  //是否流式
  stream: boolean,
  stream_options: StreamOptions,
  modalities?: Array<string>,
  translation_options?: TranslationOptions
}

/**
 * 是否输出token
 */
export interface StreamOptions {
  include_usage: boolean
}

//翻译
export interface TranslationOptions {
  source_lang: string,
  target_lang: string
}

/**
 * MessageBeanContent用于视频、语音、图片
 */
export interface MessageBean {
  role: string,
  content: string | Array<MessageBeanContent>
}

export interface MessageBeanContent {
  type: string,
  text?: string,
  image_url?: ImageUrlContent,
  video_url?: ImageUrlContent,
  input_audio?: AudioUrlContent,
}

export interface ImageUrlContent {
  url: string
}

export interface AudioUrlContent {
  data: string,
  format: string
}