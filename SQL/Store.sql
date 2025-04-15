/*
 Navicat Premium Dump SQL

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80041 (8.0.41)
 Source Host           : localhost:3306
 Source Schema         : 1_auth

 Target Server Type    : MySQL
 Target Server Version : 80041 (8.0.41)
 File Encoding         : 65001

 Date: 16/04/2025 07:02:08
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for 商城_分类
-- ----------------------------
DROP TABLE IF EXISTS `商城_分类`;
CREATE TABLE `商城_分类`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `分类名字` varchar(765) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `图标` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `所需GM级别` int NULL DEFAULT NULL,
  `启用分类` int UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of 商城_分类
-- ----------------------------
INSERT INTO `商城_分类` VALUES (1, '新品推荐', 'inv_misc_questionmark', 0, 1);
INSERT INTO `商城_分类` VALUES (2, '国补低价', 'spell_magic_polymorphrabbit', 0, 1);
INSERT INTO `商城_分类` VALUES (3, '普通物品', 'inv_holiday_summerfest_petals', 0, 1);
INSERT INTO `商城_分类` VALUES (4, '七十二变', 'inv_misc_toy_07', 0, 1);
INSERT INTO `商城_分类` VALUES (5, '坐骑宠物', 'inv_box_petcarrier_01', 0, 1);
INSERT INTO `商城_分类` VALUES (6, '增益光环', 'achievement_halloween_smiley_01', 0, 1);
INSERT INTO `商城_分类` VALUES (7, '专业精通', 'trade_engineering', 0, 1);
INSERT INTO `商城_分类` VALUES (8, '法术技能', 'spell_deathknight_bloodtap', 0, 1);
INSERT INTO `商城_分类` VALUES (9, '幻化模型', 'inv_sword_139', 0, 1);
INSERT INTO `商城_分类` VALUES (10, '头衔称号', 'inv_misc_groupneedmore', 0, 1);
INSERT INTO `商城_分类` VALUES (11, '角色定制', 'inv_sigil_mimiron', 0, 1);
INSERT INTO `商城_分类` VALUES (12, '高级功能', 'mail_gmicon', 1, 0);
INSERT INTO `商城_分类` VALUES (13, '货币兑换', 'inv_misc_coin_02', 0, 1);

-- ----------------------------
-- Table structure for 商城_货币
-- ----------------------------
DROP TABLE IF EXISTS `商城_货币`;
CREATE TABLE `商城_货币`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `货币程序类别` int UNSIGNED NOT NULL DEFAULT 1,
  `货币名称` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `图标` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `物品ID` int NOT NULL DEFAULT 0,
  `提示信息` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of 商城_货币
-- ----------------------------
INSERT INTO `商城_货币` VALUES (1, 1, '积分', 'inv_misc_coin_01', 0, '');
INSERT INTO `商城_货币` VALUES (2, 2, '经验', 'mail_gmicon', 29434, '');
INSERT INTO `商城_货币` VALUES (3, 3, '荣誉', 'inv_bannerpvp_01', 0, '');
INSERT INTO `商城_货币` VALUES (4, 4, '声望', 'inv_bannerpvp_02', 0, '');

-- ----------------------------
-- Table structure for 商城_日志
-- ----------------------------
DROP TABLE IF EXISTS `商城_日志`;
CREATE TABLE `商城_日志`  (
  `账号ID` int NULL DEFAULT NULL,
  `角色ID` int NULL DEFAULT NULL,
  `角色名` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `商品` int NULL DEFAULT NULL,
  `货币` int NULL DEFAULT NULL,
  `费用` int NULL DEFAULT NULL,
  `购买时间` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of 商城_日志
-- ----------------------------

-- ----------------------------
-- Table structure for 商城_商品
-- ----------------------------
DROP TABLE IF EXISTS `商城_商品`;
CREATE TABLE `商城_商品`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `分类` int NULL DEFAULT NULL,
  `程序` int UNSIGNED NULL DEFAULT NULL,
  `名字` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `代币` int UNSIGNED NULL DEFAULT NULL,
  `价格` int NULL DEFAULT NULL,
  `折掉` int NULL DEFAULT NULL,
  `标题名` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `标题类` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `标题文` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `图标` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `货物链接` int NULL DEFAULT NULL,
  `生物或专业` int NULL DEFAULT NULL,
  `特殊标记` int NULL DEFAULT NULL,
  `获得1` int UNSIGNED NULL DEFAULT NULL,
  `获得2` int UNSIGNED NULL DEFAULT NULL,
  `获得3` int UNSIGNED NULL DEFAULT NULL,
  `获得4` int UNSIGNED NULL DEFAULT NULL,
  `获得5` int UNSIGNED NULL DEFAULT NULL,
  `获得6` int UNSIGNED NULL DEFAULT NULL,
  `获得7` int UNSIGNED NULL DEFAULT NULL,
  `获得8` int UNSIGNED NULL DEFAULT NULL,
  `得1数` int UNSIGNED NULL DEFAULT NULL,
  `得2数` int UNSIGNED NULL DEFAULT NULL,
  `得3数` int UNSIGNED NULL DEFAULT NULL,
  `得4数` int UNSIGNED NULL DEFAULT NULL,
  `得5数` int UNSIGNED NULL DEFAULT NULL,
  `得6数` int UNSIGNED NULL DEFAULT NULL,
  `得7数` int UNSIGNED NULL DEFAULT NULL,
  `得8数` int UNSIGNED NULL DEFAULT NULL,
  `是否新品` int UNSIGNED NOT NULL DEFAULT 0,
  `当前可售` int UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1207 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of 商城_商品
-- ----------------------------
INSERT INTO `商城_商品` VALUES (1, 3, 1, '弗洛尔的无尽抗性宝箱', 1, 0, 0, '', 'item', '|cff00FFFF36格超大包裹|r', 'INV_Crate_04', 23162, 0, 0, 23162, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (2, 3, 1, '源生之能', 1, 0, 0, '', 'item', '|cff00FFFF测试一下,常用物品我是不卖的!|r', 'Spell_Nature_LightningOverload', 23571, 0, 0, 23571, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (3, 3, 1, '暗影布', 1, 0, 0, '', 'item', '|cff00FFFF测试一下,常用物品我是不卖的!|r', 'INV_Fabric_Felcloth_Ebon', 24272, 0, 0, 24272, 0, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (4, 3, 1, '钓鱼椅', 1, 0, 0, '', 'item', '|cff00FFFF可以随时使用的休闲钓鱼椅!|r', 'inv_fishingchair', 33223, 0, 1, 33223, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (5, 3, 1, '跳舞球', 1, 0, 0, '', 'item', '|cff00FFFF让周围人跳舞的音乐球!|r', 'inv_misc_discoball_01', 38301, 0, 1, 38301, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (6, 3, 1, '伊利丹之路', 1, 0, 0, '', 'item', '|cff00FFFF在你走过的路上留下火焰!|r', 'spell_fire_felfire', 38233, 0, 0, 38233, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (7, 3, 1, '塞纳留斯之路', 1, 0, 0, '', 'item', '|cff00FFFF在你走过的路上留下鲜花!|r', 'inv_misc_trailofflowers', 46779, 0, 0, 46779, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (8, 3, 1, '艾露恩的蜡烛', 1, 0, 0, '', 'item', '|cff00FFFF向目标发射烟花，可用88次!|r', 'inv_musket_02', 44915, 0, 1, 44915, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (9, 3, 1, '希尔瓦娜斯的音乐盒', 1, 0, 0, '', 'item', '|cff00FFFF召唤2个唱歌的亡灵!|r', 'inv_misc_enggizmos_18', 52253, 0, 1, 52253, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (10, 4, 2, '食人魔玩偶', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Misc_Idol_01', 49704, 17134, 0, 49704, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (11, 4, 2, '穆拉丁的礼物', 1, 0, 0, '', 'item', '|cff00FFFF随机外观，和模型不一定一致，点击预览!|r', 'spell_frost_frostward', 52201, 30356, 0, 52201, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (12, 4, 2, '测试是否显示中文和自动换行的卡德加白胡子老爷爷模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Misc_Idol_01', 49704, 18166, 0, 49704, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (13, 5, 3, '奥的灰烬', 1, 0, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'Inv_Misc_SummerFest_BrazierOrange', 40192, 18545, 0, 40192, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (14, 5, 3, '星骓', 1, 0, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'ability_mount_celestialhorse', 75614, 40625, 0, 75614, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (15, 5, 3, '迅捷幽灵虎', 1, 0, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'ability_mount_spectraltiger', 42777, 24004, 0, 42777, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (16, 5, 3, '农场小鸡', 1, 0, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'spell_magic_polymorphchicken', 10686, 7392, 0, 10686, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (17, 6, 4, '强效王者祝福', 1, 0, 0, '', 'spell', '|cff00FFFF智慧祝福+全套基本BUFF!|r', 'Spell_Magic_GreaterBlessingofKings', 25898, 0, 0, 25898, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (18, 6, 4, '强效智慧祝福', 1, 0, 0, '', 'spell', '|cff00FFFF王者祝福+全套基本BUFF!|r', 'Spell_Holy_GreaterBlessingofWisdom', 48938, 0, 0, 48938, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (19, 6, 4, '强效力量祝福', 1, 0, 0, '', 'spell', '|cff00FFFF力量祝福+全套基本BUFF!|r', 'Spell_Holy_GreaterBlessingofKings', 48934, 0, 0, 48934, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (20, 6, 4, '强效庇护祝福', 1, 0, 0, '', 'spell', '|cff00FFFF庇护祝福+全套基本BUFF!|r', 'Spell_Holy_GreaterBlessingofSanctuary', 25899, 0, 0, 25899, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (21, 6, 4, '超级猴子球魔法效果', 1, 0, 0, '', 'spell', '|cff00FFFF变成泡泡内变成疯狂的猴子，持续5分钟|r', 'INV_Misc_gem_pearl_04', 48332, 0, 0, 48332, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (22, 7, 5, '附魔', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Engraving', 0, 333, 375, 7411, 7412, 7413, 13920, 28029, 51313, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (23, 7, 5, '采矿', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Mining', 0, 186, 375, 2575, 2576, 3564, 10248, 29354, 50310, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (24, 7, 5, '草药', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Herbalism', 0, 182, 375, 2366, 2368, 3570, 11993, 28695, 50300, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (25, 7, 5, '剥皮', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_Pelt_Wolf_01', 0, 393, 375, 8613, 8617, 8618, 10768, 32678, 50305, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (26, 7, 5, '工程', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级r', 'Trade_Engineering', 0, 202, 375, 4036, 4037, 4038, 12656, 30350, 51306, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (27, 7, 5, '炼金', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Alchemy', 0, 171, 375, 2259, 3101, 3464, 11611, 28596, 51304, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (28, 7, 5, '制皮', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_ArmorKit_17', 0, 165, 375, 2108, 3104, 3811, 10662, 32549, 51302, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (29, 7, 5, '裁缝', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Tailoring', 0, 197, 375, 3908, 3909, 3910, 12180, 26790, 51309, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (30, 7, 5, '锻造', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_BlackSmithing', 0, 164, 375, 2018, 3100, 3538, 9785, 29844, 51300, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (31, 7, 5, '珠宝', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_Gem_02', 0, 755, 375, 25229, 25230, 28894, 28895, 28897, 51311, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (32, 7, 5, '铭文', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Inscription_Tradeskill01', 0, 773, 375, 45357, 45358, 45359, 45360, 45361, 45363, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (33, 7, 5, '烹饪', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_Food_15', 0, 185, 375, 2550, 3102, 3413, 18260, 33359, 51296, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (34, 7, 5, '急救', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Spell_Holy_SealOfSacrifice', 0, 129, 375, 3273, 3274, 7924, 10846, 27028, 45542, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (35, 7, 5, '钓鱼', 1, 0, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Fishing', 0, 356, 375, 7620, 7731, 7732, 18248, 33095, 51294, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (36, 8, 6, '风怒武器', 1, 0, 0, '', 'spell', '|cff00FFFF教你学会这个技能！|r', 'Spell_Nature_Cyclone', 58804, 0, 0, 58804, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (37, 9, 7, '变身法袍', 1, 0, 0, '', 'item', '|cff00FFFF附加变身技能的袍子，点击预览!|r', 'inv_shirt_guildtabard_01', 38310, 0, 0, 38310, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (38, 9, 7, '堕落的灰烬使者模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_2h_ashbringercorrupt', 61001, 0, 0, 61001, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (39, 9, 7, '末日决战模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_104', 61002, 0, 0, 61002, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (40, 9, 7, '黑冰模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_weapon_halberd17', 61003, 0, 0, 61003, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (41, 9, 7, '亡灵杀手模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_62', 61004, 0, 0, 61004, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (42, 9, 7, '冰雹模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_122', 61005, 0, 0, 61005, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (43, 9, 7, '我的泪洒黑暗湮灭之间模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_136', 61006, 0, 0, 61006, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (44, 9, 7, '霜之暗伤模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_92', 61007, 0, 0, 61007, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (45, 9, 7, '湮灭子牙模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_weapon_shortblade_84', 61008, 0, 0, 61008, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (46, 9, 7, '食尸鬼切割者模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_119', 61009, 0, 0, 61009, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (47, 9, 7, '雷霆之怒逐风者祝福之剑模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_39', 17802, 0, 0, 17802, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (48, 9, 7, '泡沫塑料剑', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'inv_sword_22', 45061, 0, 0, 45061, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (49, 9, 7, '史诗级紫色衬衫', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'inv_shirt_purple_01', 45037, 0, 0, 45037, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (50, 9, 7, '冰川长袍模型', 1, 0, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_chest_cloth_08', 61101, 0, 0, 61101, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (51, 9, 7, '礼服套装', 1, 0, 0, '', 'item', '|cff00FFFF礼服三件套,点击预览!|r', 'inv_shirt_black_01', 0, 0, 0, 10036, 10035, 10034, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (52, 9, 7, '无畏套装', 1, 0, 0, '', 'item', '|cff00FFFF无畏八件套,点击预览!|r', 'INV_Helmet_01', 0, 0, 0, 22416, 22417, 22418, 22419, 22420, 22421, 22422, 22423, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (53, 9, 7, '救赎套装', 1, 0, 0, '', 'item', '|cff00FFFF救赎八件套,点击预览!|r', 'INV_Helmet_02', 0, 0, 0, 22424, 22425, 22426, 22427, 22428, 22429, 22430, 22431, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (54, 9, 7, '地穴追猎套装', 1, 0, 0, '', 'item', '|cff00FFFF地穴追猎八件套,点击预览!|r', 'INV_Helmet_03', 0, 0, 0, 22436, 22437, 22438, 22439, 22440, 22441, 22442, 22443, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (55, 9, 7, '碎地者套装', 1, 0, 0, '', 'item', '|cff00FFFF碎地者八件套,点击预览!|r', 'INV_Helmet_04', 0, 0, 0, 22464, 22465, 22466, 22467, 22468, 22469, 22470, 22471, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (56, 9, 7, '骨镰套装', 1, 0, 0, '', 'item', '|cff00FFFF骨镰八件套,点击预览!|r', 'INV_Helmet_05', 0, 0, 0, 22476, 22477, 22478, 22479, 22480, 22481, 22482, 22483, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (57, 9, 7, '梦游者套装', 1, 0, 0, '', 'item', '|cff00FFFF梦游者八件套,点击预览!|r', 'INV_Helmet_06', 0, 0, 0, 22488, 22489, 22490, 22491, 22492, 22493, 22494, 22495, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (58, 9, 7, '霜火套装', 1, 0, 0, '', 'item', '|cff00FFFF霜火八件套,点击预览!|r', 'INV_Helmet_07', 0, 0, 0, 22496, 22497, 22498, 22499, 22500, 22501, 22502, 22503, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (59, 9, 7, '瘟疫之心套装', 1, 0, 0, '', 'item', '|cff00FFFF瘟疫之心八件套,点击预览!|r', 'INV_Helmet_08', 0, 0, 0, 22504, 22505, 22506, 22507, 22508, 22509, 22510, 22511, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (60, 9, 7, '信仰套装', 1, 0, 0, '', 'item', '|cff00FFFF信仰八件套,点击预览!|r', 'INV_Helmet_09', 0, 0, 0, 22512, 22513, 22514, 22515, 22516, 22517, 22518, 22519, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0);
INSERT INTO `商城_商品` VALUES (61, 10, 8, '纳鲁的冠军', 1, 0, 0, '头衔', '', '纳鲁的冠军', 'inv_mace_51', 0, 0, 0, 53, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (62, 10, 8, '大元帅', 1, 0, 0, '头衔', '', '大元帅', 'Achievement_PVP_A_A', 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (63, 10, 8, '高阶督军', 1, 0, 0, '头衔', '', '高阶督军', 'Achievement_PVP_H_H', 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (64, 11, 9, '等级提升1级', 1, 0, 0, '升级服务', '', '将你的角色等级提高1级。', 'Achievement_PVP_O_15', 0, 0, 70, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (65, 11, 9, '等级提升10级', 1, 0, 0, '升级服务', '', '将你的角色等级提高10级。', 'achievement_level_10', 0, 0, 70, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (66, 11, 9, '等级提升20级', 1, 0, 0, '升级服务', '', '将你的角色等级提高20。', 'achievement_level_20', 0, 0, 70, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (67, 11, 9, '直升满级', 1, 0, 0, '升级服务', '', '将你的角色等级提升到满级！', 'achievement_level_80', 0, 0, 70, 80, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (68, 11, 10, '名字自助变更', 1, 0, 0, '角色服务', '', '允许你改变你的角色名称,小退后修改。', 'vas_namechange', 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (69, 11, 10, '种族自助变更', 1, 0, 0, '角色服务', '', '允许你改变你的角色种族,小退后修改。', 'vas_racechange', 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (70, 11, 10, '阵营自助变更', 1, 0, 0, '角色服务', '', '允许你改变你的角色阵营,小退后修改。', 'vas_factionchange', 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (71, 12, 11, '更改目标名字', 1, 0, 0, '角色服务', '', '|cffff0000注意代为收费!扣你的钱更改目标名字!|r', 'vas_namechange', 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (72, 12, 11, '变更目标种族', 1, 0, 0, '角色服务', '', '|cffff0000注意代为收费!扣你的钱更改目标种族和名字!|r', 'vas_racechange', 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (73, 12, 11, '变更目标阵营', 1, 0, 0, '角色服务', '', '|cffff0000注意代为收费!扣你的钱更改目标阵营和名字!|r', 'vas_factionchange', 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;
