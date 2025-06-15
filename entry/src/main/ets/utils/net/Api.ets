import EntryContext from '../../constants/EntryContext'
import CookieJar from './cookie/CookieFun'
import PersistentCookieJar from './cookie/PersistentCookieJar'
import { JSON, uri } from '@kit.ArkTS'
import { request } from '@kit.BasicServicesKit'
import { http } from '@kit.NetworkKit'
import { ResponseBean } from '../../bean/ResponseBean'
import { requestPath } from 'utils'
import CookieUtils from './cookie/CookieUtils'
import { User } from '../../bean/LoginResponse'

const cookieJar: CookieJar = new PersistentCookieJar(EntryContext.getContext())

function parseUri(url: string): uri.URI {
  return new uri.URI(url)
}

async function requestSync<T>(path: string, method: http.RequestMethod, extraData?: object): Promise<ResponseBean<T>> {
  return new Promise<ResponseBean<T>>((resolve, reject) => {
    const headers = new Headers()
    const url = requestPath.baseUrl + path
    const uri = parseUri(url)
    const cookies = cookieJar.loadForRequest(uri)
    if (cookies.length > 0) {
      headers.cookie = CookieUtils.cookieHeader(cookies)
    }
    if (method === http.RequestMethod.POST) {
      headers.contentType = "application/x-www-form-urlencoded"
      if (!extraData) {
        //post 必须携带请求体
        extraData = new Object()
      }
    }

    const httpRequest = http.createHttp()
    console.info(`start request, path: ${path}, method: ${method}, extraData: ` +
    JSON.stringify(extraData, undefined, undefined))
    console.info(`header: ${JSON.stringify(headers)}`)

    httpRequest.request(url, {
      method: method,
      expectDataType: http.HttpDataType.OBJECT,
      header: headers,
      extraData: extraData
    }, (err, data) => {
      const res = new ResponseBean<T>()
      if (!err && data.responseCode === 200) {
        cookieJar.saveFromResponse(uri, CookieUtils.parseHttpRequestCookies(data.cookies))
        if (data.resultType === http.HttpDataType.STRING) {
          const result: ResponseBean<T> = JSON.parse(data.result as string) as ResponseBean<T>;
          res.errorCode = result.errorCode;
          res.errorMsg = result.errorMsg;
          res.data = result.data;
        } else if (data.resultType === http.HttpDataType.OBJECT) {
          const result = data.result as ResponseBean<T>;
          res.errorCode = result.errorCode;
          res.errorMsg = result.errorMsg;
          res.data = result.data;
        } else {
          res.errorCode = -1
          res.errorMsg = `UnSupport data type: ${data.resultType}`
        }
        console.info(`request success, path: ${path}, result: ${JSON.stringify(res, undefined, undefined)}`)
      } else {
        console.error(`request error, path: ${path}, error: ${JSON.stringify(err, undefined, undefined)}`)
        res.errorCode = data?.responseCode ?? -1
        res.errorMsg = err?.message ?? ""
      }
      resolve(res)
    })
  })
}

export default class Api {
  private static instance: Api

  private constructor() {
  }

  static get(): Api {
    if (Api.instance === undefined) {
      Api.instance = new Api()
    }
    return Api.instance
  }

  clearCookie() {
    cookieJar.clear()
  }

  /**
   * 登录
   * @param username
   * @param password
   * @returns
   */
  async login(username: string, password: string): Promise<ResponseBean<User>> {
    return requestSync(`/user/login?username=${username}&password=${password}`, http.RequestMethod.POST)
  }

  /**
   * 获取用户积分数据、排名
   */
  async getUserInfo(): Promise<ResponseBean<User>> {
    return requestSync("/lg/coin/userinfo/json", http.RequestMethod.GET)
  }

  /**
   * 登出
   * @returns
   */
  async logout(): Promise<ResponseBean<string>> {
    return requestSync(requestPath.PATH_LOGOUT, http.RequestMethod.GET)
  }
}

class Headers {
  contentType?: string;
  cookie?: string;
}