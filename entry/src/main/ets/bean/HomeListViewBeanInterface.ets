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
  id?: string
  link?: string
  niceDate?: string
  shareUser?: string
  superChapterName?: string
  superChapterId?: number
  tags?: TagBean[]
  title?: string
  desc?: string
  envelopePic?: string
  zan?: number
}

export interface TagBean {
  name?: string
  url?: string
}
