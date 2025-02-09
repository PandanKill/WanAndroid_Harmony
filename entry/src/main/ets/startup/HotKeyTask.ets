import { common, StartupTask } from '@kit.AbilityKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import { logger, requestPath } from 'utils';
import { JSON } from '@kit.ArkTS';
import { ResponseBean } from '../bean/ResponseBean';
import { HotKeyBean } from '../bean/HotKeyBean';

@Sendable
export default class HotKeyTask extends StartupTask {
  constructor() {
    super()
  }

  onDependencyCompleted(dependency: string, result: Object): void {

  }

  async init(context: common.AbilityStageContext): Promise<void | Object> {
    //获取热词
    let session = rcp.createSession()
    try {
      let response: rcp.Response = await session.get(requestPath.baseUrl + requestPath.PATH_HOTKEY_JSON)
      let bean = JSON.parse(response.toString()) as ResponseBean<HotKeyBean[]>
      if (bean.errorCode === 0) {
        //保存
        AppStorage.set("hotKey", bean.data)
      }
      session.close()
    } catch (err) {
      logger.error(JSON.stringify(err))
    }
    return ""
  }
}