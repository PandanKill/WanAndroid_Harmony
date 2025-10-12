/**
 * 数据库操作
 */
import { relationalStore } from "@kit.ArkData"
import { common, Context } from "@kit.AbilityKit"
import { Message } from "../pages/ChatPage"
import { BusinessError } from "@kit.BasicServicesKit"
import { DatabaseConstant } from "../constants/DatabaseConstant"
import { JSON, taskpool } from "@kit.ArkTS"
import ImageGenerationChatModel from "../model/ImageGenerationChatModel"

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
  if (store.version <= 0) {
    //创建数据库
    store.executeSql(DatabaseConstant.CREATE_SQL)
    store.version = 1
    console.info(`createStore message success`)
  }

  if (store.version <= 1) {
    store.executeSql(DatabaseConstant.CREATE_IMAGE_SQL)
    store.version = 2
    console.info(`createStore image message success`)
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
  store.insert(DatabaseConstant.CHAT_TABLE, message)
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
  predicates1.equalTo('MESSAGEID', message.MESSAGEID)

  let number = await store.update(message, predicates1)
  console.info(`updateTranslate: number = ${number}`)
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
    .equalTo('MESSAGEID', message.MESSAGEID)

  let number = await store.delete(predicates1)
  console.info(`deleteMessageData: number = ${number}`)
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
    message.referUri = resultSet.getString(resultSet.getColumnIndex('REFERURI'))
    message.referWidth = resultSet.getLong(resultSet.getColumnIndex('REFERWIDTH'))
    message.referHeight = resultSet.getLong(resultSet.getColumnIndex('REFERHEIGHT'))
    message.translateText = resultSet.getString(resultSet.getColumnIndex('TRANSLATETEXT'))
    message.translateEnable = resultSet.getLong(resultSet.getColumnIndex('TRANSLATEENABLE')) === 0 ? false : true

    messageArr.push(message)
  }
  return messageArr
}

/**
 * 插入图片表数据
 * @param context
 * @param message
 * @param config
 */
@Concurrent
async function insertImageGenMessageData(context: Context, message: relationalStore.ValuesBucket,
  config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
  store.insert(DatabaseConstant.CHAT_IMAGE_TABLE, message)
}

/**
 * 查询图片表数据
 * @param context
 * @param message
 * @param config
 */
@Concurrent
async function queryImageGenMessageData(context: Context, config: relationalStore.StoreConfig) {
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config)
  let pre = new relationalStore.RdbPredicates(DatabaseConstant.CHAT_IMAGE_TABLE)
    .orderByAsc('ID')

  let imageMsgArr: ImageGenerationChatModel[] = []

  let resultSet = await store.query(pre)

  while (resultSet.goToNextRow()) {
    let model = new ImageGenerationChatModel()
    model.messageOwner = resultSet.getLong(resultSet.getColumnIndex('MESSAGEOWNER'))
    model.messageType = resultSet.getLong(resultSet.getColumnIndex('MESSAGETYPE'))
    model.messageContent = resultSet.getString(resultSet.getColumnIndex('MESSAGECONTENT'))
    imageMsgArr.push(model)
  }

  return imageMsgArr
}

class DatabaseUtil {
  // private context: common.UIAbilityContext =  uiContext!.getHostContext()! as common.UIAbilityContext;
  /**
   * 查询数据
   * @returns
   */
  async query(context: Context): Promise<Message[]> {
    let mArr = await taskpool.execute(queryMessageData, context, CONFIG) as Message[]
    for (let index = 0; index < mArr.length; index++) {
      const element = mArr[index];
      console.info(`nihao message: ${JSON.stringify(element)}`)
    }
    return mArr
  }

