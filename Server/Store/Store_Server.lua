-- 以下配置选项可以根据您的需求进行更改。
-- 任何不在配置选项中的内容都需要对下面的代码进行修改，
-- 请谨慎操作。

local CONFIG = {
    strings = {
        insufficientFunds = "你没有足够的",                 -- 物品名会在后续脚本中附在后面
        alreadyKnown = "你已经有了这",                      -- 物品,坐骑,宠物,头衔等会在后续脚本中附加在后面
        tooHighLevel = "你已达到该服务可用的最高等级",      -- 限制等级提示
        mailBody = "包裹已满，剩余物品代为邮寄",            -- 邮件提示内容
        successBox = "兑换成功，请检查包裹(邮件)或服务效果" -- 兑换成功提示
    }
}

local AIO = AIO or require("AIO")

-- 货币服务类型
local CURRENCY_TYPES = {
    [1] = "GOLD",
    [2] = "ITEM_TOKEN",
    [3] = "SERVER_HANDLED"
}

-- 商品程序处理分类，注意和呈现在哪个图形界面的分类没有关系
local Shop_Server_Index = {
    [3] = "ItemHandler",       -- 商业材料
    [4] = "ModuleHandler",     -- 变身道具
    [5] = "MountHandler",      -- 坐骑宠物
    [6] = "BuffHandler",       -- 增益效果
    [7] = "SKILLHandler",      -- 专业技能
    [8] = "SpellHandler",      -- 魔法技能
    [9] = "transHandler",      -- 幻化装扮
    [10] = "TitleHandler",     -- 头衔称号
    [11] = "LevelHandler",     -- 等级提升
    [12] = "ServiceHandler",   -- 系统服务
    [13] = "ServiceProxy",     -- 代为服务(用于GM帮助目标改名等)
    [14] = "GoldHandler"       -- 货币代币
}

-- 把具体Shop_Services的函数的扩展名和Shop_Server_Index文本一致，即可以调用根据索引动态调用函数
local Shop_Services = {}
-- 获取Store_DataStruct获取数据库结构分类
local KEYS = GetDataStructKeys()
local StoreHandler = AIO.AddHandlers("STORE_SERVER", {})

-- 初始化防止重复点击的变量
local IsDouble = 0

function StoreHandler.FrameData(player)
    AIO.Handle(player, "STORE_CLIENT", "FrameData", GetServiceData(), GetNavData(), GetCurrencyData(), player:GetGMRank())
end

-- 此项是显示在商城左下角货币数量的相关设置
function StoreHandler.UpdateCurrencies(player)
    local tmp = {}
    for currencyId, currency in pairs(GetCurrencyData()) do
        local val = 0
        local currencyTypeText = CURRENCY_TYPES[currency[KEYS.currency.currencyType]]

        -- 若是金币，则除10000以表示多少金
        if currencyTypeText == "GOLD" then
            val = math.floor(player:GetCoinage() / 10000)
        end

        -- 若是牌子类，则直接显示数量
        if currencyTypeText == "ITEM_TOKEN" then
            val = player:GetItemCount(currency[KEYS.currency.data])
        end

        -- 获取数据库内的积分数值,积分没有对应实物
        if currencyTypeText == "SERVER_HANDLED" then
            local AccID = player:GetAccountId()
            local query = AuthDBQuery("SELECT Cion FROM account_info WHERE ID = " .. AccID)
            if query then
                val = query:GetUInt32(0)
            else
                -- 确保账号存在
                local accountExists = AuthDBQuery("SELECT id, username FROM account WHERE id = " .. AccID)
                if accountExists then
                    local userName = accountExists:GetString(1)
                    -- 明确指定所有必要字段，包括设置Cion初始值为0
                    AuthDBExecute("INSERT INTO account_info (ID, UserName, Cion) VALUES (" .. AccID .. ", '" .. userName .. "', 0)")
                    -- 验证插入是否成功
                    local verifyQuery = AuthDBQuery("SELECT Cion FROM account_info WHERE ID = " .. AccID)
                    if verifyQuery then
                        val = verifyQuery:GetUInt32(0)
                        player:SendAreaTriggerMessage("账号积分记录已成功创建")
                    else
                        val = 0
                    end
                else
                    val = 0
                end
            end
        end

        -- 格式化数值显示
        if val < 10 then
            val = "   "..val
        elseif val < 100 then
            val = "  "..val     
        elseif val < 1000 then
            val = " "..val      
        elseif val < 10000 then
            -- 不做处理
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

