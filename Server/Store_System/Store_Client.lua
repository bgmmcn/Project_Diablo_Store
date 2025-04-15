-- The below config options can be changed to suit your needs. 以下配置选项可以根据您的需要进行更改。
-- Anything not in the config options requires changes to the code below, 配置选项中没有的任何内容都需要更改以下代码，
-- do so at your own discretion. 你可以自行决定。

local CONFIG = {
	maxCategories = 12,
	strings = {
		categoryAccessDenied = "您无权访问此项目！",
	}
}



local AIO = AIO or require("AIO")
if AIO.AddAddon() then
	return
end

--------仅仅影响客户端，和服务器的LUA全局变量没有关系---------
local KEYS_CLIENT = {
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

local scaleMulti = 1

-- Helpers --

local function CoordsToTexCoords(size, xTop, yTop, xBottom, yBottom)
	local magic = (1/size)/2
	local Top = (yTop/size) + magic
	local Left = (xTop/size) + magic
	local Bottom = (yBottom/size) - magic
	local Right = (xBottom/size) - magic

	return Left, Right, Top, Bottom
end

--------仅仅影响客户端，和服务器的LUA全局变量没有关系---------
local SHOP_UI_CLIENT = {
	["Vars"] = {
		currentCategory = 1,
		currentNavId = 1,
		currentPage = 1,
		maxPages = 1,
		accountRank = 0,
		["playerCurrencies"] = {}
	},
	["Data"] = {
		nav = {},
		services = {},
		currencies = {}
	}
}

local StoreHandler = AIO.AddHandlers("STORE_CLIENT", {})

function StoreHandler.FrameData(player, services, nav, currencies, rank)
	SHOP_UI_CLIENT["Data"].services = services
	SHOP_UI_CLIENT["Data"].nav = nav
	SHOP_UI_CLIENT["Data"].currencies = currencies
	SHOP_UI_CLIENT["Vars"].accountRank = rank
	SHOP_UI_CLIENT.NavButtons_OnData()
	SHOP_UI_CLIENT.CurrencyBadges_OnData()
	SHOP_UI_CLIENT.ServiceBoxes_OnData()
end

function StoreHandler.UpdateCurrencies(player, currencies)
	for k, v in pairs(currencies) do
		SHOP_UI_CLIENT["Vars"]["playerCurrencies"][k] = v
	end
	SHOP_UI_CLIENT.CurrencyBadges_Update()
end


--商城 主窗口
function SHOP_UI_CLIENT.MainFrame_Create()
	--创建主框架
	local shopFrame = CreateFrame("Frame", "SHOP_FRAME", UIParent)
	shopFrame:SetPoint("LEFT", 100, 0)
	shopFrame:Hide()--初始隐藏
	shopFrame:SetToplevel(true) --置顶
	shopFrame:SetClampedToScreen(true) --镶嵌到屏幕
	shopFrame:SetMovable(true) --可移动
	shopFrame:EnableMouse(true) --启用鼠标
	shopFrame:RegisterForDrag("LeftButton")--左键拖动
	shopFrame:SetScript("OnDragStart", shopFrame.StartMoving)--拖动时 移动或调整大小
	shopFrame:SetScript("OnHide", shopFrame.StopMovingOrSizing)--隐藏时停止 移动或调整大小
	shopFrame:SetScript("OnDragStop", shopFrame.StopMovingOrSizing) --拖动停止时停止移动或调整大小
	
	-- Pixel size of background texture, then scaled 背景纹理的像素大小，然后缩放
	shopFrame:SetSize(1024*scaleMulti, 658*scaleMulti)
	
	-- Background texture 背景贴图
	shopFrame.Background = shopFrame:CreateTexture(nil, "BACKGROUND")
	shopFrame.Background:SetSize(shopFrame:GetSize())
	shopFrame.Background:SetPoint("CENTER", shopFrame, "CENTER")
	shopFrame.Background:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	shopFrame.Background:SetTexCoord(CoordsToTexCoords(1024, 0, 0, 1024, 658))
	
	--标题--
	shopFrame.Title = shopFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
	shopFrame.Title:SetTextHeight(20)
	shopFrame.Title:SetShadowOffset(1, -1)
	shopFrame.Title:SetPoint("TOP", shopFrame, "TOP", 0, -3)
	shopFrame.Title:SetText("|cffedd100魔      兽      商      城|r")
	
	-- create navigation button placeholders, pass parent as arg 导航
	SHOP_UI_CLIENT.NavButtons_Create(shopFrame)
	
	-- create page buttons 创建页面按钮
	SHOP_UI_CLIENT.PageButtons_Create(shopFrame)
	
	-- create service box placeholders, pass parent as arg 创建服务框占位符
	SHOP_UI_CLIENT.ServiceBoxes_Create(shopFrame)
	
	-- create currency badge placeholders 创建货币徽章占位符
	SHOP_UI_CLIENT.CurrencyBadges_Create(shopFrame)
	
	-- create placeholder preview frame 创建占位符预览框
	SHOP_UI_CLIENT.ModelFrame_Create(shopFrame)
	
	-- Request all service data 请求所有服务数据
	AIO.Handle("STORE_SERVER", "FrameData")
	AIO.Handle("STORE_SERVER", "UpdateCurrencies")
--[[	主菜单激活直接调用商城,去掉这个功能
	MainMenuMicroButton:SetScript(
		"OnClick",
		function()
			if GameMenuFrame:IsShown() then
				MainFrame_Toggle()
			end
		end
	)
]]--
	shopFrame.CloseButton = CreateFrame("Button", nil, shopFrame, "UIPanelCloseButton")
	shopFrame.CloseButton:SetSize(30, 30)
	shopFrame.CloseButton:SetPoint("TOPRIGHT", shopFrame, "TOPRIGHT", 5, 5)
	shopFrame.CloseButton:EnableMouse(true)
	shopFrame.CloseButton:SetScript(
		"OnClick",
		function()
			MainFrame_Toggle()
		end
	)
	
	shopFrame:SetScript(
		"OnShow",
		function()
			AIO.Handle("STORE_SERVER", "UpdateCurrencies")
			PlaySound("AuctionWindowOpen", "Master") 
		end
	)
	
	shopFrame:SetScript(
		"OnHide",
		function()
			-- also hide the preview window
			SHOP_UI_CLIENT["MODEL_FRAME"]:Hide()
			PlaySound("AuctionWindowClose", "Master") 
		end
	)
	
	-- make frame close on escape
	tinsert(UISpecialFrames, shopFrame:GetName())
	
	SHOP_UI_CLIENT["FRAME"] = shopFrame
end

function SHOP_UI_CLIENT.NavButtons_Create(parent)		--物品购买分类导航按钮
	SHOP_UI_CLIENT["NAV_BUTTONS"] = {}
	local offset = 0
	for i = 1, 12 do	--框架最多12个
		local navButton = CreateFrame("Button", nil, parent)
		
		-- default variables
		navButton.NavId = i
		
		-- Main button
		local size = 220
		
		navButton:SetSize(size*scaleMulti, (size/4)*scaleMulti)
		navButton:SetPoint("LEFT", parent, "LEFT", 17, 232+offset) --位置
		
		navButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		navButton:SetHighlightTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		navButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 768, 897, 1023, 960))
		navButton:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 768, 960, 1023, 1023))
		
		-- navButton name 标题
		navButton.Name = navButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		navButton.Name:SetTextHeight(18)
		navButton.Name:SetShadowOffset(1, -1)
		navButton.Name:SetPoint("CENTER", navButton, "CENTER", 8, 0)
		
		-- Icon 图标
		navButton.Icon = navButton:CreateTexture(nil, "BACKGROUND")
		navButton.Icon:SetSize(33, 33)
		navButton.Icon:SetPoint("LEFT", navButton, "LEFT", 9, -1)

		offset = offset - 42	--上下间隔（包含导航条本身高度）
		
		navButton:SetScript("OnClick", SHOP_UI_CLIENT.NavButtons_OnClick)
		
		-- push button to shop table for later access
		SHOP_UI_CLIENT["NAV_BUTTONS"][i] = navButton

		navButton:Hide()	--默认初始化隐藏所有图标
	end

	SHOP_UI_CLIENT.NavButtons_OnData()
