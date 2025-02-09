export interface ResponseBean<T> {
  data: T
  errorCode: number
  errorMsg?: string
}