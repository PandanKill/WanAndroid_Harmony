/**
 * 单个 Item 的 ViewModel
 */
@ObservedV2
export default class ImageGenerationChatViewModel {
  @Trace messageContent: string = ''
  @Trace messageOwner: number = 0
  @Trace messageType: number = 0

}