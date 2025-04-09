import { ChatPopupItem } from "../bean/ChatPopupItem";

export class GeneralPopupItemConstant {
  //通用
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
    //引用
    {
      icon: $r('app.media.icon_copy'),
      text: '引用'
    }
  ]
  //图片相关
  static readonly PicCommonItem: ChatPopupItem[] = [
    {
      icon: $r('app.media.icon_explore'),
      text: '图片描述'
    },
    //删除
    {
      icon: $r('app.media.icon_delete_white'),
      text: '图片理解'
    }
  ]
  //视频相关
  static readonly VideoCommonItem: ChatPopupItem[] = [
  //搜一搜
    {
      icon: $r('app.media.icon_explore'),
      text: '视频描述'
    },
    //删除
    {
      icon: $r('app.media.icon_delete_white'),
      text: '视频理解'
    }
  ]
  //音频相关
  static readonly AudioCommonItem: ChatPopupItem[] = [
  //搜一搜
    {
      icon: $r('app.media.icon_explore'),
      text: '语音解析'
    },
    {
      icon: $r('app.media.icon_explore'),
      text: '语音理解'
    },
    {
      icon: $r('app.media.icon_explore'),
      text: '转文字'
    },
    {
      icon: $r('app.media.icon_explore'),
      text: '语音合成'
    }
  ]
  //文本相关
  static readonly TextCommonItem: ChatPopupItem[] = [
  //搜一搜
    {
      icon: $r('app.media.icon_explore'),
      text: '翻译'
    }
  ]
}