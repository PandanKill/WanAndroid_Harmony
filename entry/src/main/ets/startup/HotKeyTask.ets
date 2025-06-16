import { common, StartupTask } from '@kit.AbilityKit';
import { ResponseBean } from '../bean/ResponseBean';
import { HotKeyBean } from '../bean/HotKeyBean';
import Api from '../utils/net/Api';

@Sendable
export default class HotKeyTask extends StartupTask {
  constructor() {
    super()
  }

  onDependencyCompleted(dependency: string, result: Object): void {

  }

  async init(context: common.AbilityStageContext): Promise<void | Object> {
    //获取热词
    let response: ResponseBean<HotKeyBean[]> = await Api.get().getHotKey()
    if (response.isSuccessWithData()) {
      AppStorage.setOrCreate("hotKey", response.data)
    }
    return ""
  }
}