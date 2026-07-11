-- [[ ANIMAL HOSPITAL ANOMALY - HARVEST OVERLORD PACK ]] --
-- Toggle Menu: Click the Draggable Web-Linked Logo or hit RightShift

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Username = LocalPlayer.Name
local GameId = game.PlaceId
local Camera = workspace.CurrentCamera

-- Global Feature Configurations
local Flags = {
    ESP = false,
    FullBright = false,
    InfJump = false,
    Fly = false,
    Spinbot = false,
    AnomalyView = false,
    WalkSpeedActive = false,
    AutoSanity = false,
    AutoLoot = false
}
local MenuOpen = false
local FlySpeed = 45
local TargetSpeedValue = 32

-- Backup lighting settings for FullBright toggle
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient
local OriginalFogEnd = Lighting.FogEnd

-- ScreenGui Core Protect Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HospitalHarvestHub"
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

--------------------------------------------------------------------------
-- 1. DRAGGABLE & RAW WEB-LINK IMAGE TOGGLE ENGINE
--------------------------------------------------------------------------
local MainHub = Instance.new("Frame")

local CustomToggle = Instance.new("ImageButton")
CustomToggle.Name = "DynamicWebMenuIcon"
CustomToggle.Size = UDim2.new(0, 55, 0, 55)
CustomToggle.Position = UDim2.new(0, 25, 0.5, -27)
CustomToggle.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
CustomToggle.Image = "rbxassetid://13410134440"
CustomToggle.Visible = false
CustomToggle.Parent = ScreenGui

Instance.new("UICorner", CustomToggle).CornerRadius = UDim.new(1, 0)
local FrameOutline = Instance.new("UIStroke", CustomToggle)
FrameOutline.Color = Color3.fromRGB(255, 65, 65)
FrameOutline.Thickness = 2

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

--------------------------------------------------------------------------
-- 2. MAIN USER HUB LAYOUT UI
--------------------------------------------------------------------------
local TabContainer = Instance.new("Frame")
local ContentPanels = Instance.new("Frame")

local function BuildInterface()
    MainHub.Size = UDim2.new(0, 550, 0, 390)
    MainHub.Position = UDim2.new(0.5, -275, 0.5, -195)
    MainHub.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    MainHub.BorderSizePixel = 0
    MainHub.Visible = false
    MainHub.Parent = ScreenGui
    Instance.new("UICorner", MainHub).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", MainHub).Color = Color3.fromRGB(45, 45, 55)

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
    InfoLabel.Text = "User: " .. Username .. "  |  Game ID: " .. GameId
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
    
    InputBox.FocusLost:Connect(function(enterPressed)
        if InputBox.Text ~= "" then
            callback(InputBox.Text)
        end
    end)
end

--------------------------------------------------------------------------
-- 3. INTERFACE BUILD & SYSTEM CONTROLS
--------------------------------------------------------------------------
BuildInterface()

local VisualsTab = CreateTab("Target ESP")
local PremiumTab = CreateTab("Donor Options")
local WorldTab = CreateTab("World Assets")
local StatsTab = CreateTab("Stat Exploits")
local AnomalyTab = CreateTab("Anomaly Sim")
local SettingsTab = CreateTab("Settings")

VisualsTab.Visible = true

AddToggle(VisualsTab, "Enable Universal Overhaul ESP", "ESP", function() end)

-- RIGID RED PLASTIC LASER REVOLVER
AddButton(PremiumTab, "Equip Red Blocky Laser Pistol", function()
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

AddToggle(PremiumTab, "Flight Motion Engine", "Fly", function() end)
AddToggle(PremiumTab, "Infinite Jump Physics", "InfJump", function() end)
AddToggle(PremiumTab, "Anti-Aim Spinbot Engine", "Spinbot", function() end)

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
        Lighting.OutdoorAmbient = OriginalOutdoorAmbient
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

-- STAT EXPLOITS TAB (SANITY GIVER + AUTO LOOT)
AddToggle(StatsTab, "Enable Auto-Sanity Giver Loop", "AutoSanity", function() end)
AddToggle(StatsTab, "Enable Auto-Loot Item Vacuum", "AutoLoot", function() end)

AddButton(StatsTab, "Instant Max Sanity Burst", function()
    -- Attempting direct remote remapping for stats
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:match("Sanity") or remote.Name:match("Restore") or remote.Name:match("Heal")) then
            remote:FireServer(100)
            remote:FireServer(true)
        end
    end
    -- Fallback: Fire any proximity prompts associated with recovery items
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and (obj.Parent.Name:match("Sanity") or obj.Parent.Name:match("Med") or obj.Parent.Name:match("Pills")) then
            fireproximityprompt(obj)
        end
    end
end)

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

