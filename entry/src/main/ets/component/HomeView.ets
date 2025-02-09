import { ListView } from '@abner/refresh'
import SizeConstant from '../constants/SizeConstant'
import { SwiperView } from './SwiperView'
import { HomeListView } from './HomeListView'

@Component
export struct HomeView {
  build() {
    Column() {
      //轮播图
      SwiperView()
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_PERCENT_25)
      //列表
      HomeListView()
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.SIZE_PERCENT_75)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }
}