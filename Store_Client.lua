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

local KEYS_CLIENT = {
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

local scaleMulti = 1

local function CoordsToTexCoords(size, xTop, yTop, xBottom, yBottom)
    local magic = (1/size)/2
    local Top = (yTop/size) + magic
    local Left = (xTop/size) + magic
    local Bottom = (yBottom/size) - magic
    local Right = (xBottom/size) - magic

    return Left, Right, Top, Bottom
end

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

function SHOP_UI_CLIENT.MainFrame_Create()
    local shopFrame = CreateFrame("Frame", "SHOP_FRAME", UIParent)
    shopFrame:SetPoint("LEFT", 100, 0)
    shopFrame:Hide()
    shopFrame:SetToplevel(true)
    shopFrame:SetClampedToScreen(true)
    shopFrame:SetMovable(true)
    shopFrame:EnableMouse(true)
    shopFrame:RegisterForDrag("LeftButton")
    shopFrame:SetScript("OnDragStart", shopFrame.StartMoving)
    shopFrame:SetScript("OnHide", shopFrame.StopMovingOrSizing)
    shopFrame:SetScript("OnDragStop", shopFrame.StopMovingOrSizing)
    
    shopFrame:SetSize(1024*scaleMulti, 658*scaleMulti)
    
    shopFrame.Background = shopFrame:CreateTexture(nil, "BACKGROUND")
    shopFrame.Background:SetSize(shopFrame:GetSize())
    shopFrame.Background:SetPoint("CENTER", shopFrame, "CENTER")
    shopFrame.Background:SetTexture("StoreFrame_Main")
    shopFrame.Background:SetTexCoord(CoordsToTexCoords(1024, 0, 0, 1024, 658))
    
    shopFrame.Title = shopFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    shopFrame.Title:SetTextHeight(20)
    shopFrame.Title:SetShadowOffset(1, -1)
    shopFrame.Title:SetPoint("TOP", shopFrame, "TOP", 0, -3)
    shopFrame.Title:SetText("|cffedd100魔      兽      商      城|r")
    
    SHOP_UI_CLIENT.NavButtons_Create(shopFrame)
    SHOP_UI_CLIENT.PageButtons_Create(shopFrame)
    SHOP_UI_CLIENT.ServiceBoxes_Create(shopFrame)
    SHOP_UI_CLIENT.CurrencyBadges_Create(shopFrame)
    SHOP_UI_CLIENT.ModelFrame_Create(shopFrame)
    
    AIO.Handle("STORE_SERVER", "FrameData")
    AIO.Handle("STORE_SERVER", "UpdateCurrencies")

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
            SHOP_UI_CLIENT["MODEL_FRAME"]:Hide()
            PlaySound("AuctionWindowClose", "Master") 
        end
    )
    
    tinsert(UISpecialFrames, shopFrame:GetName())
    
    SHOP_UI_CLIENT["FRAME"] = shopFrame
end

function SHOP_UI_CLIENT.NavButtons_Create(parent)
    SHOP_UI_CLIENT["NAV_BUTTONS"] = {}
    local offset = 0
    for i = 1, 12 do
        local navButton = CreateFrame("Button", nil, parent)
        
        navButton.NavId = i
        
        local size = 220
        
        navButton:SetSize(size*scaleMulti, (size/4)*scaleMulti)
        navButton:SetPoint("LEFT", parent, "LEFT", 17, 232+offset)
        
        navButton:SetNormalTexture("StoreFrame_Main")
        navButton:SetHighlightTexture("StoreFrame_Main")
        navButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 768, 897, 1023, 960))
        navButton:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 768, 960, 1023, 1023))
        
        navButton.Name = navButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        navButton.Name:SetTextHeight(18)
        navButton.Name:SetShadowOffset(1, -1)
        navButton.Name:SetPoint("CENTER", navButton, "CENTER", 8, 0)
        
        navButton.Icon = navButton:CreateTexture(nil, "BACKGROUND")
        navButton.Icon:SetSize(33, 33)
        navButton.Icon:SetPoint("LEFT", navButton, "LEFT", 9, -1)

        offset = offset - 42
        
        navButton:SetScript("OnClick", SHOP_UI_CLIENT.NavButtons_OnClick)
        
        SHOP_UI_CLIENT["NAV_BUTTONS"][i] = navButton
        navButton:Hide()
    end

    SHOP_UI_CLIENT.NavButtons_OnData()
