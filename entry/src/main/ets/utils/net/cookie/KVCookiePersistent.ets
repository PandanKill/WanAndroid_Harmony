import Cookie from "./Cookie";
import CookiePersistent from "./CookiePersistent";
import { preferences } from "@kit.ArkData";
import { PreferenceKey } from "../../../constants/PreferenceKey";
import CookieUtils from "./CookieUtils";

/**
 * 持久化存储 cookies
 */
export default class KVCookiePersistent implements CookiePersistent {
  private preferences: preferences.Preferences

  constructor(context: Context) {
    this.preferences = preferences.getPreferencesSync(context, {
      name: PreferenceKey.FILE_WANANDROID_STORE
    })
  }

  loadAll(): Cookie[] {
    const cookies: Cookie[] = []
    const keys = this.preferences.getSync(PreferenceKey.KEY_COOKIE_KEYS, []) as string[]
    keys.forEach((key) => {
      const value = this.preferences.getSync(key, "") as string
      if (value.length > 0) {
        const cookie = CookieUtils.fromJson(value)
        if (cookie) {
          cookies.push(cookie)
        }
      }
    })
    return cookies
  }

  saveAll(cookies: Cookie[]): void {
    cookies.forEach((cookie) => {
      this.preferences.putSync(CookieUtils.createCookieKey(cookie), JSON.stringify(cookie, undefined, undefined))
    })

    const keys = this.preferences.getSync(PreferenceKey.KEY_COOKIE_KEYS, []) as string[]
    cookies.forEach((cookie) => {
      const key = CookieUtils.createCookieKey(cookie)
      if (keys.indexOf(key) < 0) {
        keys.push(key)
      }
    })
    this.preferences.putSync(PreferenceKey.KEY_COOKIE_KEYS, keys)
    this.preferences.flush()
  }

  removeAll(cookies: Cookie[]): void {
    const keys = this.preferences.getSync(PreferenceKey.KEY_COOKIE_KEYS, []) as string[]
    cookies.forEach((cookie) => {
      const key = CookieUtils.createCookieKey(cookie)
      this.preferences.deleteSync(key)
      const index = keys.indexOf(key)
      if (index >= 0) {
        keys.splice(index, 1)
      }
    })
    this.preferences.putSync(PreferenceKey.KEY_COOKIE_KEYS, keys)
    this.preferences.flush()
  }

  clear(): void {
    this.preferences.clearSync()
    this.preferences.flush()
  }
}