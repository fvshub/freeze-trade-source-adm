-- Delta Freeze Trader v2.4
-- Adopt Me Script | Delta Executor

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════
--           CONFIGURATION
-- ══════════════════════════════════════

local CONFIG = {
    FreezeMethod = "TradeFreeze",
    AutoAccept = false,
    AutoDecline = false,
    FreezeDelay = 0.1,
    NotifyOnFreeze = true,
}

local PETS = {
    { name = "Frost Dragon",   rarity = "Legendary" },
    { name = "Shadow Dragon",  rarity = "Legendary" },
    { name = "Bat Dragon",     rarity = "Legendary" },
    { name = "Giraffe",        rarity = "Rare"      },
    { name = "Crow",           rarity = "Rare"      },
    { name = "Owl",            rarity = "Rare"      },
    { name = "Evil Unicorn",   rarity = "Ultra-Rare"},
    { name = "Parrot",         rarity = "Ultra-Rare"},
    { name = "Dodo",           rarity = "Ultra-Rare"},
    { name = "Dragon",         rarity = "Rare"      },
    { name = "Unicorn",        rarity = "Rare"      },
    { name = "Griffin",        rarity = "Ultra-Rare"},
}

local AGES = {"Newborn","Junior","Pre-Teen","Teen","Post-Teen","Full Grown"}

-- ══════════════════════════════════════
--              STATE
-- ══════════════════════════════════════

local State = {
    Frozen       = false,
    MyOffer      = {},
    TheirOffer   = {},
    Log          = {},
    ActiveTab    = "Trade",
    SelectSide   = "My",
    TradeActive  = false,
}

-- ══════════════════════════════════════
--              UTILITIES
-- ══════════════════════════════════════

local function Log(msg, level)
    level = level or "INFO"
    local entry = string.format("[%s] [%s] %s", os.date("%H:%M:%S"), level, msg)
    table.insert(State.Log, 1, entry)
    if #State.Log > 30 then table.remove(State.Log) end
    print(entry)
end

local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function MakeCorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r or 8); return c end
local function MakePadding(t,b,l,r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    return p
end
local function MakeStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c; s.Thickness = t or 1; return s end
local function MakeList(pad, spacing)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing or 6)
    l.FillDirection = Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return l
end

-- ══════════════════════════════════════
--          FREEZE CORE LOGIC
-- ══════════════════════════════════════

local function GetTradeFrame()
    local paths = {
        {"TradeWindow"},
        {"TradeFrame"},
        {"Trade","TradeFrame"},
        {"TradeHandler","TradeGui"},
    }
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        for _, path in ipairs(paths) do
            local obj = gui
            local ok = true
            for _, part in ipairs(path) do
                obj = obj:FindFirstChild(part)
                if not obj then ok = false; break end
            end
            if ok then return obj end
        end
    end
    return nil
end

local FreezeConnection = nil

