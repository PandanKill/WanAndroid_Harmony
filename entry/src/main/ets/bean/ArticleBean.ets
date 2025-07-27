export interface ArticleListBean {
  curPage: number,
  datas: ArticleBean[],
  offset: number,
  over: boolean,
  pageCount: number,
  size: number,
  total: number
}

export class ArticleBean {
  isTop: boolean = false
  author?: string
  chapterName?: string
  id: number = 0
  link?: string
  niceDate?: string
  shareUser?: string
  superChapterName?: string
  tags?: ArticleTagBean[]
  title?: string
  desc?: string
  collect: boolean = false
  envelopePic?: string
  superChapterId?: number
}

export class ArticleTagBean {
  name?: string
  url?: string
  charptId?: number
}

export class TagRouterBean {
  type?: string
  officialAcc?: number
  tags?: TabDetailBean[]
}

export class TabDetailBean {
  id?:number
  name?:string
}