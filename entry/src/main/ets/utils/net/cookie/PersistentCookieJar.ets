import Cookie from "./Cookie";
import CookieJar from "./CookieFun";
import uri from "@ohos.uri";
import { HashMap } from "@kit.ArkTS";
import CookiePersistent from "./CookiePersistent";
import KVCookiePersistent from "./KVCookiePersistent";
import CookieUtils from "./CookieUtils";
import { it } from "@ohos/hypium";

export default class PersistentCookieJar implements CookieJar {
  private cache: HashMap<string, Cookie> = new HashMap()
  private persistent: CookiePersistent

  constructor(context: Context) {
    this.persistent = new KVCookiePersistent(context)
    const cookies = this.persistent.loadAll()
    cookies.forEach((cookie) => {
      this.cache.set(CookieUtils.createCookieKey(cookie), cookie)
    })
  }

  saveFromResponse(url: uri.URI, cookies: Cookie[]): void {
    cookies.forEach((cookie) => {
      this.cache.set(CookieUtils.createCookieKey(cookie), cookie)
    })

    this.persistent.saveAll(PersistentCookieJar.filterPersistentCookies(cookies))
  }

  private static filterPersistentCookies(cookies: Cookie[]): Cookie[] {
    return cookies.filter((item) => {
      return item.persistent;
    })
  }

  loadForRequest(url: uri.URI): Cookie[] {
    const cookiesToRemove: Cookie[] = []
    const validCookies: Cookie[] = []

    const iterator: IterableIterator<Cookie> = this.cache.values()
    let result = iterator.next()
    while (!result.done) {
      const currentCookie: Cookie = result.value
      if (CookieUtils.isExpired(currentCookie)) {
        cookiesToRemove.push(currentCookie)
      } else if (CookieUtils.matches(currentCookie, url)) {
        validCookies.push(currentCookie)
      }
      result = iterator.next()
    }

    cookiesToRemove.forEach((item) => {
      this.cache.remove(CookieUtils.createCookieKey(item))
    })

    this.persistent.removeAll(cookiesToRemove)

    return validCookies
  }

  clear(): void {
    this.cache.clear()
    this.persistent.clear()
  }
}