export class ArticlesList {
  articles: Array<NavContentBean>
  cid: number
  name: string
}

export class NavContentBean {
  chapterId: number
  chapterName: string
  link: string
  title: string
}