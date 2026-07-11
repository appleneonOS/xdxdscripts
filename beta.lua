-- [[ ANIMAL HOSPITAL – STANDALONE UI (FULL) ]] --
-- Toggle Menu: Click the Draggable Logo or press RightShift

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
    AutoWork = false,
    AutoSanity = false,
    AutoLoot = false,
    AutoHeartbeat = false,
    InstantPrompts = false,
    AnomalySensor = false,
    WalkSpeedActive = false,
    Fly = false,
    InfJump = false,
    Spinbot = false,
    FullBright = false,
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

-- Create all tabs (matching your snippet)
local MainTab = CreateTab("Main")
local CombatTab = CreateTab("Combat")
local WorldTab = CreateTab("World")
local VisualsTab = CreateTab("Visuals")
local StatsTab = CreateTab("Stat Exploits")
local AnomalyTab = CreateTab("Anomaly Sim")
local SettingsTab = CreateTab("Settings")

VisualsTab.Visible = true

-- =================================================================
-- 6. POPULATE TABS (YOUR EXACT SNIPPET + EXTRA FEATURES)
-- =================================================================

-- VISUALS TAB
AddToggle(VisualsTab, "Enable Universal Overhaul ESP", "ESP", function() end)  -- Note: replaced by AnomalySensor later

-- COMBAT TAB (PremiumTab in your snippet → we use CombatTab)
-- RIGID RED PLASTIC LASER REVOLVER
AddButton(CombatTab, "Equip Red Blocky Laser Pistol", function()
    local Tool = Instance.new("Tool")
    Tool.Name = "Laser Pistol"
    Tool.RequiresHandle = true
    Tool.Grip = CFrame.new(0, -0.4, 0.6) * CFrame.Angles(0, 0, 0)
    
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Size = Vector3.new(0.5, 1.2, 0.6)
    Handle.Color = Color3.fromRGB(230, 20, 20)
    Handle.Material = Enum.Material.SmoothPlastic
    Handle.Parent = Tool
    
    local Barrel = Instance.new("Part")
    Barrel.Name = "Barrel"
    Barrel.Size = Vector3.new(0.5, 0.7, 2.2)
    Barrel.Color = Color3.fromRGB(230, 20, 20)
    Barrel.Material = Enum.Material.SmoothPlastic
    Barrel.CFrame = Handle.CFrame * CFrame.new(0, 0.5, -0.9)
    Barrel.Parent = Tool
    
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = Handle
    Weld.Part1 = Barrel
    Weld.Parent = Handle
    
    Tool.Activated:Connect(function()
        local Character = LocalPlayer.Character
        if not Character or not Character:FindFirstChild("Head") then return end
        
        local Mouse = LocalPlayer:GetMouse()
        local HitPosition = Mouse.Hit.p
        local Origin = Barrel.Position + (Barrel.CFrame.LookVector * 1.1)

        local Beam = Instance.new("Part")
        Beam.Anchored = true
        Beam.CanCollide = false
        Beam.Color = Color3.fromRGB(255, 0, 0)
        Beam.Material = Enum.Material.Neon
        
        local Dist = (Origin - HitPosition).Magnitude
        Beam.Size = Vector3.new(0.15, 0.15, Dist)
        Beam.CFrame = CFrame.new(Origin, HitPosition) * CFrame.new(0, 0, -Dist / 2)
        Beam.Parent = workspace
        game:GetService("Debris"):AddItem(Beam, 0.1)

        local Sound = Instance.new("Sound")
        Sound.SoundId = "rbxassetid://130113322"
        Sound.Volume = 0.8
        Sound.Parent = Handle
        Sound:Play()
        game:GetService("Debris"):AddItem(Sound, 1)

        local Target = Mouse.Target
        if Target and Target.Parent and Target.Parent:FindFirstChildOfClass("Humanoid") then
            Target.Parent:FindFirstChildOfClass("Humanoid"):TakeDamage(25)
        elseif Target and Target.Parent and Target.Parent.Parent:FindFirstChildOfClass("Humanoid") then
            Target.Parent.Parent:FindFirstChildOfClass("Humanoid"):TakeDamage(25)
        end
    end)
    Tool.Parent = LocalPlayer.Backpack
end)

AddToggle(CombatTab, "Flight Motion Engine", "Fly", function() end)
AddToggle(CombatTab, "Infinite Jump Physics", "InfJump", function() end)
AddToggle(CombatTab, "Anti-Aim Spinbot Engine", "Spinbot", function() end)