end

function SHOP_UI_CLIENT.NavButtons_OnClick(self)
    if(self.RequiredRank > SHOP_UI_CLIENT["Vars"].accountRank) then
        UIErrorsFrame:AddMessage(CONFIG.strings.categoryAccessDenied, 1.0, 0.0, 0.0, 2);
        PlaySound("igPlayerInviteDecline", "Master")
        return;
    end
    
    PlaySound("uChatScrollButton", "Master")
    SHOP_UI_CLIENT["Vars"].currentCategory = self.CategoryId
    SHOP_UI_CLIENT["Vars"].currentNavId = self.NavId
    SHOP_UI_CLIENT["Vars"].currentPage = 1
    
    SHOP_UI_CLIENT.NavButtons_UpdateSelect()
    SHOP_UI_CLIENT.ServiceBoxes_Update()
    SHOP_UI_CLIENT.PageButtons_Update()
end

function SHOP_UI_CLIENT.NavButtons_UpdateSelect()
    for i = 1, CONFIG.maxCategories do
        SHOP_UI_CLIENT["NAV_BUTTONS"][i]:UnlockHighlight()
    end
    
    SHOP_UI_CLIENT["NAV_BUTTONS"][SHOP_UI_CLIENT["Vars"].currentNavId]:LockHighlight()
end

function SHOP_UI_CLIENT.NavButtons_OnData()
    index = 1
    for _, v in pairs(SHOP_UI_CLIENT["Data"].nav) do
        if index > CONFIG.maxCategories then
            break
        end

        if(v[KEYS_CLIENT.category.enabled] == 1) then
            local button = SHOP_UI_CLIENT["NAV_BUTTONS"][index]
            button.CategoryId = v[KEYS_CLIENT.category.id]
            button.NameText = v[KEYS_CLIENT.category.name]
            button.IconTexture = v[KEYS_CLIENT.category.icon]
            button.RequiredRank = v[KEYS_CLIENT.category.requiredRank]
            button.Icon:SetTexture("Interface/Icons/" .. button.IconTexture .. ".blp")
            button.Name:SetFormattedText("|cffdbe005%s|r", button.NameText)
            button:Show()
            index = index + 1
        end
    end
    
    local button = SHOP_UI_CLIENT["NAV_BUTTONS"][1]
    SHOP_UI_CLIENT["Vars"].currentCategory = button.CategoryId
    SHOP_UI_CLIENT["Vars"].currentNavId = button.NavId
    SHOP_UI_CLIENT.NavButtons_UpdateSelect()
end

function SHOP_UI_CLIENT.OnPurchaseConfirm(data)
    AIO.Handle("STORE_SERVER", "Purchase", data)
end

