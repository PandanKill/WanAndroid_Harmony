export interface TopBean {
  author?: string
  chapterName?: string
  id?: string
  link?: string
  niceDate?: string
  shareUser?: string
  superChapterName?: string
  tags?: TopTagBean[]
  title?: string
  zan?: number
}

export interface TopTagBean {
  name?: string
  url?: string
}