-- WORLD UTILITIES
AddToggle(WorldTab, "Enable Custom Speed Modifier", "WalkSpeedActive", function() end)
AddTextInput(WorldTab, "Set Speed Value (Default 16)...", function(text)
    if tonumber(text) then TargetSpeedValue = tonumber(text) end
end)

AddToggle(WorldTab, "Map Full-Bright (No Fog/Darkness)", "FullBright", function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = 999999
    else
        Lighting.Ambient = OriginalAmbient
        Lighting.OutdoorAmbient = OriginalOutdoor
        Lighting.FogEnd = OriginalFogEnd
    end
end)

AddButton(WorldTab, "Instant Auto-Bypass Map Doors", function()
    for _, door in ipairs(workspace:GetDescendants()) do
        if door:IsA("BasePart") and (door.Name:match("Door") or door.Name:match("Gate")) then
            door.CanCollide = false
            door.Transparency = 0.5
        end
    end
end)

-- STAT EXPLOITS TAB
AddToggle(StatsTab, "Enable Auto-Sanity Giver Loop", "AutoSanity", function() end)
AddToggle(StatsTab, "Enable Auto-Loot Item Vacuum", "AutoLoot", function() end)

AddButton(StatsTab, "Instant Max Sanity Burst", function()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:match("Sanity") or remote.Name:match("Restore") or remote.Name:match("Heal")) then
            remote:FireServer(100)
            remote:FireServer(true)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and (obj.Parent.Name:match("Sanity") or obj.Parent.Name:match("Med") or obj.Parent.Name:match("Pills")) then
            fireproximityprompt(obj)
        end
    end
end)

-- ANOMALY TAB
AddToggle(AnomalyTab, "Activate Round-Proof Anomaly Form", "AnomalyView", function(state) end)

local function ApplyGlitchAppearance(char)
    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
            child.Color = Color3.fromRGB(255, 0, 70)
            child.Material = Enum.Material.Neon
        elseif child:IsA("Decal") or child:IsA("Texture") then
            child.Enabled = false
        end
    end
end

-- =================================================================
-- 7. EXTRA FEATURES (Auto Heartbeat, Instant Prompts, Anomaly Sensor)
-- =================================================================

-- Anomaly Sensor (Red/Green highlights)
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

local functon RestorePrompt(prompt)
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

-- Add missing toggles for the extra features (they were not in your snippet)
AddToggle(MainTab, "Auto Heartbeat Minigame", "AutoHeartbeat", function(state)
    if state then SetupAutoHeartbeat() else CleanupAutoHeartbeat() end
end)

AddToggle(MainTab, "Instant Proximity Prompts", "InstantPrompts", function(state)
    if state then SetupInstantPrompts() else CleanupInstantPrompts() end
end)

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

-- =================================================================
-- 8. CORE LOOP (Stepped)
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
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector end
        if vel.Magnitude > 0 then HRP.Velocity = vel.Unit * FlySpeed end
    end

    -- Auto Loot
    if Flags.AutoLoot then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and obj.Parent ~= LocalPlayer.Backpack and obj.Parent ~= Char then
                obj:HandleMoveTo(HRP.Position)
            elseif obj:IsA("Model") and (obj.Name:match("Key") or obj.Name:match("Item") or obj.Name:match("Battery")) then
                local primary = obj:FindFirstChildOfClass("BasePart")
                if primary then
                    obj:PivotTo(HRP.CFrame * CFrame.new(0, -2, 0))
                end
            end
        end
    end

    -- Infinite Sanity
    if Flags.AutoSanity then
        local sanity = Char:FindFirstChild("Sanity") or Char:FindFirstChild("Stats")
        if sanity then
            if sanity:IsA("NumberValue") then sanity.Value = 100
            elseif sanity:IsA("IntValue") then sanity.Value = 100 end
        end
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (remote.Name:match("Sanity") or remote.Name:match("Restore") or remote.Name:match("Heal")) then
                pcall(function() remote:FireServer(100) end)
            end
        end
    end

    -- Auto Work (treat patients)
    if Flags.AutoWork then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local parent = prompt.Parent
                if parent and (parent.Name:match("Patient") or parent.Name:match("Bed") or parent.Name:match("Station")) then
                    if (parent:GetPivot().Position - HRP.Position).Magnitude < 15 then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            end
        end
    end

    -- Anomaly View (glitch appearance)
    if Flags.AnomalyView then
        ApplyGlitchAppearance(Char)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump = true
    end
end)

-- =================================================================
-- 9. SETTINGS TAB (Destroy GUI)
-- =================================================================
AddButton(SettingsTab, "Destroy GUI", function()
    ScreenGui:Destroy()
end)

print("Animal Hospital Standalone Hub loaded! Click the logo or press RightShift to open.")
```

---