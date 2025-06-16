/**
 * 个人排名
 */
export class MineCoinContentBean {
  coinCount: number = 0
  date: number = 0
  desc: string = ''
  id: number = 0
  reason: string = ''
  type: number = 0
  userId: number = 0
  userName: string = ''
}

export class MineCoinBean {
  curPage: number = 0
  datas: MineCoinContentBean[] = []
  offset: number = 0
  pageCount: number = 0
  size: number = 0
  total: number = 0
}

/**
 * 列表排名
 */
export class CoinRankContentBean {
  coinCount: number = 0
  level: number = 0
  nickname: string = ''
  rank: number = 0
  userId: number = 0
  userName: string = ''
}

export class CoinRankBean {
  curPage: number = 0
  datas: CoinRankContentBean[] = []
  offset: number = 0
  pageCount: number = 0
  size: number = 0
  total: number = 0
}