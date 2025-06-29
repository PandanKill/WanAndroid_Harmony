/**
 * 生物验证
 */
export class TrustedAuthManager {
  private static authManager: TrustedAuthManager

  private TrustedAuthManager() {

  }

  public static get(): TrustedAuthManager {
    if (TrustedAuthManager.authManager === undefined) {
      TrustedAuthManager.authManager = new TrustedAuthManager()
    }
    return TrustedAuthManager.authManager
  }
}