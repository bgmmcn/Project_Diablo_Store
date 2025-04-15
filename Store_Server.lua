local CONFIG = {
    strings = {
        insufficientFunds = "你没有足够的",
        alreadyKnown = "你已经有了这",
        tooHighLevel = "你已达到该服务可用的最高等级",
        mailBody = "包裹已满，剩余物品代为邮寄",
        successBox = "兑换成功，请检查包裹(邮件)或服务效果"
    }
}

local AIO = AIO or require("AIO")

local CURRENCY_TYPES = {
    [1] = "GOLD",
    [2] = "ITEM",
    [3] = "COIN",
    [4] = "TOKEN"
}

local Shop_Server_Index = {
    [1] = "ItemHandler",
    [2] = "ModuleHandler",
    [3] = "MountHandler",
    [4] = "BuffHandler",
    [5] = "SKILLHandler",
    [6] = "SpellHandler",
    [7] = "transHandler",
    [8] = "TitleHandler",
    [9] = "LevelHandler",
    [10] = "ServiceHandler",
    [11] = "ServiceProxy",
    [12] = "GoldHandler"
}

local Shop_Services = {}
local KEYS = GetDataStructKeys()
local StoreHandler = AIO.AddHandlers("STORE_SERVER", {})

function StoreHandler.FrameData(player)
    AIO.Handle(player, "STORE_CLIENT", "FrameData", GetServiceData(), GetNavData(), GetCurrencyData(), player:GetGMRank())
end

function StoreHandler.UpdateCurrencies(player)
    local tmp = {}
    for currencyId, currency in pairs(GetCurrencyData()) do
        local val = 0
        local currencyTypeText = CURRENCY_TYPES[currency[KEYS.currency.currencyType]]

        if currencyTypeText == "GOLD" then
            val = math.floor(player:GetCoinage() / 10000)
        end

        if currencyTypeText == "ITEM" then
            val = player:GetItemCount(currency[KEYS.currency.data])
        end

        if currencyTypeText == "COIN" then
            local AccID = player:GetAccountId()
            local query = AuthDBQuery("SELECT Coin FROM account_info WHERE ID = " .. AccID)
            if query then
                val = query:GetUInt32(0)
            else
                AuthDBExecute("INSERT INTO account_info (ID, UserName, IP) SELECT id, username, last_attempt_ip FROM account WHERE id = " .. AccID)
                val = 0
            end
        end

        if currencyTypeText == "TOKEN" then
            local AccID = player:GetAccountId()
            local query = AuthDBQuery("SELECT Token FROM account_info WHERE ID = " .. AccID)
            if query then
                val = query:GetUInt32(0)
            end
        end

        if val < 10 then
            val = "   "..val
        elseif val < 100 then
            val = "  "..val     
        elseif val < 1000 then
            val = " "..val      
        elseif val < 10000 then
            
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

function StoreHandler.Purchase(player, serviceId)
    if IsDouble > 0 then
        return
    else
        IsDouble = IsDouble + 1        
        CreateLuaEvent(function() IsDouble = 0 end, 200, 1)
    end

    local services = GetServiceData()
    if services[serviceId] then
        services[serviceId].ID = serviceId
        local typeId = services[serviceId][KEYS.service.serviceType]
        local serviceHandler = Shop_Services[Shop_Server_Index[typeId]]
        if serviceHandler then
            local success = serviceHandler(player, services[serviceId])
            if success then
                StoreHandler.UpdateCurrencies(player)
                Shop_Services.LogPurchase(player, services[serviceId])
                player:PlayDirectSound(120, player)
                player:SendAreaTriggerMessage(services[serviceId][KEYS.service.name] .. " "..CONFIG.strings.successBox)
            end
        end
    end
end

function Shop_Services.DeductCurrency(player, currencyId, amount)
    local currency = GetCurrencyData()
    local currencyType = currency[currencyId][KEYS.currency.currencyType]
    local currencyName = currency[currencyId][KEYS.currency.name]
    local currencyData = currency[currencyId][KEYS.currency.data]
    
    if CURRENCY_TYPES[currencyType] == "GOLD" then
        if player:GetCoinage() < amount * 10000 then
            player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
            player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
            return false
        end
        player:ModifyMoney(-amount * 10000)
    end
    
    if CURRENCY_TYPES[currencyType] == "ITEM" then
        if not player:HasItem(currencyData, amount, true) then
            player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
            player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
            return false
        end
        player:RemoveItem(currencyData, amount)
    end

    if CURRENCY_TYPES[currencyType] == "COIN" then
        local AccID = player:GetAccountId()
        local query = AuthDBQuery("SELECT Coin FROM account_info WHERE ID = " .. AccID)
        
        if query then
            local currentCoin = query:GetUInt32(0)
            if currentCoin >= amount then
                AuthDBExecute("UPDATE account_info SET Coin = Coin - " .. amount .. " WHERE ID = " .. AccID)
                return true
            end
        end
        
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
        player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
        return false
    end

if CURRENCY_TYPES[currencyType] == "TOKEN" then
	local AccID = player:GetAccountId()
	local query = AuthDBQuery("SELECT Token FROM account_info WHERE ID = " .. AccID)
	
	if query then
		local currentCoin = query:GetUInt32(0)
		if currentCoin >= amount then
			AuthDBExecute("UPDATE account_info SET Token = Token - " .. amount .. " WHERE ID = " .. AccID)
			return true
		end
	end
	
	player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
	player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
	return false
end
return true
end

