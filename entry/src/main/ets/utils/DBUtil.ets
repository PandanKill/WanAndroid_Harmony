import relationalStore from "@ohos.data.relationalStore";
import { BusinessError } from "@kit.BasicServicesKit";
import { SQLConstants } from "../constants/SQLConstants";

let context = getContext(this)

let store: relationalStore.RdbStore | undefined = undefined

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: "WanAndroid.db",
  securityLevel: relationalStore.SecurityLevel.S2
}

export class DBUtil {
  createDB() {
    relationalStore.getRdbStore(context, STORE_CONFIG, (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
      if (err) {
        console.error("getRdbStore error")
        return
      }
      store = rdbStore
      rdbStore.executeSql(SQLConstants.CREATE_TABLE, (err) => {
        if (err) {
          console.error("create table error")
          return
        }

        console.info("create table succ.")
      })
    })
  }
}

let dbUtil = new DBUtil()

export default dbUtil as DBUtil;