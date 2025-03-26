import fs from '@ohos.file.fs';
import util from '@ohos.util';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';

export async function imageToBase64(uri: string): Promise<string> {
  try {
    //获取 file 对象
    const file = fs.openSync(uri, fs.OpenMode.READ_ONLY)

    //获取文件信息，文件大小
    const stat = fs.statSync(file.fd)
    const fileSize = stat.size

    //读物文件到 ArrayBuffer
    const arrayBuffer = new ArrayBuffer(fileSize)
    const readLen = fs.readSync(file.fd, arrayBuffer)
    const uint8Array: Uint8Array = new Uint8Array(arrayBuffer, 0, readLen);

    if (readLen == 0) {
      throw new Error("文件读取失败")
    }

    //转化为 Base64
    const base64Encoder = new util.Base64Helper()
    const base64Str = await base64Encoder.encodeToString(uint8Array)

    fs.closeSync(file.fd)

    return `data:image/png;base64,${base64Str}`
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error('转换失败:', err.code, err.message);
    throw new Error(err.message)
  }
}

export async function getImageRealSize(uri: string): Promise<image.Size> {
  try {
    const imageSource = image.createImageSource(uri)
    const imageInfo = await imageSource.getImageInfo()
    imageSource.release()

    return imageInfo.size
  } catch (error) {
    const err = error as BusinessError;
    console.error(`获取图片尺寸失败 [${err.code}]: ${err.message}`);
    throw new Error('无法解析图片尺寸');
  }
}

/**
 * 校验 mimeType
 * @param uri
 * @returns
 */
export async function checkFileMimeType(filePath: string): Promise<string> {
  try {
    // const realFileUri: string = fileUri.getUriFromPath(filePath)
    // const mime = await mimeType.getMimeTypeFromUri(realFileUri);
    //
    // if (mime.startsWith('image/')) {
    //   return 'image';
    // }
    // if (mime.startsWith('video/')) {
    //   return 'video';
    // }

    // MIME 类型无法识别时，回退到扩展名判断
    const filename = filePath.split('/').pop() || '';
    return getFileTypeByExtension(filename);
  } catch (err) {
    return getFileTypeByExtension(filePath);
  }
}

/**
 * 通过文件扩展名判断类型
 * @param filename 文件名（如：example.jpg）
 * @returns 'image' | 'video' | 'other'
 */
function getFileTypeByExtension(filename: string): 'image' | 'video' | 'other' {
  // 获取文件扩展名（不区分大小写）
  const ext = filename.split('.').pop()?.toLowerCase() || '';

  // 图片类型扩展名列表
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
  // 视频类型扩展名列表
  const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'webm'];

  if (imageExtensions.includes(ext)) {
    return 'image';
  } else if (videoExtensions.includes(ext)) {
    return 'video';
  } else {
    return 'other';
  }
}