end

function SHOP_UI_CLIENT.NavButtons_OnClick(self)	--点击左侧导航标签进行权限控制
	-- check whether the player has the correct rank to open a tab
	if(self.RequiredRank > SHOP_UI_CLIENT["Vars"].accountRank) then
		UIErrorsFrame:AddMessage(CONFIG.strings.categoryAccessDenied, 1.0, 0.0, 0.0, 2);
		PlaySound("igPlayerInviteDecline", "Master")
		return;
	end
	
	PlaySound("uChatScrollButton", "Master")
	--设置类别ID, 选择导航ID, 并设置当前类别翻页为1
	SHOP_UI_CLIENT["Vars"].currentCategory = self.CategoryId
	SHOP_UI_CLIENT["Vars"].currentNavId = self.NavId
	SHOP_UI_CLIENT["Vars"].currentPage = 1
	
	-- Update frame elements
	SHOP_UI_CLIENT.NavButtons_UpdateSelect()
	SHOP_UI_CLIENT.ServiceBoxes_Update()
	SHOP_UI_CLIENT.PageButtons_Update()
end

function SHOP_UI_CLIENT.NavButtons_UpdateSelect()
	-- reset all buttons to normal unselected texture
	for i = 1, CONFIG.maxCategories do
		SHOP_UI_CLIENT["NAV_BUTTONS"][i]:UnlockHighlight()
	end
	
	-- 锁定选中的Nav的高度
	SHOP_UI_CLIENT["NAV_BUTTONS"][SHOP_UI_CLIENT["Vars"].currentNavId]:LockHighlight()
end

function SHOP_UI_CLIENT.NavButtons_OnData()
	index = 1	--索引当前
	for _, v in pairs(SHOP_UI_CLIENT["Data"].nav) do
		if index > CONFIG.maxCategories then	--如果大于最大分类菜单,则截断
			break
		end

		if(v[KEYS_CLIENT.category.enabled] == 1) then	--如果该分类允许,则显示对应分类
			local button = SHOP_UI_CLIENT["NAV_BUTTONS"][index]	--给分类菜单更新数据
			button.CategoryId = v[KEYS_CLIENT.category.id]
			button.NameText = v[KEYS_CLIENT.category.name]
			button.IconTexture = v[KEYS_CLIENT.category.icon]
			button.RequiredRank = v[KEYS_CLIENT.category.requiredRank]
			button.Icon:SetTexture("Interface/Icons/" .. button.IconTexture .. ".blp")	--更新图标和名字
			button.Name:SetFormattedText("|cffdbe005%s|r", button.NameText)
			button:Show()	--显示该菜单,前面整体框架有设定默认不显示
		-- increment index
		index = index + 1
		end

	end
	
	-- 我们应当设置一个初始化默认的Nav,默认为1
	local button = SHOP_UI_CLIENT["NAV_BUTTONS"][1]
	SHOP_UI_CLIENT["Vars"].currentCategory = button.CategoryId
	SHOP_UI_CLIENT["Vars"].currentNavId = button.NavId
	SHOP_UI_CLIENT.NavButtons_UpdateSelect()
end

function SHOP_UI_CLIENT.OnPurchaseConfirm(data)
	AIO.Handle("STORE_SERVER", "Purchase", data)
end

