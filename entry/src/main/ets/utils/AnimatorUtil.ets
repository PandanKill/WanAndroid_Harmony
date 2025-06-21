/**
 * 动画
 */

/**
 * 数字变化
 * @param from
 * @param to
 * @param duration
 */
export function animatorNumber(from: number, to: number, listener: (toVal: number) => void, duration: number = 1000) {
  //三十次变化
  const step = 30
  const stepValue = (to - from) / step
  let current = from
  let i = 0

  const internal = setInterval(() => {
    //间隔变化
    i++
    current += stepValue
    if (i >= step) {
      clearInterval(internal)
      listener(to)
    } else {
      listener(current)
    }
  }, duration / step)
}