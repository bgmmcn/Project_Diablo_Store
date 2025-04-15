local ServiceData = {}
local NavData = {}
local CurrencyData = {}
local CreatureDisplays = {}

local KEYS = {
    currency = {
        id              = 0,
        currencyType    = 1,
        name            = 2,
        icon            = 3,
        data            = 4,
        tooltip         = 5
    },
    category = {
        id              = 1,
        name            = 2,
        icon            = 3,
        requiredRank    = 4,
        enabled         = 5
    },
    service = {
        id              = 0,
        cateIndex       = 1,
        serviceType     = 2,
        name            = 3,
        currency        = 4,
        price           = 5,
        discount        = 6,
        tooltipName     = 7,
        tooltipType     = 8,
        tooltipText     = 9,
        icon            = 10,
        hyperlink       = 11,
        EntryOrSkill    = 12,
        flags           = 13,
        reward_1        = 14,
        reward_2        = 15,
        reward_3        = 16,
        reward_4        = 17,
        reward_5        = 18,
        reward_6        = 19,
        reward_7        = 20,
        reward_8        = 21,
        rewardCount_1   = 22,
        rewardCount_2   = 23,
        rewardCount_3   = 24,
        rewardCount_4   = 25,
        rewardCount_5   = 26,
        rewardCount_6   = 27,
        rewardCount_7   = 28,
        rewardCount_8   = 29,
        new             = 30,
        enabled         = 31
    },
}

function GetDataStructKeys()
    return KEYS;
end

local function StrAutoWidth(str, maxWidth)
    local TempWidth = 0
    local currentIndex = 1
    local newStr = ""
    while currentIndex <= #str do
        local TempChar = string.byte(str, currentIndex)
        if TempChar >= 224 and TempChar < 240 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex + 2)
                TempWidth = TempWidth + 2
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 2)
                TempWidth = 2
            end
            currentIndex = currentIndex + 3
        elseif TempChar < 128 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex)
                TempWidth = TempWidth + 1
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex)
                TempWidth = 1
            end
            currentIndex = currentIndex + 1
        elseif TempChar >= 240 and TempChar < 248 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex + 3)
                TempWidth = TempWidth + 2
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 3)
                TempWidth = 2
            end
            currentIndex = currentIndex + 4
        elseif TempChar >= 192 then
            if TempWidth < maxWidth then
                newStr = newStr..string.sub(str, currentIndex, currentIndex + 2)
                TempWidth = TempWidth + 2
            else
                newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 2)
                TempWidth = 2
            end
            currentIndex = currentIndex + 2
        else
            return "字符串出错\r\n请报告BUG"
        end
    end
    return newStr
end

function NavData.Load()
    NavData.Cache = {};
    local Query = AuthDBQuery("SELECT * FROM 商城_分类")
    if Query then 
        repeat
            table.insert(
                NavData.Cache, {
                    Query:GetUInt32(0),
                    Query:GetString(1),
                    Query:GetString(2),
                    Query:GetUInt32(3),
                    Query:GetUInt32(4),
                }
            ) 
        until not Query:NextRow()
    end
end

function CurrencyData.Load()
    CurrencyData.Cache = {};
    local Query = AuthDBQuery("SELECT * FROM 商城_货币")
    if Query then 
        repeat
            CurrencyData.Cache[Query:GetUInt32(0)] = {
                Query:GetUInt32(1),
                Query:GetString(2),
                Query:GetString(3),
                Query:GetUInt32(4),
                Query:GetString(5),
            }
        until not Query:NextRow()
    end
end