-- 此项是商城兑换物品相关数据
function StoreHandler.Purchase(player, serviceId)
    -- 防止双击连续购买
    if IsDouble > 0 then
        return
    else
        IsDouble = IsDouble + 1        
        CreateLuaEvent(function() IsDouble = 0 end, 200, 1) -- 0.2秒后归零1次
    end

    local services = GetServiceData()
    -- 查看商城对应服务是否存在
    if services[serviceId] then
        -- 将id添加到服务子表中，不必更多的变量
        services[serviceId].ID = serviceId
        local typeId = services[serviceId][KEYS.service.serviceType]
        local serviceHandler = Shop_Services[Shop_Server_Index[typeId]]
        
        if serviceHandler then
            local success = serviceHandler(player, services[serviceId])
            -- 如果兑换成功
            if success then
                StoreHandler.UpdateCurrencies(player)                -- 更新用户UI界面
                Shop_Services.LogPurchase(player, services[serviceId]) -- 更新兑换记录
                player:PlayDirectSound(120, player)                   -- 播放兑换成功声音
                player:SendAreaTriggerMessage(services[serviceId][KEYS.service.name] .. " "..CONFIG.strings.successBox) -- 兑换成功提示
            end
        end
    end
end

-- 此项是扣款相关数据
function Shop_Services.DeductCurrency(player, currencyId, amount)
    local currency = GetCurrencyData()
    local currencyType = currency[currencyId][KEYS.currency.currencyType]
    local currencyName = currency[currencyId][KEYS.currency.name]
    local currencyData = currency[currencyId][KEYS.currency.data]
    
    -- 如果是金币的扣除方式
    if CURRENCY_TYPES[currencyType] == "GOLD" then
        if player:GetCoinage() < amount * 10000 then
            player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
            player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
            return false
        end
        -- 修改扣除的费用
        player:ModifyMoney(-amount * 10000)
    end
    
    -- 如果是牌子的扣除方式
    if CURRENCY_TYPES[currencyType] == "ITEM_TOKEN" then
        if not player:HasItem(currencyData, amount, true) then
            player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
            player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
            return false
        end
        -- 移除商品所需要的代币数量
        player:RemoveItem(currencyData, amount)
    end

    -- 积分的扣除方式
    if CURRENCY_TYPES[currencyType] == "SERVER_HANDLED" then
        local AccID = player:GetAccountId()
        local query = AuthDBQuery("SELECT Cion FROM account_info WHERE ID = " .. AccID)
        
        if query then
            local currentCion = query:GetUInt32(0)
            if currentCion >= amount then
                -- 扣除积分
                AuthDBExecute("UPDATE account_info SET Cion = Cion - " .. amount .. " WHERE ID = " .. AccID)
                return true
            end
        else
            -- 如果没有记录，创建一个新记录
            local accountExists = AuthDBQuery("SELECT id, username FROM account WHERE id = " .. AccID)
            if accountExists then
                local userName = accountExists:GetString(1)
                AuthDBExecute("INSERT INTO account_info (ID, UserName, Cion) VALUES (" .. AccID .. ", '" .. userName .. "', 0)")
            end
        end
        
        -- 积分不足或记录不存在
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.insufficientFunds.." "..currencyName.."|r")
        player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
        return false
    end
    
    return true
end

