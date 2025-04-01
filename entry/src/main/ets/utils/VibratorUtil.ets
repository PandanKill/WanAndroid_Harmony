import vibrator from "@ohos.vibrator";
import { BusinessError } from "@kit.BasicServicesKit";

/**
 * 开始震动
 */
export function startVibrator() {
  try {
    vibrator.startVibration({
      type: 'time',
      duration: 2
    }, {
      id: 0,
      usage: 'touch'
    }, (error: BusinessError) => {
      if (error) {
        console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      console.info('Succeed in starting vibration');
    })
  } catch (err) {
    let e: BusinessError = err as BusinessError;
    console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
  }
}

/**
 * 停止震动
 */
export function stopVibrator() {
  try {
    vibrator.stopVibration((error: BusinessError) => {
      if (error) {
        console.error(`Failed to stop vibration. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      console.info('Succeed in stopping vibration');
    })
  } catch (error) {
    let e: BusinessError = error as BusinessError;
    console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
  }
}