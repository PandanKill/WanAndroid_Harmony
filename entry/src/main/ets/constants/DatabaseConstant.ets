export class DatabaseConstant {
  static readonly CREATE_SQL = 'CREATE TABLE IF NOT EXISTS CHAT_MESSAGE ' +
    //自增 id
    '(ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    //消息方
    'MESSAGETYPE INTEGER NOT NULL, ' +
    //姓名
    'OWNERNAME TEXT NOT NULL, ' +
    //消息状态
    'MESSAGESTATUS INTEGER,' +
    //异常信息
    'ERRORMESSAGE TEXT,' +
    //消息类型
    'TEXTTYPE INTEGER NOT NULL,' +
    //文字内容
    'TEXTVAL TEXT, ' +
    //图片 uri
    'IMAGEURI TEXT, ' +
    //图片宽度
    'IMAGEWIDTH INTEGER, ' +
    //图片高度
    'IMAGEHEIGHT INTEGER, ' +
    //视频 url
    'VIDEOURI TEXT, ' +
    //视频宽度
    'VIDEOCAPWIDTH INTEGER, ' +
    //视频高度
    'VIDEOCAPHEIGHT INTEGER, ' +
    //视频时间
    'VIDEOTIME INTEGER, ' +
    //语音 uri
    'AUDIOURI TEXT, ' +
    //语音时间
    'AUDIOTIME INTEGER, ' +
    //发送方 id
    'MESSAGEID TEXT NOT NULL, ' +
    //是否引用
    'REFERENABLE BOOLEAN, ' +
    //引用 id
    'REFERID TEXT, ' +
    //引用类型
    'REFERTYPE INTEGER, ' +
    //引用文字
    'REFERTEXT TEXT, ' +
    //是否翻译
    'TRANSLATEENABLE BOOLEAN, ' +
    //翻译内容
    'TRANSLATETEXT TEXT)'
  /**
   * 消息表名
   */
  static readonly CHAT_TABLE = 'chat_table'
}