StaticPopupDialogs["CONFIRM_STORE_PURCHASE"] = {
	text = "确定购买 %s ？",
	button1 = "是",
	button2 = "否",
	OnAccept = function(self, data)
		SHOP_UI_CLIENT.OnPurchaseConfirm(data)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function SHOP_UI_CLIENT.ServiceBoxes_Create(parent)	--建立每页的商品列表
	SHOP_UI_CLIENT["SERVICE_BUTTONS"] = {}
	for i = 1, 8 do		--每页8个
		local service = CreateFrame("Button", nil, parent)	-- 创建对应服务框架,并预定义必要的参数
		service.ServiceId = 0
		service.Name = ""
		service.Count = ""
		service.TooltipName = nil
		service.TooltipText = nil
		service.TooltipType = ""
		service.TooltipHyperlink = 0
		
		-- determine box coordinates
		local row1_y = 110
		local row2_y = -155
		local x_offsets = {-140, 35, 210, 375}
		local BoxCoordX, BoxCoordY
		if i <= 4 then
			BoxCoordY = row1_y
		else
			BoxCoordY = row2_y
		end
		BoxCoordX = x_offsets[(i - 1) % 4 + 1]
		
		service:SetSize(160, 260)
		service:SetPoint("CENTER", parent, "CENTER", BoxCoordX, BoxCoordY)
		service:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service:SetHighlightTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 0, 658, 215, 1023))
		service:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 215, 658, 430, 1023))
		
		-- icon 图标
		service.Icon = service:CreateTexture(nil, "BACKGROUND")
		service.Icon:SetSize(40, 40)
		service.Icon:SetPoint("CENTER", service, "CENTER", 0, 70)
		
		-- 数量
		service.CountFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		service.CountFont:SetTextHeight(16)
		service.CountFont:SetShadowOffset(1, -1)
		service.CountFont:SetPoint("CENTER", service.Icon, "CENTER", 27, -15)

		-- service name 名字
		service.NameFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		service.NameFont:SetTextHeight(14)
		service.NameFont:SetJustifyH("CENTER")	--让回车后文字也水平居中。数据库内可用导入条目的方式,在文字中间添加 \n 可实现文字分行显示。直接添加不行，会自动变成 \\n
		--service.NameFont:SetJustifyV("CENTER") --文字垂直居中
		service.NameFont:SetShadowOffset(1, -1)
		service.NameFont:SetPoint("CENTER", service, "CENTER", 0, 16)
		
		-- service price 价格
		service.PriceFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		service.PriceFont:SetTextHeight(18)
		service.PriceFont:SetShadowOffset(1, -1)
		service.PriceFont:SetPoint("CENTER", service, "CENTER", 0, -35)
		
		-- price currency icon 价格图标
		service.currencyIcon = service:CreateTexture(nil, "OVERLAY")
		service.currencyIcon:SetSize(18, 18)
		service.currencyIcon:SetPoint("LEFT", service.PriceFont, "RIGHT", 0, 0)
		
		--Discount-- 折扣
		service.DicountFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		service.DicountFont:SetTextHeight(16)
		service.DicountFont:SetShadowOffset(1, -1)
		service.DicountFont:SetPoint("CENTER", service.PriceFont, "CENTER", 5, 20)
		
		--Discount Line-- 折扣线--
		service.DiscountSlash = service:CreateTexture(nil, "OVERLAY")
		service.DiscountSlash:SetSize(36, 18)	--前面数字是折扣线长度，后面数字是折扣线高度，长度是宽度2倍比较好看
		service.DiscountSlash:SetPoint("CENTER", service.DicountFont)
		service.DiscountSlash:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service.DiscountSlash:SetTexCoord(CoordsToTexCoords(1024, 992, 804, 1023, 835))
		
		--Discount Banner-- 折扣条--
		service.Banner = CreateFrame("Frame", nil, service)
		service.Banner:SetSize(80, 25)
		service.Banner:SetPoint("TOPRIGHT", service, "TOPRIGHT", 0, 4)
		
		-- Discount Banner Background-- 折扣背景--
		service.Banner.Background = service.Banner:CreateTexture(nil, "BACKGROUND")
		service.Banner.Background:SetSize(80, 25)
		service.Banner.Background:SetPoint("CENTER", service.Banner)
		service.Banner.Background:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service.Banner.Background:SetTexCoord(CoordsToTexCoords(1024, 862, 765, 961, 815))
		
		--Discount Banner Text-- 折扣背景文字--
		service.BannerText = service.Banner:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		service.BannerText:SetTextHeight(18)
		service.BannerText:SetShadowOffset(1, -1)
		service.BannerText:SetPoint("CENTER", service.Banner.Background,"CENTER", 5, -5)
		
		--New Tag-- 新品标签--
		service.newTag = service:CreateTexture(nil, "OVERLAY")
		service.newTag:SetSize(65, 30)
		service.newTag:SetPoint("CENTER", service, "LEFT", 35, 114)
		service.newTag:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service.newTag:SetTexCoord(CoordsToTexCoords(1024, 862, 816, 961, 866))
		
		-- Buy now button 购买标签
		service.buyButton = CreateFrame("Button", nil, service)
		service.buyButton:SetSize(100, 28)
		service.buyButton:SetPoint("CENTER", service, "CENTER", 0, -85)
		service.buyButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service.buyButton:SetHighlightTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service.buyButton:SetPushedTexture("Interface/Store_UI/Frames/StoreFrame_Main")
		service.buyButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 849, 837, 873))
		service.buyButton:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 849, 837, 873))
		service.buyButton:GetPushedTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 873, 837, 897))
		
		-- Buy now button text 购买文字
		service.buyButton.ButtonText = service.buyButton:CreateFontString(nil, "ARTWORK", "GameTooltipText")
		service.buyButton.ButtonText:SetTextHeight(16)
		service.buyButton.ButtonText:SetPoint("CENTER", service.buyButton, 0, 1)
		service.buyButton.ButtonText:SetText("购  买")
		
		service.buyButton:SetScript(
			"OnClick",
			function(self)
				local dialog = StaticPopup_Show("CONFIRM_STORE_PURCHASE", self:GetParent().Name)	 -- dialog contains the frame object
				if (dialog) then
					dialog.data = self:GetParent().ServiceId
				end
				
				PlaySound("STORE_CONFIRM", "Master")
			end
		)
		
		--提示信息，鼠标移到代币对应区域，会提示代币类型
		service:SetScript(
			"OnEnter",
			function(self)
				if(self.TooltipName or self.TooltipText or self.TooltipType) then
					GameTooltip:SetOwner(self, "ANCHOR_NONE")
					GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
					if(self.TooltipName) then
						GameTooltip:AddLine("|cffffffff" .. self.TooltipName .. "|r") --插入代币标题名
					end
					if(self.TooltipType == "item" or self.TooltipType == "spell") then
						GameTooltip:SetHyperlink(self.TooltipType .. ":" .. self.TooltipHyperlink)
					end
					if(self.TooltipText) then
						GameTooltip:AddLine(self.TooltipText)
					end
					GameTooltip:Show()
				end
			end
		)

		service:SetScript(
			"OnLeave",
			function(self)
				GameTooltip:Hide()
			end
		)
		
		service:SetScript(
			"OnClick",
			function(self)
				if(self.Type == 9 ) then  --9类别为幻化装备，可预览物品穿自己身上的幻化装扮，如调整过，需要更改幻化类别数字
					SHOP_UI_CLIENT.ModelFrame_ShowPlayer(self.Rewards)
				elseif (self.Type == 4 or self.Type == 5) and self.EntryOrSkill > 0 then	--4和5类可显示生物模型（物品不行）。EntryOrSkill为生物ID不是模型ID。分类如有变化自己调整
					SHOP_UI_CLIENT.ModelFrame_ShowCreature(self.EntryOrSkill)
				else		--添加的新功能，物品不可预览时候，自动隐藏预览界面
					SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:Hide()
					SHOP_UI_CLIENT["MODEL_FRAME"]:Hide()				
				end
				-- Parchment page sound
				PlaySound(836)
			end
		)
		
		service:Hide()
		SHOP_UI_CLIENT["SERVICE_BUTTONS"][i] = service
	end
	
	SHOP_UI_CLIENT.ServiceBoxes_OnData()