  /**
   * 根据消息 id 查询指定留言
   * @param context
   * @param referId
   * @returns
   */
  // async queryByReferId(context: Context, referId: string): Promise<Message> {
  //
  // }

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
      console.info(`insertReceiverMessageData ${JSON.stringify(message)}`)
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
        console.info(`insertTextMessageData ${JSON.stringify(message)}`)
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
          'REFERTEXT': message.referText,
          'REFERURI': message.referUri,
          'REFERWIDTH': message.referWidth,
          'REFERHEIGHT': message.referHeight,
          'TRANSLATEENABLE': message.translateEnable,
          'TRANSLATETEXT': message.translateText
        }
        console.info(`insertTextMessageData valueB ${JSON.stringify(valueB)}`)
        await taskpool.execute(insertSendTextMessageData, context, valueB, CONFIG)
        return;
      } else if (message.textType === 1) {
        console.info(`insertPicMessageData ${JSON.stringify(message)}`)
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
          'REFERTEXT': message.referText,
          'REFERURI': message.referUri,
          'REFERWIDTH': message.referWidth,
          'REFERHEIGHT': message.referHeight,
          'TRANSLATEENABLE': message.translateEnable,
          'TRANSLATETEXT': message.translateText
        }
        await taskpool.execute(insertSendPicMessageData, context, valueB, CONFIG)
        return;
      } else if (message.textType === 2) {
        console.info(`insertVideoMessageData ${JSON.stringify(message)}`)
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
          'REFERTEXT': message.referText,
          'REFERURI': message.referUri,
          'REFERWIDTH': message.referWidth,
          'REFERHEIGHT': message.referHeight,
          'TRANSLATEENABLE': message.translateEnable,
          'TRANSLATETEXT': message.translateText
        }
        await taskpool.execute(insertSendVideoMessageData, context, valueB, CONFIG)
        return;
      } else if (message.textType === 3) {
        console.info(`insertAudioMessageData ${JSON.stringify(message)}`)
        let valueB: relationalStore.ValuesBucket = {
          'MESSAGETYPE': message.messageType,
          'OWNERNAME': message.ownerName,
          'MESSAGESTATUS': message.messageStatus,
          'ERRORMESSAGE': message.errorMessage,
          'TEXTTYPE': message.textType,
          'AUDIOURI': message.audioUri,
          'AUDIOTIME': message.audioTime,
          'MESSAGEID': message.id,
          'REFERENABLE': message.referEnable,
          'REFERID': message.referId,
          'REFERTYPE': message.referType,
          'REFERTEXT': message.referText,
          'REFERURI': message.referUri,
          'REFERWIDTH': message.referWidth,
          'REFERHEIGHT': message.referHeight,
          'TRANSLATEENABLE': message.translateEnable,
          'TRANSLATETEXT': message.translateText
        }
        await taskpool.execute(insertSendAudioMessageData, context, valueB, CONFIG)
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
      'MESSAGEID': message.id
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
    console.info(`updateTranslate:${JSON.stringify(message)}`)
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
      'REFERTEXT': message.referText,
      'REFERURI': message.referUri,
      'REFERWIDTH': message.referWidth,
      'REFERHEIGHT': message.referHeight,
      'TRANSLATEENABLE': message.translateEnable,
      'TRANSLATETEXT': message.translateText
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

  /**
   * 插入数据
   * @param model
   */
  async insertImageGenMessage(model: ImageGenerationChatModel, context: Context) {
    let valueBundle: relationalStore.ValuesBucket = {
      'MESSAGECONTENT': model.messageContent,
      'MESSAGEOWNER': model.messageOwner,
      'MESSAGETYPE': model.messageType
    }
    await taskpool.execute(insertImageGenMessageData, context, valueBundle, CONFIG)
  }

  /**
   * 插入数据
   * @param model
   */
  async queryImageGenMessage(context: Context): Promise<ImageGenerationChatModel[]> {
    let mArr = await taskpool.execute(queryImageGenMessageData, context, CONFIG) as ImageGenerationChatModel[]
    for (let index = 0; index < mArr.length; index++) {
      const element = mArr[index];
      console.info(`nihao message: ${JSON.stringify(element)}`)
    }
    return mArr
  }
}

const databaseUtil: DatabaseUtil = new DatabaseUtil()

export default databaseUtil as DatabaseUtil