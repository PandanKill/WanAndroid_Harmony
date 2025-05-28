/**
 * 数据库操作
 */
import { relationalStore } from "@kit.ArkData"
import { common, Context } from "@kit.AbilityKit"
import { Message } from "../pages/ChatPage"
import { BusinessError } from "@kit.BasicServicesKit"
import { DatabaseConstant } from "../constants/DatabaseConstant"
import { taskpool } from "@kit.ArkTS"

const CONFIG: relationalStore.StoreConfig = {
  name: "wanandroid.db",
  securityLevel: relationalStore.SecurityLevel.S3,
  encrypt: false
}

/**
 * 初始化数据库
 * @param context
 */
@Concurrent
async function initDatabaseStore(context: Context, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
  console.info(`Create Store.db successfully!`);

  //数据库升级
  if (store.version === 0) {
    //创建数据库
    store.executeSql(DatabaseConstant.CREATE_SQL)
    store.version = 1
    console.info(`createStore success`)
  }

}

/**
 * 插入时间
 * @param context
 * @param message
 */
@Concurrent
async function insertTimeMessageData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
}

/**
 * 创建发送 Text 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendTextMessageData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let valueB: relationalStore.ValuesBucket = {
    'MESSAGETYPE': message.messageType,
    'OWNERNAME': message.ownerName,
    'MESSAGESTATUS': message.messageStatus,
    'ERRORMESSAGE': message.errorMessage,
    'TEXTTYPE': message.textType,
    'TEXTVAL': message.text,
    'MESSAGEID': message.id,
    'REFERENABLE': message.referEnable,
    'REFERID': message.referId,
    'REFERTYPE': message.referType,
    'TRANSLATEENABLE': message.translateEnable,
    'TRANSLATETEXT': message.translateText
  }
  store.insert(DatabaseConstant.CHAT_TABLE, valueB)
}

/**
 * 创建发送 Pic 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendPicMessageData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let valueB: relationalStore.ValuesBucket = {
    'MESSAGETYPE': message.messageType,
    'OWNERNAME': message.ownerName,
    'MESSAGESTATUS': message.messageStatus,
    'ERRORMESSAGE': message.errorMessage,
    'TEXTTYPE': message.textType,
    'IMAGEURI': message.imageUri,
    'IMAGEWIDTH': message.imageWidth,
    'IMAGEHEIGHT': message.imageHeight,
    'MESSAGEID': message.id,
    'REFERENABLE': message.referEnable,
    'REFERID': message.referId,
    'REFERTYPE': message.referType,
    'TRANSLATEENABLE': message.translateEnable,
    'TRANSLATETEXT': message.translateText
  }
  store.insert(DatabaseConstant.CHAT_TABLE, valueB)
}

/**
 * 创建发送 Video 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendVideoMessageData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let valueB: relationalStore.ValuesBucket = {
    'MESSAGETYPE': message.messageType,
    'OWNERNAME': message.ownerName,
    'MESSAGESTATUS': message.messageStatus,
    'ERRORMESSAGE': message.errorMessage,
    'TEXTTYPE': message.textType,
    'VIDEOURI': message.videoUri,
    'VIDEOCAPWIDTH': message.videoCapWidth,
    'VIDEOCAPHEIGHT': message.videoCapHeight,
    'VIDEOTIME': message.videoTime,
    'MESSAGEID': message.id,
    'REFERENABLE': message.referEnable,
    'REFERID': message.referId,
    'REFERTYPE': message.referType,
    'TRANSLATEENABLE': message.translateEnable,
    'TRANSLATETEXT': message.translateText
  }
  store.insert(DatabaseConstant.CHAT_TABLE, valueB)
}


/**
 * 创建发送 Video 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendAudioMessageData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
}

/**
 * 创建发送 Pic 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertReceiverTextMessageData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let valueB: relationalStore.ValuesBucket = {
    'MESSAGETYPE': message.messageType,
    'OWNERNAME': message.ownerName,
    'MESSAGESTATUS': message.messageStatus,
    'ERRORMESSAGE': message.errorMessage,
    'TEXTTYPE': message.textType,
    'TEXTVAL': message.text,
    'MESSAGEID': message.id,
    'REFERENABLE': message.referEnable,
    'REFERID': message.referId,
    'REFERTYPE': message.referType,
    'TRANSLATEENABLE': message.translateEnable,
    'TRANSLATETEXT': message.translateText
  }
  store.insert(DatabaseConstant.CHAT_TABLE, valueB)
}

/**
 * 更新翻译数据
 * @param context
 * @param message
 */
