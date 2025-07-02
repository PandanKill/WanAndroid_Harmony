import { observer } from '@kit.TelephonyKit'

@Observed
export class HomeListViewBean {
  isTop?: boolean
  author?: string
  chapterName?: string
  id: number = 0
  link?: string
  niceDate?: string
  shareUser?: string
  superChapterName?: string
  tags?: TagBean[]
  title?: string
  desc?: string
  collect: boolean = false
  envelopePic?: string
  superChapterId?: number
}

export class TagBean {
  name?: string
  url?: string
  charptId?: number
}
