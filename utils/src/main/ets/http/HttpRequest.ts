import { rcp } from "@kit.RemoteCommunicationKit"
import { logger } from '../utils/Logger'

class HttpRequest {
  private baseUrl: string = "https://www.wanandroid.com"

  /**
   * post 请求
   * @param requestPath
   * @param jsonContent
   */
  async postRequest(requestPath: string, jsonContent: string): Promise<rcp.Response> {
    logger.info(`jsonContent ${jsonContent}`)
    let session = rcp.createSession()
    return session.post(this.baseUrl + requestPath, jsonContent)
  }

  /**
   * get 请求
   * @param requestPath
   * @returns
   */
  async getRequest(requestPath: string): Promise<rcp.Response> {
    let session = rcp.createSession()
    return session.get(this.baseUrl + requestPath)
  }
}

//单例
export const httpRequest = new HttpRequest()