end

local function GetServiceData()	----获取并返回当前分类的所有服务（这里合并和优化了原来2个好多次循环的函数）
	local currentCateSvrTab = {}
	local selectCategory = SHOP_UI_CLIENT["Vars"].currentCategory
	local serviceTable = SHOP_UI_CLIENT["Data"].services

	if(selectCategory == 1) then	--如果类别为1,自动弹出所有新品
		for k, v in pairs(serviceTable) do
			if(v[KEYS_CLIENT.service.new] == 1) then
				v.ID = k
				table.insert(currentCateSvrTab, v)
			end
		end
	elseif(selectCategory == 2) then	--如果类别为2,自动弹出所有打折商品
		for k, v in pairs(serviceTable) do
			if(v[KEYS_CLIENT.service.discount] >= 1) then
				v.ID = k
				table.insert(currentCateSvrTab, v)
			end
		end
	else
		for k, v in pairs(serviceTable) do		--如果是其他类别,则添加到对应类别
			if(selectCategory == v[KEYS_CLIENT.service.cateIndex]) then
				v.ID = k
				table.insert(currentCateSvrTab, v)
			end
		end
	end

	table.sort(currentCateSvrTab,function(a, b)
		return a.ID < b.ID
	end)

	return currentCateSvrTab
end

function SHOP_UI_CLIENT.ServiceBoxes_Update()	--商品购买服务界面更新
	local services = GetServiceData()	--获取当前分类服务
	local currentPage = SHOP_UI_CLIENT["Vars"].currentPage		--获取当前服务翻到的页面
	local startIndex = currentPage * 8 -7	--当前页第一个物品索引为页面乘以8减去7
	local endIndex = startIndex + 7			--当前页第一个物品索引为页面乘以8,或者第一个索引加7
	local maxPages = math.ceil(#services / 8)	--获取最大页数
	if(maxPages < 1) then
		maxPages = 1
	end
	SHOP_UI_CLIENT["Vars"].maxPages = maxPages

	local index = 1		-- 用来计算和索引当前页面实际呈现了多少个物品
	for i, serviceData in pairs(services) do
		if i >= startIndex and i <= endIndex then
			local service = SHOP_UI_CLIENT["SERVICE_BUTTONS"][index]
			service.ServiceId = serviceData.ID	--开始获取服务的业务数据
			service.Type = serviceData[KEYS_CLIENT.service.serviceType]
			service.Name = serviceData[KEYS_CLIENT.service.name]
			service.Count = serviceData[KEYS_CLIENT.service.rewardCount_1] --由于框架限制，只能显示第一个物品的数量
			service.TooltipName = serviceData[KEYS_CLIENT.service.tooltipName]
			service.TooltipType = serviceData[KEYS_CLIENT.service.tooltipType]
			service.TooltipText = serviceData[KEYS_CLIENT.service.tooltipText]
			service.IconTexture = serviceData[KEYS_CLIENT.service.icon]
			service.Price = serviceData[KEYS_CLIENT.service.price]
			service.Currency = serviceData[KEYS_CLIENT.service.currency]
			service.TooltipHyperlink = serviceData[KEYS_CLIENT.service.hyperlink]
			service.EntryOrSkill = serviceData[KEYS_CLIENT.service.EntryOrSkill]
			service.Discount = serviceData[KEYS_CLIENT.service.discount]
			service.Flags = serviceData[KEYS_CLIENT.service.flags]
			service.New = serviceData[KEYS_CLIENT.service.new]
			service.CountFont:SetFormattedText("|cffffffff%s|r", "x"..service.Count)--数量

			service.Rewards = {}	--添加获取物品表
			for j = 0, 7 do
				table.insert(service.Rewards, serviceData[KEYS_CLIENT.service.reward_1+j])
			end

			local currencyData = SHOP_UI_CLIENT["Data"].currencies
			local currencyIcon = currencyData[service.Currency][KEYS_CLIENT.currency.icon]
			service.Icon:SetTexture("Interface/Icons/" .. service.IconTexture)	-- 更新表格数据
			service.NameFont:SetFormattedText("|cffffffff%s|r", service.Name)
			service.DicountFont:SetFormattedText("|cffdbe005%i|r", service.Price)
			--service.currencyIcon:SetTexture("Interface/Store_UI/Currencies/" .. currencyIcon)	 --不用商城通过mpq工具加入的Store_UI自带图标
			service.currencyIcon:SetTexture("Interface/Icons/" .. currencyIcon)		--改用系统自带图标

			if service.Discount >= 1 then	-- 如果打折, 则显示折扣相关信息,否则隐藏折扣信息
				local discountPct = math.floor(service.Discount / service.Price * 100 + 0.5)  --简化算法，用加0.5实现四舍五入
				service.BannerText:SetFormattedText("|cffff0088降: %i%%|r", discountPct)
				service.PriceFont:SetFormattedText("|cff1eff00%i|r", (service.Price - service.Discount))
				service.DicountFont:Show()
				service.DiscountSlash:Show()
				service.Banner:Show() --折扣背景
				service.BannerText:Show() --折扣率文字
			else
				service.PriceFont:SetFormattedText("|cffdbe005%i|r", service.Price)
				service.DicountFont:Hide()
				service.DiscountSlash:Hide()
				service.Banner:Hide()
				service.BannerText:Hide()
			end
			
			if service.New == 1 then	--如果是新品,显示新品标签,否则去掉
				service.newTag:Show()
			else
				service.newTag:Hide()
			end

			service:Show()		--呈现界面
			index = index + 1	--下一个显示索引当前页显示索引
		end
	end

	--隐藏不用显示的物品.原版有个小于8的判定,等于8时候实际需要显示的为7个,故错误多显示一个.改为 <= 8就正确了.考虑到index超过8时候for循环不会执行,所以这个判定可删除直接for循环.
	for k = index, 8 do		
		SHOP_UI_CLIENT["SERVICE_BUTTONS"][k]:Hide()
	end
	
end

function SHOP_UI_CLIENT.ServiceBoxes_OnData()		--商品购买服务界面在数据更新时候调用
	SHOP_UI_CLIENT.ServiceBoxes_Update()
	SHOP_UI_CLIENT.PageButtons_Update()
end

function SHOP_UI_CLIENT.PageButtons_Create(parent)		--建立翻页界面的主界面
	local backButton = CreateFrame("Button", nil, parent)
	backButton:SetSize(25, 25)
	backButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -100, -28)
	
	-- Set back button textures
	local backTopX, backTopY, backBotX, backBotY = 837, 866, 868, 897
	backButton:SetDisabledTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	backButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	backButton:SetPushedTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	backButton:GetDisabledTexture():SetTexCoord(CoordsToTexCoords(1024, backTopX, backTopY, backBotX, backBotY))
	backButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, backTopX+31, backTopY, backBotX+31, backBotY))
	backButton:GetPushedTexture():SetTexCoord(CoordsToTexCoords(1024, backTopX+62, backTopY, backBotX+62, backBotY))
	
	backButton:SetScript(
		"OnClick",
		function()
			SHOP_UI_CLIENT.PageButtons_OnClick(-1)
		end
	)
	
	local pageText = parent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	pageText:SetTextHeight(18)
	pageText:SetShadowOffset(1, -1)
	pageText:SetPoint("LEFT", backButton, "RIGHT", 20, 0)
	
	local forwardButton = CreateFrame("Button", nil, parent)
	forwardButton:SetSize(25, 25)
	forwardButton:SetPoint("LEFT", backButton, "RIGHT", 65, 0)
	
	-- Set back button textures
	local forwTopX, forwTopY, forwBotX, forwBotY = 930, 866, 961, 897
	forwardButton:SetDisabledTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	forwardButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	forwardButton:SetPushedTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	forwardButton:GetDisabledTexture():SetTexCoord(CoordsToTexCoords(1024, forwTopX, forwTopY, forwBotX, forwBotY))
	forwardButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, forwTopX+31, forwTopY, forwBotX+31, forwBotY))
	forwardButton:GetPushedTexture():SetTexCoord(CoordsToTexCoords(1024, forwTopX+62, forwTopY, forwBotX+62, forwBotY))
	
	forwardButton:SetScript(
		"OnClick",
		function()
			SHOP_UI_CLIENT.PageButtons_OnClick(1)
		end
	)
	
	SHOP_UI_CLIENT["PAGING_ELEMENTS"] = {backButton, forwardButton, pageText}
	SHOP_UI_CLIENT.PageButtons_Update()