--------------------------------------------------------------------------
-- 4. ULTRA RUNTIME STEPPED ENGINE
--------------------------------------------------------------------------
RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    local HRP = Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Head")
    local Hum = Char:FindFirstChildOfClass("Humanoid")

    if Hum and Flags.WalkSpeedActive then
        Hum.WalkSpeed = TargetSpeedValue
    end

    if HRP and Flags.Spinbot then
        HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end

    if HRP and Flags.Fly then
        local Vector = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Vector = Vector + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Vector = Vector - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Vector = Vector - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Vector = Vector + Camera.CFrame.RightVector end
        HRP.Velocity = Vector.Unit * FlySpeed
    end

    if Flags.AnomalyView then
        ApplyGlitchAppearance(Char)
    end

    -- Continuous Sanity Recovery Loop
    if Flags.AutoSanity then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local pName = prompt.Parent.Name:lower()
                if pName:match("sanity") or pName:match("pill") or pName:match("med") or pName:match("station") then
                    if HRP and (prompt.Parent:GetPivot().Position - HRP.Position).Magnitude < 25 then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
    end

    -- Continuous Item Loot Vacuum
    if Flags.AutoLoot and HRP then
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Tool") or (item:IsA("Model") and (item.Name:match("Key") or item.Name:match("Item") or item.Name:match("Battery"))) then
                if item:IsA("Tool") and item.Parent ~= LocalPlayer.Backpack and item.Parent ~= Char then
                    item:HandleMoveTo(HRP.Position)
                elseif item:IsA("Model") and item:FindFirstChildOfClass("BasePart") then
                    item:ScaleTo(0.1)
                    item:PivotTo(HRP.CFrame)
                end
            end
        end
    end

    -- HIGH-DENSITY LAYER DISCOVERY ENGINE (ESP)
    if Flags.ESP then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= Char then
                local foundHum = obj:FindFirstChildOfClass("Humanoid")
                local coreNode = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChildOfClass("Part")
                
                if foundHum and coreNode then
                    local associatedPlayer = Players:GetPlayerFromCharacter(obj)
                    
                    if associatedPlayer then
                        if associatedPlayer ~= LocalPlayer and not ScreenGui:FindFirstChild(obj.Name .. "_PESP") then
                            local b = Instance.new("BillboardGui")
                            b.Name = obj.Name .. "_PESP"
                            b.AlwaysOnTop = true
                            b.Size = UDim2.new(0, 100, 0, 20)
                            b.StudsOffset = Vector3.new(0, 3.5, 0)
                            b.Adornee = coreNode
                            b.Parent = ScreenGui

                            local t = Instance.new("TextLabel")
                            t.Size = UDim2.new(1, 0, 1, 0)
                            t.BackgroundTransparency = 1
                            t.Font = Enum.Font.FredokaOne
                            t.TextSize = 11
                            t.TextColor3 = Color3.fromRGB(50, 255, 100)
                            t.Text = associatedPlayer.Name
                            t.Parent = b

                            local high = Instance.new("Highlight")
                            high.Name = "BoxFrame"
                            high.Adornee = obj
                            high.FillTransparency = 1
                            high.OutlineColor = Color3.fromRGB(50, 255, 100)
                            high.OutlineTransparency = 0.2
                            high.Parent = b
                        end
                    else
                        if not ScreenGui:FindFirstChild(obj.Name .. "_MESP") then
                            local b = Instance.new("BillboardGui")
                            b.Name = obj.Name .. "_MESP"
                            b.AlwaysOnTop = true
                            b.Size = UDim2.new(0, 120, 0, 25)
                            b.StudsOffset = Vector3.new(0, 4, 0)
                            b.Adornee = coreNode
                            b.Parent = ScreenGui

                            local t = Instance.new("TextLabel")
                            t.Size = UDim2.new(1, 0, 1, 0)
                            t.BackgroundTransparency = 1
                            t.Font = Enum.Font.FredokaOne
                            t.TextSize = 12
                            t.TextColor3 = Color3.fromRGB(255, 40, 40)
                            t.Text = "[!] ANOMALY: " .. obj.Name
                            t.Parent = b

                            local high = Instance.new("Highlight")
                            high.Name = "BoxFrame"
                            high.Adornee = obj
                            high.FillColor = Color3.fromRGB(255, 40, 40)
                            high.FillTransparency = 0.5
                            high.OutlineColor = Color3.fromRGB(255, 255, 255)
                            high.OutlineTransparency = 0.1
                            high.Parent = b
                        end
                    end
                end
            end
        end
    else
        for _, item in ipairs(ScreenGui:GetChildren()) do
            if item.Name:match("_PESP") or item.Name:match("_MESP") then item:Destroy() end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump then
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChildOfClass("Humanoid") then
            Char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        SetMenuVisibility(not MenuOpen)
    end
end)

SetMenuVisibility(true)