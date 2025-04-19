/**
 * emoji 列表
 */
import { EmojiConstant } from '../constants/EmojiConstant'
import SizeConstant from '../constants/SizeConstant'

@Component
export struct EmojiListView {
  private emojis: string[] = EmojiConstant.emojiArr
  emojiClick: (item: string) => void = (item) => {
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.emojis, (item: string, index: number) => {
          GridItem() {
            Text(item)
              .aspectRatio(1)
              .width(SizeConstant.FULL_SIZE)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.emojiClick(item)
              })
          }
        })
      }.columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .layoutDirection(GridDirection.Row)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .transition(TransitionEffect.translate({
      y: SizeConstant.SIZE_PERCENT_25
    }).animation({
      duration: 100,
      curve: Curve.Linear
    }))
  }
}