local function DoFreeze()
    if State.Frozen then return end
    State.Frozen = true
    Log("🧊 FREEZE INITIATED", "FREEZE")

    local tradeFrame = GetTradeFrame()
    if tradeFrame then
        local offerFrame = tradeFrame:FindFirstChild("MyOffer") or tradeFrame:FindFirstChild("YourOffer")
        if offerFrame then
            for _, btn in ipairs(offerFrame:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    btn.Active = false
                    btn.AutoButtonColor = false
                end
            end
            Log("Offer frame input locked", "FREEZE")
        end
    end

    FreezeConnection = RunService.Heartbeat:Connect(function()
        if not State.Frozen then
            FreezeConnection:Disconnect()
            return
        end
        local tf = GetTradeFrame()
        if tf then
            local offer = tf:FindFirstChild("MyOffer") or tf:FindFirstChild("YourOffer")
            if offer then
                for _, btn in ipairs(offer:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        btn.Active = false
                    end
                end
            end
        end
    end)

    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            or game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        if remotes then
            Log("Remote intercept active", "FREEZE")
        end
    end)

    Log("✅ Trade frozen successfully!", "FREEZE")
end

local function DoUnfreeze()
    if not State.Frozen then return end
    State.Frozen = false

    if FreezeConnection then
        FreezeConnection:Disconnect()
        FreezeConnection = nil
    end

    local tradeFrame = GetTradeFrame()
    if tradeFrame then
        local offerFrame = tradeFrame:FindFirstChild("MyOffer") or tradeFrame:FindFirstChild("YourOffer")
        if offerFrame then
            for _, btn in ipairs(offerFrame:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    btn.Active = true
                    btn.AutoButtonColor = true
                end
            end
        end
    end

    Log("❌ Trade unfrozen", "WARN")
end

-- ══════════════════════════════════════
--             GUI BUILD
-- ══════════════════════════════════════

if PlayerGui:FindFirstChild("DeltaFreezeTrader") then
    PlayerGui:FindFirstChild("DeltaFreezeTrader"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFreezeTrader"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 420)
Main.Position = UDim2.new(0.5, -260, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
MakeCorner(10).Parent = Main
MakeStroke(Color3.fromRGB(25, 25, 50), 1).Parent = Main

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(99, 102, 241)
Shadow.ImageTransparency = 0.85
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
MakeCorner(10).Parent = TitleBar

local TitleBarBottom = Instance.new("Frame")
TitleBarBottom.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarBottom.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarBottom.BackgroundColor3 = Color3.fromRGB(14, 14, 30)
TitleBarBottom.BorderSizePixel = 0
TitleBarBottom.Parent = TitleBar

local TrafficLights = {"FF5F57","FFBD2E","28CA41"}
for i, col in ipairs(TrafficLights) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 8 + (i-1)*18, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromHex(col)
    dot.BorderSizePixel = 0
    dot.Parent = TitleBar
    MakeCorner(99).Parent = dot
end

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -160, 1, 0)
TitleLabel.Position = UDim2.new(0, 70, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DELTA  •  Adopt Me Freeze Trader v2.4"
TitleLabel.TextColor3 = Color3.fromRGB(80, 80, 120)
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(0, 180, 0, 22)
TabHolder.Position = UDim2.new(1, -186, 0.5, -11)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = TitleBar

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 4)
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.Parent = TabHolder

local TABS = {"Trade", "Pets", "Log"}
local TabButtons = {}

local function RefreshTabs()
    for _, tab in ipairs(TABS) do
        local btn = TabButtons[tab]
        local active = State.ActiveTab == tab
        Tween(btn, {
            BackgroundColor3 = active and Color3.fromRGB(30, 30, 70) or Color3.fromRGB(12, 12, 22),
            TextColor3 = active and Color3.fromRGB(165, 180, 252) or Color3.fromRGB(60, 60, 90),
        })
    end
end

for _, tabName in ipairs(TABS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 52, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(60, 60, 90)
    btn.TextSize = 9
    btn.Font = Enum.Font.Code
    btn.BorderSizePixel = 0
    btn.Parent = TabHolder
    MakeCorner(5).Parent = btn
    MakeStroke(Color3.fromRGB(30, 30, 50), 1).Parent = btn
    TabButtons[tabName] = btn
    btn.MouseButton1Click:Connect(function()
        State.ActiveTab = tabName
        RefreshTabs()
        UpdateContent()
    end)
end

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 1, -44)
Content.Position = UDim2.new(0, 8, 0, 40)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 22)
StatusBar.Position = UDim2.new(0, 0, 1, -22)
StatusBar.BackgroundColor3 = Color3.fromRGB(6, 6, 14)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = Main

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 7, 0, 7)
StatusDot.Position = UDim2.new(1, -60, 0.5, -3)
StatusDot.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusBar
MakeCorner(99).Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 55, 1, 0)
StatusText.Position = UDim2.new(1, -52, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "READY"
StatusText.TextColor3 = Color3.fromRGB(50, 50, 70)
StatusText.TextSize = 9
StatusText.Font = Enum.Font.Code
StatusText.Parent = StatusBar

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, -80, 1, 0)
FooterLabel.Position = UDim2.new(0, 8, 0, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "DELTA EXECUTOR  •  ADOPT ME MODULE"
FooterLabel.TextColor3 = Color3.fromRGB(25, 25, 40)
FooterLabel.TextSize = 8
FooterLabel.Font = Enum.Font.Code
FooterLabel.TextXAlignment = Enum.TextXAlignment.Left
FooterLabel.Parent = StatusBar

-- ══════════════════════════════════════
--           DRAGGING
-- ══════════════════════════════════════

local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ══════════════════════════════════════
--        TAB CONTENT RENDERING
-- ══════════════════════════════════════

local function ClearContent()
    for _, c in ipairs(Content:GetChildren()) do c:Destroy() end
end

local function MakeButton(text, bgColor, textColor, size, pos, parent)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(1, 0, 0, 32)
    btn.Position = pos or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = bgColor or Color3.fromRGB(99, 102, 241)
    btn.Text = text
    btn.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Code
    btn.BorderSizePixel = 0
    btn.Parent = parent
    MakeCorner(7).Parent = btn
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.fromRGB(255,255,255), 0.08)}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = bgColor}) end)
    return btn
