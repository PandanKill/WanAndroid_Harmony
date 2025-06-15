import { User } from "../bean/LoginResponse"
import EntryContext from "../constants/EntryContext"
import { preferences } from "@kit.ArkData"
import { PreferenceKey } from "../constants/PreferenceKey"
import Preference from "../utils/Preference"
import Api from "../utils/net/Api"
import { router } from "@kit.ArkUI"

export class UserService {
  private static instance: UserService
  private user?: User
  private userObservers: ((user?: User) => void)[] = []

  static get(): UserService {
    if (UserService.instance === undefined) {
      UserService.instance = new UserService()
    }
    return UserService.instance
  }

  private constructor() {
    const context = EntryContext.getContext()
    const user = Preference.get(context).getUser()
    if (user) {
      this.user = user
      this.notifyObserver()
      this.updateUser().catch()
    }
  }

  getUser(): User | undefined {
    return this.user
  }

  setUser(user?: User) {
    this.user = user
    this.notifyObserver()
    const context = EntryContext.getContext()
    Preference.get(context).putUser(user)
  }

  async updateUser(): Promise<User> {
    if (this.isLogin()) {
      const res = await Api.get().getUserInfo()
      if (res.isSuccessWithData()) {
        const user = this.user!!
        user.coinCount = res.getDataOrThrow().coinCount
        user.level = res.getDataOrThrow().level
        user.rank = res.getDataOrThrow().rank
        this.setUser(user)
        return Promise.resolve(user)
      } else {
        return Promise.reject(res.errorMsg)
      }
    } else {
      return Promise.reject()
    }
  }

  isLogin(): boolean {
    if (this.user) {
      return true
    }
    return false
  }

  notifyObserver() {
    this.userObservers.forEach((observer) => {
      if (observer) {
        observer(this.user)
      }
    })
  }

  addUserObserver(observer: (user?: User) => void) {
    if (!this.userObservers.includes(observer)) {
      this.userObservers.push(observer);
    }
  }

  removeUserObserver(observer: (user?: User) => void) {
    const index = this.userObservers.indexOf(observer);
    if (index >= 0) {
      this.userObservers.splice(index, 1);
    }
  }

  clearUser() {
    this.setUser(undefined);
    Api.get().clearCookie();
  }

  checkLogin(onLogin?: () => void) {
    if (this.isLogin()) {
      if (onLogin) {
        onLogin()
      }
    } else {
      router.pushUrl({
        url: "pages/LoginPage"
      })
    }
  }
}