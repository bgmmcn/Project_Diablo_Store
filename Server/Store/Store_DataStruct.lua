-- 定义商城系统数据结构缓存
local ServiceData = {}    -- 商品数据
local NavData = {}        -- 导航分类数据
local CurrencyData = {}   -- 货币类型数据
local CreatureDisplays = {} -- 生物模型显示数据

-- 数据库表字段索引映射，确保代码中一致使用相同的索引
local KEYS = {
    currency = {
        id              = 0,  -- 货币ID
        currencyType    = 1,  -- 货币类型: 1=金币, 2=物品, 3=积分
        name            = 2,  -- 货币名称
        icon            = 3,  -- 图标
        data            = 4,  -- 相关数据(如物品ID)
        tooltip         = 5   -- 鼠标提示文本
    },
    category = {
        id              = 1,  -- 分类ID
        name            = 2,  -- 分类名称
        icon            = 3,  -- 分类图标
        requiredRank    = 4,  -- 访问所需权限
        enabled         = 5   -- 是否启用
    },
    service = {
        id              = 0,  -- 商品ID
        cateIndex       = 1,  -- 所属分类
        serviceType     = 2,  -- 服务类型(3=物品, 4=变身, 5=坐骑, 等)
        name            = 3,  -- 商品名称
        currency        = 4,  -- 货币ID
        price           = 5,  -- 价格
        discount        = 6,  -- 折扣
        tooltipName     = 7,  -- 提示框标题
        tooltipType     = 8,  -- 提示框类型(item/spell)
        tooltipText     = 9,  -- 提示框内容
        icon            = 10, -- 图标
        hyperlink       = 11, -- 超链接ID
        EntryOrSkill    = 12, -- 生物或技能ID
        flags           = 13, -- 标识
        reward_1        = 14, -- 奖励1
        reward_2        = 15, -- 奖励2
        reward_3        = 16, -- 奖励3
        reward_4        = 17, -- 奖励4
        reward_5        = 18, -- 奖励5
        reward_6        = 19, -- 奖励6
        reward_7        = 20, -- 奖励7
        reward_8        = 21, -- 奖励8
        rewardCount_1   = 22, -- 奖励1数量
        rewardCount_2   = 23, -- 奖励2数量
        rewardCount_3   = 24, -- 奖励3数量
        rewardCount_4   = 25, -- 奖励4数量
        rewardCount_5   = 26, -- 奖励5数量
        rewardCount_6   = 27, -- 奖励6数量
        rewardCount_7   = 28, -- 奖励7数量
        rewardCount_8   = 29, -- 奖励8数量
        new             = 30, -- 是否为新品
        enabled         = 31  -- 是否启用
    },
}

-- 导出数据结构键映射
function GetDataStructKeys()
    return KEYS;
end

-- 字符串自动换行处理函数
-- @param str 输入字符串
-- @param maxWidth 最大宽度
-- @return 处理后的字符串(带换行符)
local function StrAutoWidth(str, maxWidth)
    local TempWidth = 0
    local currentIndex = 1
    local newStr = ""
    while currentIndex <= #str do
        local TempChar = string.byte(str, currentIndex)
        -- 中文字符(UTF-8 3字节)
        if TempChar >= 224 and TempChar < 240 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex + 2)
                TempWidth = TempWidth + 2
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 2)
                TempWidth = 2
            end
            currentIndex = currentIndex + 3
        -- 英文字符(ASCII 1字节)
        elseif TempChar < 128 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex)
                TempWidth = TempWidth + 1
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex)
                TempWidth = 1
            end
            currentIndex = currentIndex + 1
        -- 特殊字符(UTF-8 4字节, 如Emoji)
        elseif TempChar >= 240 and TempChar < 248 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex + 3)
                TempWidth = TempWidth + 2
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 3)
                TempWidth = 2
            end
            currentIndex = currentIndex + 4
        -- 其他UTF-8字符(2字节)
        elseif TempChar >= 192 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex + 1)
                TempWidth = TempWidth + 2
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 1)
                TempWidth = 2
            end
            currentIndex = currentIndex + 2
        else
            -- 不支持的编码
            return "字符串出错\r\n请报告BUG"
        end
    end
    return newStr
end

