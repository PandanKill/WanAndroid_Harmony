import { LoadState } from '../bean/LoadState'
import SizeConstant from '../constants/SizeConstant'

@Component
export struct PageLoadingComponent {
  @Prop loadState: LoadState
  onReload?: () => void
  @BuilderParam content: () => void

  build() {
    Stack() {
      if (this.loadState === LoadState.LOADING) {
        //显示loading动画
        LoadingProgress()
          .color($r('app.color.color_0000FF'))
          .width(SizeConstant.SIZE_40)
          .height(SizeConstant.SIZE_40)
      } else if (this.loadState === LoadState.SUCCESS) {
        this.content()
      } else if (this.loadState === LoadState.FAILURE) {
        //加载失败
        Text("加载失败，点击重试")
          .fontSize($r('app.float.font_15'))
          .onClick(() => {
            if (this.onReload) {
              this.onReload()
            }
          })
      } else {
        //没有数据
        Text("没有数据")
          .fontSize($r('app.float.font_15'))
          .onClick(() => {
            if (this.onReload) {
              this.onReload()
            }
          })
      }
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_FFFFFF'))
  }
}