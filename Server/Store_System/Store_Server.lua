-- The below config options can be changed to suit your needs.
-- Anything not in the config options requires changes to the code below,
-- do so at your own discretion.


--ZhangHaoJF = {}  --示例定义,正常应该在第三方全局模式定义,或者这里定义后关联数据库的数据

local CONFIG = {
	strings = {
		insufficientFunds = "你没有足够的",					--物品名会在后续脚本中附在后面
		alreadyKnown = "你已经有了这",						--物品,坐骑,宠物,头衔等会在后续脚本中附加在后面
		tooHighLevel = "你已达到该服务可用的最高等级",		--限制等级提示
		mailBody = "包裹已满，剩余物品代为邮寄",			--邮件提示内容
		successBox = "购买成功，请检查包裹(邮件)或服务效果"	--购买成功提示
	}
}

local AIO = AIO or require("AIO")

local CURRENCY_TYPES = {   --货币服务类型
	[1] = "GOLD",
	[2] = "ITEM_TOKEN",
	[3] = "SERVER_HANDLED"
}

local Shop_Server_Index = {  		--商品程序处理分类，注意和呈现在哪个图形界面的分类没有关系
		[3] = "ItemHandler", 		--  商业材料
	    [4] = "ModuleHandler", 		--  变身道具
		[5] = "MountHandler",		--  坐骑宠物
		[6] = "BuffHandler", 		--  增益效果
		[7] = "SKILLHandler",		--  专业技能
		[8] = "SpellHandler",		--  魔法技能
		[9] = "transHandler", 		--  幻化装扮
		[10] = "TitleHandler",		--  头衔称号
		[11] = "LevelHandler", 		--  等级提升
		[12] = "ServiceHandler", 	--  系统服务
		[13] = "ServiceProxy", 		--  代为服务(用于GM帮助目标改名等)
		[14] = "GoldHandler"		--  货币代币

}
local Shop_Services = {}			--把具体Shop_Services的函数的扩展名和Shop_Server_Index文本一致，即可以调用根据索引动态调用函数
local KEYS = GetDataStructKeys() 	--获取Store_DataStruct获取数据库结构分类
local StoreHandler = AIO.AddHandlers("STORE_SERVER", {})

function StoreHandler.FrameData(player)
	AIO.Handle(player, "STORE_CLIENT", "FrameData", GetServiceData(),GetNavData(), GetCurrencyData(), player:GetGMRank())
end

function StoreHandler.UpdateCurrencies(player)  -- 此项是显示在商城左下角货币数量的相关设置
	local tmp = {}
	for currencyId, currency in pairs(GetCurrencyData()) do
		local val = 0
		local currencyTypeText = CURRENCY_TYPES[currency[KEYS.currency.currencyType]]

		if currencyTypeText == "GOLD" then  -- 若是金币，则除10000以表示多少金
			val = math.floor(player:GetCoinage() / 10000)
		end

		if currencyTypeText == "ITEM_TOKEN" then -- 若是牌子类，则直接显示数量
			val = player:GetItemCount(currency[KEYS.currency.data])
		end

		if currencyTypeText == "SERVER_HANDLED" then	--获取数据库内的积分数值,积分没有对应实物
			local AccID = player:GetAccountId()
			--ZhangHaoJF[AccID] = {}	--假装定义当前账号积分(示例,不用实际定义),正常应该在其他地方定义或者通过数据库获取
			if ZhangHaoJF and ZhangHaoJF[AccID] then	-- ZhangHaoJF[AccID] 为账号可用积分,ZhangHaoJF为全局数组,由炉石或者其他lua做成全局参数,这样这里可以调用
				val = ZhangHaoJF[AccID]
			end
		end

		if val < 10 then
			val = "   "..val
		elseif val < 100 then
			val = "  "..val		
		elseif val < 1000 then
			val = " "..val		
		elseif val < 10000 then
			--啥也不干
		elseif val < 100000 then
			local changW = math.floor(val/10000)
			val = " "..changW.."万+"
		else
			local changW = math.floor(val/10000)
			val = changW.."万+"
		end
		table.insert(tmp, val)

	end
	AIO.Handle(player, "STORE_CLIENT", "UpdateCurrencies", tmp)
