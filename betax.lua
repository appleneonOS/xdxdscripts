-- [[ ANIMAL HOSPITAL – STANDALONE UI ]] --
-- Toggle Menu: Click the Draggable Web-Linked Logo or hit RightShift

-- =================================================================
-- 1. SERVICES & CONFIG
-- =================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local Username = LocalPlayer.Name
local GameId = game.PlaceId
local Camera = workspace.CurrentCamera

-- Cheat states
local Flags = {
    ESP = false,            -- replaced with AnomalySensor
    FullBright = false,
    InfJump = false,
    Fly = false,
    Spinbot = false,
    AnomalyView = false,
    WalkSpeedActive = false,
    AutoSanity = false,
    AutoLoot = false,
    AutoHeartbeat = false,
    InstantPrompts = false,
    AnomalySensor = false,   -- new
}
local MenuOpen = false
local FlySpeed = 45
local TargetSpeedValue = 32

-- Backup lighting
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoor = Lighting.OutdoorAmbient
local OriginalFogEnd = Lighting.FogEnd

-- =================================================================
-- 2. GUI CONTAINER (with protection)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimalHospitalHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

local function tween(object, info, properties)
    local t = TweenService:Create(object, TweenInfo.new(unpack(info)), properties)
    t:Play()
    return t
end

-- =================================================================
-- 3. DRAGGABLE LOGO & MENU TOGGLE
-- =================================================================
local MainHub = Instance.new("Frame")
local CustomToggle = Instance.new("ImageButton")
CustomToggle.Name = "DynamicWebMenuIcon"
CustomToggle.Size = UDim2.new(0, 55, 0, 55)
CustomToggle.Position = UDim2.new(0, 25, 0.5, -27)
CustomToggle.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
CustomToggle.Image = "rbxassetid://13410134440"  -- custom icon
CustomToggle.Visible = false
CustomToggle.Parent = ScreenGui

Instance.new("UICorner", CustomToggle).CornerRadius = UDim.new(1, 0)
local FrameOutline = Instance.new("UIStroke", CustomToggle)
FrameOutline.Color = Color3.fromRGB(255, 65, 65)
FrameOutline.Thickness = 2

-- Dragging logic
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    CustomToggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

CustomToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = CustomToggle.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

CustomToggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

local function SetMenuVisibility(state)
    MenuOpen = state
    MainHub.Visible = MenuOpen
    CustomToggle.Visible = not MenuOpen
end

CustomToggle.MouseButton1Click:Connect(function()
    SetMenuVisibility(true)
end)

-- RightShift toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift and input.UserInputType == Enum.UserInputType.Keyboard then
        SetMenuVisibility(not MenuOpen)
    end
end)

-- =================================================================
-- 4. MAIN UI LAYOUT (Tabs + Panels)
-- =================================================================
local TabContainer = Instance.new("Frame")
local ContentPanels = Instance.new("Frame")

local function BuildInterface()
    MainHub.Size = UDim2.new(0, 550, 0, 430)
    MainHub.Position = UDim2.new(0.5, -275, 0.5, -215)
    MainHub.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    MainHub.BorderSizePixel = 0
    MainHub.Visible = false
    MainHub.Parent = ScreenGui
    Instance.new("UICorner", MainHub).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", MainHub).Color = Color3.fromRGB(45, 45, 55)

    -- Top Header
    local TopHeader = Instance.new("Frame")
    TopHeader.Size = UDim2.new(1, 0, 0, 45)
    TopHeader.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    TopHeader.BorderSizePixel = 0
    TopHeader.Parent = MainHub
    Instance.new("UICorner", TopHeader).CornerRadius = UDim.new(0, 10)

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 1, 0)
    InfoLabel.Position = UDim2.new(0, 15, 0, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Animal Hospital  |  User: " .. Username .. "  |  Game ID: " .. GameId
    InfoLabel.Font = Enum.Font.FredokaOne
    InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
    InfoLabel.TextSize = 12
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.Parent = TopHeader

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.FredokaOne
    CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TopHeader
    CloseBtn.MouseButton1Click:Connect(function()
        SetMenuVisibility(false)
    end)

    -- Tab Container (left)
    TabContainer.Size = UDim2.new(0, 140, 1, -45)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainHub

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = TabContainer
    Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 10)

    -- Content Panels (right)
    ContentPanels.Size = UDim2.new(1, -155, 1, -60)
    ContentPanels.Position = UDim2.new(0, 147, 0, 52)
    ContentPanels.BackgroundTransparency = 1
    ContentPanels.Parent = MainHub
