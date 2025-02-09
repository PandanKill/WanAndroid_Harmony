export class BannerBean {
  desc: string
  imagePath: string | Resource
  title: string
  url: string

  constructor(desc: string,
    imagePath: string | Resource,
    title: string,
    url: string) {
    this.desc = desc
    this.imagePath = imagePath
    this.title = title
    this.url = url
  }
}