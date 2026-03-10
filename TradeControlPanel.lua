-- Trade Control Panel v1.0
-- Adopt Me Script | Delta Executor
-- UI Style: Light/White Panel with toggles

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════
--              STATE
-- ══════════════════════════════════════

local State = {
    TargetMode   = "AllPlayers",   -- "AllPlayers" or player name
    TargetPlayer = nil,
    TradeScam    = true,
    FreezeTrade  = true,
    AutoAccept   = true,
    Log          = {},
    FreezeConn   = nil,
}

-- ══════════════════════════════════════
--              UTILITIES
-- ══════════════════════════════════════

local function Log(msg, level)
    level = level or "INFO"
    local entry = string.format("[%s] [%s] %s", os.date("%H:%M:%S"), level, msg)
    table.insert(State.Log, 1, entry)
    if #State.Log > 40 then table.remove(State.Log) end
    print(entry)
end

local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function MakeCorner(r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function MakePadding(t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    return p
end

local function MakeStroke(col, thickness)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(220, 220, 220)
    s.Thickness = thickness or 1
    return s
end

local function MakeList(spacing)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing or 8)
    l.FillDirection = Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return l
end

-- ══════════════════════════════════════
--          FREEZE / TRADE SCAM LOGIC
-- ══════════════════════════════════════

local function GetTradeFrame()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        local tf = gui:FindFirstChild("TradeWindow")
            or gui:FindFirstChild("TradeFrame")
        if tf then return tf end
        local trade = gui:FindFirstChild("Trade")
        if trade then
            local inner = trade:FindFirstChild("TradeFrame")
            if inner then return inner end
        end
    end
    return nil
end

local function ApplyFreeze()
    if State.FreezeConn then State.FreezeConn:Disconnect() end
    if not State.FreezeTrade then return end

    State.FreezeConn = RunService.Heartbeat:Connect(function()
        if not State.FreezeTrade then
            State.FreezeConn:Disconnect()
            State.FreezeConn = nil
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
    Log("Freeze Trade active", "FREEZE")
end

local function ApplyAutoAccept()
    if not State.AutoAccept then return end
    task.spawn(function()
        while State.AutoAccept do
            pcall(function()
                local tf = GetTradeFrame()
                if tf then
                    local acceptBtn = tf:FindFirstChild("Accept", true)
                        or tf:FindFirstChild("AcceptButton", true)
                    if acceptBtn and acceptBtn:IsA("TextButton") then
                        acceptBtn:Invoke()
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
    Log("Auto Accept active", "INFO")
end

-- ══════════════════════════════════════
--              GUI BUILD
-- ══════════════════════════════════════

if PlayerGui:FindFirstChild("TradeControlPanel") then
    PlayerGui:FindFirstChild("TradeControlPanel"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TradeControlPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ── Main Window (white card style) ──
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 340, 0, 500)
Main.Position = UDim2.new(0.5, -170, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
MakeCorner(14).Parent = Main

-- Soft shadow
local Shadow = Instance.new("ImageLabel")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 10)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.ZIndex = 0
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.82
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.Parent = Main

-- ── Title Bar ──
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = Main
MakeCorner(14).Parent = TitleBar

-- Bottom cover for rounded top only
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 2
TitleFix.Parent = TitleBar

-- Divider under title
local TitleDivider = Instance.new("Frame")
TitleDivider.Size = UDim2.new(1, 0, 0, 1)
TitleDivider.Position = UDim2.new(0, 0, 1, -1)
TitleDivider.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
TitleDivider.BorderSizePixel = 0
TitleDivider.ZIndex = 3
TitleDivider.Parent = TitleBar

-- Traffic lights
local lightColors = {Color3.fromRGB(255,95,87), Color3.fromRGB(255,189,46), Color3.fromRGB(40,202,65)}
for i, col in ipairs(lightColors) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 13, 0, 13)
    dot.Position = UDim2.new(0, 10 + (i-1)*20, 0.5, -6)
    dot.BackgroundColor3 = col
    dot.BorderSizePixel = 0
    dot.ZIndex = 4
    dot.Parent = TitleBar
    MakeCorner(99).Parent = dot
end

-- Title text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 78, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Trade Control Panel"
TitleLabel.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 4
TitleLabel.Parent = TitleBar

-- ── Scroll content area ──
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -44)
Scroll.Position = UDim2.new(0, 0, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local ScrollList = MakeList(0)
ScrollList.Parent = Scroll
MakePadding(10, 14, 12, 12).Parent = Scroll

-- ══════════════════════════════════════
--          UI COMPONENT HELPERS
-- ══════════════════════════════════════

local function MakeSection(title, icon, layoutOrder)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Color3.fromRGB(249, 249, 252)
    section.BorderSizePixel = 0
    section.LayoutOrder = layoutOrder or 1
    section.Parent = Scroll
    MakeCorner(10).Parent = section
    MakeStroke(Color3.fromRGB(235, 235, 240), 1).Parent = section
    MakePadding(10, 10, 12, 12).Parent = section
    MakeList(8).Parent = section

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Text = (icon and icon.." " or "") .. title
    header.TextColor3 = Color3.fromRGB(30, 30, 30)
    header.TextSize = 13
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 0
    header.Parent = section

    return section
end

local function MakeToggle(parent, label, defaultValue, layoutOrder, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder or 1
    row.Parent = parent
    MakeCorner(8).Parent = row
    MakeStroke(Color3.fromRGB(235, 235, 240), 1).Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(40, 180, 100)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Toggle track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -56, 0.5, -12)
    track.BackgroundColor3 = defaultValue and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(210, 210, 215)
    track.BorderSizePixel = 0
    track.Parent = row
    MakeCorner(99).Parent = track

    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = defaultValue and UDim2.new(0, 22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    MakeCorner(99).Parent = knob

    -- Drop shadow on knob
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Position = UDim2.new(0.5, 0, 0.5, 1)
    knobShadow.Size = UDim2.new(1, 8, 1, 8)
    knobShadow.ZIndex = 0
    knobShadow.Image = "rbxassetid://5554236805"
    knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.ImageTransparency = 0.88
    knobShadow.ScaleType = Enum.ScaleType.Slice
    knobShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    knobShadow.Parent = knob

    local toggled = defaultValue
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        Tween(track, {BackgroundColor3 = toggled and Color3.fromRGB(52,199,89) or Color3.fromRGB(210,210,215)})
        Tween(knob, {Position = toggled and UDim2.new(0,22,0.5,-10) or UDim2.new(0,2,0.5,-10)})
        if onChange then onChange(toggled) end
    end)

    return row, function() return toggled end
end

local function MakePlayerRow(player, isSelected, layoutOrder, onClick)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = isSelected and Color3.fromRGB(255, 245, 245) or Color3.fromRGB(255, 255, 255)
    row.BorderSizePixel = 0
    row.LayoutOrder = layoutOrder or 1
    row.Parent = nil -- caller parents it
    MakeCorner(8).Parent = row
    if isSelected then
        MakeStroke(Color3.fromRGB(255, 180, 180), 1.5).Parent = row
    else
        MakeStroke(Color3.fromRGB(235, 235, 240), 1).Parent = row
    end

    -- Left accent bar
    if isSelected then
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, -12)
        accent.Position = UDim2.new(0, 0, 0.5, -((52-12)/2))
        accent.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        accent.BorderSizePixel = 0
        accent.Parent = row
        MakeCorner(99).Parent = accent
    end

    -- Avatar circle
    local avatarBg = Instance.new("Frame")
    avatarBg.Size = UDim2.new(0, 36, 0, 36)
    avatarBg.Position = UDim2.new(0, 14, 0.5, -18)
    avatarBg.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
    avatarBg.BorderSizePixel = 0
    avatarBg.Parent = row
    MakeCorner(99).Parent = avatarBg

    -- Try to load avatar
    pcall(function()
        if player and player ~= "AllPlayers" then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundTransparency = 1
            img.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            img.Parent = avatarBg
            MakeCorner(99).Parent = img
        end
    end)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -100, 0, 20)
    nameLabel.Position = UDim2.new(0, 58, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player == "AllPlayers" and "All Players" or (type(player) == "table" and player.Name or tostring(player))
    nameLabel.TextColor3 = Color3.fromRGB(25, 25, 25)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    if player ~= "AllPlayers" then
        local userLabel = Instance.new("TextLabel")
        userLabel.Size = UDim2.new(1, -100, 0, 16)
        userLabel.Position = UDim2.new(0, 58, 0, 28)
        userLabel.BackgroundTransparency = 1
        userLabel.Text = "@" .. (type(player) == "userdata" and player.Name or tostring(player))
        userLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
        userLabel.TextSize = 11
        userLabel.Font = Enum.Font.Gotham
        userLabel.TextXAlignment = Enum.TextXAlignment.Left
        userLabel.Parent = row
    end

    -- Checkmark if selected
    if isSelected then
        local check = Instance.new("Frame")
        check.Size = UDim2.new(0, 28, 0, 28)
        check.Position = UDim2.new(1, -40, 0.5, -14)
        check.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        check.BorderSizePixel = 0
        check.Parent = row
        MakeCorner(99).Parent = check

        local checkMark = Instance.new("TextLabel")
        checkMark.Size = UDim2.new(1, 0, 1, 0)
        checkMark.BackgroundTransparency = 1
        checkMark.Text = "✓"
        checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkMark.TextSize = 14
        checkMark.Font = Enum.Font.GothamBold
        checkMark.Parent = check
    end

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = row
    if onClick then hitbox.MouseButton1Click:Connect(onClick) end

    return row
end

-- ══════════════════════════════════════
--          BUILD THE PANEL
-- ══════════════════════════════════════

-- Spacer
local spacer1 = Instance.new("Frame")
spacer1.Size = UDim2.new(1, 0, 0, 2)
spacer1.BackgroundTransparency = 1
spacer1.LayoutOrder = 0
spacer1.Parent = Scroll

-- ── Section 1: Select Target ──
local targetSection = MakeSection("Select Target", "🎯", 1)

local function RefreshTargetList()
    for _, ch in ipairs(targetSection:GetChildren()) do
        if ch:IsA("Frame") and ch.Name == "PlayerRow" then ch:Destroy() end
    end

    -- All Players row
    local allRow = MakePlayerRow("AllPlayers", State.TargetMode == "AllPlayers", 1, function()
        State.TargetMode = "AllPlayers"
        State.TargetPlayer = nil
        Log("Target set to All Players", "INFO")
        RefreshTargetList()
        RefreshStatusBox()
    end)
    allRow.Name = "PlayerRow"
    allRow.LayoutOrder = 1
    allRow.Parent = targetSection

    -- Real players
    local order = 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local isSelected = State.TargetMode == "Player" and State.TargetPlayer == plr
            local row = MakePlayerRow(plr, isSelected, order, function()
                State.TargetMode = "Player"
                State.TargetPlayer = plr
                Log("Target set to " .. plr.Name, "INFO")
                RefreshTargetList()
                RefreshStatusBox()
            end)
            row.Name = "PlayerRow"
            row.LayoutOrder = order
            row.Parent = targetSection
            order = order + 1
        end
    end
end

RefreshTargetList()

Players.PlayerAdded:Connect(function() task.wait(0.5); RefreshTargetList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); RefreshTargetList() end)

-- ── Section 2: Trade System Status ──
local statusSection = MakeSection("Trade System Status", "🔧", 2)

local StatusBody
function RefreshStatusBox()
    if StatusBody then StatusBody:Destroy() end
    StatusBody = Instance.new("Frame")
    StatusBody.Size = UDim2.new(1, 0, 0, 0)
    StatusBody.AutomaticSize = Enum.AutomaticSize.Y
    StatusBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatusBody.BorderSizePixel = 0
    StatusBody.LayoutOrder = 1
    StatusBody.Parent = statusSection
    MakeCorner(8).Parent = StatusBody
    MakeStroke(Color3.fromRGB(235, 235, 240), 1).Parent = StatusBody
    MakePadding(10, 10, 12, 12).Parent = StatusBody
    MakeList(4).Parent = StatusBody

    local lines = {
        "Target: " .. (State.TargetMode == "AllPlayers" and "All Players" or (State.TargetPlayer and State.TargetPlayer.Name or "None")),
        "• Trade Scam: " .. (State.TradeScam and "ON" or "OFF"),
        "• Freeze Trade: " .. (State.FreezeTrade and "ON" or "OFF"),
        "• Auto Accept: " .. (State.AutoAccept and "ON" or "OFF"),
    }

    for i, line in ipairs(lines) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = line
        lbl.TextColor3 = i == 1 and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(100, 100, 110)
        lbl.TextSize = 11
        lbl.Font = i == 1 and Enum.Font.GothamSemibold or Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = i
        lbl.Parent = StatusBody
    end
end

RefreshStatusBox()

-- ── Section 3: Toggles ──
local toggleSection = Instance.new("Frame")
toggleSection.Size = UDim2.new(1, 0, 0, 0)
toggleSection.AutomaticSize = Enum.AutomaticSize.Y
toggleSection.BackgroundTransparency = 1
toggleSection.LayoutOrder = 3
toggleSection.Parent = Scroll
MakeList(6).Parent = toggleSection

MakeToggle(toggleSection, "Trade Scam", State.TradeScam, 1, function(val)
    State.TradeScam = val
    Log("Trade Scam " .. (val and "ON" or "OFF"), "INFO")
    RefreshStatusBox()
end)

MakeToggle(toggleSection, "Freeze Trade", State.FreezeTrade, 2, function(val)
    State.FreezeTrade = val
    if val then ApplyFreeze() elseif State.FreezeConn then
        State.FreezeConn:Disconnect(); State.FreezeConn = nil
    end
    Log("Freeze Trade " .. (val and "ON" or "OFF"), "FREEZE")
    RefreshStatusBox()
end)

MakeToggle(toggleSection, "Auto Accept", State.AutoAccept, 3, function(val)
    State.AutoAccept = val
    if val then ApplyFreeze() end
    Log("Auto Accept " .. (val and "ON" or "OFF"), "INFO")
    RefreshStatusBox()
end)

-- ── Bottom spacer ──
local spacerBottom = Instance.new("Frame")
spacerBottom.Size = UDim2.new(1, 0, 0, 6)
spacerBottom.BackgroundTransparency = 1
spacerBottom.LayoutOrder = 99
spacerBottom.Parent = Scroll

-- ══════════════════════════════════════
--           DRAGGING
-- ══════════════════════════════════════

local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
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
--              INIT
-- ══════════════════════════════════════

-- Entry animation
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, -170, 0.5, -265)
Tween(Main, {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -170, 0.5, -250)
}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Start active features
if State.FreezeTrade then ApplyFreeze() end

Log("Trade Control Panel loaded", "INFO")
print("✅ Trade Control Panel v1.0 loaded!")
