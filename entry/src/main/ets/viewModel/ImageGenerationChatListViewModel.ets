/**
 * AI 生图
 */
import ImageGenerationChatViewModel from "./ImageGenerationChatViewModel";
import http from "@ohos.net.http";
import { BusinessError } from "@kit.BasicServicesKit";
import { image } from "@kit.ImageKit";
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { fileIo } from "@kit.CoreFileKit";
import databaseUtil from "../utils/DatabaseUtil";
import ImageGenerationChatModel from "../model/ImageGenerationChatModel";
import { JSON } from "@kit.ArkTS";

@ObservedV2
export default class ImageGenerationChatListViewModel {
  @Trace chatViewModelList: ImageGenerationChatViewModel[] = []
  @Trace imageSrc: PixelMap | undefined

  /**
   * 获取所有数据
   */
  async loadAllContent() {
    let mArr = await databaseUtil.queryImageGenMessage(getContext())
    for (let index = 0; index < mArr.length; index++) {
      const element = mArr[index];
      let chatViewModel = new ImageGenerationChatViewModel()
      chatViewModel.messageContent = element.messageContent
      chatViewModel.messageOwner = element.messageOwner
      chatViewModel.messageType = element.messageType
      this.chatViewModelList.push(chatViewModel)
    }
    console.info(`query image message succ. ${JSON.stringify(this.chatViewModelList)}`)
  }

  /**
   * 请求 AI 生图
   */
  async toGetImageAi(edVal: string) {
    let model = new ImageGenerationChatViewModel()
    model.messageContent = edVal
    model.messageOwner = 0
    model.messageType = 0
    this.chatViewModelList.push(model)
  }

  /**
   * 显示图片
   * @param imgSrc
   */
  requestImageSrc(imgSrc: string) {
    http.createHttp()
      .request(imgSrc, (error: BusinessError, data: http.HttpResponse) => {
        if (error) {
          console.error(`request image failed, code: ${error.code}, message: ${error.message}`);
        } else {
          let imgData: ArrayBuffer = data.result as ArrayBuffer
          let imageSource: image.ImageSource = image.createImageSource(imgData)

          class sizeTmp {
            height: number = 100;
            width: number = 100;
          }

          let options: Record<string, number | boolean | sizeTmp> = {
            'alphaType': 0,
            'editable': false,
            'pixelFormat': 3,
            'scaleMode': 1,
            'size': { height: 100, width: 100 }
          }
          imageSource.createPixelMap(options).then((pixMap: PixelMap) => {
            console.error('image createPixelMap success');
            this.imageSrc = pixMap;
            imageSource.release();
          }).catch(() => {
            imageSource.release()
          })
        }
      })
  }

  /**
   * 下载图片
   * @param pixelMap
   */
  async downloadImage(context: Context, pixelMap: image.PixelMap): Promise<boolean> {
    try {
      let imagePackerApi = image.createImagePacker()
      // 2. 设置打包选项
      let packOptions: image.PackingOption = {
        format: "image/jpeg", // 或 "image/png"
        quality: 100          // 质量 0-100
      };
      // 4. 获取相册文件目录
      let helper = photoAccessHelper.getPhotoAccessHelper(context);
      // onClick触发后一分钟内通过createAsset接口创建图片文件，一分钟后createAsset权限收回。
      let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
      // 3. 将 PixelMap 打包为 ArrayBuffer
      let arrayBuffer: ArrayBuffer = await imagePackerApi.packToData(pixelMap, packOptions);


      // 5. 写入文件
      let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      await fileIo.write(file.fd, arrayBuffer);
      await fileIo.close(file.fd);
      return true
    } catch (error) {
      console.error('Failed to save PixelMap:', error);
      return false
    }
  }
}