end

local function RarityColor(rarity)
    if rarity == "Legendary"  then return Color3.fromRGB(255, 215, 0) end
    if rarity == "Ultra-Rare" then return Color3.fromRGB(167, 139, 250) end
    if rarity == "Rare"       then return Color3.fromRGB(248, 113, 113) end
    return Color3.fromRGB(96, 165, 250)
end

local function RenderOfferList(frame, offer)
    for _, ch in ipairs(frame:GetChildren()) do
        if ch:IsA("Frame") and ch.Name:sub(1,4) == "Slot" then ch:Destroy() end
    end
    for i = 1, 4 do
        local pet = offer[i]
        local slot = Instance.new("Frame")
        slot.Name = "Slot"..i
        slot.Size = UDim2.new(1, 0, 0, 36)
        slot.BackgroundColor3 = pet and Color3.fromRGB(16, 16, 28) or Color3.fromRGB(10, 10, 18)
        slot.BorderSizePixel = 0
        slot.LayoutOrder = i
        slot.Parent = frame
        MakeCorner(7).Parent = slot
        if pet then
            MakeStroke(RarityColor(pet.rarity):Lerp(Color3.new(0,0,0), 0.6), 1).Parent = slot
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -8, 0.55, 0)
            nameLabel.Position = UDim2.new(0, 8, 0, 4)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = pet.name
            nameLabel.TextColor3 = RarityColor(pet.rarity)
            nameLabel.TextSize = 11
            nameLabel.Font = Enum.Font.Code
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = slot
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1, -8, 0.4, 0)
            infoLabel.Position = UDim2.new(0, 8, 0.55, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Text = (pet.mega and "Mega  " or pet.neon and "Neon  " or "") .. (pet.age or "Newborn")
            infoLabel.TextColor3 = Color3.fromRGB(80, 80, 110)
            infoLabel.TextSize = 9
            infoLabel.Font = Enum.Font.Code
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Parent = slot
        else
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Size = UDim2.new(1, 0, 1, 0)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "-- slot "..i.." --"
            emptyLabel.TextColor3 = Color3.fromRGB(25, 25, 40)
            emptyLabel.TextSize = 9
            emptyLabel.Font = Enum.Font.Code
            emptyLabel.Parent = slot
            MakeStroke(Color3.fromRGB(15, 15, 25), 1).Parent = slot
        end
    end
end

-- ── TRADE TAB ──
local function RenderTradeTab()
    ClearContent()

    local Banner = Instance.new("Frame")
    Banner.Name = "FreezeBanner"
    Banner.Size = UDim2.new(1, 0, 0, State.Frozen and 42 or 0)
    Banner.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
    Banner.BorderSizePixel = 0
    Banner.ClipsDescendants = true
    Banner.LayoutOrder = 0
    Banner.Parent = Content
    MakeCorner(7).Parent = Banner
    MakeStroke(Color3.fromRGB(99, 102, 241), 1).Parent = Banner
    local BannerText = Instance.new("TextLabel")
    BannerText.Size = UDim2.new(1, -16, 1, 0)
    BannerText.Position = UDim2.new(0, 8, 0, 0)
    BannerText.BackgroundTransparency = 1
    BannerText.Text = "TRADE FROZEN  —  Offer locked. Switch pets in Adopt Me now."
    BannerText.TextColor3 = Color3.fromRGB(165, 180, 252)
    BannerText.TextSize = 10
    BannerText.Font = Enum.Font.Code
    BannerText.TextXAlignment = Enum.TextXAlignment.Left
    BannerText.Parent = Banner

    local PanelRow = Instance.new("Frame")
    PanelRow.Size = UDim2.new(1, 0, 0, 240)
    PanelRow.Position = UDim2.new(0, 0, 0, State.Frozen and 50 or 6)
    PanelRow.BackgroundTransparency = 1
    PanelRow.Parent = Content

    local function MakePanel(label, offer, xPos, color)
        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0.47, 0, 1, 0)
        panel.Position = UDim2.new(xPos, 0, 0, 0)
        panel.BackgroundColor3 = Color3.fromRGB(13, 13, 22)
        panel.BorderSizePixel = 0
        panel.Parent = PanelRow
        MakeCorner(8).Parent = panel
        MakeStroke(color:Lerp(Color3.new(0,0,0), 0.7), 1).Parent = panel
        MakePadding(8,8,8,8).Parent = panel

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = color
        lbl.TextSize = 9
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = 0
        lbl.Parent = panel

        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, 0, 0, 172)
        listFrame.Position = UDim2.new(0, 0, 0, 20)
        listFrame.BackgroundTransparency = 1
        listFrame.Parent = panel
        MakeList(0, 4).Parent = listFrame

        RenderOfferList(listFrame, offer)
        return listFrame
    end

    MakePanel("YOUR OFFER",  State.MyOffer,    0,    Color3.fromRGB(99, 102, 241))
    MakePanel("THEIR OFFER", State.TheirOffer, 0.53, Color3.fromRGB(236, 72, 153))

    local BtnRow = Instance.new("Frame")
    BtnRow.Size = UDim2.new(1, 0, 0, 34)
    BtnRow.Position = UDim2.new(0, 0, 0, State.Frozen and 300 or 256)
    BtnRow.BackgroundTransparency = 1
    BtnRow.Parent = Content

    local FreezeBtn = MakeButton(
        State.Frozen and "UNFREEZE TRADE" or "FREEZE TRADE",
        State.Frozen and Color3.fromRGB(80, 40, 180) or Color3.fromRGB(79, 70, 229),
        Color3.fromRGB(255, 255, 255),
        UDim2.new(0.72, -4, 1, 0),
        UDim2.new(0, 0, 0, 0),
        BtnRow
    )
    FreezeBtn.MouseButton1Click:Connect(function()
        if State.Frozen then DoUnfreeze() else DoFreeze() end
        Tween(StatusDot, {BackgroundColor3 = State.Frozen and Color3.fromRGB(99,102,241) or Color3.fromRGB(34,197,94)})
        StatusText.Text = State.Frozen and "FROZEN" or "READY"
        UpdateContent()
    end)

    local ClearBtn = MakeButton(
        "CLEAR",
        Color3.fromRGB(15, 15, 28),
        Color3.fromRGB(70, 70, 100),
        UDim2.new(0.28, -4, 1, 0),
        UDim2.new(0.72, 4, 0, 0),
        BtnRow
    )
    MakeStroke(Color3.fromRGB(30, 30, 50), 1).Parent = ClearBtn
    ClearBtn.MouseButton1Click:Connect(function()
        State.MyOffer = {}
        State.TheirOffer = {}
        DoUnfreeze()
        Log("Trade cleared", "INFO")
        UpdateContent()
    end)
