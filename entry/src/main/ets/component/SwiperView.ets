import SizeConstant from '../constants/SizeConstant'
import { router } from '@kit.ArkUI'
import { httpRequest, logger, requestPath } from 'utils';
import { BusinessError } from '@ohos.base';
import { ResponseBean } from '../bean/ResponseBean';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BannerBean } from '../bean/BannerBean';

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
    //填充数据
    let session = rcp.createSession()
    session.get(requestPath.baseUrl + requestPath.PATH_HOME_BANNER).then((response) => {
      console.info(`Response succeeded: ${response}`);
      if (response !== undefined) {
        let responseBean: ResponseBean<BannerBean[]> =
          JSON.parse(response.toString()!!) as ResponseBean<BannerBean[]>
        if (responseBean.errorCode !== 0) {
          //默认数据
          this.swiperPics = [
            new BannerBean("默认数据", $r('app.media.yangmi'), "默认数据", "https://www.wanandroid.com/blog/show/2"),
            new BannerBean("默认数据", $r('app.media.yangmi'), "默认数据", "https://www.wanandroid.com/blog/show/2"),
            new BannerBean("默认数据", $r('app.media.yangmi'), "默认数据", "https://www.wanandroid.com/blog/show/2"),
          ]
        } else {
          //获取成功
          logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
          this.swiperPics = responseBean.data
          // this.swiperDataSource = new SwiperDataSource(this.swiperPics)
        }
      }
    }).catch((err: BusinessError) => {
      // this.swiperDataSource = new SwiperDataSource(this.swiperPics)
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    }).finally(() => {
      session.close()
    })
  }

  build() {
    Swiper() {
      ForEach(this.swiperPics, (item: BannerBean, index: number) => {
        Image(item.imagePath)
          .objectFit(ImageFit.Fill)
          .width(SizeConstant.FULL_SIZE)
          .height(SizeConstant.FULL_SIZE)
          .onClick(() => {
            router.pushUrl({
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