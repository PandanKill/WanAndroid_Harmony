import { StartupConfig, StartupConfigEntry, StartupListener } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { logger } from 'utils';
import { JSON } from '@kit.ArkTS';

export default class StartupCustomConfig extends StartupConfigEntry {
  onConfig(): StartupConfig {
    let onCompl = (err: BusinessError) => {
      if (err) {
        logger.error("StartupCustomConfig fail: " + JSON.stringify(err))
      } else {
        logger.error("StartupCustomConfig success")
      }
    }

    //监听器
    let startListener: StartupListener = {
      'onCompleted': onCompl
    }

    let config: StartupConfig = {
      timeoutMs: 10000,
      startupListener: startListener
    }

    return config
  }
}