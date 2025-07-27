/**
 * 加载状态
 */
export enum LoadState {
  //正在加载
  LOADING,
  //加载成功
  SUCCESS,
  //加载失败，显示失败页面
  FAILURE,
  //空数据
  EMPTY
}