-- 加载商城分类数据
function NavData.Load()
    NavData.Cache = {};
    local Query = AuthDBQuery("SELECT * FROM 商城_分类")
    if Query then 
        repeat
            table.insert(
                NavData.Cache, {
                    Query:GetUInt32(0), -- id
                    Query:GetString(1), -- name
                    Query:GetString(2), -- icon
                    Query:GetUInt32(3), -- requiredRank
                    Query:GetUInt32(4), -- enabled
                }
            ) 
        until not Query:NextRow()
    end
end

-- 加载货币数据
function CurrencyData.Load()
    CurrencyData.Cache = {};
    local Query = AuthDBQuery("SELECT * FROM 商城_货币")
    if Query then 
        repeat
            CurrencyData.Cache[Query:GetUInt32(0)] = { -- 以ID为键
                Query:GetUInt32(1), -- type
                Query:GetString(2), -- name
                Query:GetString(3), -- icon
                Query:GetUInt32(4), -- data
                Query:GetString(5), -- tooltip
            }
        until not Query:NextRow()
    end
end

-- 加载商品数据
function ServiceData.Load()
    ServiceData.Cache = {};
    local Query = AuthDBQuery("SELECT * FROM 商城_商品;");
    if Query then
        repeat
            if Query:GetUInt32(KEYS.service.enabled) == 1 then
                local KEYSServiceId = Query:GetUInt32(0) -- 商品ID
                ServiceData.Cache[KEYSServiceId] = {
                    Query:GetUInt32(KEYS.service.cateIndex),
                    Query:GetUInt32(KEYS.service.serviceType),
                    StrAutoWidth(Query:GetString(KEYS.service.name), 14),  -- 商品名称格式化，强制14个宽度后换行显示
                    Query:GetUInt32(KEYS.service.currency),
                    Query:GetUInt32(KEYS.service.price),
                    Query:GetUInt32(KEYS.service.discount),
                    Query:GetString(KEYS.service.tooltipName),
                    Query:GetString(KEYS.service.tooltipType),
                    Query:GetString(KEYS.service.tooltipText),
                    Query:GetString(KEYS.service.icon),
                    Query:GetUInt32(KEYS.service.hyperlink),
                    Query:GetUInt32(KEYS.service.EntryOrSkill),
                    Query:GetUInt32(KEYS.service.flags),
                    Query:GetUInt32(KEYS.service.reward_1),
                    Query:GetUInt32(KEYS.service.reward_2),
                    Query:GetUInt32(KEYS.service.reward_3),
                    Query:GetUInt32(KEYS.service.reward_4),
                    Query:GetUInt32(KEYS.service.reward_5),
                    Query:GetUInt32(KEYS.service.reward_6),
                    Query:GetUInt32(KEYS.service.reward_7),
                    Query:GetUInt32(KEYS.service.reward_8),
                    Query:GetUInt32(KEYS.service.rewardCount_1),
                    Query:GetUInt32(KEYS.service.rewardCount_2),
                    Query:GetUInt32(KEYS.service.rewardCount_3),
                    Query:GetUInt32(KEYS.service.rewardCount_4),
                    Query:GetUInt32(KEYS.service.rewardCount_5),
                    Query:GetUInt32(KEYS.service.rewardCount_6),
                    Query:GetUInt32(KEYS.service.rewardCount_7),
                    Query:GetUInt32(KEYS.service.rewardCount_8),
                    Query:GetUInt32(KEYS.service.new),
                    Query:GetUInt32(KEYS.service.enabled),
                }
                
                -- 专业技能特殊处理
                if Query:GetUInt32(KEYS.service.serviceType) == 7 then
                    -- 用flags获取专业最高级索引，300对应60，375对应70，450对应80
                    local levelIndex = math.ceil(Query:GetUInt32(KEYS.service.flags) / 75)
                    if levelIndex < 1 or levelIndex > 6 then
                        levelIndex = 6 -- 输入不正确默认为80级
                    end
                    -- 用最大可获得技能代替超链接ID
                    ServiceData.Cache[KEYSServiceId][KEYS.service.hyperlink] = Query:GetUInt32(KEYS.service.reward_1 + levelIndex - 1)
                end
            end
        until not Query:NextRow()
    end
end