end

local function CreateTab(tabName)
    local Panel = Instance.new("ScrollingFrame")
    Panel.Size = UDim2.new(1, 0, 1, 0)
    Panel.BackgroundTransparency = 1
    Panel.CanvasSize = UDim2.new(0, 0, 1.8, 0)
    Panel.ScrollBarThickness = 2
    Panel.Visible = false
    Panel.Parent = ContentPanels

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = Panel

    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(0.9, 0, 0, 34)
    NavBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    NavBtn.Text = tabName
    NavBtn.Font = Enum.Font.FredokaOne
    NavBtn.TextSize = 12
    NavBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
    NavBtn.Parent = TabContainer
    Instance.new("UICorner", NavBtn).CornerRadius = UDim.new(0, 6)

    NavBtn.MouseButton1Click:Connect(function()
        for _, p in ipairs(ContentPanels:GetChildren()) do p.Visible = false end
        for _, b in ipairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(140, 140, 150) end
        end
        Panel.Visible = true
        NavBtn.TextColor3 = Color3.fromRGB(255, 65, 65)
    end)

    return Panel
end

-- UI Helpers
local function AddToggle(parent, text, flag, callback)
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0.96, 0, 0, 38)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    ToggleBg.Parent = parent
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.7, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.Font = Enum.Font.FredokaOne
    Lbl.TextColor3 = Color3.fromRGB(215, 215, 220)
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = ToggleBg

    local Click = Instance.new("TextButton")
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.BackgroundTransparency = 1
    Click.Text = ""
    Click.Parent = ToggleBg

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 32, 0, 16)
    Box.Position = UDim2.new(1, -42, 0.5, -8)
    Box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Box.Parent = ToggleBg
    Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 10, 0, 10)
    Dot.Position = UDim2.new(0, 3, 0.5, -5)
    Dot.BackgroundColor3 = Color3.fromRGB(140, 140, 150)
    Dot.Parent = Box
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    Click.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        if Flags[flag] then
            tween(Box, {0.15, Enum.EasingStyle.Quad}, {BackgroundColor3 = Color3.fromRGB(255, 65, 65)})
            tween(Dot, {0.15, Enum.EasingStyle.Quad}, {Position = UDim2.new(1, -13, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        else
            tween(Box, {0.15, Enum.EasingStyle.Quad}, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)})
            tween(Dot, {0.15, Enum.EasingStyle.Quad}, {Position = UDim2.new(0, 3, 0.5, -5), BackgroundColor3 = Color3.fromRGB(140, 140, 150)})
        end
        callback(Flags[flag])
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.96, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Btn.Font = Enum.Font.FredokaOne
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    Btn.TextSize = 12
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(45, 45, 55)
    Btn.MouseButton1Click:Connect(callback)
end

local function AddTextInput(parent, placeholder, callback)
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0.96, 0, 0, 38)
    InputBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    InputBox.Font = Enum.Font.FredokaOne
    InputBox.PlaceholderText = placeholder
    InputBox.Text = ""
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.TextSize = 11
    InputBox.Parent = parent
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", InputBox).Color = Color3.fromRGB(40, 40, 50)

    InputBox.FocusLost:Connect(function()
        if InputBox.Text ~= "" then
            callback(InputBox.Text)
        end
    end)
