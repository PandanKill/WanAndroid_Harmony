import { preferences } from "@kit.ArkData"
import { Context } from "@kit.AbilityKit"
import { PreferenceKey } from "../constants/PreferenceKey"
import { User } from "../bean/LoginResponse"
import { JSON } from "@kit.ArkTS"

export default class Preference {
  private static instance: Preference
  private preferences: preferences.Preferences

  private constructor(context: Context) {
    this.preferences = preferences.getPreferencesSync(context, {
      name: PreferenceKey.FILE_WANANDROID_STORE
    })
  }

  static get(context: Context): Preference {
    if (Preference.instance === undefined) {
      Preference.instance = new Preference(context)
    }
    return Preference.instance
  }

  getUser(): User | undefined {
    const json = this.preferences.getSync(PreferenceKey.KEY_USER_INFO, "") as string;
    if (json) {
      const user: User = JSON.parse(json) as User
      return user;
    } else {
      return undefined;
    }
  }

  putUser(user?: User) {
    if (user) {
      this.preferences.putSync(PreferenceKey.KEY_USER_INFO, JSON.stringify(user))
    } else {
      this.preferences.deleteSync(PreferenceKey.KEY_USER_INFO)
    }
    this.preferences.flush()
  }

  getSearchHistory(): string {
    return this.preferences.getSync(PreferenceKey.PREFERENCE_KET_HISTORY, "") as string
  }

  putSearchHistory(history: string[]) {
    this.preferences.put(PreferenceKey.PREFERENCE_KET_HISTORY, JSON.stringify(history))
    this.preferences.flush()
  }
}