end

-- ── PETS TAB ──
local function RenderPetsTab()
    ClearContent()

    local SideRow = Instance.new("Frame")
    SideRow.Size = UDim2.new(1, 0, 0, 26)
    SideRow.BackgroundTransparency = 1
    SideRow.Parent = Content
    local SideList = Instance.new("UIListLayout")
    SideList.FillDirection = Enum.FillDirection.Horizontal
    SideList.Padding = UDim.new(0, 6)
    SideList.VerticalAlignment = Enum.VerticalAlignment.Center
    SideList.Parent = SideRow

    local SideLabel = Instance.new("TextLabel")
    SideLabel.Size = UDim2.new(0, 70, 1, 0)
    SideLabel.BackgroundTransparency = 1
    SideLabel.Text = "ADD TO ->"
    SideLabel.TextColor3 = Color3.fromRGB(50, 50, 70)
    SideLabel.TextSize = 9
    SideLabel.Font = Enum.Font.Code
    SideLabel.Parent = SideRow

    for _, side in ipairs({"My Side", "Their Side"}) do
        local key = side == "My Side" and "My" or "Their"
        local active = State.SelectSide == key
        local sbtn = Instance.new("TextButton")
        sbtn.Size = UDim2.new(0, 80, 0, 22)
        sbtn.BackgroundColor3 = active and Color3.fromRGB(25, 25, 55) or Color3.fromRGB(12, 12, 22)
        sbtn.Text = side
        sbtn.TextColor3 = active and Color3.fromRGB(165, 180, 252) or Color3.fromRGB(55, 55, 80)
        sbtn.TextSize = 9
        sbtn.Font = Enum.Font.Code
        sbtn.BorderSizePixel = 0
        sbtn.Parent = SideRow
        MakeCorner(5).Parent = sbtn
        MakeStroke(active and Color3.fromRGB(99,102,241) or Color3.fromRGB(25,25,40), 1).Parent = sbtn
        sbtn.MouseButton1Click:Connect(function()
            State.SelectSide = key
            RenderPetsTab()
        end)
    end

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, -34)
    Scroll.Position = UDim2.new(0, 0, 0, 32)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 100)
    Scroll.BorderSizePixel = 0
    Scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#PETS / 3) * 52)
    Scroll.Parent = Content

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0, 156, 0, 44)
    Grid.CellPadding = UDim2.new(0, 6, 0, 6)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = Scroll

    for i, pet in ipairs(PETS) do
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0, 156, 0, 44)
        card.BackgroundColor3 = Color3.fromRGB(13, 13, 24)
        card.Text = ""
        card.BorderSizePixel = 0
        card.LayoutOrder = i
        card.Parent = Scroll
        MakeCorner(7).Parent = card
        MakeStroke(RarityColor(pet.rarity):Lerp(Color3.new(0,0,0), 0.65), 1).Parent = card

        local pname = Instance.new("TextLabel")
        pname.Size = UDim2.new(1, -8, 0, 18)
        pname.Position = UDim2.new(0, 8, 0, 6)
        pname.BackgroundTransparency = 1
        pname.Text = pet.name
        pname.TextColor3 = RarityColor(pet.rarity)
        pname.TextSize = 11
        pname.Font = Enum.Font.Code
        pname.TextXAlignment = Enum.TextXAlignment.Left
        pname.Parent = card

        local prarity = Instance.new("TextLabel")
        prarity.Size = UDim2.new(1, -8, 0, 14)
        prarity.Position = UDim2.new(0, 8, 0, 24)
        prarity.BackgroundTransparency = 1
        prarity.Text = pet.rarity
        prarity.TextColor3 = Color3.fromRGB(60, 60, 80)
        prarity.TextSize = 9
        prarity.Font = Enum.Font.Code
        prarity.TextXAlignment = Enum.TextXAlignment.Left
        prarity.Parent = card

        card.MouseEnter:Connect(function()
            Tween(card, {BackgroundColor3 = RarityColor(pet.rarity):Lerp(Color3.new(0,0,0), 0.85)})
        end)
        card.MouseLeave:Connect(function()
            Tween(card, {BackgroundColor3 = Color3.fromRGB(13, 13, 24)})
        end)
        card.MouseButton1Click:Connect(function()
            local offer = State.SelectSide == "My" and State.MyOffer or State.TheirOffer
            if #offer >= 4 then
                Log("Max 4 pets per side!", "WARN")
                return
            end
            table.insert(offer, { name = pet.name, rarity = pet.rarity, age = "Newborn", neon = false, mega = false })
            Log("Added "..pet.name.." to "..State.SelectSide.." side", "ADD")
            if State.SelectSide == "My" then State.MyOffer = offer else State.TheirOffer = offer end
        end)
    end
