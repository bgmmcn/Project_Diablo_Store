/*
 Navicat Premium Data Transfer

 Source Server         : 10.1.2.3家里正式服
 Source Server Type    : MariaDB
 Source Server Version : 101104
 Source Host           : 10.1.2.3:53306
 Source Schema         : 商城

 Target Server Type    : MariaDB
 Target Server Version : 101104
 File Encoding         : 65001

 Date: 25/10/2023 23:53:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for 商品
-- ----------------------------
DROP TABLE IF EXISTS `商城_商品`;
CREATE TABLE `商城_商品`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `分类` int(10) NULL DEFAULT NULL,
  `程序` int(10) UNSIGNED NULL DEFAULT NULL,
  `名字` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `代币` int(11) UNSIGNED NULL DEFAULT NULL,
  `价格` int(11) NULL DEFAULT NULL,
  `折掉` int(11) NULL DEFAULT NULL,
  `标题名` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `标题类` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `标题文` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `图标` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `货物链接` int(11) NULL DEFAULT NULL,
  `生物或专业` int(11) NULL DEFAULT NULL,
  `特殊标记` int(11) NULL DEFAULT NULL,
  `获得1` int(10) UNSIGNED NULL DEFAULT NULL,
  `获得2` int(10) UNSIGNED NULL DEFAULT NULL,
  `获得3` int(10) UNSIGNED NULL DEFAULT NULL,
  `获得4` int(10) UNSIGNED NULL DEFAULT NULL,
  `获得5` int(10) UNSIGNED NULL DEFAULT NULL,
  `获得6` int(10) UNSIGNED NULL DEFAULT NULL,
  `获得7` int(10) UNSIGNED NULL DEFAULT NULL,
  `获得8` int(10) UNSIGNED NULL DEFAULT NULL,
  `得1数` int(10) UNSIGNED NULL DEFAULT NULL,
  `得2数` int(10) UNSIGNED NULL DEFAULT NULL,
  `得3数` int(10) UNSIGNED NULL DEFAULT NULL,
  `得4数` int(10) UNSIGNED NULL DEFAULT NULL,
  `得5数` int(10) UNSIGNED NULL DEFAULT NULL,
  `得6数` int(10) UNSIGNED NULL DEFAULT NULL,
  `得7数` int(10) UNSIGNED NULL DEFAULT NULL,
  `得8数` int(10) UNSIGNED NULL DEFAULT NULL,
  `是否新品` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `当前可售` int(10) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1219 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of 商品
-- ----------------------------
INSERT INTO `商城_商品` VALUES (301, 3, 3, '弗洛尔的无尽抗性宝箱', 3, 1200, 200, '', 'item', '|cff00FFFF36格超大包裹|r', 'INV_Crate_04', 23162, 0, 0, 23162, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (302, 3, 3, '源生之能', 2, 120, 20, '', 'item', '|cff00FFFF测试一下,常用物品我是不卖的!|r', 'Spell_Nature_LightningOverload', 23571, 0, 0, 23571, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (303, 3, 3, '暗影布', 1, 1500, 0, '', 'item', '|cff00FFFF测试一下,常用物品我是不卖的!|r', 'INV_Fabric_Felcloth_Ebon', 24272, 0, 0, 24272, 0, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (304, 3, 3, '钓鱼椅', 3, 888, 0, '', 'item', '|cff00FFFF可以随时使用的休闲钓鱼椅!|r', 'inv_fishingchair', 33223, 0, 1, 33223, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (305, 3, 3, '跳舞球', 3, 888, 0, '', 'item', '|cff00FFFF让周围人跳舞的音乐球!|r', 'inv_misc_discoball_01', 38301, 0, 1, 38301, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (306, 3, 3, '伊利丹之路', 3, 200, 20, '', 'item', '|cff00FFFF在你走过的路上留下火焰!|r', 'spell_fire_felfire', 38233, 0, 0, 38233, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (307, 3, 3, '塞纳留斯之路', 3, 200, 20, '', 'item', '|cff00FFFF在你走过的路上留下鲜花!|r', 'inv_misc_trailofflowers', 46779, 0, 0, 46779, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (308, 3, 3, '艾露恩的蜡烛', 3, 888, 88, '', 'item', '|cff00FFFF向目标发射烟花，可用88次!|r', 'inv_musket_02', 44915, 0, 1, 44915, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (309, 3, 3, '希尔瓦娜斯的音乐盒', 3, 1000, 0, '', 'item', '|cff00FFFF召唤2个唱歌的亡灵!|r', 'inv_misc_enggizmos_18', 52253, 0, 1, 52253, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (401, 4, 4, '食人魔玩偶', 3, 500, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Misc_Idol_01', 49704, 17134, 0, 49704, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (402, 4, 4, '穆拉丁的礼物', 3, 500, 0, '', 'item', '|cff00FFFF随机外观，和模型不一定一致，点击预览!|r', 'spell_frost_frostward', 52201, 30356, 0, 52201, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (403, 4, 4, '测试是否显示中文和自动换行的卡德加白胡子老爷爷模型', 3, 50000, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Misc_Idol_01', 49704, 18166, 0, 49704, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (501, 5, 5, '奥的灰烬', 3, 36000, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'Inv_Misc_SummerFest_BrazierOrange', 40192, 18545, 0, 40192, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (502, 5, 5, '星骓', 3, 6000, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'ability_mount_celestialhorse', 75614, 40625, 0, 75614, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (503, 5, 5, '迅捷幽灵虎', 3, 6000, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'ability_mount_spectraltiger', 42777, 24004, 0, 42777, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (504, 5, 5, '农场小鸡', 3, 1000, 0, '', 'spell', '|cff00FFFF点击预览!|r', 'spell_magic_polymorphchicken', 10686, 7392, 0, 10686, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (601, 6, 6, '强效王者祝福', 1, 50, 0, '', 'spell', '|cff00FFFF智慧祝福+全套基本BUFF!|r', 'Spell_Magic_GreaterBlessingofKings', 25898, 0, 0, 25898, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (602, 6, 6, '强效智慧祝福', 1, 50, 0, '', 'spell', '|cff00FFFF王者祝福+全套基本BUFF!|r', 'Spell_Holy_GreaterBlessingofWisdom', 48938, 0, 0, 48938, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (603, 6, 6, '强效力量祝福', 1, 50, 0, '', 'spell', '|cff00FFFF力量祝福+全套基本BUFF!|r', 'Spell_Holy_GreaterBlessingofKings', 48934, 0, 0, 48934, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (604, 6, 6, '强效庇护祝福', 1, 50, 0, '', 'spell', '|cff00FFFF庇护祝福+全套基本BUFF!|r', 'Spell_Holy_GreaterBlessingofSanctuary', 25899, 0, 0, 25899, 43002, 48162, 48074, 48470, 48170, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (605, 6, 6, '超级猴子球魔法效果', 1, 50, 0, '', 'spell', '|cff00FFFF变成泡泡内变成疯狂的猴子，持续5分钟|r', 'INV_Misc_gem_pearl_04', 48332, 0, 0, 48332, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (701, 7, 7, '附魔', 3, 2000, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Engraving', 0, 333, 375, 7411, 7412, 7413, 13920, 28029, 51313, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (702, 7, 7, '采矿', 3, 1500, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Mining', 0, 186, 375, 2575, 2576, 3564, 10248, 29354, 50310, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (703, 7, 7, '草药', 3, 1500, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Herbalism', 0, 182, 375, 2366, 2368, 3570, 11993, 28695, 50300, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (704, 7, 7, '剥皮', 3, 1500, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_Pelt_Wolf_01', 0, 393, 375, 8613, 8617, 8618, 10768, 32678, 50305, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (705, 7, 7, '工程', 3, 2000, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级r', 'Trade_Engineering', 0, 202, 375, 4036, 4037, 4038, 12656, 30350, 51306, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (706, 7, 7, '炼金', 3, 2000, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Alchemy', 0, 171, 375, 2259, 3101, 3464, 11611, 28596, 51304, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (707, 7, 7, '制皮', 3, 2000, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_ArmorKit_17', 0, 165, 375, 2108, 3104, 3811, 10662, 32549, 51302, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (708, 7, 7, '裁缝', 3, 2000, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Tailoring', 0, 197, 375, 3908, 3909, 3910, 12180, 26790, 51309, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (709, 7, 7, '锻造', 3, 2000, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_BlackSmithing', 0, 164, 375, 2018, 3100, 3538, 9785, 29844, 51300, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (710, 7, 7, '珠宝', 3, 2000, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_Gem_02', 0, 755, 375, 25229, 25230, 28894, 28895, 28897, 51311, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (711, 7, 7, '铭文', 3, 1500, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Inscription_Tradeskill01', 0, 773, 375, 45357, 45358, 45359, 45360, 45361, 45363, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (712, 7, 7, '烹饪', 3, 1500, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'INV_Misc_Food_15', 0, 185, 375, 2550, 3102, 3413, 18260, 33359, 51296, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (713, 7, 7, '急救', 3, 1500, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Spell_Holy_SealOfSacrifice', 0, 129, 375, 3273, 3274, 7924, 10846, 27028, 45542, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (714, 7, 7, '钓鱼', 3, 1500, 0, '', 'spell', '|cff00FFFF将熟练度提升至满级|r', 'Trade_Fishing', 0, 356, 375, 7620, 7731, 7732, 18248, 33095, 51294, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (801, 8, 8, '风怒武器', 3, 100000, 0, '', 'spell', '|cff00FFFF教你学会这个技能！|r', 'Spell_Nature_Cyclone', 58804, 0, 0, 58804, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `商城_商品` VALUES (900, 9, 9, '变身法袍', 3, 8888, 0, '', 'item', '|cff00FFFF附加变身技能的袍子，点击预览!|r', 'inv_shirt_guildtabard_01', 38310, 0, 0, 38310, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (901, 9, 9, '堕落的灰烬使者模型', 3, 3500, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_2h_ashbringercorrupt', 61001, 0, 0, 61001, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (902, 9, 9, '末日决战模型', 3, 3500, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_104', 61002, 0, 0, 61002, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (903, 9, 9, '黑冰模型', 3, 2200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_weapon_halberd17', 61003, 0, 0, 61003, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (904, 9, 9, '亡灵杀手模型', 3, 1200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_62', 61004, 0, 0, 61004, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (905, 9, 9, '冰雹模型', 3, 2200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_122', 61005, 0, 0, 61005, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (906, 9, 9, '我的泪洒黑暗湮灭之间模型', 3, 1200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_136', 61006, 0, 0, 61006, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (907, 9, 9, '霜之暗伤模型', 3, 1200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_92', 61007, 0, 0, 61007, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (908, 9, 9, '湮灭子牙模型', 3, 1200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_weapon_shortblade_84', 61008, 0, 0, 61008, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (909, 9, 9, '食尸鬼切割者模型', 3, 1200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_119', 61009, 0, 0, 61009, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO `商城_商品` VALUES (910, 9, 9, '雷霆之怒逐风者祝福之剑模型', 3, 3500, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_Sword_39', 17802, 0, 0, 17802, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (911, 9, 9, '泡沫塑料剑', 3, 1000, 0, '', 'item', '|cff00FFFF点击预览!|r', 'inv_sword_22', 45061, 0, 0, 45061, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (912, 9, 9, '史诗级紫色衬衫', 3, 1000, 0, '', 'item', '|cff00FFFF点击预览!|r', 'inv_shirt_purple_01', 45037, 0, 0, 45037, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (913, 9, 9, '冰川长袍模型', 3, 1200, 0, '', 'item', '|cff00FFFF点击预览!|r', 'INV_chest_cloth_08', 61101, 0, 0, 61101, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (930, 9, 9, '礼服套装', 3, 1000, 0, '', 'item', '|cff00FFFF礼服三件套,点击预览!|r', 'inv_shirt_black_01', 0, 0, 0, 10036, 10035, 10034, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (941, 9, 9, '无畏套装', 3, 1000, 0, '', 'item', '|cff00FFFF无畏八件套,点击预览!|r', 'INV_Helmet_01', 0, 0, 0, 22416, 22417, 22418, 22419, 22420, 22421, 22422, 22423, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (942, 9, 9, '救赎套装', 3, 1000, 0, '', 'item', '|cff00FFFF救赎八件套,点击预览!|r', 'INV_Helmet_02', 0, 0, 0, 22424, 22425, 22426, 22427, 22428, 22429, 22430, 22431, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (943, 9, 9, '地穴追猎套装', 3, 1000, 0, '', 'item', '|cff00FFFF地穴追猎八件套,点击预览!|r', 'INV_Helmet_03', 0, 0, 0, 22436, 22437, 22438, 22439, 22440, 22441, 22442, 22443, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (944, 9, 9, '碎地者套装', 3, 1000, 0, '', 'item', '|cff00FFFF碎地者八件套,点击预览!|r', 'INV_Helmet_04', 0, 0, 0, 22464, 22465, 22466, 22467, 22468, 22469, 22470, 22471, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (945, 9, 9, '骨镰套装', 3, 1000, 0, '', 'item', '|cff00FFFF骨镰八件套,点击预览!|r', 'INV_Helmet_05', 0, 0, 0, 22476, 22477, 22478, 22479, 22480, 22481, 22482, 22483, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (946, 9, 9, '梦游者套装', 3, 1000, 0, '', 'item', '|cff00FFFF梦游者八件套,点击预览!|r', 'INV_Helmet_06', 0, 0, 0, 22488, 22489, 22490, 22491, 22492, 22493, 22494, 22495, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (947, 9, 9, '霜火套装', 3, 1000, 0, '', 'item', '|cff00FFFF霜火八件套,点击预览!|r', 'INV_Helmet_07', 0, 0, 0, 22496, 22497, 22498, 22499, 22500, 22501, 22502, 22503, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (948, 9, 9, '瘟疫之心套装', 3, 1000, 0, '', 'item', '|cff00FFFF瘟疫之心八件套,点击预览!|r', 'INV_Helmet_08', 0, 0, 0, 22504, 22505, 22506, 22507, 22508, 22509, 22510, 22511, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (949, 9, 9, '信仰套装', 3, 1000, 0, '', 'item', '|cff00FFFF信仰八件套,点击预览!|r', 'INV_Helmet_09', 0, 0, 0, 22512, 22513, 22514, 22515, 22516, 22517, 22518, 22519, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `商城_商品` VALUES (1001, 10, 10, '纳鲁的冠军', 3, 3000, 0, '头衔', '', '纳鲁的冠军', 'inv_mace_51', 0, 0, 0, 53, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1002, 10, 10, '大元帅', 3, 3000, 0, '头衔', '', '大元帅', 'Achievement_PVP_A_A', 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1003, 10, 10, '高阶督军', 3, 3000, 0, '头衔', '', '高阶督军', 'Achievement_PVP_H_H', 0, 0, 0, 28, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1101, 11, 11, '等级提升1级', 1, 240, 10, '升级服务', '', '将你的角色等级提高1级。', 'Achievement_PVP_O_15', 0, 0, 70, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1102, 11, 11, '等级提升10级', 3, 666, 0, '升级服务', '', '将你的角色等级提高10级。', 'achievement_level_10', 0, 0, 70, 10, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1103, 11, 11, '等级提升20级', 3, 1111, 0, '升级服务', '', '将你的角色等级提高20。', 'achievement_level_20', 0, 0, 70, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1104, 11, 11, '直升满级', 3, 4000, 600, '升级服务', '', '将你的角色等级提升到满级！', 'achievement_level_80', 0, 0, 70, 80, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1201, 11, 12, '名字自助变更', 3, 999999, 0, '角色服务', '', '允许你改变你的角色名称,小退后修改。', 'vas_namechange', 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1202, 11, 12, '种族自助变更', 3, 999999, 0, '角色服务', '', '允许你改变你的角色种族,小退后修改。', 'vas_racechange', 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1203, 11, 12, '阵营自助变更', 3, 999999, 0, '角色服务', '', '允许你改变你的角色阵营,小退后修改。', 'vas_factionchange', 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1204, 12, 13, '更改目标名字', 3, 3999, 0, '角色服务', '', '|cffff0000注意代为收费!扣你的钱更改目标名字!|r', 'vas_namechange', 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1205, 12, 13, '变更目标种族', 3, 3999, 0, '角色服务', '', '|cffff0000注意代为收费!扣你的钱更改目标种族和名字!|r', 'vas_racechange', 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO `商城_商品` VALUES (1206, 12, 13, '变更目标阵营', 3, 3999, 0, '角色服务', '', '|cffff0000注意代为收费!扣你的钱更改目标阵营和名字!|r', 'vas_factionchange', 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1);

-- ----------------------------
-- Table structure for 分类
-- ----------------------------
DROP TABLE IF EXISTS `商城_分类`;
CREATE TABLE `商城_分类`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `分类名字` varchar(765) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `图标` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `所需GM级别` int(11) NULL DEFAULT NULL,
  `启用分类` int(10) UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of 分类
-- ----------------------------
INSERT INTO `商城_分类` VALUES (1, '新品推荐', 'inv_helmet_96', 0, 1);
INSERT INTO `商城_分类` VALUES (2, '打折商品', 'inv_scroll_11', 0, 1);
INSERT INTO `商城_分类` VALUES (3, '商品材料', 'ability_warrior_challange', 0, 1);
INSERT INTO `商城_分类` VALUES (4, '变身道具', 'inv_misc_toy_07', 0, 1);
INSERT INTO `商城_分类` VALUES (5, '坐骑宠物', 'inv_box_petcarrier_01', 0, 1);
INSERT INTO `商城_分类` VALUES (6, '增益效果', 'spell_holy_arcaneIntellect', 0, 1);
INSERT INTO `商城_分类` VALUES (7, '专业技能', 'inv_misc_note_01', 0, 1);
INSERT INTO `商城_分类` VALUES (8, '魔法技能', 'spell_holy_holynova', 0, 0);
INSERT INTO `商城_分类` VALUES (9, '幻化装备', 'inv_misc_note_03', 0, 1);
INSERT INTO `商城_分类` VALUES (10, '头衔称号', 'spell_holy_surgeoflight', 0, 1);
INSERT INTO `商城_分类` VALUES (11, '系统服务', 'inv_misc_toy_05', 0, 1);
INSERT INTO `商城_分类` VALUES (12, 'GM服务', 'inv_misc_toy_05', 1, 1);

-- ----------------------------
-- Table structure for 货币
-- ----------------------------
DROP TABLE IF EXISTS `商城_货币`;
CREATE TABLE `商城_货币`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `货币程序类别` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `货币名称` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `图标` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `物品ID` int(11) NOT NULL DEFAULT 0,
  `提示信息` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of 货币
-- ----------------------------
INSERT INTO `商城_货币` VALUES (1, 1, '金币', 'INV_Misc_Coin_01', 0, '');
INSERT INTO `商城_货币` VALUES (2, 2, '公正徽章', 'Spell_Holy_ChampionsBond', 29434, '');
INSERT INTO `商城_货币` VALUES (3, 3, '积分', 'INV_Misc_Gem_Variety_01', 0, '');

-- ----------------------------
-- Table structure for 日志
-- ----------------------------
DROP TABLE IF EXISTS `商城_日志`;
CREATE TABLE `商城_日志`  (
  `账号ID` int(11) NULL DEFAULT NULL,
  `角色ID` int(11) NULL DEFAULT NULL,
  `角色名` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '',
  `商品` int(11) NULL DEFAULT NULL,
  `货币` int(11) NULL DEFAULT NULL,
  `费用` int(11) NULL DEFAULT NULL,
  `购买时间` timestamp NULL DEFAULT current_timestamp()
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of 日志
-- ----------------------------
INSERT INTO `商城_日志` VALUES (11, 2183, '守护世界平衡', 701, 3, 2000, '2023-10-25 22:59:24');

SET FOREIGN_KEY_CHECKS = 1;