end

function StoreHandler.Purchase(player, serviceId) -- 此项是商城购买物品相关数据
	local services = GetServiceData()
	if services[serviceId] then				--查看商城对应服务是否存在
		services[serviceId].ID = serviceId	--将id添加到服务子表中，不必更多的变量
		local typeId = services[serviceId][KEYS.service.serviceType]
		local serviceHandler = Shop_Services[Shop_Server_Index[typeId]]
		if serviceHandler then
			local success = serviceHandler(player, services[serviceId])
			if success then	--如果购买成功
				StoreHandler.UpdateCurrencies(player)				--更新用户UI界面
				Shop_Services.LogPurchase(player, services[serviceId])	--更新购买记录
				player:PlayDirectSound(120, player)					--播放购买成功声音
				player:SendAreaTriggerMessage(services[serviceId][KEYS.service.name] .. " "..CONFIG.strings.successBox)		--购买成功提示
			end
		end
	end
end

-- Helper functions 此项是扣款相关数据
function Shop_Services.DeductCurrency(player, currencyId, amount)
	local currency = GetCurrencyData()
	local currencyType = currency[currencyId][KEYS.currency.currencyType]
	local currencyName = currency[currencyId][KEYS.currency.name]
	local currencyData = currency[currencyId][KEYS.currency.data]
	
	if CURRENCY_TYPES[currencyType] == "GOLD" then	--如果是金币的扣除方式
		if player:GetCoinage() < amount * 10000 then
			player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
			player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
			return false
		end
		player:ModifyMoney(-amount * 10000)	--修改扣除的费用
	end
	
	if CURRENCY_TYPES[currencyType] == "ITEM_TOKEN" then	--如果是牌子的扣除方式
		if not player:HasItem(currencyData, amount, true) then
			player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
			player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
			return false
		end
		player:RemoveItem(currencyData, amount)	--移除商品所需要的代币数量
	end

	if CURRENCY_TYPES[currencyType] == "SERVER_HANDLED" then	--积分的扣除方式
		local AccID = player:GetAccountId()
		--ZhangHaoJF[AccID] = {}	--假装定义当前账号积分(示例,不用实际定义),正常应该在其他地方定义或者通过数据库获取
		if ZhangHaoJF and ZhangHaoJF[AccID] and ZhangHaoJF[AccID] >= amount then	--如果有积分和使用积分,并且有足够购买的积分
			ZhangHaoJF[AccID] = ZhangHaoJF[AccID] - amount
			--AuthDBQuery("update 账号积分表 set 积分='"..ZhangHaoJF[AccID].."' where 账号='"..AccID.."';")	--示例用,不能去掉注释,否则服务器崩溃,需要和你自己的积分表关联
		else	--不满足上面任何都扣除失败
			player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
			player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
			return false
		end
	end
	return true
end

function Shop_Services.LogPurchase(player, data)--购买日志
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	--注意插入字符串需要额外的引号,由于双引号系统使用了,这里 "..player:GetName().." 外面用单引号括号 ' ' ,否则容易导致服务器宕机。
	--另外为了方便改字段名，插入对象名字 (账号ID, 角色ID, 角色名......) 不再写入sql，用完整写入所有字段数据代替，故需补上 current_timestamp() 这样提交到数据库后,自动生成当前时间
	WorldDBExecute("INSERT INTO 商城.购买日志 VALUES("..player:GetAccountId()..", "..player:GetGUIDLow()..", '"..player:GetName().."', "..data.ID..", "..currency..", "..amount..", current_timestamp());")
end

