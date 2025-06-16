import { logger, requestPath } from 'utils'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit';
import SizeConstant from '../constants/SizeConstant';
import { ProjectTabBean } from '../bean/ProjectTabBean';
import { ResponseBean } from '../bean/ResponseBean';
import { ProjectTabContentView } from './ProjectTabContentView';
import Api from '../utils/net/Api';

@Component
export struct ProjectContentView {
  //当前索引
  @State private currentIndex: number = 0
  //tabs页
  @State tabNames: ProjectTabBean[] = []

  aboutToAppear(): void {
    this.loadProjectTree()
  }

  async loadProjectTree() {
    let responseBean: ResponseBean<ProjectTabBean[]> = await Api.get().getProjectTree()
    if (responseBean.isSuccessWithData()) {
      //获取成功
      logger.error(`nihai :${JSON.stringify(responseBean.data)}`)
      this.tabNames = responseBean.getDataOrThrow()
    }
  }

  @Builder
  tabuilder(name: string, index: number) {
    Text(name)
      .fontSize($r('app.float.font_12'))
      .fontColor(index === this.currentIndex ? $r('app.color.color_272A36') : $r('app.color.color_999999'))
      .padding({ right: SizeConstant.SIZE_10, left: SizeConstant.SIZE_10 })
      .height(SizeConstant.FULL_SIZE)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start }) {
        ForEach(this.tabNames, (bean: ProjectTabBean, index: number) => {
          TabContent() {
            ProjectTabContentView({ contentId: bean.id })
              .width(SizeConstant.FULL_SIZE)
              .height(SizeConstant.FULL_SIZE)
          }.tabBar(this.tabuilder(bean.name, index))
        })
      }
      .vertical(false)
      .barWidth(SizeConstant.FULL_SIZE)
      .barHeight(40)
      .scrollable(true)
      .barMode(BarMode.Scrollable, {
        nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER
      })
      .width(SizeConstant.FULL_SIZE)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }.width(SizeConstant.FULL_SIZE)
    .height(SizeConstant.FULL_SIZE)
    .backgroundColor($r('app.color.color_FFFFFF'))
  }
}