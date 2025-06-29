/**
 *分享页面
 */
import { PullToRefresh } from '@ohos/pulltorefresh'
import SizeConstant from '../constants/SizeConstant'
import { JSON } from '@kit.ArkTS'
import { NavHeaderView } from '../component/NavHeaderView'

@Entry
@Component
struct SharePage {
  @State data: string[] = []
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.data.push("nihao1")
    this.data.push("nihao2")
    this.data.push("nihao3")
  }

  build() {
    Column() {
      NavHeaderView({
        title: $r('app.string.title_share')
      })

      PullToRefresh({
        data: this.data,
        scroller: this.scroller,
        customList: () => {
          this.itemListLayout()
        },
        onRefresh: () => {
          return new Promise<string>((resolve, reject) => {
            setTimeout(() => {
              this.data.push("nihaoonRefresh1")
              resolve("success")
            }, 3000)
          })
        },
        onLoadMore: () => {
          return new Promise<string>((resolve, reject) => {
            setTimeout(() => {
              this.data.push("nihaoonLoadMore1")
              resolve("success")
            }, 3000)
          })
        }
      })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }

  /**
   * 列表
   */
  @Builder
  itemListLayout() {
    Column() {
      List({ scroller: this.scroller }) {
        ForEach(this.data, (item: string, index: number) => {
          ListItem() {
            Text(item)
          }.width(SizeConstant.FULL_SIZE)
        }, (item: string, index: number) => JSON.stringify(item) + index)
      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }
}