end

function SHOP_UI_CLIENT.PageButtons_OnClick(val)	--翻页界面点击
	local currentPage = SHOP_UI_CLIENT["Vars"].currentPage
	local maxPages = SHOP_UI_CLIENT["Vars"].maxPages

	if(currentPage+val < 1 or currentPage+val > maxPages) then
		return
	end
	
	PlaySound("igSpellBookOpen", "Master")
	SHOP_UI_CLIENT["Vars"].currentPage = currentPage + val
	SHOP_UI_CLIENT.ServiceBoxes_Update()
	SHOP_UI_CLIENT.PageButtons_Update()
end

function SHOP_UI_CLIENT.PageButtons_Update()		--翻页界面更新,当前分类物品大于8个的时候显示
	local currentPage = SHOP_UI_CLIENT["Vars"].currentPage
	local maxPages = SHOP_UI_CLIENT["Vars"].maxPages
	
	if(maxPages == 1) then		-- 最大只有一页的话,隐藏翻页界面
		SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Hide()
		SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Hide()
		SHOP_UI_CLIENT["PAGING_ELEMENTS"][3]:Hide()
		return
	end
	
	SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Show()
	SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Show()
	SHOP_UI_CLIENT["PAGING_ELEMENTS"][3]:Show()

	if(currentPage == 1) then	--第一页的话,向前翻页不可用
		SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Disable()
	else
		SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Enable()
	end

	if(currentPage == maxPages) then	--最后一页的话,向后翻页不可用
		SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Disable()
	else
		SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Enable()
	end
	
	SHOP_UI_CLIENT["PAGING_ELEMENTS"][3]:SetFormattedText("|cffffffff%i / %i|r", currentPage, maxPages)	-- 更新当前页码