--3、物品
function Shop_Services.ItemHandler(player, data)
	if data[KEYS.service.flags] == 1 then		--flags为1表示唯一性检查
		local knownitem, rewarditem = 0, 0  	--轮流检查玩家是否有此物品或技能
		for i = 0, 7 do
			if data[KEYS.service.reward_1+i] > 0 then
				if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
					knownitem = knownitem + 1
				end
				rewarditem = rewarditem + 1
			end
		end
		if knownitem == rewarditem then  --如果拥有所有唯一物品，购买失败。唯一物品建议每次卖一个，否则多余唯一物品会邮寄且无法取回。
										 --可改判断为 knownitem > 0 则有唯一标记时候，拥有任意当前清单内物品都提示失败
			player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
			player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
			return false
		end	
	end

	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] --获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) --扣除货币
	if not deducted then  	-- 若扣除失败，中止并通知
		return false
	end

	for i = 0, 7 do		--依次循环发放8套物品
		for j = 1, data[KEYS.service.rewardCount_1+i] do	--每套内物品一个一个发放，避免满了丢失
			if not player:AddItem(data[KEYS.service.reward_1+i], 1) then 	--如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
				SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
				break	--发放不成功结束对应套直接发放循环
			end
		end
	end
	player:SaveToDB() --保存数据
	return true
end

--4、变身道具
function Shop_Services.ModuleHandler(player, data)
	local knownitem, rewarditem = 0, 0  	--轮流检查玩家是否有此物品或技能
	for i = 0, 7 do
		if data[KEYS.service.reward_1+i] > 0 then
			if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
				knownitem = knownitem + 1
			end
			rewarditem = rewarditem + 1
		end
	end
	if knownitem == rewarditem then  --如果都有，则购买失败并通知
		player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end

	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] 	--获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) --扣除货币
	if not deducted then  --若扣除失败，中止并通知
		return false
	end
	
	for i = 0, 7 do		--依次循环发放8套物品
		for j = 1, data[KEYS.service.rewardCount_1+i] do	--每套内物品一个一个发放，避免满了丢失
			if not player:AddItem(data[KEYS.service.reward_1+i], 1) then 	--如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
				SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
				break	--发放不成功结束对应套直接发放循环
			end
		end
	end
	player:SaveToDB() --保存数据
	return true
end

--5、坐骑宠物
function Shop_Services.MountHandler(player, data)
	local knownCount, rewardCount = 0, 0
	for i = 0, 7 do   --轮流检查玩家是否有此物品或技能
		if data[KEYS.service.reward_1+i] > 0 then
			if player:HasSpell(data[KEYS.service.reward_1+i]) then
				knownCount = knownCount + 1
			end
			rewardCount = rewardCount + 1
		end
	end
	if knownCount == rewardCount then    --如果都有，则购买失败并通知
		player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end

	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]--获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) --扣除货币
	if not deducted then --若扣除失败，中止并通知
		return false
	end

	for i = 0, 7 do   -- 学习所有技能
		if data[KEYS.service.reward_1+i] > 0 then
			player:LearnSpell(data[KEYS.service.reward_1+i])
		end
	end
	player:SaveToDB() --保存数据
	return true
end

--6、增益效果
function Shop_Services.BuffHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] --获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) --扣除货币
	if not deducted then--若扣除失败，中止并通知
		return false
	end

	for i = 0, 7 do  -- 施放所有技能状态
		if data[KEYS.service.reward_1+i] > 0 then
			player:CastSpell(player, data[KEYS.service.reward_1+i], true)
		end
	end
	return true
end

