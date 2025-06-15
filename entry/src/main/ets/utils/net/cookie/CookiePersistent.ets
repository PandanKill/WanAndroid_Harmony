import Cookie from "./Cookie";

export default interface CookiePersistent {
  loadAll(): Cookie[]

  saveAll(cookies: Cookie[]): void

  removeAll(cookies: Cookie[]): void

  clear(): void
}