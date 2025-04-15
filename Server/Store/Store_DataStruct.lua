local ServiceData = {}
local NavData = {}
local CurrencyData = {}
local CreatureDisplays = {}

local KEYS = {
	currency = {
		id				= 0,
		currencyType	= 1,
		name			= 2,
		icon			= 3,
		data			= 4,
		tooltip			= 5
	},
	category = {
		id				= 1,
		name			= 2,
		icon			= 3,
		requiredRank	= 4,
		enabled			= 5
	},
	service = {
		id				= 0,
		cateIndex		= 1,
		serviceType		= 2,
		name			= 3,
		currency		= 4,
		price			= 5,
		discount		= 6,
		tooltipName		= 7,
		tooltipType		= 8,
		tooltipText		= 9,
		icon			= 10,
		hyperlink		= 11,
		EntryOrSkill	= 12,
		flags			= 13,
		reward_1		= 14,
		reward_2		= 15,
		reward_3		= 16,
		reward_4		= 17,
		reward_5		= 18,
		reward_6		= 19,
		reward_7		= 20,
		reward_8		= 21,
		rewardCount_1	= 22,
		rewardCount_2	= 23,
		rewardCount_3	= 24,
		rewardCount_4	= 25,
		rewardCount_5	= 26,
		rewardCount_6	= 27,
		rewardCount_7	= 28,
		rewardCount_8	= 29,
		new				= 30,
		enabled			= 31
	},
}

function GetDataStructKeys()
	return KEYS;
end