StaticPopupDialogs["CONFIRM_STORE_PURCHASE"] = {
    text = "确定兑换 %s ？",
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

function SHOP_UI_CLIENT.ServiceBoxes_Create(parent)
    SHOP_UI_CLIENT["SERVICE_BUTTONS"] = {}
    for i = 1, 8 do
        local service = CreateFrame("Button", nil, parent)
        service.ServiceId = 0
        service.Name = ""
        service.Count = ""
        service.TooltipName = nil
        service.TooltipText = nil
        service.TooltipType = ""
        service.TooltipHyperlink = 0
        
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
        service:SetNormalTexture("StoreFrame_Main")
        service:SetHighlightTexture("StoreFrame_Main")
        service:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 0, 658, 215, 1023))
        service:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 215, 658, 430, 1023))
        
        service.Icon = service:CreateTexture(nil, "BACKGROUND")
        service.Icon:SetSize(40, 40)
        service.Icon:SetPoint("CENTER", service, "CENTER", 0, 70)
        
        service.CountFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        service.CountFont:SetTextHeight(16)
        service.CountFont:SetShadowOffset(1, -1)
        service.CountFont:SetPoint("CENTER", service.Icon, "CENTER", 27, -15)

        service.NameFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        service.NameFont:SetTextHeight(14)
        service.NameFont:SetJustifyH("CENTER")
        service.NameFont:SetShadowOffset(1, -1)
        service.NameFont:SetPoint("CENTER", service, "CENTER", 0, 16)
        
        service.PriceFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        service.PriceFont:SetTextHeight(18)
        service.PriceFont:SetShadowOffset(1, -1)
        service.PriceFont:SetPoint("CENTER", service, "CENTER", 0, -35)
        
        service.currencyIcon = service:CreateTexture(nil, "OVERLAY")
        service.currencyIcon:SetSize(18, 18)
        service.currencyIcon:SetPoint("LEFT", service.PriceFont, "RIGHT", 0, 0)
        
        service.DicountFont = service:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        service.DicountFont:SetTextHeight(16)
        service.DicountFont:SetShadowOffset(1, -1)
        service.DicountFont:SetPoint("CENTER", service.PriceFont, "CENTER", 5, 20)
        
        service.DiscountSlash = service:CreateTexture(nil, "OVERLAY")
        service.DiscountSlash:SetSize(36, 18)
        service.DiscountSlash:SetPoint("CENTER", service.DicountFont)
        service.DiscountSlash:SetTexture("StoreFrame_Main")
        service.DiscountSlash:SetTexCoord(CoordsToTexCoords(1024, 992, 804, 1023, 835))
        
        service.Banner = CreateFrame("Frame", nil, service)
        service.Banner:SetSize(80, 25)
        service.Banner:SetPoint("TOPRIGHT", service, "TOPRIGHT", 0, 4)
        
        service.Banner.Background = service.Banner:CreateTexture(nil, "BACKGROUND")
        service.Banner.Background:SetSize(80, 25)
        service.Banner.Background:SetPoint("CENTER", service.Banner)
        service.Banner.Background:SetTexture("StoreFrame_Main")
        service.Banner.Background:SetTexCoord(CoordsToTexCoords(1024, 862, 765, 961, 815))
        
        service.BannerText = service.Banner:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        service.BannerText:SetTextHeight(18)
        service.BannerText:SetShadowOffset(1, -1)
        service.BannerText:SetPoint("CENTER", service.Banner.Background,"CENTER", 5, -5)
        
        service.newTag = service:CreateTexture(nil, "OVERLAY")
        service.newTag:SetSize(65, 30)
        service.newTag:SetPoint("CENTER", service, "LEFT", 35, 114)
        service.newTag:SetTexture("StoreFrame_Main")
        service.newTag:SetTexCoord(CoordsToTexCoords(1024, 862, 816, 961, 866))
        
        service.buyButton = CreateFrame("Button", nil, service)
        service.buyButton:SetSize(100, 28)
        service.buyButton:SetPoint("CENTER", service, "CENTER", 0, -85)
        service.buyButton:SetNormalTexture("StoreFrame_Main")
        service.buyButton:SetHighlightTexture("StoreFrame_Main")
        service.buyButton:SetPushedTexture("StoreFrame_Main")
        service.buyButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 849, 837, 873))
        service.buyButton:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 849, 837, 873))
        service.buyButton:GetPushedTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 873, 837, 897))
        
        service.buyButton.ButtonText = service.buyButton:CreateFontString(nil, "ARTWORK", "GameTooltipText")
        service.buyButton.ButtonText:SetTextHeight(16)
        service.buyButton.ButtonText:SetPoint("CENTER", service.buyButton, 0, 1)
        service.buyButton.ButtonText:SetText("兑  换")
        
        service.buyButton:SetScript(
            "OnClick",
            function(self)
                local dialog = StaticPopup_Show("CONFIRM_STORE_PURCHASE", self:GetParent().Name)
                if (dialog) then
                    dialog.data = self:GetParent().ServiceId
                end
                
                PlaySound("STORE_CONFIRM", "Master")
            end
        )
        
        service:SetScript(
            "OnEnter",
            function(self)
                if(self.TooltipName or self.TooltipText or self.TooltipType) then
                    GameTooltip:SetOwner(self, "ANCHOR_NONE")
                    GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
                    if(self.TooltipName) then
                        GameTooltip:AddLine("|cffffffff" .. self.TooltipName .. "|r")
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
                if(self.Type == 7) then
                    SHOP_UI_CLIENT.ModelFrame_ShowPlayer(self.Rewards)
                elseif (self.Type == 2 or self.Type == 3) and self.EntryOrSkill > 0 then
                    SHOP_UI_CLIENT.ModelFrame_ShowCreature(self.EntryOrSkill)
                else
                    SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:Hide()
                    SHOP_UI_CLIENT["MODEL_FRAME"]:Hide()                
                end
                PlaySound(836)
            end
        )
        
        service:Hide()
        SHOP_UI_CLIENT["SERVICE_BUTTONS"][i] = service
    end
    
    SHOP_UI_CLIENT.ServiceBoxes_OnData()
