export interface AIRequestBean {
  model: string,
  messages: Array<MessageBean>,
  stream: boolean,
  stream_options: StreamOptions
  // input: InputBean,
  // parameters: ParametersBean
}

export interface StreamOptions {
  include_usage: boolean
}

export interface InputBean {
  messages: Array<MessageBean>
}

export interface MessageBean {
  role: string,
  content: string
}

export interface ParametersBean {
  result_format: string,
  incremental_output: boolean
}

export interface AISpeakBean {
  choices: Array<DeltaBean | null> | undefined,
  model: string,

  //speek id
  id: string
}

export interface DeltaBean {
  delta: DeltaContentBean
}

export interface DeltaContentBean {
  content: string | null,
  reasoning_content: string | null
}