local function StrAutoWidth(str, maxWidth)	--字符串长度大于多少时候回车,中英文混合时候,英文为单数会多显示一个,中英混合时候单数时候不会突出来1个,双数有可能
	local TempWidth = 0
	local currentIndex = 1
	local newStr = ""
	while currentIndex <= #str do
		local TempChar = string.byte(str,currentIndex)
		if TempChar >= 224 and TempChar < 240 then	--中文字符串,,以3个1,一个0开头，注意判断排序按概率高地的,以提高命中率,中文概率最大
			if TempWidth < maxWidth then
				newStr = newStr..string.sub(str, currentIndex, currentIndex + 2)		--截取3位
				TempWidth = TempWidth + 2		--显示位宽增加2个
			else
				newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 2)	--增加换行
				TempWidth = 2	--因为已经回车并加了2个位宽的中文的字符了,所以下一行已经用了2个
			end
			currentIndex = currentIndex + 3
		elseif TempChar < 128 then			--英文字符串，以0开头
			if TempWidth < maxWidth then
				newStr = newStr..string.sub(str, currentIndex, currentIndex)			--只截取1位
				TempWidth = TempWidth + 1		--显示位宽增加1个
			else
				newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex)		--增加回车换行
				TempWidth = 1	--因为已经回车并加了1个位宽的英文的字符了,所以下一行已经用了2个
			end
			currentIndex = currentIndex + 1
		elseif TempChar >= 240 and TempChar < 248 then	--特殊字符,如笑脸等,以4个1,一个0开头
			if TempWidth < maxWidth then
				newStr = newStr..string.sub(str, currentIndex, currentIndex + 3)		--截取4位
				TempWidth = TempWidth + 2		--显示位宽增加2个
			else
				newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 3)	--增加回车换行
				TempWidth = 2
			end
			currentIndex = currentIndex + 4
		elseif TempChar >= 192 then			--2个字符的,不知道啥类型，,以2个1,一个0开头
			if TempWidth < maxWidth then
				newStr = newStr..string.sub(str, currentIndex, currentIndex + 2)		--截取2位
				TempWidth = TempWidth + 2		--显示位宽增加2个,并不确定,猜测是2个
			else
				newStr = newStr.."\n"..string.sub(str, currentIndex, currentIndex + 2)	--增加回车换行
				TempWidth = 2
			end
			currentIndex = currentIndex + 2
		else	--其他5个1和6个1后面加0的不适用于utf-8 mb4
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
					Query:GetUInt32(0), --id
					Query:GetString(1), --name
					Query:GetString(2), --icon
					Query:GetUInt32(3), --requiredRank
					Query:GetUInt32(4),	--enabled
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
			CurrencyData.Cache[Query:GetUInt32(0)] = { -- id
				Query:GetUInt32(1), -- type
				Query:GetString(2), -- name
				Query:GetString(3), -- icon
				Query:GetUInt32(4), -- data
				Query:GetString(5), -- tooltip
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
				local KEYSServiceId = Query:GetUInt32(0)	--ID
				ServiceData.Cache[KEYSServiceId] = {
					Query:GetUInt32(KEYS.service.cateIndex),
					Query:GetUInt32(KEYS.service.serviceType),
					StrAutoWidth(Query:GetString(KEYS.service.name), 14),  --强制14个显示宽度后换行显示。从store_client.lua移到这里,一次执行一直有效,提高效率
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
				if Query:GetUInt32(KEYS.service.serviceType) == 7 then		--专业具体描述跟随等级调整
					local levelIndex = math.ceil(Query:GetUInt32(KEYS.service.flags) / 75)	--用flags获取专业最高级索引，300对应60，375对应70，450对应80，其他数值不建议
					if levelIndex < 1 or levelIndex > 6 then
						levelIndex = 6		--如输入不正确，改为默认80级
					end		
					ServiceData.Cache[KEYSServiceId][KEYS.service.hyperlink] = Query:GetUInt32(KEYS.service.reward_1 + levelIndex - 1) --用最大可获得技能代替
				end
			end
		until not Query:NextRow()
	end
end

function CreatureDisplays.Load()
	CreatureDisplays.Cache = {}		--每次重新load时候清空
	local tmp = ""	--数据库查询的临时参数
	for k, v in pairs(ServiceData.Cache) do		--合并多个生物ID为一个有效的数据库查询语句的参数, 对变身和坐骑类进行预处理,如果类型为4和5(或者根据定义)则注册客户端预览模型
		if (v[KEYS.service.serviceType] == 4 or v[KEYS.service.serviceType] == 5) and v[KEYS.service.EntryOrSkill] > 0 then
			if tmp ~= "" then	--如果不是第一个生物ID，每次加入逗号和空格，以组成有效的数据库查询分隔符
				tmp = tmp .. ", "
			end
			tmp = tmp .. v[KEYS.service.EntryOrSkill]	--合并当前循环的生物ID为有效的数据库查询语句
		end
	end
	if tmp == "" then	--修复服务器崩溃。如果没有任何模型，查询数据库会导致服务器崩溃
		return false
	end		
	
	--获取生物模型显示缓存的所有信息
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

	for k, v in pairs (CreatureDisplays.Cache) do		--让本地缓存的生物模型保持汉化状态，如不需要汉化，或者不是AZ和TC端，或者出错的，酌情删除
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
		[1] = { -- Human
			[0] = 1908,
			[1] = 2032,
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
	cantLearn = {
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
	cantUse = {
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

function GetSoundEffect(key, race, gender)
	local effect = 0
	if SoundEffects[key][race][gender] then
		effect = SoundEffects[key][race][gender]
	end
	return effect
end

local function SendCreatureQueryResponse(player, data)
	local packet = CreatePacket(97, 100)	--Creature.cpp 的 CreatureTemplate::InitializeQueryData(), 141行开始
	packet:WriteULong(data[1])			--Entry
	packet:WriteString(data[2] or "")	--名字
	packet:WriteUByte(0)
	packet:WriteUByte(0)
	packet:WriteUByte(0)
	packet:WriteString(data[3] or "")	--title外号
	packet:WriteString(data[4] or "")	--图标
	packet:WriteULong(data[5])			--flags
	packet:WriteULong(data[6])			--type
	packet:WriteULong(data[7])			--family
	packet:WriteULong(data[8])			--rank
	packet:WriteULong(data[9])			--KillCredit1
	packet:WriteULong(data[10])			--KillCredit2
	packet:WriteULong(data[11])			--模型1
	packet:WriteULong(data[12])			--模型2
	packet:WriteULong(data[13])			--模型3
	packet:WriteULong(data[14])			--模型4
	packet:WriteFloat(data[15])			--血量
	packet:WriteFloat(data[16])			--蓝量
	packet:WriteUByte(data[17])			--RacialLeader
	packet:WriteULong(0)
	packet:WriteULong(0)
	packet:WriteULong(0)
	packet:WriteULong(0)
	packet:WriteULong(0)
	packet:WriteULong(0)
	packet:WriteULong(data[18])			--移动速度
	player:SendPacket(packet)
end

local function OnLogin(event, player)
	for _, v in pairs (CreatureDisplays.Cache) do
		SendCreatureQueryResponse(player, v)
	end
end

RegisterPlayerEvent(3, OnLogin)