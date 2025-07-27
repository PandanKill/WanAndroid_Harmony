import { TabDetailBean, TagRouterBean } from '../bean/ArticleBean';
import { LoadState } from '../bean/LoadState';
import { ResponseBean } from '../bean/ResponseBean'
import { TreeContentBean, TreeListBean } from '../bean/TreeContentBean'
import SizeConstant from '../constants/SizeConstant'
import Api from '../utils/net/Api'
import { PageLoadingComponent } from './PageLoadingComponent';

@Component
export struct TiXiContentView {
  @State contentMap: TreeListBean[] = []
  @State loadState: LoadState = LoadState.LOADING

  aboutToAppear(): void {
    //加载体系数据
    this.loadInitData()
  }

  private loadInitData() {
    this.loadState = LoadState.LOADING
    this.loadData().then((data) => {
      if (data.length > 0) {
        this.loadState = LoadState.SUCCESS
        this.contentMap = data
      } else {
        this.loadState = LoadState.EMPTY
      }
    }, () => {
      this.loadState = LoadState.FAILURE
    })
  }

  private async loadData(): Promise<TreeListBean[]> {
    let bean: ResponseBean<TreeListBean[]> = await Api.get().getTiXiData()
    if (bean.isSuccessWithData()) {
      return Promise.resolve(bean.getDataOrThrow())
    } else {
      return Promise.reject()
    }
  }

  build() {
    PageLoadingComponent({
      loadState: this.loadState,
      onReload: () => {
        this.loadInitData()
      }
    }) {
      List() {
        ForEach(this.contentMap, (item: TreeListBean, index: number) => {
          ListItem() {
            Column() {
              Text(item.name)
                .fontWeight(350)
                .margin({ top: SizeConstant.SIZE_15 })
                .fontSize($r('app.float.font_12'))
                .fontColor($r('app.color.color_333333'))
              Flex({
                wrap: FlexWrap.Wrap
              }) {
                ForEach(item.children, (bean: TreeContentBean, index: number) => {
                  Text(bean.name)
                    .fontSize($r('app.float.font_12'))
                    .fontColor($r('app.color.color_666666'))
                    .margin({ top: SizeConstant.SIZE_10, left: SizeConstant.SIZE_5, right: SizeConstant.SIZE_5 })
                    .fontWeight(400)
                    .padding({
                      left: SizeConstant.SIZE_10,
                      right: SizeConstant.SIZE_10,
                      top: SizeConstant.SIZE_5,
                      bottom: SizeConstant.SIZE_5
                    })
                    .backgroundColor($r('app.color.color_F6F6F6'))
                    .borderRadius(SizeConstant.SIZE_15)
                    .onClick(() => {
                      let tagBean = new TagRouterBean()
                      tagBean.type = "TiXi"
                      tagBean.officialAcc = bean.id
                      tagBean.tags = item.children.map((bean: TreeContentBean) => {
                        let bean1 = new TabDetailBean()
                        bean1.id = bean.id
                        bean1.name = bean.name
                        return bean1
                      })

                      this.getUIContext().getRouter().pushUrl({
                        url: "pages/TagDetailPage",
                        params: tagBean
                      })
                    })
                }, (bean: TreeContentBean, index: number) => JSON.stringify(bean) + index)
              }.width(SizeConstant.FULL_SIZE)
              .margin({ bottom: SizeConstant.SIZE_10 })
            }.width(SizeConstant.FULL_SIZE)
            .alignItems(HorizontalAlign.Start)
            .padding({ left: SizeConstant.SIZE_10, right: SizeConstant.SIZE_10 })
          }.width(SizeConstant.FULL_SIZE)
        }, (item: TreeListBean, index: number) => JSON.stringify(item) + index)
      }.width(SizeConstant.FULL_SIZE)
      .height(SizeConstant.FULL_SIZE)
      .scrollBar(BarState.Off)
    }
  }
}