--7 专业技能
function Shop_Services.SKILLHandler(player, data)
	local levelIndex = math.ceil(data[KEYS.service.flags] / 75)		--用生物entry这个字段设定技能最高等级，300对应60，375对应70，450对应80，也可其他数值但是不建议
	if levelIndex < 1 or levelIndex > 6 then	--如输入不正确，改为获取版本默认的索引级别
		if GetCoreExpansion() < 1 then  	--地球版本
			levelIndex = 4
		elseif GetCoreExpansion() < 2 then  --外域版本
			levelIndex = 5
		else								--WLK版本
			levelIndex = 6
		end
	end

	local knownCount, rewardCount = 0, 0  	
	for i = 0, levelIndex - 1 do  	--循环levelIndex次查询技能
		if data[KEYS.service.reward_1+i] > 0 then
			if player:HasSpell(data[KEYS.service.reward_1+i]) then
				knownCount = knownCount + 1
			end
			rewardCount = rewardCount + 1
		end
	end
	if knownCount == rewardCount then --如果都有，则购买失败并通知
		player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]   --获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) --扣除货币
	if not deducted then --若扣除失败，中止并通知
		return false
	end
	for i = 0, levelIndex - 1 do  -- 学习levelIndex个技能
		if data[KEYS.service.reward_1+i] > 0 then
			player:LearnSpell(data[KEYS.service.reward_1+i])
		end
	end
	player:AdvanceSkill(data[KEYS.service.EntryOrSkill], levelIndex * 75 - 1)	--默认有一点要去掉
	player:SaveToDB() --保存数据
	return true
end

--8、魔法技能
function Shop_Services.SpellHandler(player, data)
	local knownCount, rewardCount = 0, 0
	for i = 0, 7 do   --轮流检查玩家是否有此物品或技能
		if data[KEYS.service.reward_1+i] > 0 then
			if player:HasSpell(data[KEYS.service.reward_1+i]) then
				knownCount = knownCount + 1
			end
			rewardCount = rewardCount + 1
		end
	end
	if knownCount == rewardCount then    --如果都有，则购买失败并通知
		player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end

	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]	--获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) --扣除货币
	if not deducted then --若扣除失败，中止并通知
		return false
	end

	for i = 0, 7 do   -- 学习所有技能
		if data[KEYS.service.reward_1+i] > 0 then
			player:LearnSpell(data[KEYS.service.reward_1+i])
		end
	end
	player:SaveToDB() --保存数据
	return true
end

--9、幻化装扮
function Shop_Services.transHandler(player, data)
	local knownitem, rewarditem = 0, 0  	--轮流检查玩家是否有此物品或技能
	for i = 0, 7 do
		if data[KEYS.service.reward_1+i] > 0 then
			if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
				knownitem = knownitem + 1
			end
			rewarditem = rewarditem + 1
		end
	end
	if knownitem == rewarditem then  --如果都有，则购买失败并通知
		player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end

	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] 	--获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) --扣除货币
	if not deducted then  --若扣除失败，中止并通知
		return false
	end

	for i = 0, 7 do		--依次循环发放8套物品
		for j = 1, data[KEYS.service.rewardCount_1+i] do	--每套内物品一个一个发放，避免满了丢失
			if not player:AddItem(data[KEYS.service.reward_1+i], 1) then 	--如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
				SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
				break	--发放不成功结束对应套直接发放循环
			end
		end
	end
	player:SaveToDB() --保存数据
	return true
end

--10、头衔称号
function Shop_Services.TitleHandler(player, data)
	local knownitem, rewarditem = 0, 0  	--轮流检查玩家是否有此称号
	for i = 0, 7 do
		if data[KEYS.service.reward_1+i] > 0 then
			if player:HasTitle(data[KEYS.service.reward_1+i]) then
				knownitem = knownitem + 1
			end
			rewarditem = rewarditem + 1
		end
	end
	if knownitem == rewarditem then  --如果都有，则购买失败并通知
		player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."称号|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end

	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] --获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount)	--扣除货币
	if not deducted then --若扣除失败，中止并通知
		return false
	end
	player:SetKnownTitle(data[KEYS.service.reward_1])-- 发放所有称号
	player:SaveToDB() --保存数据
	return true
end