function Shop_Services.LogPurchase(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    AuthDBExecute("INSERT INTO 商城_日志 VALUES("..player:GetAccountId()..", "..player:GetGUIDLow()..", '"..player:GetName().."', "..data.ID..", "..currency..", "..amount..", current_timestamp());")
end

function Shop_Services.ItemHandler(player, data)
    if data[KEYS.service.flags] == 1 then
        local knownitem, rewarditem = 0, 0
        for i = 0, 7 do
            if data[KEYS.service.reward_1+i] > 0 then
                if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
                    knownitem = knownitem + 1
                end
                rewarditem = rewarditem + 1
            end
        end
        if knownitem == rewarditem then
            player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
            player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
            return false
        end 
    end

    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end

    for i = 0, 7 do
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break
            end
        end
    end
    player:SaveToDB()
    return true
end

function Shop_Services.ModuleHandler(player, data)
    local knownitem, rewarditem = 0, 0
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end
    if knownitem == rewarditem then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end
    
    for i = 0, 7 do
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break
            end
        end
    end
    player:SaveToDB()
    return true
end

function Shop_Services.MountHandler(player, data)
    local knownCount, rewardCount = 0, 0
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasSpell(data[KEYS.service.reward_1+i]) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1
        end
    end
    if knownCount == rewardCount then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end

    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:LearnSpell(data[KEYS.service.reward_1+i])
        end
    end
    player:SaveToDB()
    return true
end

function Shop_Services.BuffHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end

    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:CastSpell(player, data[KEYS.service.reward_1+i], true)
        end
    end
    return true
end

function Shop_Services.SKILLHandler(player, data)
    local levelIndex = math.ceil(data[KEYS.service.flags] / 75)
    if levelIndex < 1 or levelIndex > 6 then
        if GetCoreExpansion() < 1 then
            levelIndex = 4
        elseif GetCoreExpansion() < 2 then
            levelIndex = 5
        else
            levelIndex = 6
        end
    end

    local knownCount, rewardCount = 0, 0
    for i = 0, levelIndex - 1 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasSpell(data[KEYS.service.reward_1+i]) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1
        end
    end
    if knownCount == rewardCount then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end
    
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end
    
    for i = 0, levelIndex - 1 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:LearnSpell(data[KEYS.service.reward_1+i])
        end
    end
    player:AdvanceSkill(data[KEYS.service.EntryOrSkill], levelIndex * 75 - 1)
    player:SaveToDB()
    return true
end

function Shop_Services.SpellHandler(player, data)
    local knownCount, rewardCount = 0, 0
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasSpell(data[KEYS.service.reward_1+i]) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1
        end
    end
    if knownCount == rewardCount then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end

    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:LearnSpell(data[KEYS.service.reward_1+i])
        end
    end
    player:SaveToDB()
    return true
end

function Shop_Services.transHandler(player, data)
    local knownitem, rewarditem = 0, 0
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end
    if knownitem == rewarditem then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end

    for i = 0, 7 do
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break
            end
        end
    end
    player:SaveToDB()
    return true
end

function Shop_Services.TitleHandler(player, data)
    local knownitem, rewarditem = 0, 0
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasTitle(data[KEYS.service.reward_1+i]) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end
    if knownitem == rewarditem then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."称号|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end
    player:SetKnownTitle(data[KEYS.service.reward_1])
    player:SaveToDB()
    return true
end

function Shop_Services.LevelHandler(player, data)
    if data[KEYS.service.flags] < 1 or data[KEYS.service.flags] > 80 then
        if GetCoreExpansion() < 1 then
            data[KEYS.service.flags] = 60
        elseif GetCoreExpansion() < 2 then
            data[KEYS.service.flags] = 70
        else
            data[KEYS.service.flags] = 80
        end
    end

    if player:GetLevel() >= data[KEYS.service.flags] then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.tooHighLevel..data[KEYS.service.flags].."|r")
        player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
        return false
    end

    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end

    local level = player:GetLevel() + data[KEYS.service.reward_1]
    if level > data[KEYS.service.flags] then
        level = data[KEYS.service.flags]
    end
    player:SetLevel(level)
    player:SaveToDB()
    return true
end

function Shop_Services.ServiceHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end
    player:SetAtLoginFlag(data[KEYS.service.reward_1])
    player:SendAreaTriggerMessage("|cFFFF0000请小退以完成角色修改服务！|r")
    player:SaveToDB()
    return true
end
    
function Shop_Services.ServiceProxy(player, data)
    local target = player:GetSelection()
    if target and target:GetTypeId() == player:GetTypeId() and target ~= player then
        local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
        local deducted = Shop_Services.DeductCurrency(player, currency, amount)
        if not deducted then
            return false
        end
        target:SetAtLoginFlag(data[KEYS.service.reward_1])
        target:SendBroadcastMessage("|cFFFF0000请小退以完成角色修改服务！|r")
        target:SendAreaTriggerMessage("|cFFFF0000请小退以完成角色修改服务！|r")
        target:SaveToDB()
        player:SendAreaTriggerMessage("|cFFFF0000已经完成角色服务！|r")
        return true
    else
        player:SendBroadcastMessage("|cFFFF0000请正确选择需要角色修改服务的目标！|r")
        player:SendAreaTriggerMessage("|cFFFF0000请正确选择需要角色修改服务的目标！|r")
        return false        
    end
end

function Shop_Services.GoldHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    if not deducted then
        return false
    end

    for i = 0, 7 do
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break
            end
        end
    end
    player:SaveToDB()
    return true
end