end

function SHOP_UI_CLIENT.CurrencyBadges_Create(parent)	--建立金币和代币的主界面
	SHOP_UI_CLIENT["CURRENCY_BUTTONS"] = {}
	
	local currencyBackdrop = CreateFrame("Frame", nil, parent)
	currencyBackdrop:SetSize(220, 32)	--设置代币框总体大小，宽度和上面的分类一致
	currencyBackdrop:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 32)		--底下左侧为锚点，水平加上边框8像素，垂直加上底部32像素为起始锚点
	
	for i = 1, 4 do
		-- Button frame
		local currencyButton = CreateFrame("Button", nil, currencyBackdrop)
		currencyButton:SetSize(55, 32)	--代币框提示区域大小,水平乘以4不超过220,垂直2个字高度32像素,在这个区域鼠标移过去会有代币类型提示
		
		-- Amount text 货币数量显示位置
		currencyButton.Amount = currencyButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		currencyButton.Amount:SetTextHeight(16)
		currencyButton.Amount:SetPoint("CENTER", currencyButton, "CENTER", 0, 0)	--锚点为代币组框架中间点,货币文字靠锚点居中
		
		-- amount icon 货币图标
		currencyButton.Icon = currencyButton:CreateTexture(nil, "OVERLAY")
		currencyButton.Icon:SetSize(16, 16)
		currencyButton.Icon:SetPoint("CENTER", currencyButton, "RIGHT", 0, 0)	--原来锚点为货币,导致之间的空隙不好调整,现统一改为代币主框架中间点,图标靠锚点的右边侧
		
		currencyButton:SetScript(
			"OnEnter",
			function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
				GameTooltip:AddLine("|cffffffff" .. self.currencyName .. "|r")
				if(self.currencyTooltip) then
					GameTooltip:AddLine(self.currencyTooltip)
				end
				GameTooltip:Show()
			end
		)

		currencyButton:SetScript(
			"OnLeave",
			function(self)
				GameTooltip:Hide()
			end
		)
		
		currencyButton:Hide()	-- 默认隐藏,对应代币有会在其他地方开启显示
		SHOP_UI_CLIENT["CURRENCY_BUTTONS"][i] = currencyButton		--推送按钮表给后续使用
	end
end

function SHOP_UI_CLIENT.CurrencyBadges_OnData()	--金币和代币数据刷新时候呈现的界面
	local shownCount = 0
	for k, v in pairs(SHOP_UI_CLIENT["Data"].currencies) do
		shownCount = shownCount + 1		-- 显示代币类加1
		if shownCount > 4 then
			break;
		end
		local button = SHOP_UI_CLIENT["CURRENCY_BUTTONS"][shownCount]
		button.currencyId = k
		button.currencyType = v[KEYS_CLIENT.currency.currencyType]
		button.currencyName = v[KEYS_CLIENT.currency.name]
		button.currencyIcon = v[KEYS_CLIENT.currency.icon]
		button.currencyTooltip = v[KEYS_CLIENT.currency.tooltip]
		button.shown = true
		button:Show()	--有对应代币就显示
	end
	
	for i = 1, shownCount do	--动态调整代币的显示式样
		local button = SHOP_UI_CLIENT["CURRENCY_BUTTONS"][i]
		local padding = 30 * (shownCount - 1)	--加大这个可以让排列更密集. 必须保证 shownCount 为4时候,下面括号内的和为220
		local spacing = (130 + padding) / shownCount	--各类货币的显示间距,括号的和可以视为总体动态长度。需要调整 shownCount 为 4 时候，不超过框架宽度220(第一个数字145)
		local total_width = (shownCount - 1) * spacing	--计算总体宽度
		local offset_x = -total_width / 2	--总体宽度除以2作为水平方向框架整体偏移量
		local x = offset_x + (i - 1) * spacing 	--确定每种代币显示的位置
		button:SetPoint("CENTER", button:GetParent(), "CENTER", x, 0)	--设置对应代币水平方向锚点
	end
	
	SHOP_UI_CLIENT.CurrencyBadges_Update()
end

function SHOP_UI_CLIENT.CurrencyBadges_Update()		--左下角金币和代币更新
	for _, button in pairs(SHOP_UI_CLIENT["CURRENCY_BUTTONS"]) do
		if(button.shown) then
			button.currencyValue = SHOP_UI_CLIENT["Vars"]["playerCurrencies"][button.currencyId]
			button.Amount:SetText(button.currencyValue)
--			button.Icon:SetTexture("Interface/Store_UI/Currencies/"..button.currencyIcon)  	--弃用商城自带图标
			button.Icon:SetTexture("Interface/Icons/" ..button.currencyIcon)				--采用系统自带图标
		end
	end
end

