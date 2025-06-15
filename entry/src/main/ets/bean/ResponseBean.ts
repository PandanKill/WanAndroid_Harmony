export class ResponseBean<T> {
  data?: T = undefined
  errorCode: number = 0
  errorMsg: string = ""

  isSuccess(): boolean {
    return this.errorCode === 0
  }

  isSuccessWithData(): boolean {
    return this.errorCode === 0 && this.data !== undefined
  }

  getDataOrThrow(): T {
    return this.data!!
  }
}