import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, KeyboardAvoidMode, window } from '@kit.ArkUI';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { StorageKey } from '../constants/StorageKey';
import { BusinessError } from '@kit.BasicServicesKit';
import dbUtil, { DBUtil } from '../utils/DBUtil';

export default class EntryAbility extends UIAbility {
  private window?: window.Window

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    AppStorage.setOrCreate<ConfigurationConstant.ColorMode>('colorModel', this.context.config.colorMode)
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    //创建表
    // dbUtil.createDB()

    //获取窗口信息
    windowStage.getMainWindow().then((window1: window.Window) => {
      this.window = window1
      //设置沉浸式
      window1.setWindowLayoutFullScreen(true).then(() => {
        console.info('Succeeded in setting the window layout to full-screen mode.');
      })
        .catch((err: BusinessError) => {
          console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
        });
      //获取导航栏高度
      let navHeight = window1.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
      AppStorage.setOrCreate("navHeight", navHeight)

      //获取状态栏高度
      let statusHeight = window1.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
      AppStorage.setOrCreate('topRectHeight', statusHeight);

      //安全区域监听
      window1.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          AppStorage.setOrCreate('topRectHeight', topRectHeight);
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height;
          AppStorage.setOrCreate('navHeight', bottomRectHeight);
        }
      })

      //设置breakpoint
      this.updateBreakpoint(window1.getWindowProperties().windowRect.width)
      window1.on('windowSizeChange', (size) => {
        //监听size，重置
        this.updateBreakpoint(size.width)
      })
    })

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageWillDestroy(windowStage: window.WindowStage): void {

  }

  // onConfigurationUpdate(newConfig: Configuration): void {
  //   let currentColorMode: ConfigurationConstant.ColorMode | undefined = AppStorage.get('colorModel')
  //   if (currentColorMode?.toString() !== newConfig.colorMode) {
  //     AppStorage.setOrCreate<ConfigurationConstant.ColorMode>('colorModel', parseInt(newConfig.colorMode))
  //   }
  // }

  /**
   * 获取断点
   * @param windowWidth
   */
  private updateBreakpoint(windowWidth: number) {
    let windowVp = windowWidth / display.getDefaultDisplaySync().densityPixels
    let curBp: string = ''
    if (windowVp < BreakpointConstants.BREAKPOINT_RANGES[0]) {
      //sm
      curBp = BreakpointConstants.BREAKPOINT_SM
    } else if (windowVp < BreakpointConstants.BREAKPOINT_RANGES[1]) {
      //md
      curBp = BreakpointConstants.BREAKPOINT_MD
    } else {
      //sm
      curBp = BreakpointConstants.BREAKPOINT_LG
    }
    AppStorage.setOrCreate(StorageKey.KEY_CURRENTBREAKPOINT, curBp)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