-- 记录购买日志
function Shop_Services.LogPurchase(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 注意插入字符串需要额外的引号,由于双引号系统使用了,这里 "..player:GetName().." 外面用单引号括号 ' ' ,否则容易导致服务器宕机。
    -- 另外为了方便改字段名，插入对象名字 (账号ID, 角色ID, 角色名......) 不再写入sql，用完整写入所有字段数据代替，故需补上 current_timestamp() 这样提交到数据库后,自动生成当前时间
    AuthDBExecute("INSERT INTO 商城_日志 VALUES("..player:GetAccountId()..", "..player:GetGUIDLow()..", '"..player:GetName().."', "..data.ID..", "..currency..", "..amount..", current_timestamp());")
end

------ 各类商城服务的实现函数 ------

-- 3、物品
function Shop_Services.ItemHandler(player, data)
    -- flags为1表示唯一性检查
    if data[KEYS.service.flags] == 1 then
        local knownitem, rewarditem = 0, 0  -- 轮流检查玩家是否有此物品或技能
        for i = 0, 7 do
            if data[KEYS.service.reward_1+i] > 0 then
                if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
                    knownitem = knownitem + 1
                end
                rewarditem = rewarditem + 1
            end
        end
        -- 如果拥有所有唯一物品，兑换失败。唯一物品建议每次卖一个，否则多余唯一物品会邮寄且无法取回。
        -- 可改判断为 knownitem > 0 则有唯一标记时候，拥有任意当前清单内物品都提示失败
        if knownitem == rewarditem then
            player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
            player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
            return false
        end 
    end

    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end

    -- 依次循环发放8套物品
    for i = 0, 7 do
        -- 每套内物品一个一个发放，避免满了丢失
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            -- 如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break -- 发放不成功结束对应套直接发放循环
            end
        end
    end
    
    player:SaveToDB() -- 保存数据
    return true
end

-- 4、变身道具
function Shop_Services.ModuleHandler(player, data)
    local knownitem, rewarditem = 0, 0  -- 轮流检查玩家是否有此物品或技能
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end
    
    -- 如果都有，则兑换失败并通知
    if knownitem == rewarditem then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end
    
    -- 依次循环发放8套物品
    for i = 0, 7 do
        -- 每套内物品一个一个发放，避免满了丢失
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            -- 如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break -- 发放不成功结束对应套直接发放循环
            end
        end
    end
    
    player:SaveToDB() -- 保存数据
    return true
end

-- 5、坐骑宠物
function Shop_Services.MountHandler(player, data)
    local knownCount, rewardCount = 0, 0
    -- 轮流检查玩家是否有此物品或技能
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasSpell(data[KEYS.service.reward_1+i]) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1
        end
    end
    
    -- 如果都有，则兑换失败并通知
    if knownCount == rewardCount then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end

    -- 学习所有技能
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:LearnSpell(data[KEYS.service.reward_1+i])
        end
    end
    
    player:SaveToDB() -- 保存数据
    return true
end

-- 6、增益效果
function Shop_Services.BuffHandler(player, data)
    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end

    -- 施放所有技能状态
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:CastSpell(player, data[KEYS.service.reward_1+i], true)
        end
    end
    
    return true
end

-- 7、专业技能
function Shop_Services.SKILLHandler(player, data)
    -- 用生物entry这个字段设定技能最高等级，300对应60，375对应70，450对应80，也可其他数值但是不建议
    local levelIndex = math.ceil(data[KEYS.service.flags] / 75)
    -- 如输入不正确，改为获取版本默认的索引级别
    if levelIndex < 1 or levelIndex > 6 then
        if GetCoreExpansion() < 1 then     -- 经典版本
            levelIndex = 4
        elseif GetCoreExpansion() < 2 then -- 燃烧的远征版本
            levelIndex = 5
        else                              -- 巫妖王之怒版本
            levelIndex = 6
        end
    end

    local knownCount, rewardCount = 0, 0
    -- 循环levelIndex次查询技能
    for i = 0, levelIndex - 1 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasSpell(data[KEYS.service.reward_1+i]) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1
        end
    end
    
    -- 如果都有，则兑换失败并通知
    if knownCount == rewardCount then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end
    
    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end
    
    -- 学习levelIndex个技能
    for i = 0, levelIndex - 1 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:LearnSpell(data[KEYS.service.reward_1+i])
        end
    end
    
    -- 默认有一点要去掉
    player:AdvanceSkill(data[KEYS.service.EntryOrSkill], levelIndex * 75 - 1)
    
    player:SaveToDB() -- 保存数据
    return true
end

-- 8、魔法技能
function Shop_Services.SpellHandler(player, data)
    local knownCount, rewardCount = 0, 0
    -- 轮流检查玩家是否有此物品或技能
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasSpell(data[KEYS.service.reward_1+i]) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1
        end
    end
    
    -- 如果都有，则兑换失败并通知
    if knownCount == rewardCount then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end

    -- 学习所有技能
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            player:LearnSpell(data[KEYS.service.reward_1+i])
        end
    end
    
    player:SaveToDB() -- 保存数据
    return true
end

-- 9、幻化装扮
function Shop_Services.transHandler(player, data)
    local knownitem, rewarditem = 0, 0  -- 轮流检查玩家是否有此物品或技能
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasItem(data[KEYS.service.reward_1+i], 1, true) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end
    
    -- 如果都有，则兑换失败并通知
    if knownitem == rewarditem then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."物品|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end

    -- 依次循环发放8套物品
    for i = 0, 7 do
        -- 每套内物品一个一个发放，避免满了丢失
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            -- 如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break -- 发放不成功结束对应套直接发放循环
            end
        end
    end
    
    player:SaveToDB() -- 保存数据
    return true
end

-- 10、头衔称号
function Shop_Services.TitleHandler(player, data)
    local knownitem, rewarditem = 0, 0  -- 轮流检查玩家是否有此称号
    for i = 0, 7 do
        if data[KEYS.service.reward_1+i] > 0 then
            if player:HasTitle(data[KEYS.service.reward_1+i]) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end
    
    -- 如果都有，则兑换失败并通知
    if knownitem == rewarditem then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.alreadyKnown.."称号|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end
    
    -- 发放称号
    player:SetKnownTitle(data[KEYS.service.reward_1])
    
    player:SaveToDB() -- 保存数据
    return true
end

-- 11、等级提升
function Shop_Services.LevelHandler(player, data)
    -- 消除等级错误设定
    if data[KEYS.service.flags] < 1 or data[KEYS.service.flags] > 80 then
        if GetCoreExpansion() < 1 then      -- 经典版本
            data[KEYS.service.flags] = 60
        elseif GetCoreExpansion() < 2 then  -- 燃烧的远征版本
            data[KEYS.service.flags] = 70
        else                                -- 巫妖王之怒版本
            data[KEYS.service.flags] = 80
        end
    end

    -- 通过flags内填写等级，限制当前服务能达到的最大等级，大于这个则终止服务。
    if player:GetLevel() >= data[KEYS.service.flags] then
        player:SendAreaTriggerMessage("|cFFFF0000"..CONFIG.strings.tooHighLevel..data[KEYS.service.flags].."|r")
        player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
        return false
    end

    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 如果没有从玩家身上扣除货币，则中止并发送消息
    if not deducted then
        return false
    end

    -- 升级后的等级=现有等级+兑换等级
    local level = player:GetLevel() + data[KEYS.service.reward_1]
    -- 如果升级后的等级大于flags内限制的等级，取flags的等级为提升的等级。
    if level > data[KEYS.service.flags] then
        level = data[KEYS.service.flags]
    end
    
    player:SetLevel(level)
    player:SaveToDB() -- 保存数据
    return true
end

-- 12、系统服务 角色改名等技能
function Shop_Services.ServiceHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 若扣除失败，中止并通知
    if not deducted then
        return false
    end
    
    -- 设置系统服务 0x1, 1改名字。0x2, 2遗忘所有法术。0x8, 8变容貌。 0x40, 64转阵营。 0x80, 128变种族。
    player:SetAtLoginFlag(data[KEYS.service.reward_1])
    player:SendAreaTriggerMessage("|cFFFF0000请小退以完成角色修改服务！|r")
    
    player:SaveToDB() -- 保存数据
    return true
end
    
-- 13、GM代为目标角色改名等服务
function Shop_Services.ServiceProxy(player, data)
    local target = player:GetSelection()
    if target and target:GetTypeId() == player:GetTypeId() and target ~= player then
        local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
        -- 扣除货币
        local deducted = Shop_Services.DeductCurrency(player, currency, amount)
        -- 若扣除失败，中止并通知
        if not deducted then
            return false
        end
        
        -- 设置系统服务 0x1, 1改名字。0x2, 2遗忘所有法术。0x8, 8变容貌。 0x40, 64转阵营。 0x80, 128变种族。
        target:SetAtLoginFlag(data[KEYS.service.reward_1])
        target:SendBroadcastMessage("|cFFFF0000请小退以完成角色修改服务！|r")
        target:SendAreaTriggerMessage("|cFFFF0000请小退以完成角色修改服务！|r")
        
        target:SaveToDB() -- 保存数据
        player:SendAreaTriggerMessage("|cFFFF0000已经完成角色服务！|r")
        return true
    else
        player:SendBroadcastMessage("|cFFFF0000请正确选择需要角色修改服务的目标！|r")
        player:SendAreaTriggerMessage("|cFFFF0000请正确选择需要角色修改服务的目标！|r")
        return false        
    end
end

-- 14、货币代币
function Shop_Services.GoldHandler(player, data)
    -- 获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 扣除商城货币
    local deducted = Shop_Services.DeductCurrency(player, currency, amount)
    -- 如果没有从玩家身上扣除货币，则中止并发送消息
    if not deducted then
        return false
    end

    -- 依次循环发放8套物品
    for i = 0, 7 do
        -- 每套内物品一个一个发放，避免满了丢失
        for j = 1, data[KEYS.service.rewardCount_1+i] do
            -- 如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
            if not player:AddItem(data[KEYS.service.reward_1+i], 1) then
                SendMail("商城快递："..data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1+i], (data[KEYS.service.rewardCount_1+i] -j + 1))
                break -- 发放不成功结束对应套直接发放循环
            end
        end
    end
    
    player:SaveToDB() -- 保存数据
    return true
end