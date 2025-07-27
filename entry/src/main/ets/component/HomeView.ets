import SizeConstant from '../constants/SizeConstant'
import { SwiperView } from './SwiperView'
import { HomeListView } from './HomeListView'

@Component
export struct HomeView {
  build() {
    Column() {
      //列表
      HomeListView()
        .width(SizeConstant.FULL_SIZE)
        .height(SizeConstant.FULL_SIZE)
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
  }
}