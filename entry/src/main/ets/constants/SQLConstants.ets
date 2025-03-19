export class SQLConstants {
  static readonly CREATE_TABLE = "CREATE TABLE IF NOT EXISTS chat_ai (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, messageType INTEGER, ownerName TEXT, request_id TEXT)";
}