end

local function GetServiceData()
    local currentCateSvrTab = {}
    local selectCategory = SHOP_UI_CLIENT["Vars"].currentCategory
    local serviceTable = SHOP_UI_CLIENT["Data"].services

    if(selectCategory == 1) then
        for k, v in pairs(serviceTable) do
            if(v[KEYS_CLIENT.service.new] == 1) then
                v.ID = k
                table.insert(currentCateSvrTab, v)
            end
        end
    elseif(selectCategory == 2) then
        for k, v in pairs(serviceTable) do
            if(v[KEYS_CLIENT.service.discount] >= 1) then
                v.ID = k
                table.insert(currentCateSvrTab, v)
            end
        end
    else
        for k, v in pairs(serviceTable) do
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

function SHOP_UI_CLIENT.ServiceBoxes_Update()
    local services = GetServiceData()
    local currentPage = SHOP_UI_CLIENT["Vars"].currentPage
    local startIndex = currentPage * 8 -7
    local endIndex = startIndex + 7
    local maxPages = math.ceil(#services / 8)
    if(maxPages < 1) then
        maxPages = 1
    end
    SHOP_UI_CLIENT["Vars"].maxPages = maxPages

    local index = 1
    for i, serviceData in pairs(services) do
        if i >= startIndex and i <= endIndex then
            local service = SHOP_UI_CLIENT["SERVICE_BUTTONS"][index]
            service.ServiceId = serviceData.ID
            service.Type = serviceData[KEYS_CLIENT.service.serviceType]
            service.Name = serviceData[KEYS_CLIENT.service.name]
            service.Count = serviceData[KEYS_CLIENT.service.rewardCount_1]
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
            service.CountFont:SetFormattedText("|cffffffff%s|r", "x"..service.Count)

            service.Rewards = {}
            for j = 0, 7 do
                table.insert(service.Rewards, serviceData[KEYS_CLIENT.service.reward_1+j])
            end

            local currencyData = SHOP_UI_CLIENT["Data"].currencies
            local currencyIcon = currencyData[service.Currency][KEYS_CLIENT.currency.icon]
            service.Icon:SetTexture("Interface/Icons/" .. service.IconTexture)
            service.NameFont:SetFormattedText("|cffffffff%s|r", service.Name)
            service.DicountFont:SetFormattedText("|cffdbe005%i|r", service.Price)
            service.currencyIcon:SetTexture("Interface/Icons/" .. currencyIcon)

            if service.Discount >= 1 then
                local discountPct = math.floor(service.Discount / service.Price * 100 + 0.5)
                service.BannerText:SetFormattedText("|cffff0088降: %i%%|r", discountPct)
                service.PriceFont:SetFormattedText("|cff1eff00%i|r", (service.Price - service.Discount))
                service.DicountFont:Show()
                service.DiscountSlash:Show()
                service.Banner:Show()
                service.BannerText:Show()
            else
                service.PriceFont:SetFormattedText("|cffdbe005%i|r", service.Price)
                service.DicountFont:Hide()
                service.DiscountSlash:Hide()
                service.Banner:Hide()
                service.BannerText:Hide()
            end
            
            if service.New == 1 then
                service.newTag:Show()
            else
                service.newTag:Hide()
            end

            service:Show()
            index = index + 1
        end
    end

    for k = index, 8 do        
        SHOP_UI_CLIENT["SERVICE_BUTTONS"][k]:Hide()
    end
end

function SHOP_UI_CLIENT.ServiceBoxes_OnData()
    SHOP_UI_CLIENT.ServiceBoxes_Update()
    SHOP_UI_CLIENT.PageButtons_Update()
end

function SHOP_UI_CLIENT.PageButtons_Create(parent)
    local backButton = CreateFrame("Button", nil, parent)
    backButton:SetSize(25, 25)
    backButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -100, -28)
    
    local backTopX, backTopY, backBotX, backBotY = 837, 866, 868, 897
    backButton:SetDisabledTexture("StoreFrame_Main")
    backButton:SetNormalTexture("StoreFrame_Main")
    backButton:SetPushedTexture("StoreFrame_Main")
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
    
    local forwTopX, forwTopY, forwBotX, forwBotY = 930, 866, 961, 897
    forwardButton:SetDisabledTexture("StoreFrame_Main")
    forwardButton:SetNormalTexture("StoreFrame_Main")
    forwardButton:SetPushedTexture("StoreFrame_Main")
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

