export interface AIRequestBean {
  model: string,
  input: InputBean,
  parameters: ParametersBean
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