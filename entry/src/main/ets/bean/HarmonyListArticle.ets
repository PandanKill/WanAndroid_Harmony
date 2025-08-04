import { ArticleBean } from "./ArticleBean"

export interface HarmonyListArticle {
  links: HarmonyAllArticle
}

export interface HarmonyAllArticle {
  articleList: ArticleBean[],
  author: string,
  name: string
}