import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 校验权限是否获取
 * @param permission
 * @returns
 */
export async function checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
  let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED

  //获取应用程序的accessTokenId
  let tokenId: number = 0
  try {
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo
    tokenId = appInfo.accessTokenId
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
  }

  //校验应用是否申请过权限
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission)
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
  }

  return grantStatus
}

/**
 * 获取权限
 * @param permissions
 * @param context
 */
export function requestPermissionForUser(permissions: Array<Permissions>, context: common.UIAbilityContext,
  grantStat: () => void, deniedStat: () => void): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    let grantStatus: Array<number> = data.authResults
    let length: number = grantStatus.length
    for (let i = 0; i < length; i++) {
      console.info(`grantStatus[i]: ${grantStatus[i]}}`)
      if (grantStatus[i] === 0) {
        //用户授权成功
        console.info(`grantStatus success`)
      } else {
        //用户拒绝授权
        console.info(`grantStatus refuse`)
        requestPermissionForSetting(permissions, context, grantStat, deniedStat)
        return
      }
    }
    //授权成功
    grantStat()
  }).catch((err: BusinessError) => {
    console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}

/**
 * 二次引导
 * @param permissions
 * @param context
 */
function requestPermissionForSetting(permissions: Array<Permissions>, context: common.UIAbilityContext,
  grantStat: () => void, deniedStat: () => void): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
  atManager.requestPermissionOnSetting(context, permissions).then((data) => {
    let grantStatus: Array<number> = data
    let length: number = grantStatus.length
    for (let i = 0; i < length; i++) {
      console.info(`grantStatus[i]: ${grantStatus[i]}}`)
      if (grantStatus[i] === 0) {
        //用户授权成功
        console.info(`grantStatus success`)
      } else {
        //用户拒绝授权
        console.info(`grantStatus refuse`)
        deniedStat()
        return
      }
    }
    //授权成功
    grantStat()
  }).catch((err: BusinessError) => {
    console.error(`Failed to requestPermissionForSetting permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}