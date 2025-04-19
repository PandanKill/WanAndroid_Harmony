/**
 * AI返回Bean
 */
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
 * 异常
 */
export interface ErrorBean {
  error: ErrorContentBean
}

export interface ErrorContentBean {
  message: string,
  type: string
}