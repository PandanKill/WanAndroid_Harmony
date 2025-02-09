import { observer } from '@kit.TelephonyKit'

@Observed
export class HomeListViewBean {
  isTop?: boolean
  author?: string
  chapterName?: string
  id?: string
  link?: string
  niceDate?: string
  shareUser?: string
  superChapterName?: string
  tags?: TagBean[]
  title?: string
  desc?: string
  envelopePic?: string
  superChapterId?: number
  zan?: boolean
}

export class TagBean {
  name?: string
  url?: string
  charptId?: number
}