-- LEVELS 11、等级提升
function Shop_Services.LevelHandler(player, data)
	if data[KEYS.service.flags] < 1 or data[KEYS.service.flags] > 80 then	--消除等级错误设定
		if GetCoreExpansion() < 1 then  	--地球版本
			data[KEYS.service.flags] = 60
		elseif GetCoreExpansion() < 2 then  --外域版本
			data[KEYS.service.flags] = 70
		else								--WLK版本
			data[KEYS.service.flags] = 80
		end
	end

	if player:GetLevel() >= data[KEYS.service.flags] then --通过flags内填写等级，限制当前服务能达到的最大等级，大于这个则终止服务。
		player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.tooHighLevel..data[KEYS.service.flags].."|r")
		player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
		return false
	end

	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]	--获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount)	--扣除货币
	if not deducted then	--如果没有从玩家身上扣除货币，则中止并发送消息
		return false
	end

	local level = player:GetLevel() + data[KEYS.service.reward_1] --升级后的等级=现有等级+购买等级
	if level > data[KEYS.service.flags] then		--如果升级后的等级大于flags内限制的等级，取flags的等级为提升的等级。
		level = data[KEYS.service.flags]
	end
	player:SetLevel(level)
	player:SaveToDB() --保存数据
	return true
end

--12、系统服务 角色改名等技能
function Shop_Services.ServiceHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) 	--扣除货币
	if not deducted then --若扣除失败，中止并通知
		return false
	end
	player:SetAtLoginFlag(data[KEYS.service.reward_1]) 	-- 设置系统服务 0x1, 1改名字。0x2, 2遗忘所有法术。0x8, 8变容貌。 0x40, 64转阵营。 0x80, 128变种族。
	player:SendAreaTriggerMessage("|cFFFF0000请小退以完成角色修改服务！|r")
	player:SaveToDB() --保存数据
	return true
end
	
--13、GM代为目标角色改名等服务
function Shop_Services.ServiceProxy(player, data)
	local target = player:GetSelection()
	if target and target:GetTypeId() == player:GetTypeId() and target ~= player then
		local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
		local deducted = Shop_Services.DeductCurrency(player, currency, amount) 	--扣除货币
		if not deducted then --若扣除失败，中止并通知
			return false
		end
		target:SetAtLoginFlag(data[KEYS.service.reward_1]) 	-- 设置系统服务 0x1, 1改名字。0x2, 2遗忘所有法术。0x8, 8变容貌。 0x40, 64转阵营。 0x80, 128变种族。
		target:SendBroadcastMessage("|cFFFF0000请小退以完成角色修改服务！|r")
		target:SendAreaTriggerMessage("|cFFFF0000请小退以完成角色修改服务！|r")
		target:SaveToDB() --保存数据
		player:SendAreaTriggerMessage("|cFFFF0000已经完成角色服务！|r")
		return true
	else
		player:SendBroadcastMessage("|cFFFF0000请正确选择需要角色修改服务的目标！|r")
		player:SendAreaTriggerMessage("|cFFFF0000请正确选择需要角色修改服务的目标！|r")
		return false		
	end
end

--14、货币代币(仅仅示例,还需要匹配数据库和实际情况修改)
function Shop_Services.GoldHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] --获取数据库相应数值，货币种类。售价-打折
	local deducted = Shop_Services.DeductCurrency(player, currency, amount) -- 扣除商城货币
	if not deducted then --如果没有从玩家身上扣除货币，则中止并发送消息
		return false
	end

	for i = 0, 7 do		--依次循环发放8套物品
		for j = 1, data[KEYS.service.rewardCount_1+i] do	--每套内物品一个一个发放，避免满了丢失
			if not player:AddItem(data[KEYS.service.reward_1+i], 1) then 	--如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
				SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
				break	--发放不成功结束对应套直接发放循环
			end
		end
	end
	player:SaveToDB() --保存数据
	return true
end