function ServiceData.Load()
    ServiceData.Cache = {};
    local Query = AuthDBQuery("SELECT * FROM 商城_商品;");
    if Query then
        repeat
            if Query:GetUInt32(KEYS.service.enabled) == 1 then
                local KEYSServiceId = Query:GetUInt32(0)
                ServiceData.Cache[KEYSServiceId] = {
                    Query:GetUInt32(KEYS.service.cateIndex),
                    Query:GetUInt32(KEYS.service.serviceType),
                    StrAutoWidth(Query:GetString(KEYS.service.name), 14),
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
                if Query:GetUInt32(KEYS.service.serviceType) == 7 then
                    local levelIndex = math.ceil(Query:GetUInt32(KEYS.service.flags) / 75)
                    if levelIndex < 1 or levelIndex > 6 then
                        levelIndex = 6
                    end        
                    ServiceData.Cache[KEYSServiceId][KEYS.service.hyperlink] = Query:GetUInt32(KEYS.service.reward_1 + levelIndex - 1)
                end
            end
        until not Query:NextRow()
    end
end

function CreatureDisplays.Load()
    CreatureDisplays.Cache = {}
    local tmp = ""
    for k, v in pairs(ServiceData.Cache) do
        if (v[KEYS.service.serviceType] == 4 or v[KEYS.service.serviceType] == 5) and v[KEYS.service.EntryOrSkill] > 0 then
            if tmp ~= "" then
                tmp = tmp .. ", "
            end
            tmp = tmp .. v[KEYS.service.EntryOrSkill]
        end
    end
    if tmp == "" then
        return false
    end        
    
    local Query = WorldDBQuery("SELECT entry, `name`, subname, IconName, type_flags, `type`, family, `rank`, KillCredit1, KillCredit2, HealthModifier, ManaModifier, RacialLeader, MovementType FROM creature_template WHERE entry IN ("..tmp..");")
    if Query then
        repeat
            table.insert(
                CreatureDisplays.Cache, {
                    Query:GetUInt32(0),
                    Query:GetString(1),
                    Query:GetString(2),
                    Query:GetString(3),
                    Query:GetUInt32(4),
                    Query:GetUInt32(5),
                    Query:GetUInt32(6),
                    Query:GetUInt32(7),
                    Query:GetUInt32(8),
                    Query:GetUInt32(9), 
                    10045,
                    0,
                    0,
                    0,
                    Query:GetFloat(10),
                    Query:GetFloat(11),
                    Query:GetUInt32(12),
                    Query:GetUInt32(13)
                }
            )
        until not Query:NextRow()
    end

    for k, v in pairs(CreatureDisplays.Cache) do
        local Querylocale = WorldDBQuery("SELECT * FROM creature_template_locale WHERE entry = "..v[1].." and locale = 'zhCN';")
        if Querylocale then
            v[2] = Querylocale:GetString(2)
            v[3] = Querylocale:GetString(3)
        end

        local Querymodel = WorldDBQuery("SELECT * FROM creature_template_model WHERE CreatureID = "..v[1]..";")
        if Querymodel then
            repeat
                local idxtmp = Querymodel:GetUInt16(1)
                if idxtmp == 0 then
                    v[11] = Querymodel:GetUInt32(2)
                elseif idxtmp == 1 then
                    v[12] = Querymodel:GetUInt32(2)
                elseif idxtmp == 2 then
                    v[13] = Querymodel:GetUInt32(2)
                elseif idxtmp == 3 then
                    v[14] = Querymodel:GetUInt32(2)
                end
            until not Querymodel:NextRow()
        end
    end
end

function GetServiceData()
    return ServiceData.Cache;
end

function GetNavData()
    return NavData.Cache;
end

function GetCurrencyData()
    return CurrencyData.Cache;
end

ServiceData.Load()
NavData.Load()
CurrencyData.Load()
CreatureDisplays.Load()

local SoundEffects = {
    notEnoughMoney = {
        [1] = {
            [0] = 1908,
            [1] = 2032,
        },
        [2] = {
            [0] = 2319,
            [1] = 2356,
        },
        [3] = {
            [0] = 1598,
            [1] = 1669,
        },
        [4] = {
            [0] = 2151,
            [1] = 2262,
        },
        [5] = {
            [0] = 2096,
            [1] = 2207,
        },
        [6] = {
            [0] = 2426,
            [1] = 2462,
        },
        [7] = {
            [0] = 1724,
            [1] = 1779,
        },
        [8] = {
            [0] = 1835,
            [1] = 1945,
        },
        [10] = {
            [0] = 9583,
            [1] = 9584,
        },
        [11] = {
            [0] = 9498,
            [1] = 9499,
        }
    },
    cantLearn = {
        [1] = {
            [0] = 2622,
            [1] = 2585,
        },
        [2] = {
            [0] = 2949,
            [1] = 2966,
        },
        [3] = {
            [0] = 2605,
            [1] = 2893,
        },
        [4] = {
            [0] = 2644,
            [1] = 2661,
        },
        [5] = {
            [0] = 2633,
            [1] = 2597,
        },
        [6] = {
            [0] = 2616,
            [1] = 2918,
        },
        [7] = {
            [0] = 2882,
            [1] = 2907,
        },
        [8] = {
            [0] = 2611,
            [1] = 2977,
        },
        [10] = {
            [0] = 9571,
            [1] = 9572,
        },
        [11] = {
            [0] = 9487,
            [1] = 9486,
        }
    },
    cantUse = {
        [1] = {
            [0] = 1918,
            [1] = 2042,
        },
        [2] = {
            [0] = 2329,
            [1] = 2384,
        },
        [3] = {
            [0] = 1653,
            [1] = 1696,
        },
        [4] = {
            [0] = 2161,
            [1] = 2272,
        },
        [5] = {
            [0] = 2106,
            [1] = 2217,
        },
        [6] = {
            [0] = 2483,
            [1] = 2482,
        },
        [7] = {
            [0] = 1753,
            [1] = 1808,
        },
        [8] = {
            [0] = 1863,
            [1] = 1987,
        },
        [10] = {
            [0] = 9611,
            [1] = 9612,
        },
        [11] = {
            [0] = 9535,
            [1] = 9536,
        }
    }
}

function GetSoundEffect(key, race, gender)
    local effect = 0
    if SoundEffects[key][race][gender] then
        effect = SoundEffects[key][race][gender]
    end
    return effect
end

local function SendCreatureQueryResponse(player, data)
    local packet = CreatePacket(97, 100)
    packet:WriteULong(data[1])
    packet:WriteString(data[2] or "")
    packet:WriteUByte(0)
    packet:WriteUByte(0)
    packet:WriteUByte(0)
    packet:WriteString(data[3] or "")
    packet:WriteString(data[4] or "")
    packet:WriteULong(data[5])
    packet:WriteULong(data[6])
    packet:WriteULong(data[7])
    packet:WriteULong(data[8])
    packet:WriteULong(data[9])
    packet:WriteULong(data[10])
    packet:WriteULong(data[11])
    packet:WriteULong(data[12])
    packet:WriteULong(data[13])
    packet:WriteULong(data[14])
    packet:WriteFloat(data[15])
    packet:WriteFloat(data[16])
    packet:WriteUByte(data[17])
    packet:WriteULong(0)
    packet:WriteULong(0)
    packet:WriteULong(0)
    packet:WriteULong(0)
    packet:WriteULong(0)
    packet:WriteULong(0)
    packet:WriteULong(data[18])
    player:SendPacket(packet)
end

local function OnLogin(event, player)
    for _, v in pairs(CreatureDisplays.Cache) do
        SendCreatureQueryResponse(player, v)
    end
end

RegisterPlayerEvent(3, OnLogin)