import { ChatPopupItem } from "../bean/ChatPopupItem";

export class GeneralPopupItemConstant {
  static readonly CommonItem: ChatPopupItem[] = [
  //搜一搜
    {
      icon: $r('app.media.icon_explore'),
      text: '搜一搜'
    },
    //删除
    {
      icon: $r('app.media.icon_delete_white'),
      text: '删除'
    },
    //复制
    {
      icon: $r('app.media.icon_copy'),
      text: '复制'
    },
    //询问
    {
      icon: $r('app.media.icon_question'),
      text: '询问'
    }
  ]
}