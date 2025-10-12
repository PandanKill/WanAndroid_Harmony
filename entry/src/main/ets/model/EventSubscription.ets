import hiAppEvent from "@ohos.hiviewdfx.hiAppEvent";
import { BusinessError } from "@kit.BasicServicesKit";
import hilog from "@ohos.hilog";

export function eventCrashSubscription(): void {
  try {
    // 构建崩溃事件的自定义参数
    let params: Record<string, hiAppEvent.ParamType> = {
      "test_data": 100, //test_data为自定义数据，开发者可根据实际需求自定义params参数。
    };
    // 开发者可以设置崩溃事件的自定义参数
    hiAppEvent.setEventParam(params, hiAppEvent.domain.OS, hiAppEvent.event.APP_CRASH).then(() => {
      hilog.info(0x0000, 'testTag', `HiAppEvent success to set event param`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `HiAppEvent code: ${err.code}, message: ${err.message}`);
    });

    // 开发者可以设置崩溃事件的自定义参数
    hiAppEvent.setEventParam(params, hiAppEvent.domain.OS, hiAppEvent.event.APP_FREEZE).then(() => {
      hilog.info(0x0000, 'testTag', `HiAppEvent success to set event param`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `HiAppEvent code: ${err.code}, message: ${err.message}`);
    });
    // 开发者可以设置崩溃事件的自定义参数
    hiAppEvent.setEventParam(params, hiAppEvent.domain.OS, hiAppEvent.event.RESOURCE_OVERLIMIT).then(() => {
      hilog.info(0x0000, 'testTag', `HiAppEvent success to set event param`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `HiAppEvent code: ${err.code}, message: ${err.message}`);
    });


    // 构建崩溃日志规格自定义参数
    let configParams: Record<string, hiAppEvent.ParamType> = {
      "extend_pc_lr_printing": true, // 使能扩展打印pc和lr寄存器附近的内存值
      "log_file_cutoff_sz_bytes": 102400, // 截断崩溃日志到100KB
      "simplify_vma_printing": true // 使能精简打印maps
    };


    // 开发者可以设置崩溃日志配置参数
    hiAppEvent.setEventConfig(hiAppEvent.event.APP_CRASH, configParams).then(() => {
      hilog.info(0x0000, 'testTag', `HiAppEvent success to set event config.`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `HiAppEvent code: ${err.code}, message: ${err.message}`);
    });
    // 开发者可以设置崩溃日志配置参数
    hiAppEvent.setEventConfig(hiAppEvent.event.APP_FREEZE, configParams).then(() => {
      hilog.info(0x0000, 'testTag', `HiAppEvent success to set event config.`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `HiAppEvent code: ${err.code}, message: ${err.message}`);
    });
    // 开发者可以设置崩溃日志配置参数
    hiAppEvent.setEventConfig(hiAppEvent.event.RESOURCE_OVERLIMIT, configParams).then(() => {
      hilog.info(0x0000, 'testTag', `HiAppEvent success to set event config.`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `HiAppEvent code: ${err.code}, message: ${err.message}`);
    });

    // Add application event observer method, which can be used to subscribe to application events
    hiAppEvent.addWatcher({
      // Developers can customize observer names, which the system will use to identify different observers
      name: 'mst',
      // Developers can subscribe to system events of interest, where they have subscribed to crash events
      appEventFilters: [
        {
          domain: hiAppEvent.domain.OS,
          names: [hiAppEvent.event.APP_CRASH, hiAppEvent.event.APP_FREEZE, hiAppEvent.event.RESOURCE_OVERLIMIT]
        }
      ],
      // 开发者可以自行实现订阅实时回调函数，以便对订阅获取到的事件数据进行自定义处理
      onReceive: (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
        hilog.info(0x0000, 'testTag', `HiAppEvent onReceive: domain=${domain}`);
        for (const eventGroup of appEventGroups) {
          // 开发者可以根据事件集合中的事件名称区分不同的系统事件
          hilog.info(0x0000, 'testTag', `HiAppEvent eventName=${eventGroup.name}`);
          for (const eventInfo of eventGroup.appEventInfos) {
            // 开发者可以对事件集合中的事件数据进行自定义处理，此处是将事件数据打印在日志中
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.domain=${eventInfo.domain}`);
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.name=${eventInfo.name}`);
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.eventType=${eventInfo.eventType}`);
            // 开发者可以获取到崩溃事件发生的时间戳
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.time=${eventInfo.params['time']}`);
            // 开发者可以获取到崩溃事件发生的崩溃类型
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.crash_type=${eventInfo.params['crash_type']}`);
            // 开发者可以获取到崩溃应用的前后台状态
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.foreground=${eventInfo.params['foreground']}`);
            // 开发者可以获取到崩溃应用的版本信息
            hilog.info(0x0000, 'testTag',
              `HiAppEvent eventInfo.params.bundle_version=${eventInfo.params['bundle_version']}`);
            // 开发者可以获取到崩溃应用的包名
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.bundle_name=${eventInfo.params['bundle_name']}`);
            // 开发者可以获取到崩溃应用的进程id
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.pid=${eventInfo.params['pid']}`);
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.uid=${eventInfo.params['uid']}`);
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.uuid=${eventInfo.params['uuid']}`);
            // 开发者可以获取到崩溃事件发生的异常类型、异常原因和异常调用栈
            hilog.info(0x0000, 'testTag',
              `HiAppEvent eventInfo.params.exception=${JSON.stringify(eventInfo.params['exception'])}`);
            // 开发者可以获取到崩溃事件发生时日志信息
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.hilog.size=${eventInfo.params['hilog'].length}`);
            // 开发者可以获取到崩溃事件发生时的崩溃日志文件
            hilog.info(0x0000, 'testTag',
              `HiAppEvent eventInfo.params.external_log=${JSON.stringify(eventInfo.params['external_log'])}`);
            hilog.info(0x0000, 'testTag',
              `HiAppEvent eventInfo.params.log_over_limit=${eventInfo.params['log_over_limit']}`);
            // 开发者可以获取到崩溃事件的自定义数据test_data
            hilog.info(0x0000, 'testTag', `HiAppEvent eventInfo.params.test_data=${eventInfo.params['test_data']}`);
          }
        }
      }
    });
  } catch (error) {
    let err = error as BusinessError;
    console.error(`addWatcher failed, error code=${err.code}, message=${err.message}`);
  }
}