-- 加载生物模型显示数据
function CreatureDisplays.Load()
    CreatureDisplays.Cache = {} -- 清空缓存
    local tmp = "" -- 构建IN查询语句参数
    
    -- 收集所有需要预览的生物ID
    for k, v in pairs(ServiceData.Cache) do
        -- 对变身和坐骑类进行处理(类型4和5)
        if (v[KEYS.service.serviceType] == 4 or v[KEYS.service.serviceType] == 5) and v[KEYS.service.EntryOrSkill] > 0 then
            if tmp ~= "" then
                tmp = tmp .. ", "
            end
            tmp = tmp .. v[KEYS.service.EntryOrSkill]
        end
    end
    
    -- 如果没有需要预览的生物，直接返回
    if tmp == "" then
        return false
    end
    
    -- 查询生物模板数据
    local Query = WorldDBQuery("SELECT entry, `name`, subname, IconName, type_flags, `type`, family, `rank`, KillCredit1, KillCredit2, HealthModifier, ManaModifier, RacialLeader, MovementType FROM creature_template WHERE entry IN ("..tmp..");")
    if Query then
        repeat
            table.insert(
                CreatureDisplays.Cache, {
                    Query:GetUInt32(0),  -- entry
                    Query:GetString(1),  -- name
                    Query:GetString(2),  -- subname
                    Query:GetString(3),  -- IconName
                    Query:GetUInt32(4),  -- type_flags
                    Query:GetUInt32(5),  -- type
                    Query:GetUInt32(6),  -- family
                    Query:GetUInt32(7),  -- rank
                    Query:GetUInt32(8),  -- KillCredit1
                    Query:GetUInt32(9),  -- KillCredit2
                    10045,              -- 默认模型ID
                    0,                  -- 模型ID2
                    0,                  -- 模型ID3
                    0,                  -- 模型ID4
                    Query:GetFloat(10),  -- HealthModifier
                    Query:GetFloat(11),  -- ManaModifier
                    Query:GetUInt32(12), -- RacialLeader
                    Query:GetUInt32(13)  -- MovementType
                }
            )
        until not Query:NextRow()
    end

    -- 获取生物的本地化名称和模型ID
    for k, v in pairs(CreatureDisplays.Cache) do
        -- 获取中文名称(如果有)
        local Querylocale = WorldDBQuery("SELECT * FROM creature_template_locale WHERE entry = "..v[1].." and locale = 'zhCN';")
        if Querylocale then
            v[2] = Querylocale:GetString(2)  -- 覆盖为中文名
            v[3] = Querylocale:GetString(3)  -- 覆盖为中文副标题
        end

        -- 获取生物的实际模型ID
        local Querymodel = WorldDBQuery("SELECT * FROM creature_template_model WHERE CreatureID = "..v[1]..";")
        if Querymodel then
            repeat
                local idxtmp = Querymodel:GetUInt16(1)
                if idxtmp == 0 then
                    v[11] = Querymodel:GetUInt32(2)      -- 模型ID1
                elseif idxtmp == 1 then
                    v[12] = Querymodel:GetUInt32(2)      -- 模型ID2
                elseif idxtmp == 2 then
                    v[13] = Querymodel:GetUInt32(2)      -- 模型ID3
                elseif idxtmp == 3 then
                    v[14] = Querymodel:GetUInt32(2)      -- 模型ID4
                end
            until not Querymodel:NextRow()
        end
    end
end

-- 获取商品数据
function GetServiceData()
    return ServiceData.Cache;
end

-- 获取导航数据
function GetNavData()
    return NavData.Cache;
end

-- 获取货币数据
function GetCurrencyData()
    return CurrencyData.Cache;
end

-- 初始化数据
ServiceData.Load()
NavData.Load()
CurrencyData.Load()
CreatureDisplays.Load()

