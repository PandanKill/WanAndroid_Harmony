import { ChatPopupItem } from "../bean/ChatPopupItem";

export class GeneralPopupItemConstant {
  static readonly CommonItem: ChatPopupItem[] = [
  //搜一搜
    {
      icon: $r('app.media.icon_explore'),
      text: '搜一搜'
    },
    //引用
    {
      icon: $r('app.media.icon_explore'),
      text: '引用'
    },
    //删除
    {
      icon: $r('app.media.icon_explore'),
      text: '删除'
    },
    //复制
    {
      icon: $r('app.media.icon_explore'),
      text: '复制'
    }
  ]
}