import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { logger, requestPath } from 'utils';
import { BusinessError } from '@ohos.base';
import { ResponseBean } from '../bean/ResponseBean';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BannerBean } from '../bean/BannerBean';
import Api from '../utils/net/Api';

class SwiperDataSource implements IDataSource {
  private bannerImgList: BannerBean[] = [];

  constructor(bannerImgList: BannerBean[]) {
    this.bannerImgList = bannerImgList;
  }

  totalCount(): number {
    return this.bannerImgList.length
  }

  getData(index: number): BannerBean {
    return this.bannerImgList[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
  }
}

@Component
export struct SwiperView {
  @State private swiperPics: BannerBean[] = []

  // private swiperDataSource: SwiperDataSource = new SwiperDataSource([])

  aboutToAppear(): void {
    this.loadBannerData()
  }

  async loadBannerData() {
    let responseBean: ResponseBean<BannerBean[]> = await Api.get().getSwiperArt()
    if (responseBean.isSuccessWithData()) {
      //获取成功
      logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
      this.swiperPics = responseBean.getDataOrThrow()
    }
  }

  build() {
    Swiper() {
      ForEach(this.swiperPics, (item: BannerBean, index: number) => {
        Image(item.imagePath)
          .objectFit(ImageFit.Fill)
          .width(SizeConstant.FULL_SIZE)
          .height(SizeConstant.FULL_SIZE)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: "pages/WebPage",
              params: {
                webUrl: item.url
              }
            })
          })
      }, (item: Resource, index: number) => index + JSON.stringify(item))
    }
    .width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .loop(true)
    .autoPlay(true)
    .index(1)
    .displayCount(1)
    .indicator(Indicator.dot()
      .right(SizeConstant.SIZE_10)
      .itemWidth(SizeConstant.SIZE_5)
      .itemHeight(SizeConstant.SIZE_5)
      .selectedItemWidth(SizeConstant.SIZE_5)
      .selectedItemHeight(SizeConstant.SIZE_5)
      .color($r('app.color.swiper_indicator'))
      .selectedColor($r('app.color.color_FFFFFF'))
    )
  }
}