-- 种族/性别对应的声音效果
local SoundEffects = {
    notEnoughMoney = { -- 金币不足
        [1] = { -- Human
            [0] = 1908, -- Male
            [1] = 2032, -- Female
        },
        [2] = { -- Orc
            [0] = 2319,
            [1] = 2356,
        },
        [3] = { -- Dwarf
            [0] = 1598,
            [1] = 1669,
        },
        [4] = { -- Night elf
            [0] = 2151,
            [1] = 2262,
        },
        [5] = { -- Undead
            [0] = 2096,
            [1] = 2207,
        },
        [6] = { -- Tauren
            [0] = 2426,
            [1] = 2462,
        },
        [7] = { -- Gnome
            [0] = 1724,
            [1] = 1779,
        },
        [8] = { -- Troll
            [0] = 1835,
            [1] = 1945,
        },
        [10] = { -- Blood elf
            [0] = 9583,
            [1] = 9584,
        },
        [11] = { -- Draenei
            [0] = 9498,
            [1] = 9499,
        }
    },
    cantLearn = { -- 无法学习
        [1] = { -- Human
            [0] = 2622,
            [1] = 2585,
        },
        [2] = { -- Orc
            [0] = 2949,
            [1] = 2966,
        },
        [3] = { -- Dwarf
            [0] = 2605,
            [1] = 2893,
        },
        [4] = { -- Night elf
            [0] = 2644,
            [1] = 2661,
        },
        [5] = { -- Undead
            [0] = 2633,
            [1] = 2597,
        },
        [6] = { -- Tauren
            [0] = 2616,
            [1] = 2918,
        },
        [7] = { -- Gnome
            [0] = 2882,
            [1] = 2907,
        },
        [8] = { -- Troll
            [0] = 2611,
            [1] = 2977,
        },
        [10] = { -- Blood elf
            [0] = 9571,
            [1] = 9572,
        },
        [11] = { -- Draenei
            [0] = 9487,
            [1] = 9486,
        }
    },
    cantUse = { -- 无法使用
        [1] = { -- Human
            [0] = 1918,
            [1] = 2042,
        },
        [2] = { -- Orc
            [0] = 2329,
            [1] = 2384,
        },
        [3] = { -- Dwarf
            [0] = 1653,
            [1] = 1696,
        },
        [4] = { -- Night elf
            [0] = 2161,
            [1] = 2272,
        },
        [5] = { -- Undead
            [0] = 2106,
            [1] = 2217,
        },
        [6] = { -- Tauren
            [0] = 2483,
            [1] = 2482,
        },
        [7] = { -- Gnome
            [0] = 1753,
            [1] = 1808,
        },
        [8] = { -- Troll
            [0] = 1863,
            [1] = 1987,
        },
        [10] = { -- Blood elf
            [0] = 9611,
            [1] = 9612,
        },
        [11] = { -- Draenei
            [0] = 9535,
            [1] = 9536,
        }
    }
}

-- 获取声音效果ID
function GetSoundEffect(key, race, gender)
    local effect = 0
    if SoundEffects[key] and SoundEffects[key][race] and SoundEffects[key][race][gender] then
        effect = SoundEffects[key][race][gender]
    end
    return effect
end

-- 发送生物查询响应数据包
local function SendCreatureQueryResponse(player, data)
    -- 创建数据包，对应Creature.cpp的CreatureTemplate::InitializeQueryData()
    local packet = CreatePacket(97, 100)
    packet:WriteULong(data[1])         -- Entry
    packet:WriteString(data[2] or "")  -- 名字
    packet:WriteUByte(0)
    packet:WriteUByte(0)
    packet:WriteUByte(0)
    packet:WriteString(data[3] or "")  -- 称号/副标题
    packet:WriteString(data[4] or "")  -- 图标
    packet:WriteULong(data[5])         -- flags
    packet:WriteULong(data[6])         -- type
    packet:WriteULong(data[7])         -- family
    packet:WriteULong(data[8])         -- rank
    packet:WriteULong(data[9])         -- KillCredit1
    packet:WriteULong(data[10])        -- KillCredit2
    packet:WriteULong(data[11])        -- 模型ID1
    packet:WriteULong(data[12])        -- 模型ID2
    packet:WriteULong(data[13])        -- 模型ID3
    packet:WriteULong(data[14])        -- 模型ID4
    packet:WriteFloat(data[15])        -- 血量修正
    packet:WriteFloat(data[16])        -- 蓝量修正
    packet:WriteUByte(data[17])        -- RacialLeader
    packet:WriteULong(0)               -- 占位
    packet:WriteULong(0)               -- 占位
    packet:WriteULong(0)               -- 占位
    packet:WriteULong(0)               -- 占位
    packet:WriteULong(0)               -- 占位
    packet:WriteULong(0)               -- 占位
    packet:WriteULong(data[18])        -- 移动速度
    player:SendPacket(packet)
end

-- 玩家登录时发送所有生物模型数据
local function OnLogin(event, player)
    for _, v in pairs(CreatureDisplays.Cache) do
        SendCreatureQueryResponse(player, v)
    end
end

-- 注册玩家登录事件
RegisterPlayerEvent(3, OnLogin)