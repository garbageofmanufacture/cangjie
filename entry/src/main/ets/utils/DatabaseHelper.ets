// src/main/ets/utils/DatabaseHelper.ets
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit'; // 👉 使用更精确的 UIAbilityContext 导入

export class DatabaseHelper {
  private static rdbStore: relationalStore.RdbStore | null = null;

  // 👉 注意这里改成了 common.UIAbilityContext
  public static async initDb(context: common.UIAbilityContext): Promise<void> {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'AgricultureForum.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      DatabaseHelper.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      hilog.info(0x0000, 'testTag', '✅ 数据库实例获取成功！');
      await DatabaseHelper.createTables();
    } catch (err) {
      hilog.error(0x0000, 'testTag', `❌ 数据库初始化失败: ${JSON.stringify(err)}`);
    }
  }

  private static async createTables(): Promise<void> {
    if (!DatabaseHelper.rdbStore) return;

    const sqlUser = `CREATE TABLE IF NOT EXISTS User (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT UNIQUE NOT NULL, password TEXT NOT NULL, username TEXT NOT NULL, role INTEGER DEFAULT 0, bio TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`;
    const sqlPost = `CREATE TABLE IF NOT EXISTS Post (id INTEGER PRIMARY KEY AUTOINCREMENT, author_id TEXT NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL, views INTEGER DEFAULT 0, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`;
    const sqlQA = `CREATE TABLE IF NOT EXISTS ExpertQA (id INTEGER PRIMARY KEY AUTOINCREMENT, questioner_id TEXT NOT NULL, expert_id TEXT, question TEXT NOT NULL, answer TEXT, status INTEGER DEFAULT 0, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`;
    const sqlCalendar = `CREATE TABLE IF NOT EXISTS Calendar (id INTEGER PRIMARY KEY AUTOINCREMENT, solar_term TEXT NOT NULL, advice TEXT NOT NULL, crop_type TEXT)`;
    const sqlProduct = `CREATE TABLE IF NOT EXISTS Product (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, price REAL NOT NULL, stock INTEGER DEFAULT 0, image_url TEXT)`;

    try {
      await DatabaseHelper.rdbStore.executeSql(sqlUser);
      await DatabaseHelper.rdbStore.executeSql(sqlPost);
      await DatabaseHelper.rdbStore.executeSql(sqlQA);
      await DatabaseHelper.rdbStore.executeSql(sqlCalendar);
      await DatabaseHelper.rdbStore.executeSql(sqlProduct);
      hilog.info(0x0000, 'testTag', '✅ 所有核心数据表创建成功！');
    } catch (err) {
      hilog.error(0x0000, 'testTag', `❌ 建表执行失败: ${JSON.stringify(err)}`);
    }
  }

  public static getStore(): relationalStore.RdbStore | null {
    return DatabaseHelper.rdbStore;
  }
}