function SHOP_UI_CLIENT.ModelFrame_Create(parent)   --建立预览窗口主界面
	local modelFrame = CreateFrame("Frame", nil, parent)
	modelFrame:SetSize(300, 658)
	modelFrame:SetPoint("LEFT", parent, "RIGHT", 0, 0)
	modelFrame:Hide()
	
	--标题--
	modelFrame.Title = modelFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	modelFrame.Title:SetTextHeight(20)
	modelFrame.Title:SetShadowOffset(1, -1)
	modelFrame.Title:SetPoint("TOP", modelFrame, "TOP", 0, -12)
	modelFrame.Title:SetText("|cffedd100预      览|r")

	--背景图片
	modelFrame.Background = modelFrame:CreateTexture(nil, "BACKGROUND")
	modelFrame.Background:SetSize(modelFrame:GetSize())
	modelFrame.Background:SetPoint("CENTER", modelFrame, "CENTER")
	modelFrame.Background:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
	modelFrame.Background:SetTexCoord(CoordsToTexCoords(1024, 430, 658, 701, 1023))
	
	modelFrame:SetScript(
		"OnHide",
		function()
			PlaySound("INTERFACESOUND_CHARWINDOWCLOSE", "Master")
		end
	)

	modelFrame:SetScript(
		"OnShow",
		function()
			PlaySound("INTERFACESOUND_CHARWINDOWOPEN", "Master")
		end
	)
	
	--关闭按钮操作
	modelFrame.CloseButton = CreateFrame("Button", nil, modelFrame, "UIPanelCloseButton")
	modelFrame.CloseButton:SetSize(28, 28)
	modelFrame.CloseButton:SetPoint("TOPRIGHT", modelFrame, "TOPRIGHT", 4, 3)
	modelFrame.CloseButton:EnableMouse(true)
	modelFrame.CloseButton:SetScript(
		"OnClick",
		function()
			PlaySound("INTERFACESOUND_CHARWINDOWCLOSE", "Master")
			modelFrame:Hide()
		end
	)
	
	-- Player Model frame 显示区域
	modelFrame.playerModel = CreateFrame("DressUpModel", nil, modelFrame)  --装备分类
	modelFrame.playerModel:SetPoint("CENTER", modelFrame, "CENTER", 0, -25)
	modelFrame.playerModel:SetSize(255, 550)

	-- Enable model frame mouse dragging
	local turnSpeed = 34
	local dragSpeed = 100
	local zoomSpeed = 0.5
	modelFrame.playerModel:SetPosition(0, 0, 0)
	modelFrame.playerModel:EnableMouse(true)
	modelFrame.playerModel:EnableMouseWheel(true)
	modelFrame.playerModel:SetScript(
		"OnMouseDown",
		function(self, button)
			local startPos = {
				GetCursorPosition()
			}
			if button == "LeftButton" then
				self:SetScript(
					"OnUpdate",
					function(self)
						local curX = ({
							GetCursorPosition()
						})[1]
						self:SetFacing(
							((curX - startPos[1]) / turnSpeed) + self:GetFacing()
						)
						startPos[1] = curX
					end
				)
			end
		end
	)
	
	modelFrame.playerModel:SetScript(
		"OnMouseUp",
		function(self, button)
			self:SetScript("OnUpdate", nil)
		end
	)
	
	modelFrame.playerModel:SetScript(
		"OnMouseWheel",
		function(self, zoom)
			local pos = {
				self:GetPosition()
			}
			if zoom == 1 then
				pos[1] = pos[1] + zoomSpeed
			else
				pos[1] = pos[1] - zoomSpeed
			end
			
			if(pos[1] > 1) then
				pos[1] = 1
			elseif(pos[1] < -0.5) then
				pos[1] = -0.5
			end
			
			self:SetPosition(pos[1], pos[2], pos[3])
		end
	)
	
	-- Creature Model frame
	modelFrame.creatureModel = CreateFrame("PlayerModel", nil, modelFrame) --宠物坐骑模型类
	modelFrame.creatureModel:SetPoint("CENTER", modelFrame, "CENTER", 0, -25)
	modelFrame.creatureModel:SetSize(255, 550)

	-- Enable model frame mouse dragging
	local turnSpeed = 34
	local dragSpeed = 100
	local zoomSpeed = 0.5
	modelFrame.creatureModel:SetPosition(0, 0, 0)
	modelFrame.creatureModel:EnableMouse(true)
	modelFrame.creatureModel:EnableMouseWheel(true)
	modelFrame.creatureModel:SetScript(
		"OnMouseDown",
		function(self, button)
			local startPos = {
				GetCursorPosition()
			}
			if button == "LeftButton" then
				self:SetScript(
					"OnUpdate",
					function(self)
						local curX = ({
							GetCursorPosition()
						})[1]
						self:SetFacing(
							((curX - startPos[1]) / turnSpeed) + self:GetFacing()
						)
						startPos[1] = curX
					end
				)
			end
		end
	)
	
	modelFrame.creatureModel:SetScript(
		"OnMouseUp",
		function(self, button)
			self:SetScript("OnUpdate", nil)
		end
	)
	
	modelFrame.creatureModel:SetScript(
		"OnMouseWheel",
		function(self, zoom)
			local pos = {
				self:GetPosition()
			}
			if zoom == 1 then
				pos[1] = pos[1] + zoomSpeed
			else
				pos[1] = pos[1] - zoomSpeed
			end
			
			if(pos[1] > 1) then
				pos[1] = 1
			elseif(pos[1] < -0.5) then
				pos[1] = -0.5
			end
			
			self:SetPosition(pos[1], pos[2], pos[3])
		end
	)
	
	-- Rotate left button
	modelFrame.leftButton = CreateFrame("Button", nil, modelFrame)
	modelFrame.leftButton:SetSize(35, 35)
	modelFrame.leftButton:SetFrameLevel(modelFrame:GetFrameLevel()+2)
	modelFrame.leftButton:SetPoint("CENTER", modelFrame, "BOTTOM", -30, 40)
	modelFrame.leftButton:SetNormalTexture("Interface/buttons/ui-rotationleft-button-up.blp")
	modelFrame.leftButton:SetHighlightTexture("Interface/buttons/ui-common-mousehilight.blp")
	modelFrame.leftButton:SetPushedTexture("Interface/buttons/ui-rotationleft-button-down.blp")

	modelFrame.leftButton:SetScript(
		"OnMouseDown",
		function(self, button)
			PlaySound("igInventoryRotateCharacter")
			self:SetScript(
				"OnUpdate",
				function(self, elapsed)
					if(modelFrame.playerModel:IsShown()) then
						modelFrame.playerModel:SetFacing(modelFrame.playerModel:GetFacing() + 0.03)
					end
					
					if(modelFrame.creatureModel:IsShown()) then
						modelFrame.creatureModel:SetFacing(modelFrame.creatureModel:GetFacing() + 0.03)
					end
				end
			)
		end
	)

	modelFrame.leftButton:SetScript(
		"OnMouseUp",
		function(self, button)
			self:SetScript("OnUpdate", nil)
		end
	)
	
	-- Rotate right button
	modelFrame.rightButton = CreateFrame("Button", nil, modelFrame)
	modelFrame.rightButton:SetSize(35, 35)
	modelFrame.rightButton:SetFrameLevel(modelFrame:GetFrameLevel()+2)
	modelFrame.rightButton:SetPoint("CENTER", modelFrame, "BOTTOM", 30, 40)
	modelFrame.rightButton:SetNormalTexture("Interface/buttons/ui-rotationright-button-up.blp")
	modelFrame.rightButton:SetHighlightTexture("Interface/buttons/ui-common-mousehilight.blp")
	modelFrame.rightButton:SetPushedTexture("Interface/buttons/ui-rotationright-button-down.blp")

	modelFrame.rightButton:SetScript(
		"OnMouseDown",
		function(self, button)
			PlaySound("igInventoryRotateCharacter")
			self:SetScript(
				"OnUpdate",
				function(self, elapsed)
					if(modelFrame.playerModel:IsShown()) then
						modelFrame.playerModel:SetFacing(modelFrame.playerModel:GetFacing() - 0.03)
					end
					
					if(modelFrame.creatureModel:IsShown()) then
						modelFrame.creatureModel:SetFacing(modelFrame.creatureModel:GetFacing() - 0.03)
					end
				end
			)
		end
	)

	modelFrame.rightButton:SetScript(
		"OnMouseUp",
		function(self, button)
			self:SetScript("OnUpdate", nil)
		end
	)
	
	SHOP_UI_CLIENT["MODEL_FRAME"] = modelFrame