@Concurrent
async function updateTranslateData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let valueB: relationalStore.ValuesBucket = {}

  let predicates1 = new relationalStore.RdbPredicates(DatabaseConstant.CHAT_TABLE)
    .equalTo('MESSAGEID', message.id)

  store.update(valueB, predicates1)
}

/**
 * 查询留言数据
 * @param context
 * @param message
 */
@Concurrent
async function deleteMessageData(context: Context, message: Message, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let valueB: relationalStore.ValuesBucket = {}

  let predicates1 = new relationalStore.RdbPredicates(DatabaseConstant.CHAT_TABLE)
    .equalTo('MESSAGEID', message.id)

  store.delete(predicates1)
}

/**
 * 删除留言数据
 * @param context
 * @param message
 */
@Concurrent
async function queryMessageData(context: Context, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
  let messageArr: Message[] = []

  let predicates1 = new relationalStore.RdbPredicates(DatabaseConstant.CHAT_TABLE)
    //id 升序排列
    .orderByAsc('ID')

  let resultSet: relationalStore.ResultSet = await store.query(predicates1)
  while (resultSet.goToNextRow()) {

    //获取列表数据
    let message = new Message()
    message.messageType = resultSet.getLong(resultSet.getColumnIndex('MESSAGETYPE'))
    message.ownerName = resultSet.getString(resultSet.getColumnIndex('OWNERNAME'))
    //...

    messageArr.push(message)
  }
  return messageArr
}

class DatabaseUtil {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  /**
   * 查询数据
   * @returns
   */
  async query(): Promise<Message[]> {
    let mArr = await taskpool.execute(queryMessageData, this.context, CONFIG) as Message[]
    return mArr
  }

  /**
   * 插入数据
   * @param message
   */
  async insert(message: Message): Promise<void> {
    if (message.messageType === 0) {
      await taskpool.execute(insertTimeMessageData, this.context, message, CONFIG)
      return;
    } else if (message.messageType === 2) {
      await taskpool.execute(insertReceiverTextMessageData, this.context, message, CONFIG)
      return;
    } else {
      if (message.textType === 0) {
        await taskpool.execute(insertSendTextMessageData, this.context, message, CONFIG)
        return;
      } else if (message.textType === 1) {
        await taskpool.execute(insertSendPicMessageData, this.context, message, CONFIG)
        return;
      } else if (message.textType === 2) {
        await taskpool.execute(insertSendVideoMessageData, this.context, message, CONFIG)
        return;
      } else if (message.textType === 3) {
        await taskpool.execute(insertSendAudioMessageData, this.context, message, CONFIG)
        return;
      }
    }
  }

  /**
   * 删除数据
   * @param message
   * @returns
   */
  async delete(message: Message): Promise<void> {
    await taskpool.execute(deleteMessageData, this.context, message, CONFIG)
    return
  }

  /**
   * 更新翻译数据
   * @param message
   * @returns
   */
  async updateTranslate(message: Message): Promise<void> {
    await taskpool.execute(updateTranslateData, this.context, message, CONFIG)
    return
  }

  /**
   * 插入数据
   * @param message
   * @returns
   */
  async initData(context: Context): Promise<void> {
    await taskpool.execute(initDatabaseStore, context, CONFIG)
    return
  }
}

const databaseUtil: DatabaseUtil = new DatabaseUtil()

export default databaseUtil as DatabaseUtil