end

-- =================================================================
-- 5. BUILD INTERFACE & TABS
-- =================================================================
BuildInterface()

local MainTab = CreateTab("Main")
local CombatTab = CreateTab("Combat")
local WorldTab = CreateTab("World")
local VisualsTab = CreateTab("Visuals")
local LoaderTab = CreateTab("Loader")
local SettingsTab = CreateTab("Settings")

MainTab.Visible = true

-- =================================================================
-- 6. POPULATE TABS
-- =================================================================

-- MAIN TAB
AddToggle(MainTab, "Auto Work (Treat Patients)", "AutoWork", function() end)
AddToggle(MainTab, "Infinite Sanity", "AutoSanity", function() end)
AddToggle(MainTab, "Auto Loot (Vacuum)", "AutoLoot", function() end)
AddToggle(MainTab, "Auto Heartbeat Minigame", "AutoHeartbeat", function(state)
    if state then SetupAutoHeartbeat() else CleanupAutoHeartbeat() end
end)
AddToggle(MainTab, "Instant Proximity Prompts", "InstantPrompts", function(state)
    if state then SetupInstantPrompts() else CleanupInstantPrompts() end
end)

-- COMBAT TAB
AddToggle(CombatTab, "Spinbot (Anti-Aim)", "Spinbot", function() end)

-- WORLD TAB
AddToggle(WorldTab, "Speed Modifier", "WalkSpeedActive", function() end)
AddTextInput(WorldTab, "Set Speed Value (Default 16)...", function(text)
    if tonumber(text) then TargetSpeedValue = tonumber(text) end
end)
AddToggle(WorldTab, "Fly", "Fly", function() end)
AddTextInput(WorldTab, "Set Fly Speed (Default 45)...", function(text)
    if tonumber(text) then FlySpeed = tonumber(text) end
end)
AddToggle(WorldTab, "Infinite Jump", "InfJump", function() end)
AddButton(WorldTab, "Bypass All Doors", function()
    for _, door in ipairs(workspace:GetDescendants()) do
        if door:IsA("BasePart") and (door.Name:match("Door") or door.Name:match("Gate")) then
            door.CanCollide = false
            door.Transparency = 0.5
        end
    end
end)

-- VISUALS TAB
AddToggle(VisualsTab, "Anomaly Sensor (Red/Green)", "AnomalySensor", function(state)
    if state then
        ApplyAnomalyHighlights()
        if not _G.npcConnection then
            _G.npcConnection = workspace.NPCs.ChildAdded:Connect(function(instance)
                if Flags.AnomalySensor then HighlightNPC(instance) end
            end)
        end
    else
        for _, child in ipairs(workspace.NPCs:GetChildren()) do ClearHighlights(child) end
        if _G.npcConnection then _G.npcConnection:Disconnect(); _G.npcConnection = nil end
    end
end)

AddToggle(VisualsTab, "FullBright (No Fog)", "FullBright", function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = 999999
    else
        Lighting.Ambient = OriginalAmbient
        Lighting.OutdoorAmbient = OriginalOutdoorAmbient
        Lighting.FogEnd = OriginalFogEnd
    end
end)

-- LOADER TAB
AddTextInput(LoaderTab, "Paste Lua Code or URL...", function(text)
    _G.pastedCode = text
end)
AddButton(LoaderTab, "Execute Code", function()
    local code = _G.pastedCode
    if code and code ~= "" then
        local success, err = pcall(function() loadstring(code)() end)
        if success then print("Code executed.") else warn("Error: " .. tostring(err)) end
    end
end)
AddButton(LoaderTab, "Load from URL (Raw)", function()
    local url = _G.pastedCode
    if url and url:match("^https?://") then
        local success, err = pcall(function()
            local code = game:HttpGet(url)
            loadstring(code)()
        end)
        if success then print("Loaded from URL.") else warn("Error: " .. tostring(err)) end
    else
        print("Paste a valid URL in the text box.")
    end
end)

