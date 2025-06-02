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
async function insertTimeMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
  console.info(`insertTimeMessageData value lgwww ${JSON.stringify(message)}`)

  store.insert(DatabaseConstant.CHAT_TABLE, message).then((num) => {
    console.info(`insertTimeMessageData num ${num}`)

  }).catch((err: BusinessError) => {
    console.error(`insertTimeMessageData num ${err.message}, ${err.code}`)

  })
}

/**
 * 创建发送 Text 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendTextMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
  console.info(`insertTimeMessageData value lgwww ${JSON.stringify(message)}`)

  store.insert(DatabaseConstant.CHAT_TABLE, message).then((num) => {
    console.info(`insertTimeMessageData num ${num}`)

  }).catch((err: BusinessError) => {
    console.error(`insertTimeMessageData num ${err.message}, ${err.code}`)

  })
}

/**
 * 创建发送 Pic 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendPicMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  store.insert(DatabaseConstant.CHAT_TABLE, message)
}

/**
 * 创建发送 Video 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendVideoMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  store.insert(DatabaseConstant.CHAT_TABLE, message)
}


/**
 * 创建发送 Video 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertSendAudioMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
}

/**
 * 创建发送 Pic 的消息
 * @param context
 * @param message
 */
@Concurrent
async function insertReceiverTextMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  store.insert(DatabaseConstant.CHAT_TABLE, message)
}

/**
 * 更新翻译数据
 * @param context
 * @param message
 */
@Concurrent
async function updateTranslateData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let predicates1 = new relationalStore.RdbPredicates(DatabaseConstant.CHAT_TABLE)
    .equalTo('MESSAGEID', message.id)

  store.update(message, predicates1)
}

/**
 * 删除留言数据
 * @param context
 * @param message
 */
@Concurrent
async function deleteMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)

  let predicates1 = new relationalStore.RdbPredicates(DatabaseConstant.CHAT_TABLE)
    .equalTo('MESSAGEID', message.id)

  store.delete(predicates1)
}

/**
 * 查询留言数据
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
    message.messageStatus = resultSet.getLong(resultSet.getColumnIndex('MESSAGESTATUS'))
    message.errorMessage = resultSet.getString(resultSet.getColumnIndex('ERRORMESSAGE'))
    message.textType = resultSet.getLong(resultSet.getColumnIndex('TEXTTYPE'))
    message.text = resultSet.getString(resultSet.getColumnIndex('TEXTVAL'))
    message.imageUri = resultSet.getString(resultSet.getColumnIndex('IMAGEURI'))
    message.imageWidth = resultSet.getLong(resultSet.getColumnIndex('IMAGEWIDTH'))
    message.imageHeight = resultSet.getLong(resultSet.getColumnIndex('IMAGEHEIGHT'))
    message.videoUri = resultSet.getString(resultSet.getColumnIndex('VIDEOURI'))
    message.videoCapWidth = resultSet.getLong(resultSet.getColumnIndex('VIDEOCAPWIDTH'))
    message.videoCapHeight = resultSet.getLong(resultSet.getColumnIndex('VIDEOCAPHEIGHT'))
    message.videoTime = resultSet.getLong(resultSet.getColumnIndex('VIDEOTIME'))
    message.audioUri = resultSet.getString(resultSet.getColumnIndex('AUDIOURI'))
    message.audioTime = resultSet.getLong(resultSet.getColumnIndex('AUDIOTIME'))
    message.id = resultSet.getString(resultSet.getColumnIndex('MESSAGEID'))
    message.referEnable = resultSet.getLong(resultSet.getColumnIndex('REFERENABLE')) === 0 ? false : true
    message.referId = resultSet.getString(resultSet.getColumnIndex('REFERID'))
    message.referType = resultSet.getLong(resultSet.getColumnIndex('REFERTYPE'))
    message.referText = resultSet.getString(resultSet.getColumnIndex('REFERTEXT'))
    message.translateText = resultSet.getString(resultSet.getColumnIndex('TRANSLATETEXT'))
    message.translateEnable = resultSet.getLong(resultSet.getColumnIndex('TRANSLATEENABLE')) === 0 ? false : true

    messageArr.push(message)
  }
  return messageArr
}

class DatabaseUtil {
  // private context: common.UIAbilityContext =  uiContext!.getHostContext()! as common.UIAbilityContext;
  /**
   * 查询数据
   * @returns
   */
  async query(context: Context): Promise<Message[]> {
    let mArr = await taskpool.execute(queryMessageData, context, CONFIG) as Message[]
    return mArr
  }

  /**
   * 插入数据
   * @param message
   */
  async insert(message: Message, context: Context): Promise<void> {
    if (message.messageType === 0) {
      console.info(`insertTimeMessageData ${JSON.stringify(message)}`)
      let valueB: relationalStore.ValuesBucket = {
        'MESSAGETYPE': message.messageType,
        'TEXTVAL': message.text,
        'MESSAGEID': message.id
      }
      console.info(`insertTimeMessageData valueB ${JSON.stringify(valueB)}`)
      await taskpool.execute(insertTimeMessageData, context, valueB, CONFIG)
      return;
    } else if (message.messageType === 2) {
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
      await taskpool.execute(insertReceiverTextMessageData, context, valueB, CONFIG)
      return;
    } else {
      if (message.textType === 0) {
        console.info(`insertTimeMessageData ${JSON.stringify(message)}`)
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
        console.info(`insertTimeMessageData valueB ${JSON.stringify(valueB)}`)
        await taskpool.execute(insertSendTextMessageData, context, valueB, CONFIG)
        return;
      } else if (message.textType === 1) {

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
        await taskpool.execute(insertSendPicMessageData, context, valueB, CONFIG)
        return;
      } else if (message.textType === 2) {

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
        await taskpool.execute(insertSendVideoMessageData, context, valueB, CONFIG)
        return;
      } else if (message.textType === 3) {
        await taskpool.execute(insertSendAudioMessageData, context, message, CONFIG)
        return;
      }
    }
  }

  /**
   * 删除数据
   * @param message
   * @returns
   */
  async delete(message: Message, context: Context): Promise<void> {
    let valueB: relationalStore.ValuesBucket = {
      'id': message.id
    }
    await taskpool.execute(deleteMessageData, context, valueB, CONFIG)
    return
  }

  /**
   * 更新翻译数据
   * @param message
   * @returns
   */
  async updateTranslate(message: Message, context: Context): Promise<void> {
    let valueB: relationalStore.ValuesBucket = {
      'id': message.id
    }
    await taskpool.execute(updateTranslateData, context, valueB, CONFIG)
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