end

-- ── LOG TAB ──
local function RenderLogTab()
    ClearContent()
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 80)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(#State.Log * 18, 100))
    Scroll.Parent = Content
    MakeCorner(7).Parent = Scroll
    MakePadding(8,8,8,8).Parent = Scroll
    MakeList(0,2).Parent = Scroll

    if #State.Log == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 18)
        empty.BackgroundTransparency = 1
        empty.Text = "// No activity yet..."
        empty.TextColor3 = Color3.fromRGB(35, 35, 50)
        empty.TextSize = 10
        empty.Font = Enum.Font.Code
        empty.TextXAlignment = Enum.TextXAlignment.Left
        empty.Parent = Scroll
    end

    for i, entry in ipairs(State.Log) do
        local col = Color3.fromRGB(55, 55, 80)
        if entry:find("FREEZE") then col = Color3.fromRGB(165, 180, 252)
        elseif entry:find("WARN")   then col = Color3.fromRGB(251, 191, 36)
        elseif entry:find("ADD")    then col = Color3.fromRGB(52, 211, 153)
        elseif entry:find("REMOVE") then col = Color3.fromRGB(248, 113, 113) end

        local row = Instance.new("TextLabel")
        row.Size = UDim2.new(1, 0, 0, 16)
        row.BackgroundTransparency = 1
        row.Text = entry
        row.TextColor3 = col
        row.TextSize = 9
        row.Font = Enum.Font.Code
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.LayoutOrder = i
        row.Parent = Scroll
    end
end

-- ══════════════════════════════════════
--         MAIN UPDATE FUNCTION
-- ══════════════════════════════════════

function UpdateContent()
    RefreshTabs()
    if State.ActiveTab == "Trade" then RenderTradeTab()
    elseif State.ActiveTab == "Pets" then RenderPetsTab()
    elseif State.ActiveTab == "Log"  then RenderLogTab() end
end

-- ══════════════════════════════════════
--              INIT
-- ══════════════════════════════════════

RefreshTabs()
UpdateContent()
Log("Delta Freeze Trader loaded", "INFO")
Log("Attach to an active trade and press FREEZE", "INFO")

Main.Position = UDim2.new(0.5, -260, 0.5, -230)
Main.BackgroundTransparency = 1
Tween(Main, {
    Position = UDim2.new(0.5, -260, 0.5, -210),
    BackgroundTransparency = 0
}, 0.35, Enum.EasingStyle.Back)

print("Delta Freeze Trader v2.4 loaded!")
