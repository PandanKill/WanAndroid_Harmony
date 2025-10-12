import { ChatPopupItem } from "../bean/ChatPopupItem";

export class GeneralPopupItemConstant {
  //通用
  static readonly CommonItem: ChatPopupItem[] = [
  //删除
    {
      icon: $r('app.media.icon_delete_white'),
      text: '删除',
      itemId: 1
    }
  ]
  //图片相关
  static readonly PicCommonItem: ChatPopupItem[] = [
    {
      icon: $r("app.media.icon_tuili"),
      text: '图片推理',
      itemId: 2
    },
    {
      icon: $r('app.media.icon_lijie'),
      text: '图片理解',
      itemId: 3
    },
    {
      icon: $r('app.media.icon_pic_get_text'),
      text: '文字提取',
      itemId: 4
    }
  ]
  //视频相关
  static readonly VideoCommonItem: ChatPopupItem[] = [
    {
      icon: $r('app.media.icon_lijie'),
      text: '视频理解',
      itemId: 5
    },
    //删除
    {
      icon: $r('app.media.icon_tuili'),
      text: '视频推理',
      itemId: 6
    }
  ]
  //音频相关
  static readonly AudioCommonItem: ChatPopupItem[] = [
  // {
  //   icon: $r('app.media.icon_tuili'),
  //   text: '语音推理',
  //   itemId: 7
  // },
    {
      icon: $r('app.media.icon_lijie'),
      text: '语音理解',
      itemId: 8
    },
    {
      icon: $r('app.media.icon_turn_text'),
      text: '转文字',
      itemId: 9
    },
    //听悟
    {
      icon: $r('app.media.icon_zhengli'),
      text: '语音整理',
      itemId: 10
    }
  ]
  //文本相关
  static readonly TextCommonItem: ChatPopupItem[] = [
  //搜一搜
    {
      icon: $r('app.media.icon_translte'),
      text: '翻译',
      itemId: 11
    },
    {
      icon: $r('app.media.icon_explore'),
      text: '搜一搜',
      itemId: 12
    },
    //复制
    {
      icon: $r('app.media.icon_copy'),
      text: '复制',
      itemId: 13
    },
    //多轮对话
    {
      icon: $r('app.media.icon_ref'),
      text: '引用',
      itemId: 14
    },
    //重发
    {
      icon: $r('app.media.icon_resend'),
      text: '重发',
      itemId: 15
    }
  ]
  /**
   * 图片下载
   */
  static readonly ImagePopupItem: ChatPopupItem[] = [
    {
      icon: $r('app.media.icon_download'),
      text: '下载',
      itemId: 16
    }
  ]
}