end

function SHOP_UI_CLIENT.ModelFrame_ShowPlayer(EntryOrSkill)	--装备幻化预览调用(到玩家身上)
	-- hacky ass model frame handling
	-- hide model frames
	if(SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:IsShown()) then
		SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:Hide()
	end
--[[	直接覆盖,不需要隐藏。改为在显示框架内,如没有预览则隐藏
	SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:Hide()
	SHOP_UI_CLIENT["MODEL_FRAME"]:Hide()
]]--	
	-- set the correct unit and show frame
	SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:SetUnit("player")
	SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:Show()
	SHOP_UI_CLIENT["MODEL_FRAME"]:Show()
	
	if(EntryOrSkill) then
        for _, id in pairs(EntryOrSkill) do
            if(id > 0) then
                SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:TryOn(id)
            end
        end
	end

	PlaySound("INTERFACESOUND_GAMESCROLLBUTTON", "Master")
end

function SHOP_UI_CLIENT.ModelFrame_ShowCreature(EntryOrSkill)		--装备幻化预览调用(显示生物模型)
	-- hacky ass model frame handling
	-- hide model frames
	if(SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:IsShown()) then
		SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:Hide()
	end
--[[	--直接覆盖,不需要隐藏。改为在显示框架内,如没有预览则隐藏
	SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:Hide()
	SHOP_UI_CLIENT["MODEL_FRAME"]:Hide()
]]--	
	-- set the correct unit and show frame
	SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:SetCreature(EntryOrSkill)
	SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:Show()
	SHOP_UI_CLIENT["MODEL_FRAME"]:Show()

	PlaySound("INTERFACESOUND_GAMESCROLLBUTTON", "Master")
end

function MainFrame_Toggle()		--主窗口开关切换
	if SHOP_UI_CLIENT["FRAME"]:IsShown() and SHOP_UI_CLIENT["FRAME"]:IsVisible() then
		SHOP_UI_CLIENT["FRAME"]:Hide()
	else
		SHOP_UI_CLIENT["FRAME"]:Show()
	end
end

local function ModifyGameMenuFrame()  --商店按钮
	-- Increase the escape menu frame size 商店按钮大小
	local frame = _G["GameMenuFrame"]
	frame:SetSize(195, 270)
	
	-- move the buttons down 商店按钮位置
	local videoButton = _G["GameMenuButtonOptions"]
	videoButton:SetPoint("CENTER", frame, "TOP", 0, -70)
	
	-- add store button to the game menu 在游戏菜单中添加商店按钮
	local storeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate");
	storeButton:SetPoint("CENTER", frame, 0, 165)
	storeButton:SetSize(144, 24)
	storeButton.Text = storeButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	storeButton.Text:SetTextHeight(16)
	storeButton.Text:SetShadowOffset(1, -1)
	storeButton.Text:SetPoint("CENTER", storeButton, "CENTER", 0, 0)
	storeButton.Text:SetText("|cffdbe005魔兽商城");--名字
	
	-- on click open the shop frame and hide the escape menu 点击打开商店框架并隐藏逃生菜单
	storeButton:SetScript("OnClick", function()
		HideUIPanel(frame)
		MainFrame_Toggle()
	end)
end

-- Start frame creation on load 加载时开始创建框架
SHOP_UI_CLIENT.MainFrame_Create()

-- Modify the game menu frame to add the store button 修改游戏菜单框以添加商店按钮
ModifyGameMenuFrame()