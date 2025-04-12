import { ChatPopupItem } from "../bean/ChatPopupItem";
import { Message } from "../pages/ChatPage";

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

  /**
   * 点击Item
   * @param item
   */
  onClickItem(item: ChatPopupItem, message: Message) {
    switch (item.itemId) {
      case 14:
        //引用
        this.onReferListener(message)
        break
    }
  }
}

let itemClickManager: PopupItemClickManager = new PopupItemClickManager();

//单利
export default itemClickManager as PopupItemClickManager