function SHOP_UI_CLIENT.PageButtons_OnClick(val)
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

function SHOP_UI_CLIENT.PageButtons_Update()
    local currentPage = SHOP_UI_CLIENT["Vars"].currentPage
    local maxPages = SHOP_UI_CLIENT["Vars"].maxPages
    
    if(maxPages == 1) then
        SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Hide()
        SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Hide()
        SHOP_UI_CLIENT["PAGING_ELEMENTS"][3]:Hide()
        return
    end
    
    SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Show()
    SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Show()
    SHOP_UI_CLIENT["PAGING_ELEMENTS"][3]:Show()

    if(currentPage == 1) then
        SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Disable()
    else
        SHOP_UI_CLIENT["PAGING_ELEMENTS"][1]:Enable()
    end

    if(currentPage == maxPages) then
        SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Disable()
    else
        SHOP_UI_CLIENT["PAGING_ELEMENTS"][2]:Enable()
    end
    
    SHOP_UI_CLIENT["PAGING_ELEMENTS"][3]:SetFormattedText("|cffffffff%i / %i|r", currentPage, maxPages)
end

function SHOP_UI_CLIENT.CurrencyBadges_Create(parent)
    SHOP_UI_CLIENT["CURRENCY_BUTTONS"] = {}
    
    local currencyBackdrop = CreateFrame("Frame", nil, parent)
    currencyBackdrop:SetSize(220, 32)
    currencyBackdrop:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 32)
    
    for i = 1, 4 do
        local currencyButton = CreateFrame("Button", nil, currencyBackdrop)
        currencyButton:SetSize(55, 32)
        
        currencyButton.Amount = currencyButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        currencyButton.Amount:SetTextHeight(16)
        currencyButton.Amount:SetPoint("CENTER", currencyButton, "CENTER", 0, 0)
        
        currencyButton.Icon = currencyButton:CreateTexture(nil, "OVERLAY")
        currencyButton.Icon:SetSize(16, 16)
        currencyButton.Icon:SetPoint("CENTER", currencyButton, "RIGHT", 0, 0)
        
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
        
        currencyButton:Hide()
        SHOP_UI_CLIENT["CURRENCY_BUTTONS"][i] = currencyButton
    end
end

function SHOP_UI_CLIENT.CurrencyBadges_OnData()
    local shownCount = 0
    for k, v in pairs(SHOP_UI_CLIENT["Data"].currencies) do
        shownCount = shownCount + 1
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
        button:Show()
    end
    
    for i = 1, shownCount do
        local button = SHOP_UI_CLIENT["CURRENCY_BUTTONS"][i]
        local padding = 30 * (shownCount - 1)
        local spacing = (130 + padding) / shownCount
        local total_width = (shownCount - 1) * spacing
        local offset_x = -total_width / 2
        local x = offset_x + (i - 1) * spacing
        button:SetPoint("CENTER", button:GetParent(), "CENTER", x, 0)
    end
    
    SHOP_UI_CLIENT.CurrencyBadges_Update()
end

function SHOP_UI_CLIENT.CurrencyBadges_Update()
    for _, button in pairs(SHOP_UI_CLIENT["CURRENCY_BUTTONS"]) do
        if(button.shown) then
            button.currencyValue = SHOP_UI_CLIENT["Vars"]["playerCurrencies"][button.currencyId]
            button.Amount:SetText(button.currencyValue)
            button.Icon:SetTexture("Interface/Icons/" ..button.currencyIcon)
        end
    end
end

