import fs from '@ohos.file.fs';
import util from '@ohos.util';
import { BusinessError } from '@kit.BasicServicesKit';

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