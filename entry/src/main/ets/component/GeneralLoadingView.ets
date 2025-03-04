//通用 loading 动画框
@Component
struct GeneralLoadingView {
  //首次加载
  @Prop isFirstLoading: boolean = false
  //非加载内容
  @BuilderParam
  customBuilder?: () => void

  build() {

  }
}