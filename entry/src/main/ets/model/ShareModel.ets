import { systemShare } from "@kit.ShareKit"
import { uniformTypeDescriptor } from "@kit.ArkData"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"

class ShareModel {
  /**
   * 链接分享
   * @param content
   * @param link
   * @param uiContext
   */
  shareLink(content: string, link: string, uiContext: UIContext) {
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
      content: link,
      title: content,
      // thumbnail:$r('app.media.icon_message')
    })
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData)
    let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL
    }).then(() => {
      console.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    })
  }
}

export default new ShareModel()