-- SETTINGS TAB
AddButton(SettingsTab, "Destroy GUI", function()
    ScreenGui:Destroy()
end)

-- =================================================================
-- 7. FEATURE IMPLEMENTATIONS (Anomaly Sensor, Heartbeat, Prompts)
-- =================================================================

-- Anomaly Sensor helpers
local function HighlightNPC(instance)
    ClearHighlights(instance)
    local h = Instance.new("Highlight")
    h.Parent = instance
    h.Adornee = instance
    if instance:GetAttribute("HasCameraEffect") or instance:GetAttribute("Skinwalker") or instance:GetAttribute("CameraEffect") then
        h.FillColor = Color3.new(1, 0, 0)
    else
        h.FillColor = Color3.new(0, 1, 0)
    end
    instance:SetAttribute("_highlight", h)
end

local function ClearHighlights(instance)
    local existing = instance:GetAttribute("_highlight")
    if existing and existing:IsA("Highlight") then
        existing:Destroy()
        instance:SetAttribute("_highlight", nil)
    end
    for _, obj in ipairs(instance:GetChildren()) do
        if obj:IsA("Highlight") then obj:Destroy() end
    end
end

local function ApplyAnomalyHighlights()
    if not workspace:FindFirstChild("NPCs") then
        warn("workspace.NPCs not found")
        return
    end
    for _, v in ipairs(workspace.NPCs:GetChildren()) do
        HighlightNPC(v)
    end
end

-- Auto Heartbeat
local heartbeatConnection = nil
local function SetupAutoHeartbeat()
    if heartbeatConnection then return end
    local Net = ReplicatedStorage:FindFirstChild("Net")
    if not Net then warn("Net folder missing") return end
    local startEvent = Net:FindFirstChild("RE/StartHeartbeatMinigame")
    local completeEvent = Net:FindFirstChild("RE/HeartbeatMinigameComplete")
    if not startEvent or not completeEvent then
        warn("Heartbeat remotes not found")
        return
    end
    heartbeatConnection = startEvent.OnClientEvent:Connect(function()
        if Flags.AutoHeartbeat then
            task.wait(0.2)
            pcall(function() completeEvent:FireServer(true, true) end)
        end
    end)
    print("Auto Heartbeat activated")
end

local function CleanupAutoHeartbeat()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
        print("Auto Heartbeat deactivated")
    end
end

-- Instant Prompts
local promptConnection = nil
local function SetPromptInstant(prompt)
    if not prompt:GetAttribute("OriginalHoldDuration") then
        prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
    end
    prompt.HoldDuration = 0
end

local function RestorePrompt(prompt)
    local orig = prompt:GetAttribute("OriginalHoldDuration")
    if orig then
        prompt.HoldDuration = orig
        prompt:SetAttribute("OriginalHoldDuration", nil)
    end
end

local function ApplyInstantToAllPrompts()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then SetPromptInstant(prompt) end
    end
end

local function RestoreAllPrompts()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then RestorePrompt(prompt) end
    end
end

local function SetupInstantPrompts()
    if promptConnection then return end
    ApplyInstantToAllPrompts()
    promptConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
        if Flags.InstantPrompts then SetPromptInstant(prompt) end
    end)
    print("Instant Prompts activated")
end

local function CleanupInstantPrompts()
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end
    RestoreAllPrompts()
    print("Instant Prompts deactivated")
end

-- =================================================================
-- 8. MAIN LOOP (Stepped)
-- =================================================================
RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    local HRP = Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Head")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum then return end

    -- Speed
    if Flags.WalkSpeedActive then
        Hum.WalkSpeed = TargetSpeedValue
    end

    -- Spinbot
    if Flags.Spinbot then
        HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end

    -- Fly
    if Flags.Fly then
        local vel = Vector3.new(0,0,0)
        if UserInputService:IsKeyDo