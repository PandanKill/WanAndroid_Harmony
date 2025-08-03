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
import { ArticlesList } from '../../bean/NavContentBean'
import { ProjectTabBean } from '../../bean/ProjectTabBean'
import { BannerBean } from '../../bean/BannerBean'
import { TreeListBean } from '../../bean/TreeContentBean'
import { HotKeyBean } from '../../bean/HotKeyBean'
import { CoinRankBean, MineCoinBean } from '../../bean/CoinBean'
import { ArticleBean, ArticleListBean, ShareArticleListBean, TabDetailBean } from '../../bean/ArticleBean'

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

  /**
   * 获取问答
   * @returns
   */
  async getWendaList(pageNum: number): Promise<ResponseBean<ArticleListBean>> {
    return requestSync(`/wenda/list/${pageNum}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取微信公众号
   * @returns
   */
  async getWXArticle(): Promise<ResponseBean<TabDetailBean[]>> {
    return requestSync(requestPath.PATH_WXARTICLE_CHAPTERS, http.RequestMethod.GET)
  }

  /**
   * 获取置顶
   * @returns
   */
  async getTopArt(): Promise<ResponseBean<ArticleBean[]>> {
    return requestSync(requestPath.PATH_TOP, http.RequestMethod.GET)
  }

  /**
   * 获取文章
   * @returns
   */
  async getArticleList(page: number): Promise<ResponseBean<ArticleListBean>> {
    return requestSync(`/article/list/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取导航数据
   * @returns
   */
  async getNavList(): Promise<ResponseBean<ArticlesList[]>> {
    return requestSync(requestPath.PATH_NAV, http.RequestMethod.GET)
  }

  /**
   * 获取项目树
   * @returns
   */
  async getProjectTree(): Promise<ResponseBean<ProjectTabBean[]>> {
    return requestSync(requestPath.PATH_PROJECT_TREE, http.RequestMethod.GET)
  }

  /**
   * 获取项目列表
   * @returns
   */
  async getProjectList(currentIndex: number, contentId: number): Promise<ResponseBean<ArticleListBean>> {
    return requestSync(`/project/list/${currentIndex}/json?cid=${contentId}`,
      http.RequestMethod.GET)
  }

  /**
   * 获取用户文章
   * @returns
   */
  async getUserArticle(currentIndex: number): Promise<ResponseBean<ArticleListBean>> {
    return requestSync(`/user_article/list/${currentIndex}/json`,
      http.RequestMethod.GET)
  }

  /**
   * 获取用户文章
   * @returns
   */
  async getSwiperArt(): Promise<ResponseBean<BannerBean[]>> {
    return requestSync(requestPath.PATH_HOME_BANNER,
      http.RequestMethod.GET)
  }

  /**
   * 获取用户文章
   * @returns
   */
  async getCommonPath(path: string): Promise<ResponseBean<ArticleListBean>> {
    return requestSync(path, http.RequestMethod.GET)
  }

  /**
   * 获取用户文章
   * @returns
   */
  async getTiXiData(): Promise<ResponseBean<TreeListBean[]>> {
    return requestSync(requestPath.PATH_TREE, http.RequestMethod.GET)
  }

  /**
   * 获取用户文章
   * @returns
   */
  async getHotKey(): Promise<ResponseBean<HotKeyBean[]>> {
    return requestSync(requestPath.PATH_HOTKEY_JSON, http.RequestMethod.GET)
  }

  /**
   * 获取
   * @returns
   */
  async getMineCoin(page: number): Promise<ResponseBean<MineCoinBean>> {
    return requestSync(`/lg/coin/list/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取积分排名
   * @returns
   */
  async getCoinRank(page: number): Promise<ResponseBean<CoinRankBean>> {
    return requestSync(`/coin/rank/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取积分排名
   * @returns
   */
  async getMineCollect(page: number): Promise<ResponseBean<ArticleListBean>> {
    return requestSync(`/lg/collect/list/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 搜索
   * @param searchData
   * @param page
   */
  async search(searchData: string, page: number): Promise<ResponseBean<ArticleListBean>> {
    return requestSync(`/article/query/${page}/json?k=${encodeURIComponent(searchData)}`, http.RequestMethod.POST)
  }

  /**
   * 收藏站内文章
   * @param searchData
   * @param page
   */
  async collectArticle(id: number): Promise<ResponseBean<undefined>> {
    return requestSync(`/lg/collect/${id}/json`, http.RequestMethod.POST)
  }

  /**
   * 取消收藏
   * @param searchData
   * @param page
   */
  async unCollectArticle(id: number): Promise<ResponseBean<undefined>> {
    return requestSync(`/lg/uncollect_originId/${id}/json`, http.RequestMethod.POST)
  }

  /**
   * 获取分享文章列表
   * @param page
   * @returns
   */
  async getShareArticle(page: number): Promise<ResponseBean<ShareArticleListBean>> {
    return requestSync(`/user/lg/private_articles/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取分享文章列表
   * @param page
   * @returns
   */
  async deleteShareArticle(id: number): Promise<ResponseBean<undefined>> {
    return requestSync(`/lg/user_article/delete/${id}/json`, http.RequestMethod.POST)
  }
}

class Headers {
  contentType?: string;
  cookie?: string;
}