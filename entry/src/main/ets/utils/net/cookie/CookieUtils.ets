import Cookie from "./Cookie";
import uri from "@ohos.uri";

export default class CookieUtils {
  /**
   * * httpRequest 返回的 cookie 格式：
   * ```
   * #HttpOnly_www.wanandroid.com  FALSE  /  TRUE  0  JSESSIONID  564CB756D6C2F19456141DA377A0D692
   * www.wanandroid.com  FALSE  /  FALSE  1705495544  loginUserName  chaywong
   * www.wanandroid.com  FALSE  /  FALSE  1705495544  token_pass  d4fb1b1219a552003c5ec2e93221b0b0
   * .wanandroid.com  TRUE  /  FALSE  1705495544  loginUserName_wanandroid_com  chaywong
   * .wanandroid.com  TRUE  /  FALSE  1705495544  token_pass_wanandroid_com  d4fb1b1219a552003c5ec2e93221b0b0
   * ```
   * cookieStr--> Cookie[]
   * @param cookieString
   * @returns
   */
  static parseHttpRequestCookies(cookieString: string): Cookie[] {
    if (!cookieString) {
      return []
    }

    console.info(`parseHttpRequestCookies: ${cookieString}`)

    const cookies: Cookie[] = []
    //cookie 每行
    const lines = cookieString.split("\r\n")
    lines.forEach((line) => {
      const attrs = line.split("\t")
      if (attrs.length !== 7 || !attrs[0]) {
        return
      }

      let domain = attrs[0]
      let httpOnly = false
      if (domain.startsWith("#HttpOnly_")) {
        domain = domain.substring("#HttpOnly_".length)
        httpOnly = true
      }

      cookies.push({
        domain: domain,
        path: attrs[2],
        expiresAt: parseInt(attrs[4]),
        name: attrs[5],
        value: attrs[6],
        httpOnly: httpOnly,
        persistent: true
      })
    })

    return cookies
  }


  static cookieHeader(cookies: Cookie[]): string | undefined {
    let str = "";
    cookies.forEach((cookie, index) => {
      if (index > 0) {
        str += "; ";
      }
      str += cookie.name + "=" + cookie.value;
    });
    return str;
  }

  /**
   * cookie 是否匹配 url
   * @param currentCookie
   * @param url
   */
  static matches(currentCookie: Cookie, url: uri.URI) {
    const domainMatch = CookieUtils.domainMatch(url.host, currentCookie.domain)
    if (!domainMatch) {
      return false
    }
    if (!CookieUtils.patchMatch(url, currentCookie.path)) {
      return false
    }
    return true
  }

  static patchMatch(url: uri.URI, path: string): boolean {
    const urlPath = url.path
    if (urlPath === path) {
      return true
    }

    if (urlPath.startsWith(path)) {
      if (path.endsWith("/")) {
        return true
      }
      if (urlPath[path.length] === "/") {
        return true
      }
    }
    return false
  }

  static domainMatch(urlHost: string, domain: string) {
    if (urlHost === domain) {
      return true
    }

    return urlHost.endsWith(domain) && urlHost[urlHost.length - domain.length - 1] === "-"
  }

  static createCookieKey(cookie: Cookie): string {
    return `
    https: //${cookie.domain}${cookie.path}|${cookie.name}`
  }


  static fromJson(json: string): Cookie | undefined {
    if (json.length === 0) {
      return undefined;
    }
    const temp: Cookie | undefined = JSON.parse(json);
    return temp;
  }

  /**
   * 是否过期
   * @param cookie
   * @returns
   */
  static isExpired(cookie: Cookie): boolean {
    const nowTime = Date.now() / 1000;
    return cookie.expiresAt < nowTime;
  }
}