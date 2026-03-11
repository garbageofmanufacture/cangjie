// src/main/ets/utils/DatabaseHelper.ets
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

// 🌟 用户资料的数据结构
export interface UserProfileInfo {
  username: string;
  email: string;
  address: string;
}

// 🌟 帖子列表的数据结构（严格模式必须定义，消灭 any）
export interface PostItemData {
  title: string;
  content: string;
  time: string;
}

export class DatabaseHelper {
  private static rdbStore: relationalStore.RdbStore | null = null;

  public static async initDb(context: common.UIAbilityContext): Promise<void> {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'AgricultureForum.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      DatabaseHelper.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      hilog.info(0x0000, 'testTag', '✅ 数据库实例获取成功！');
      await DatabaseHelper.createTables();
      await DatabaseHelper.initAdminUser();
    } catch (err) {
      hilog.error(0x0000, 'testTag', `❌ 数据库初始化失败: ${JSON.stringify(err)}`);
    }
  }

  private static async createTables(): Promise<void> {
    if (!DatabaseHelper.rdbStore) return;

    // 创建核心数据表
    const sqlUser = `CREATE TABLE IF NOT EXISTS User (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT UNIQUE NOT NULL, password TEXT NOT NULL, username TEXT NOT NULL, role INTEGER DEFAULT 0, bio TEXT, email TEXT, address TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`;
    const sqlPost = `CREATE TABLE IF NOT EXISTS Post (id INTEGER PRIMARY KEY AUTOINCREMENT, author_id TEXT NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL, views INTEGER DEFAULT 0, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`;
    const sqlQA = `CREATE TABLE IF NOT EXISTS ExpertQA (id INTEGER PRIMARY KEY AUTOINCREMENT, questioner_id TEXT NOT NULL, expert_id TEXT, question TEXT NOT NULL, answer TEXT, status INTEGER DEFAULT 0, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)`;
    const sqlCalendar = `CREATE TABLE IF NOT EXISTS Calendar (id INTEGER PRIMARY KEY AUTOINCREMENT, solar_term TEXT NOT NULL, advice TEXT NOT NULL, crop_type TEXT)`;
    const sqlProduct = `CREATE TABLE IF NOT EXISTS Product (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, price REAL NOT NULL, stock INTEGER DEFAULT 0, image_url TEXT)`;

    // 你写的包含新字段的建表语句，非常正确！
    const sqlComment = `CREATE TABLE IF NOT EXISTS Comment ( id INTEGER PRIMARY KEY AUTOINCREMENT,post_id INTEGER NOT NULL,author_id TEXT NOT NULL,content TEXT NOT NULL,created_at DATETIME DEFAULT CURRENT_TIMESTAMP,parent_id INTEGER DEFAULT 0,target_author TEXT DEFAULT '')`;

    try {
      await DatabaseHelper.rdbStore.executeSql(sqlUser);
      await DatabaseHelper.rdbStore.executeSql(sqlPost);
      await DatabaseHelper.rdbStore.executeSql(sqlQA);
      await DatabaseHelper.rdbStore.executeSql(sqlCalendar);
      await DatabaseHelper.rdbStore.executeSql(sqlProduct);
      await DatabaseHelper.rdbStore.executeSql(sqlComment);

      // 🌟 数据库无痛升级补丁：自动为旧版本 App 追加新字段
      // 加上这两句，你以后都不用手动卸载重装 App 啦！
      try {
        await DatabaseHelper.rdbStore.executeSql(`ALTER TABLE Comment ADD COLUMN parent_id INTEGER DEFAULT 0`);
        await DatabaseHelper.rdbStore.executeSql(`ALTER TABLE Comment ADD COLUMN target_author TEXT DEFAULT ''`);
        hilog.info(0x0000, 'testTag', '✅ Comment表旧数据字段热升级成功！');
      } catch (alterErr) {
        // 如果报错，说明字段已经存在（或者是新安装的App），直接忽略即可，不影响正常运行
        hilog.info(0x0000, 'testTag', '💡 Comment表字段已是最新，无需热升级。');
      }

      hilog.info(0x0000, 'testTag', '✅ 所有核心数据表创建/校验成功！');
    } catch (err) {
      hilog.error(0x0000, 'testTag', `❌ 建表执行失败: ${JSON.stringify(err)}`);
    }
  }

<<<<<<< HEAD
  // === 用户相关操作 ===

  // 读取真实用户数据
  public static async getUserProfile(userId: string): Promise<UserProfileInfo | null> {
    if (!DatabaseHelper.rdbStore) return null;
    let predicates = new relationalStore.RdbPredicates("User");
    predicates.equalTo("user_id", userId);
    try {
      let resultSet = await DatabaseHelper.rdbStore.query(predicates);
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        let email = resultSet.getString(resultSet.getColumnIndex("email")) || '';
        let address = resultSet.getString(resultSet.getColumnIndex("address")) || '';
        let username = resultSet.getString(resultSet.getColumnIndex("username")) || '';
        resultSet.close();
        return { email, address, username };
      }
      resultSet.close();
      return null;
    } catch (e) { return null; }
  }

  // 将用户修改的数据回写数据库
  public static async updateUserProfile(userId: string, email: string, address: string): Promise<boolean> {
    if (!DatabaseHelper.rdbStore) return false;
    let predicates = new relationalStore.RdbPredicates("User");
    predicates.equalTo("user_id", userId);
    let values: relationalStore.ValuesBucket = { "email": email, "address": address };
    try {
      let rows = await DatabaseHelper.rdbStore.update(values, predicates);
      return rows > 0;
    } catch (e) { return false; }
  }

  // === 帖子检索操作 ===

  // 🌟 新增：根据账号检索该用户发布的所有帖子
  public static async getMyPosts(userId: string): Promise<PostItemData[]> {
    if (!DatabaseHelper.rdbStore) return [];

    let predicates = new relationalStore.RdbPredicates("Post");
    // 兼容查询当前登录账号，或者是之前演示用的“热心农友”
    predicates.equalTo("author_id", userId).or().equalTo("author_id", "热心农友");
    predicates.orderByDesc("id"); // 最新发布的排在前面（按ID倒序）
=======
  // 🌟 预设管理员 admin 账号
  private static async initAdminUser(): Promise<void> {
    if (!DatabaseHelper.rdbStore) return;
>>>>>>> dd3b6d05c6cd0c939cc61c466404ee49d82bc14f

    try {
      let resultSet = await DatabaseHelper.rdbStore.query(predicates);
      let posts: PostItemData[] = [];
      while (resultSet.goToNextRow()) {
        posts.push({
          title: resultSet.getString(resultSet.getColumnIndex("title")),
          content: resultSet.getString(resultSet.getColumnIndex("content")),
          time: "已发布"
        });
      }
      resultSet.close();
      return posts;
    } catch (e) {
      return [];
    }
  }

  // === 系统操作 ===

  private static async initAdminUser(): Promise<void> {
    if (!DatabaseHelper.rdbStore) return;
    try {
      let predicates = new relationalStore.RdbPredicates("User");
      predicates.equalTo("user_id", "admin");
      let resultSet = await DatabaseHelper.rdbStore.query(predicates);
      if (resultSet.rowCount === 0) {
        const values: relationalStore.ValuesBucket = {
          "user_id": "admin", "password": "123123", "username": "超级管理员", "role": 1, "bio": "系统最高权限管理员"
        };
        await DatabaseHelper.rdbStore.insert("User", values);
      }
      resultSet.close();
    } catch (err) {}
  }

  public static getStore(): relationalStore.RdbStore | null {
    return DatabaseHelper.rdbStore;
  }
}