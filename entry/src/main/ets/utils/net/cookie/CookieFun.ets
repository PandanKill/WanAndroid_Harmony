import { uri } from "@kit.ArkTS";
import Cookie from "./Cookie";

export default interface CookieJar {
  saveFromResponse(url: uri.URI, cookies: Cookie[]): void

  loadForRequest(url: uri.URI): Cookie[]

  clear(): void
}