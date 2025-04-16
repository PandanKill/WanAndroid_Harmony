import { ChatPopupItem } from "../bean/ChatPopupItem";
import { Message } from "../pages/ChatPage";
import { pasteboard } from "@kit.BasicServicesKit";
import { common, Want } from "@kit.AbilityKit";

/**
 * 聊天 Item 点击
 */
class PopupItemClickManager {
  /**
   * 使用回调可以
   * 或者使用 state 监听状态变化，然后 watch 处理
   */
  //引用
  onReferListener: (refItem: Message) => void = (refItem) => {
  }
  //删除
  onDeleteListener: (deleteItem: Message) => void = (deleteItem) => {

  }
  //重发
  onResendListener: (deleteItem: Message) => void = (deleteItem) => {

  }

  /**
   * 点击Item
   * @param item
   */
  onClickItem(item: ChatPopupItem, message: Message) {
    switch (item.itemId) {
      case 1:
        //删除
        this.onDeleteListener(message)
        break
      case 2:
        //图片推理
        break
      case 3:
        //图片理解
        break
      case 4:
        //文字提取
        break
      case 5:
        //视频理解
        break
      case 6:
        //视频推理
        break
      case 7:
        //语音推理
        break
      case 8:
        //语音理解
        break
      case 9:
        //转文字
        break
      case 10:
        //语音整理
        break
      case 11:
        //翻译
        break
      case 12:
        this.searchData(message.text)
        break
      case 13:
        //复制
        this.savePasteboardData(message.text)
        break
      case 14:
        //引用
        this.onReferListener(message)
        break
      case 15:
        //重发
        this.onResendListener(message)
        break
    }
  }

  /**
   * 网页搜索
   * @param text
   */
  searchData(searchText: string) {
    // URL 编码文字（处理空格和特殊字符）
    let encodedText = encodeURIComponent(searchText);

    // 选择搜索引擎的 URL 格式（示例使用 Google）
    let searchUrl = `https://www.baidu.com/s?wd=${encodedText}`;
    let want: Want = {
      action: "ohos.want.action.viewData",
      entities: ['entity.system.browsable'],
      uri: searchUrl
    };

    (getContext(this) as common.UIAbilityContext).startAbility(want)
  }

  /**
   * 复制
   * @param text
   */
  async savePasteboardData(text: string) {
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    let systemPasteboard = pasteboard.getSystemPasteboard()
    await systemPasteboard.setData(pasteData)
  }
}

let itemClickManager: PopupItemClickManager = new PopupItemClickManager();

//单利
export default itemClickManager as PopupItemClickManager