function SHOP_UI_CLIENT.ModelFrame_Create(parent)
    local modelFrame = CreateFrame("Frame", nil, parent)
    modelFrame:SetSize(300, 658)
    modelFrame:SetPoint("LEFT", parent, "RIGHT", 0, 0)
    modelFrame:Hide()
    
    modelFrame.Title = modelFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    modelFrame.Title:SetTextHeight(20)
    modelFrame.Title:SetShadowOffset(1, -1)
    modelFrame.Title:SetPoint("TOP", modelFrame, "TOP", 0, -12)
    modelFrame.Title:SetText("|cffedd100预      览|r")

    modelFrame.Background = modelFrame:CreateTexture(nil, "BACKGROUND")
    modelFrame.Background:SetSize(modelFrame:GetSize())
    modelFrame.Background:SetPoint("CENTER", modelFrame, "CENTER")
    modelFrame.Background:SetTexture("StoreFrame_Main")
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
    
    modelFrame.playerModel = CreateFrame("DressUpModel", nil, modelFrame)
    modelFrame.playerModel:SetPoint("CENTER", modelFrame, "CENTER", 0, -25)
    modelFrame.playerModel:SetSize(255, 550)

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
    
    modelFrame.creatureModel = CreateFrame("PlayerModel", nil, modelFrame)
    modelFrame.creatureModel:SetPoint("CENTER", modelFrame, "CENTER", 0, -25)
    modelFrame.creatureModel:SetSize(255, 550)

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

function SHOP_UI_CLIENT.ModelFrame_ShowPlayer(EntryOrSkill)
    if(SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:IsShown()) then
        SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:Hide()
    end
    
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

function SHOP_UI_CLIENT.ModelFrame_ShowCreature(EntryOrSkill)
    if(SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:IsShown()) then
        SHOP_UI_CLIENT["MODEL_FRAME"].playerModel:Hide()
    end
    
    SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:SetCreature(EntryOrSkill)
    SHOP_UI_CLIENT["MODEL_FRAME"].creatureModel:Show()
    SHOP_UI_CLIENT["MODEL_FRAME"]:Show()

    PlaySound("INTERFACESOUND_GAMESCROLLBUTTON", "Master")
end

function MainFrame_Toggle()
    if SHOP_UI_CLIENT["FRAME"]:IsShown() and SHOP_UI_CLIENT["FRAME"]:IsVisible() then
        SHOP_UI_CLIENT["FRAME"]:Hide()
    else
        SHOP_UI_CLIENT["FRAME"]:Show()
    end
end

SHOP_UI_CLIENT.MainFrame_Create()

local icon = CreateFrame("Button", nil, WorldFrame)
icon:SetSize(32, 32)
icon:SetPoint("TOP", WorldFrame, "TOP", 0, -10)
icon:SetNormalTexture("Interface\\Addons\\DiabolicUI\\media\\textures\\DiabolicUI_Button_51x51_Pushed")
icon:SetFrameStrata("HIGH")
icon:SetClampedToScreen(true)
icon:SetScript(
    "OnClick",
    function(self, button, down)
        if SHOP_UI_CLIENT["FRAME"]:IsShown() and SHOP_UI_CLIENT["FRAME"]:IsVisible() then
            SHOP_UI_CLIENT["FRAME"]:Hide()
        else
            SHOP_UI_CLIENT["FRAME"]:Show()
        end
    end
)
icon:SetScript(
    "OnEnter",
    function(self)
        icon:SetAlpha(1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("点击打开魔兽商城！")
        GameTooltip:Show()
    end
)
icon:SetScript(
    "OnLeave",
    function(self)
        icon:SetAlpha(0.5)
        GameTooltip:Hide()
    end
)

icon:SetMovable(true)
icon:EnableMouse(true)
icon:RegisterForDrag("LeftButton")
icon:SetScript(
    "OnDragStart",
    function(self)
        self:StartMoving()
    end
)
icon:SetScript(
    "OnDragStop",
    function(self)
        self:StopMovingOrSizing()
    end
)

if not icon:IsVisible() then
    icon:ClearAllPoints()
    icon:SetPoint("TOP", WorldFrame, "TOP", 0, -100)
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("CHAT_MSG_ADDON")

SLASH_CUSTOMSHOP1 = "/store"
SlashCmdList["CUSTOMSHOP"] = function()
    if SHOP_UI_CLIENT["FRAME"]:IsShown() then
        SHOP_UI_CLIENT["FRAME"]:Hide()
    else
        SHOP_UI_CLIENT["FRAME"]:Show()
    end
end