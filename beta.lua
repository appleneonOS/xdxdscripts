-- [[ ANIMAL HOSPITAL – WINDUI + ALL FEATURES ]] --
-- Toggle Menu: Click the draggable logo or press RightShift

-- ========== 1. LOAD WINDUI ==========
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main_example.lua"))()

-- ========== 2. CREATE GUI CONTAINER (EARLY) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimalHospitalHub"
ScreenGui.ResetOnSpawn = false
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- ========== 3. BUILD WINDOW & TABS (IMMEDIATELY) ==========
local Window = WindUI:CreateWindow({
    Title = "Animal Hospital",
    Icon = "stethoscope",
    Author = "Shellaes",
    Folder = "AnimalHospital_Configs",
    Size = UDim2.new(0, 550, 0, 480),
    Transparent = false,
    Parent = ScreenGui
})

-- Create tabs (they exist now, ready for interaction)
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "sword" })
local WorldTab = Window:Tab({ Title = "World", Icon = "globe" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local LoaderTab = Window:Tab({ Title = "Pastebin Loader", Icon = "code" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ========== 4. NOW LOAD SERVICES & CONFIGURATIONS ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global cheat states
local Cheats = {
    AutoWork = false,
    InfiniteSanity = false,
    AnomalySensor = false,
    Speed = false,
    Fly = false,
    AutoLoot = false,
    DoorBypass = false,
    FullBright = false,
    InfJump = false,
    Spinbot = false,
    AutoHeartbeat = false,
    InstantPrompts = false,
}

-- Settings
local SpeedValue = 32
local FlySpeed = 45

-- Backup lighting
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoor = Lighting.OutdoorAmbient
local OriginalFog = Lighting.FogEnd

-- ========== 5. POPULATE TABS WITH CONTROLS ==========
-- Main Tab
MainTab:Paragraph({
    Title = "Welcome to Animal Hospital",
    Content = "Toggle cheats below. Some features require you to be in-game."
})

MainTab:Toggle({
    Title = "Auto Work (Treat Patients)",
    Desc = "Automatically interacts with patients and medical stations",
    Value = false,
    Callback = function(state) Cheats.AutoWork = state end
})

MainTab:Toggle({
    Title = "Infinite Sanity",
    Desc = "Keeps your sanity at maximum",
    Value = false,
    Callback = function(state) Cheats.InfiniteSanity = state end
})

MainTab:Toggle({
    Title = "Auto Loot (Vacuum)",
    Desc = "Pulls all tools and items to you",
    Value = false,
    Callback = function(state) Cheats.AutoLoot = state end
})

MainTab:Toggle({
    Title = "Auto Heartbeat Minigame",
    Desc = "Automatically completes the heartbeat minigame when it appears",
    Value = false,
    Callback = function(state)
        Cheats.AutoHeartbeat = state
        if state then SetupAutoHeartbeat() else CleanupAutoHeartbeat() end
    end
})

MainTab:Toggle({
    Title = "Instant Proximity Prompts",
    Desc = "All proximity prompts activate instantly without holding",
    Value = false,
    Callback = function(state)
        Cheats.InstantPrompts = state
        if state then SetupInstantPrompts() else CleanupInstantPrompts() end
    end
})

-- Combat Tab
CombatTab:Toggle({
    Title = "Spinbot (Anti-Aim)",
    Desc = "Continuously rotates your character",
    Value = false,
    Callback = function(state) Cheats.Spinbot = state end
})

-- World Tab
WorldTab:Toggle({
    Title = "Speed Modifier",
    Desc = "Changes your walkspeed",
    Value = false,
    Callback = function(state) Cheats.Speed = state end
})

WorldTab:Slider({
    Title = "Speed Value",
    Desc = "Adjust walkspeed (default 16)",
    Min = 16,
    Max = 200,
    Default = 32,
    Callback = function(value) SpeedValue = value end
})

WorldTab:Toggle({
    Title = "Fly",
    Desc = "Toggle flight (WASD to move)",
    Value = false,
    Callback = function(state) Cheats.Fly = state end
})

WorldTab:Slider({
    Title = "Fly Speed",
    Desc = "Adjust flight speed",
    Min = 10,
    Max = 200,
    Default = 45,
    Callback = function(value) FlySpeed = value end
})

WorldTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump infinitely",
    Value = false,
    Callback = function(state) Cheats.InfJump = state end
})

WorldTab:Button({
    Title = "Bypass All Doors",
    Desc = "Makes all doors non-collidable and transparent",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:match("Door") or obj.Name:match("Gate")) then
                obj.CanCollide = false
                obj.Transparency = 0.5
            end
        end
        print("Doors bypassed!")
    end
})

-- Visuals Tab
VisualsTab:Toggle({
    Title = "Anomaly Sensor",
    Desc = "Highlights NPCs: Red = Anomalous, Green = Normal",
    Value = false,
    Callback = function(state)
        Cheats.AnomalySensor = state
        if state then
            ApplyAnomalyHighlights()
            if not _G.npcConnection then
                _G.npcConnection = Workspace.NPCs.ChildAdded:Connect(function(instance)
                    if Cheats.AnomalySensor then HighlightNPC(instance) end
                end)
            end
        else
            for _, child in ipairs(Workspace.NPCs:GetChildren()) do ClearHighlights(child) end
            if _G.npcConnection then _G.npcConnection:Disconnect(); _G.npcConnection = nil end
        end
    end
})

VisualsTab:Toggle({
    Title = "FullBright",
    Desc = "Removes fog and darkness",
    Value = false,
    Callback = function(state)
        Cheats.FullBright = state
        if state then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.FogEnd = 999999
        else
            Lighting.Ambient = OriginalAmbient
            Lighting.OutdoorAmbient = OriginalOutdoor
            Lighting.FogEnd = OriginalFog
        end
    end
})

-- Loader Tab
LoaderTab:Paragraph({
    Title = "Pastebin Script Loader",
    Content = "Paste raw Lua script code from Pastebin or other sources and click 'Execute Script' to run it."
})

LoaderTab:Textbox({
    Title = "Script Code",
    Desc = "Paste the raw Lua script here",
    Value = "",
    Callback = function(text) _G.pastedScript = text end
})

LoaderTab:Button({
    Title = "Execute Script",
    Desc = "Runs the pasted Lua code",
    Callback = function()
        local code = _G.pastedScript
        if code and code ~= "" then
            local success, err = pcall(function() loadstring(code)() end)
            if success then print("Pasted script executed successfully!") else warn("Failed: " .. tostring(err)) end
        else
            print("Please paste some Lua code first.")
        end
    end
})

LoaderTab:Button({
    Title = "Load from URL (Raw)",
    Desc = "Fetches and runs script from a raw Pastebin URL",
    Callback = function()
        local url = _G.cheatURL
        if url and url ~= "" then
            local success, err = pcall(function()
                local code = game:HttpGet(url)
                loadstring(code)()
            end)
            if success then print("Loaded from URL successfully!") else warn("Failed: " .. tostring(err)) end
        else
            print("Please enter a URL in the Settings tab first.")
        end
    end
})

-- Settings Tab
SettingsTab:Paragraph({
    Title = "Settings & URL Loader",
    Content = "Enter a raw Pastebin URL to load scripts remotely."
})

SettingsTab:Textbox({
    Title = "Raw Script URL",
    Desc = "Paste the raw Pastebin URL (e.g., https://pastebin.com/raw/xxxx)",
    Value = "",
    Callback = function(text) _G.cheatURL = text end
})

SettingsTab:Button({
    Title = "Destroy GUI",
    Desc = "Removes the entire interface",
    Callback = function()
        ScreenGui:Destroy()
        Window:Destroy()
    end
})

-- ========== 6. FEATURE IMPLEMENTATIONS (DEFINED AFTER UI) ==========
-- Helper functions for Anomaly Sensor
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
    if not Workspace:FindFirstChild("NPCs") then
        warn("workspace.NPCs not found – sensor disabled")
        return
    end
    for _, v in ipairs(Workspace.NPCs:GetChildren()) do
        HighlightNPC(v)
    end
end

-- Auto Heartbeat
local heartbeatConnection = nil
local function SetupAutoHeartbeat()
    if heartbeatConnection then return end
    local Net = ReplicatedStorage:FindFirstChild("Net")
    if not Net then warn("Auto Heartbeat: 'Net' folder not found") return end
    local heartbeatEvent = Net:FindFirstChild("RE/StartHeartbeatMinigame")
    local completeEvent = Net:FindFirstChild("RE/HeartbeatMinigameComplete")
    if not heartbeatEvent or not completeEvent then
        warn("Auto Heartbeat: Remote events not found")
        return
    end
    heartbeatConnection = heartbeatEvent.OnClientEvent:Connect(function()
        if Cheats.AutoHeartbeat then
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
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then SetPromptInstant(prompt) end
    end
end

local function RestoreAllPrompts()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then RestorePrompt(prompt) end
    end
end

local function SetupInstantPrompts()
    if promptConnection then return end
    ApplyInstantToAllPrompts()
    promptConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
        if Cheats.InstantPrompts then SetPromptInstant(prompt) end
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

-- ========== 7. CORE CHEAT ENGINE (RUNS CONTINUOUSLY) ==========
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Speed
    if Cheats.Speed then hum.WalkSpeed = SpeedValue end

    -- Spinbot
    if Cheats.Spinbot then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end

    -- Fly
    if Cheats.Fly then
        local vel = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector end
        if vel.Magnitude > 0 then hrp.Velocity = vel.Unit * FlySpeed end
    end

    -- Auto Loot
    if Cheats.AutoLoot then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") and obj.Parent ~= LocalPlayer.Backpack and obj.Parent ~= character then
                obj:HandleMoveTo(hrp.Position)
            elseif obj:IsA("Model") and (obj.Name:match("Key") or obj.Name:match("Item") or obj.Name:match("Battery")) then
                local primary = obj:FindFirstChildOfClass("BasePart")
                if primary then obj:PivotTo(hrp.CFrame * CFrame.new(0, -2, 0)) end
            end
        end
    end

    -- Infinite Sanity
    if Cheats.InfiniteSanity then
        local sanity = character:FindFirstChild("Sanity") or character:FindFirstChild("Stats")
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

    -- Auto Work
    if Cheats.AutoWork then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local parent = prompt.Parent
                if parent and (parent.Name:match("Patient") or parent.Name:match("Bed") or parent.Name:match("Station")) then
                    if (parent:GetPivot().Position - hrp.Position).Magnitude < 15 then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Cheats.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump = true
    end
end)

print("Animal Hospital Hub loaded! Press RightShift to toggle menu.")