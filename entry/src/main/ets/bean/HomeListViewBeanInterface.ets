import { observer } from '@kit.TelephonyKit'

export interface HomeListViewBeanInterface {
  curPage: number,
  datas: HomeBean[],
  offset: number,
  over: boolean,
  pageCount: number,
  size: number,
  total: number
}

export interface HomeBean {
  author?: string
  chapterName?: string
  id: number
  link?: string
  niceDate?: string
  shareUser?: string
  superChapterName?: string
  superChapterId?: number
  tags?: TagBean[]
  title?: string
  desc?: string
  collect: boolean
  envelopePic?: string
}

export interface TagBean {
  name?: string
  url?: string
}
