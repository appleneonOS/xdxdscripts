local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UIContainer = pcall(function() return CoreGui end) and CoreGui or PlayerGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local scaleFactor = isMobile and 1.25 or 1.0
local baseWidth, baseHeight = 560 * scaleFactor, 390 * scaleFactor

local States = {
	WalkSpeed = 50,
	SpeedToggle = false,
	InfStamina = false,
	JumpBoost = false,
	JumpPower = 100,
	NoClip = false,
	GodSanity = false,
	PatientESP = false,
	HospitalsAnomalyESP = false,
	ItemsESP = false,
	Fullbright = false,
	NoStatic = false,
	FastInteract = false,
	AutoPromptAura = false,
	PromptRange = 15,
	AntiJumpscare = false,
	
	VipUnlocked = false,
	GodModeInfection = false,
	AutoCleanHazards = false,
	AnomalyKillAura = false,
	KillAuraRange = 25,
	AutoCollectMeds = false,
	GhostModeMonsters = false,
	InstantSafeCracker = false,
	SmartDiagnosisXRay = false,
	AutoEquipDefense = false,
	InfiniteSyringeUse = false,
	NoPatientDegradation = false,
	CustomFOV = 70
}

local CurrentAccent = Color3.fromRGB(40, 160, 110)
local ThemeObjects = {}

local function ApplyTheme(newColor)
	CurrentAccent = newColor
	for _, obj in pairs(ThemeObjects) do
		if obj.Type == "Background" then
			obj.Element.BackgroundColor3 = newColor
		elseif obj.Type == "Text" then
			obj.Element.TextColor3 = newColor
		elseif obj.Type == "Border" then
			obj.Element.BorderColor3 = newColor
		end
	end
end

local HighlightFolder = Instance.new("Folder")
HighlightFolder.Name = "AnimalHospitalHighlights"
HighlightFolder.Parent = UIContainer

local function ClearESP(espType)
	for _, child in ipairs(HighlightFolder:GetChildren()) do
		if child:GetAttribute("ESPType") == espType then
			child:Destroy()
		end
	end
end

local function CreateHighlight(target, espType, fillColor, outlineColor)
	if not target or (not target:IsA("Model") and not target:IsA("BasePart")) then return end
	local targetId = target:GetDebugId()
	local existing = HighlightFolder:FindFirstChild(targetId)
	if existing then 
		existing.FillColor = fillColor
		existing.OutlineColor = outlineColor
		return 
	end

	local h = Instance.new("Highlight")
	h.Name = targetId
	h.Adornee = target
	h.FillColor = fillColor
	h.OutlineColor = outlineColor
	h.FillTransparency = 0.35
	h.OutlineTransparency = 0
	h:SetAttribute("ESPType", espType)
	h.Parent = HighlightFolder
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimalHospitalProPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = UIContainer

local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 85 * scaleFactor, 0, 35 * scaleFactor)
OpenBtn.Position = UDim2.new(0.02, 0, 0.22, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 22)
OpenBtn.BorderColor3 = CurrentAccent
OpenBtn.BorderSizePixel = 2
OpenBtn.Text = "By Mighty"
OpenBtn.TextColor3 = CurrentAccent
OpenBtn.TextSize = 13 * scaleFactor
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)
table.insert(ThemeObjects, {Element = OpenBtn, Type = "Border"})
table.insert(ThemeObjects, {Element = OpenBtn, Type = "Text"})

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, baseWidth, 0, baseHeight)
MainFrame.Position = UDim2.new(0.5, -baseWidth / 2, 0.5, -baseHeight / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 18)
MainFrame.BorderColor3 = Color3.fromRGB(30, 45, 38)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42 * scaleFactor)
TopBar.BackgroundColor3 = Color3.fromRGB(11, 15, 13)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local TopTitle = Instance.new("TextLabel")
TopTitle.Size = UDim2.new(0.85, 0, 1, 0)
TopTitle.Position = UDim2.new(0.03, 0, 0, 0)
TopTitle.BackgroundTransparency = 1
TopTitle.Text = "ANIMAL HOSPITAL [V.2]"
TopTitle.TextColor3 = CurrentAccent
TopTitle.TextSize = 14 * scaleFactor
TopTitle.Font = Enum.Font.GothamBold
TopTitle.TextXAlignment = Enum.TextXAlignment.Left
TopTitle.Parent = TopBar
table.insert(ThemeObjects, {Element = TopTitle, Type = "Text"})

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35 * scaleFactor, 0, 30 * scaleFactor)
CloseBtn.Position = UDim2.new(1, -42 * scaleFactor, 0.5, -15 * scaleFactor)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14 * scaleFactor
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140 * scaleFactor, 1, -42 * scaleFactor)
Sidebar.Position = UDim2.new(0, 0, 0, 42 * scaleFactor)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 17, 15)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)
Instance.new("UIPadding", Sidebar).PaddingLeft = UDim.new(0, 8)
Instance.new("UIPadding", Sidebar).PaddingRight = UDim.new(0, 8)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -150 * scaleFactor, 1, -50 * scaleFactor)
ContentArea.Position = UDim2.new(0, 145 * scaleFactor, 0, 46 * scaleFactor)
ContentArea.BackgroundColor3 = Color3.fromRGB(20, 24, 22)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame
Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 8)

local Tabs = {}
local ActiveTabBtn = nil
local KeyFrame = nil

local function SwitchTab(TabBtn, TabFrame)
	for _, t in pairs(Tabs) do
		t.Btn.BackgroundColor3 = Color3.fromRGB(28, 34, 30)
		t.Btn.TextColor3 = Color3.fromRGB(180, 190, 185)
		t.Frame.Visible = false
	end
	if KeyFrame then KeyFrame.Visible = false end
	ActiveTabBtn = TabBtn
	TabBtn.BackgroundColor3 = CurrentAccent
	TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabFrame.Visible = true
end

local function CreateTab(tabName, order, isVip)
	local TabBtn = Instance.new("TextButton")
	TabBtn.Size = UDim2.new(1, 0, 0, 35 * scaleFactor)
	TabBtn.BackgroundColor3 = isVip and Color3.fromRGB(45, 35, 10) or Color3.fromRGB(28, 34, 30)
	TabBtn.Text = tabName
	TabBtn.TextColor3 = isVip and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(180, 190, 185)
	TabBtn.TextSize = 13 * scaleFactor
	TabBtn.Font = Enum.Font.GothamSemibold
	TabBtn.LayoutOrder = order
	TabBtn.Parent = Sidebar
	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

	local TabFrame = Instance.new("ScrollingFrame")
	TabFrame.Size = UDim2.new(1, -16, 1, -16)
	TabFrame.Position = UDim2.new(0, 8, 0, 8)
	TabFrame.BackgroundTransparency = 1
	TabFrame.BorderSizePixel = 0
	TabFrame.ScrollBarThickness = 5
	TabFrame.Visible = false
	TabFrame.Parent = ContentArea
	
	local FrameLayout = Instance.new("UIListLayout")
	FrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
	FrameLayout.Padding = UDim.new(0, 8)
	FrameLayout.Parent = TabFrame

	TabBtn.MouseButton1Click:Connect(function()
		if isVip and not States.VipUnlocked then
			for _, t in pairs(Tabs) do
				t.Btn.BackgroundColor3 = Color3.fromRGB(28, 34, 30)
				t.Btn.TextColor3 = Color3.fromRGB(180, 190, 185)
				t.Frame.Visible = false
			end
			ActiveTabBtn = TabBtn
			TabBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
			TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			if KeyFrame then KeyFrame.Visible = true end
			return
		end
		SwitchTab(TabBtn, TabFrame)
	end)

	table.insert(Tabs, {Btn = TabBtn, Frame = TabFrame, IsVip = isVip})
	if #Tabs == 1 then
		ActiveTabBtn = TabBtn
		TabBtn.BackgroundColor3 = CurrentAccent
		TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabFrame.Visible = true
		table.insert(ThemeObjects, {Element = TabBtn, Type = "Background"})
	end

	return TabFrame, TabBtn
end

local function CreateStyledButton(parentTab, labelText, defaultColor, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -6, 0, 38 * scaleFactor)
	Btn.BackgroundColor3 = defaultColor or Color3.fromRGB(34, 40, 36)
	Btn.Text = labelText
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.TextSize = 13 * scaleFactor
	Btn.Font = Enum.Font.GothamMedium
	Btn.Parent = parentTab
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

	if callback then
		Btn.MouseButton1Click:Connect(function()
			callback(Btn)
		end)
	end
	return Btn
end

local function CreateToggle(parentTab, labelText, stateKey, callback)
	local Btn = CreateStyledButton(parentTab, labelText .. ": [OFF]", Color3.fromRGB(34, 40, 36))
	Btn.MouseButton1Click:Connect(function()
		States[stateKey] = not States[stateKey]
		Btn.BackgroundColor3 = States[stateKey] and Color3.fromRGB(40, 150, 70) or Color3.fromRGB(34, 40, 36)
		Btn.Text = labelText .. ": " .. (States[stateKey] and "[ON]" or "[OFF]")
		if callback then callback(States[stateKey]) end
	end)
	return Btn
end

local function CreateSlider(parentTab, labelText, stateKey, minVal, maxVal, step)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -6, 0, 42 * scaleFactor)
	Container.BackgroundColor3 = Color3.fromRGB(28, 34, 30)
	Container.Parent = parentTab
	Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.55, 0, 1, 0)
	Label.Position = UDim2.new(0.04, 0, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = labelText .. ": " .. States[stateKey]
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 13 * scaleFactor
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local LessBtn = Instance.new("TextButton")
	LessBtn.Size = UDim2.new(0, 34 * scaleFactor, 0, 28 * scaleFactor)
	LessBtn.Position = UDim2.new(0.65, 0, 0.5, -14 * scaleFactor)
	LessBtn.BackgroundColor3 = Color3.fromRGB(48, 58, 52)
	LessBtn.Text = "-"
	LessBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	LessBtn.TextSize = 16 * scaleFactor
	LessBtn.Font = Enum.Font.GothamBold
	LessBtn.Parent = Container

	local MoreBtn = Instance.new("TextButton")
	MoreBtn.Size = UDim2.new(0, 34 * scaleFactor, 0, 28 * scaleFactor)
	MoreBtn.Position = UDim2.new(0.82, 0, 0.5, -14 * scaleFactor)
	MoreBtn.BackgroundColor3 = Color3.fromRGB(48, 58, 52)
	MoreBtn.Text = "+"
	MoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	MoreBtn.TextSize = 16 * scaleFactor
	MoreBtn.Font = Enum.Font.GothamBold
	MoreBtn.Parent = Container

	Instance.new("UICorner", LessBtn).CornerRadius = UDim.new(0, 6)
	Instance.new("UICorner", MoreBtn).CornerRadius = UDim.new(0, 6)

	LessBtn.MouseButton1Click:Connect(function()
		States[stateKey] = math.clamp(States[stateKey] - step, minVal, maxVal)
		Label.Text = labelText .. ": " .. States[stateKey]
	end)

	MoreBtn.MouseButton1Click:Connect(function()
		States[stateKey] = math.clamp(States[stateKey] + step, minVal, maxVal)
		Label.Text = labelText .. ": " .. States[stateKey]
	end)
end

local MoveTab = CreateTab("Movement", 1, false)
CreateToggle(MoveTab, "Infinite Stamina & Boost", "InfStamina")
CreateToggle(MoveTab, "Speed Override Toggle", "SpeedToggle")
CreateSlider(MoveTab, "WalkSpeed Target", "WalkSpeed", 16, 250, 10)
CreateToggle(MoveTab, "Jump Boost Override", "JumpBoost")
CreateSlider(MoveTab, "JumpPower Target", "JumpPower", 50, 300, 25)
CreateToggle(MoveTab, "NoClip (Pass Walls)", "NoClip")
CreateToggle(MoveTab, "Sanity Freeze (God Mode)", "GodSanity")

local VisualsTab = CreateTab("Visuals", 2, false)
CreateToggle(VisualsTab, "Esp Anomalies & Fake Patients", "PatientESP", function(state) if not state then ClearESP("Patient") end end)
CreateToggle(VisualsTab, "Esp Hospital Slime/Hazards", "HospitalsAnomalyESP", function(state) if not state then ClearESP("HospitalAnomaly") end end)
CreateToggle(VisualsTab, "Esp Meds / Safes / Weapons", "ItemsESP", function(state) if not state then ClearESP("Item") end end)
CreateToggle(VisualsTab, "Fullbright (No Dark Rooms)", "Fullbright", function(state) if not state then Lighting.Brightness = 1 Lighting.ClockTime = 14 end end)
CreateToggle(VisualsTab, "Disable Static & Cam Grain", "NoStatic")

local WorldTab = CreateTab("World", 3, false)
CreateToggle(WorldTab, "Instant Proximity Interact", "FastInteract")
CreateToggle(WorldTab, "Auto-Aura Interact Prompts", "AutoPromptAura")
CreateSlider(WorldTab, "Aura Prompt Range", "PromptRange", 5, 50, 5)
CreateToggle(WorldTab, "Anti-Jumpscare Shield", "AntiJumpscare")

local GearTab = CreateTab("Hospital Gear", 4, false)
local SelectedTool = nil
local DetectedToolsList = {}
local DropdownOpen = false

local ScanBtn = CreateStyledButton(GearTab, "🔄 Scan Hospital Meds & Tools", Color3.fromRGB(34, 40, 36))
local DropdownBtn = CreateStyledButton(GearTab, "Select Tool: [Click to Open Dropdown] ▼", Color3.fromRGB(34, 40, 36))

local DropdownContainer = Instance.new("ScrollingFrame")
DropdownContainer.Size = UDim2.new(1, -6, 0, 130 * scaleFactor)
DropdownContainer.BackgroundColor3 = Color3.fromRGB(22, 26, 24)
DropdownContainer.BorderSizePixel = 1
DropdownContainer.BorderColor3 = Color3.fromRGB(45, 60, 50)
DropdownContainer.ScrollBarThickness = 6
DropdownContainer.Visible = false
DropdownContainer.Parent = GearTab
Instance.new("UICorner", DropdownContainer).CornerRadius = UDim.new(0, 6)

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Padding = UDim.new(0, 4)
DropdownLayout.Parent = DropdownContainer
Instance.new("UIPadding", DropdownContainer).PaddingTop = UDim.new(0, 4)
Instance.new("UIPadding", DropdownContainer).PaddingLeft = UDim.new(0, 4)

local GiveBtn = CreateStyledButton(GearTab, "🎁 Equip / Claim Selected Item", Color3.fromRGB(40, 150, 70))

local function PopulateDropdown()
	for _, child in pairs(DropdownContainer:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	DetectedToolsList = {}
	
	for _, place in pairs({Workspace, ReplicatedStorage, Lighting}) do
		pcall(function()
			for _, item in pairs(place:GetDescendants()) do
				if item:IsA("Tool") then
					table.insert(DetectedToolsList, item)
				end
			end
		end)
	end
	
	for _, tool in pairs(DetectedToolsList) do
		local itemBtn = Instance.new("TextButton")
		itemBtn.Size = UDim2.new(1, -10, 0, 30 * scaleFactor)
		itemBtn.BackgroundColor3 = Color3.fromRGB(34, 40, 36)
		itemBtn.Text = "  🩹 " .. tool.Name .. " (" .. tool.Parent.Name .. ")"
		itemBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
		itemBtn.Font = Enum.Font.GothamMedium
		itemBtn.TextSize = 12 * scaleFactor
		itemBtn.TextXAlignment = Enum.TextXAlignment.Left
		itemBtn.Parent = DropdownContainer
		Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)
		
		itemBtn.MouseButton1Click:Connect(function()
			SelectedTool = tool
			DropdownBtn.Text = "Selected Tool: [" .. tool.Name .. "] ▼"
			DropdownOpen = false
			DropdownContainer.Visible = false
		end)
	end
	DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, #DetectedToolsList * 34)
	if #DetectedToolsList == 0 then
		DropdownBtn.Text = "No Meds Found (Click Scan First)"
	end
end

ScanBtn.MouseButton1Click:Connect(function()
	ScanBtn.Text = "🔄 Scanning Hospital Areas..."
	PopulateDropdown()
	task.wait(0.2)
	ScanBtn.Text = "🔄 Scan Hospital Meds & Tools (" .. #DetectedToolsList .. " Found)"
end)

DropdownBtn.MouseButton1Click:Connect(function()
	DropdownOpen = not DropdownOpen
	DropdownContainer.Visible = DropdownOpen
	if DropdownOpen and #DetectedToolsList == 0 then
		PopulateDropdown()
	end
end)

GiveBtn.MouseButton1Click:Connect(function()
	if SelectedTool then
		pcall(function()
			local clone = SelectedTool:Clone()
			clone.Parent = LocalPlayer:WaitForChild("Backpack")
		end)
		if SelectedTool.Parent and SelectedTool:IsDescendantOf(Workspace) then
			pcall(function() SelectedTool.Parent = LocalPlayer.Character end)
		end
	end
end)

local VipTab, VipTabBtn = CreateTab("VIP 🔒", 5, true)
CreateToggle(VipTab, "👑 God Mode & Infection Immunity", "GodModeInfection")
CreateToggle(VipTab, "👑 Auto-Clean Slime & Hazards", "AutoCleanHazards")
CreateToggle(VipTab, "👑 Anomaly Kill Aura & Defend", "AnomalyKillAura")
CreateSlider(VipTab, "👑 Anomaly Kill Aura Range", "KillAuraRange", 10, 80, 5)
CreateToggle(VipTab, "👑 Auto-Collect All Medical Supplies", "AutoCollectMeds")
CreateToggle(VipTab, "👑 Ghost Mode (Invisible to Monsters)", "GhostModeMonsters", function(state)
	local char = LocalPlayer.Character
	if char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = state and 1 or 0
			end
		end
	end
end)
CreateToggle(VipTab, "👑 Instant Safe & Lock Cracker", "InstantSafeCracker")
CreateToggle(VipTab, "👑 Smart Diagnosis X-Ray (Show Sickness)", "SmartDiagnosisXRay")
CreateToggle(VipTab, "👑 Auto-Equip Gun/Weapon on Threat", "AutoEquipDefense")
CreateToggle(VipTab, "👑 Infinite Syringe / Med Uses", "InfiniteSyringeUse")
CreateToggle(VipTab, "👑 Freeze Patient Health Degradation", "NoPatientDegradation")
CreateSlider(VipTab, "👑 Hospital Field of View Override", "CustomFOV", 50, 120, 5)

CreateStyledButton(VipTab, "⚡ Instant Cure All Nearby Animal Patients", Color3.fromRGB(40, 150, 70), function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= char then
			local n = string.lower(obj.Name)
			if string.find(n, "patient") or string.find(n, "animal") or obj:GetAttribute("IsPatient") then
				for _, prompt in pairs(obj:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") then
						fireproximityprompt(prompt)
					end
				end
				pcall(function()
					obj:SetAttribute("Cured", true)
					obj:SetAttribute("Sickness", "None")
					obj:SetAttribute("Health", 100)
				end)
			end
		end
	end
end)

CreateStyledButton(VipTab, "⚡ Teleport to Emergency Safe Room", Color3.fromRGB(160, 110, 20), function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local safeTarget = nil
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local n = string.lower(obj.Name)
			if string.find(n, "saferoom") or string.find(n, "security") or string.find(n, "lobby") or string.find(n, "spawn") then
				safeTarget = obj
				break
			end
		end
	end
	if safeTarget then
		hrp.CFrame = safeTarget.CFrame + Vector3.new(0, 4, 0)
	else
		hrp.CFrame = CFrame.new(0, 50, 0)
	end
end)

CreateStyledButton(VipTab, "⚡ Destroy All Infected / Monster Mimics", Color3.fromRGB(180, 50, 50), function()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			local n = string.lower(obj.Name)
			if string.find(n, "anomaly") or string.find(n, "mimic") or string.find(n, "monster") or string.find(n, "infected") or obj:GetAttribute("IsBad") then
				obj:Destroy()
			end
		end
	end
end)

CreateStyledButton(VipTab, "⚡ Remove All Locked Hospital Doors & Barriers", Color3.fromRGB(160, 110, 20), function()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local n = string.lower(obj.Name)
			if string.find(n, "door") or string.find(n, "gate") or string.find(n, "lock") or string.find(n, "barrier") or string.find(n, "window") or string.find(n, "glass") then
				obj:Destroy()
			end
		end
	end
end)
 
KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(1, -16, 1, -16)
KeyFrame.Position = UDim2.new(0, 8, 0, 8)
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 22)
KeyFrame.BorderColor3 = Color3.fromRGB(215, 170, 20)
KeyFrame.BorderSizePixel = 2
KeyFrame.Visible = false
KeyFrame.Parent = ContentArea
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 8)
 
local KeyCloseBtn = Instance.new("TextButton")
KeyCloseBtn.Size = UDim2.new(0, 30 * scaleFactor, 0, 30 * scaleFactor)
KeyCloseBtn.Position = UDim2.new(1, -35 * scaleFactor, 0, 5 * scaleFactor)
KeyCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
KeyCloseBtn.Text = "X"
KeyCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyCloseBtn.Font = Enum.Font.GothamBold
KeyCloseBtn.TextSize = 14 * scaleFactor
KeyCloseBtn.Parent = KeyFrame
Instance.new("UICorner", KeyCloseBtn).CornerRadius = UDim.new(0, 6)
 
KeyCloseBtn.MouseButton1Click:Connect(function()
	KeyFrame.Visible = false
	SwitchTab(Tabs[1].Btn, Tabs[1].Frame)
end)
 
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35 * scaleFactor)
KeyTitle.Position = UDim2.new(0, 0, 0.05, 0)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔒 VIP RESTRICTED ACCESS"
KeyTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 16 * scaleFactor
KeyTitle.Parent = KeyFrame
 
local KeyHint = Instance.new("TextLabel")
KeyHint.Size = UDim2.new(0.9, 0, 0, 45 * scaleFactor)
KeyHint.Position = UDim2.new(0.05, 0, 0.22, 0)
KeyHint.BackgroundTransparency = 1
KeyHint.Text = "find the creator you must find it to achieve the key"
KeyHint.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyHint.Font = Enum.Font.GothamMedium
KeyHint.TextSize = 12 * scaleFactor
KeyHint.TextWrapped = true
KeyHint.Parent = KeyFrame
 
local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 40 * scaleFactor)
KeyInput.Position = UDim2.new(0.1, 0, 0.48, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 36, 32)
KeyInput.BorderColor3 = Color3.fromRGB(70, 95, 80)
KeyInput.PlaceholderText = "Enter VIP Key Here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamBold
KeyInput.TextSize = 14 * scaleFactor
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
 
local KeySubmit = Instance.new("TextButton")
KeySubmit.Size = UDim2.new(0.6, 0, 0, 38 * scaleFactor)
KeySubmit.Position = UDim2.new(0.2, 0, 0.73, 0)
KeySubmit.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
KeySubmit.Text = "UNLOCK VIP FEATURES"
KeySubmit.TextColor3 = Color3.fromRGB(255, 255, 255)
KeySubmit.Font = Enum.Font.GothamBold
KeySubmit.TextSize = 13 * scaleFactor
KeySubmit.Parent = KeyFrame
Instance.new("UICorner", KeySubmit).CornerRadius = UDim.new(0, 6)
 
KeySubmit.MouseButton1Click:Connect(function()
	if KeyInput.Text == "Mighty901" then
		KeySubmit.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
		KeySubmit.Text = "KEY ACCEPTED! UNLOCKING..."
		task.wait(0.5)
		States.VipUnlocked = true
		VipTabBtn.Text = "VIP 👑"
		VipTabBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
		KeyFrame.Visible = false
		SwitchTab(VipTabBtn, VipTab)
	else
		KeySubmit.BackgroundColor3 = Color3.fromRGB(200, 45, 45)
		KeySubmit.Text = "INVALID KEY! TRY AGAIN"
		task.wait(1)
		KeySubmit.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
		KeySubmit.Text = "UNLOCK VIP FEATURES"
	end
end)
 
local SettingsTab = CreateTab("Settings", 6, false)
 
local function CreateThemeToggle(name, color)
	local tBtn = CreateStyledButton(SettingsTab, "Apply Theme: " .. name, Color3.fromRGB(34, 40, 36))
	tBtn.MouseButton1Click:Connect(function()
		ApplyTheme(color)
		if ActiveTabBtn and ActiveTabBtn ~= VipTabBtn then ActiveTabBtn.BackgroundColor3 = color end
	end)
end
 
CreateThemeToggle("Hospital Green (Default)", Color3.fromRGB(40, 160, 110))
CreateThemeToggle("Pro Blue", Color3.fromRGB(60, 95, 220))
CreateThemeToggle("Crimson Emergency Red", Color3.fromRGB(210, 45, 45))
CreateThemeToggle("Midnight Purple", Color3.fromRGB(140, 50, 220))
CreateThemeToggle("Gold VIP", Color3.fromRGB(230, 170, 20))
 
CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	OpenBtn.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	OpenBtn.Visible = false
end)
 
RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
 
	if hum then
		if States.SpeedToggle then hum.WalkSpeed = States.WalkSpeed end
		if States.JumpBoost then hum.JumpPower = States.JumpPower end
		if States.GodModeInfection then 
			hum.Health = hum.MaxHealth 
			LocalPlayer:SetAttribute("Infected", false)
			LocalPlayer:SetAttribute("InfectionLevel", 0)
		end
	end
 
	if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = States.CustomFOV end
 
	if States.InfStamina then
		LocalPlayer:SetAttribute("Stamina", 100)
		LocalPlayer:SetAttribute("MaxStamina", 100)
		LocalPlayer:SetAttribute("SpeedBoost", 9999)
	end
	if States.GodSanity then LocalPlayer:SetAttribute("Sanity", 100) end
	if States.NoClip and char then
		for _, part in pairs(char:GetChildren()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	if States.Fullbright then
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
	end
 
	if States.AnomalyKillAura and hrp then
		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj ~= char then
				local n = string.lower(obj.Name)
				if string.find(n, "anomaly") or string.find(n, "mimic") or string.find(n, "monster") or string.find(n, "infected") or obj:GetAttribute("IsBad") then
					local targetPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChildOfClass("BasePart")
					if targetPart and (targetPart.Position - hrp.Position).Magnitude <= States.KillAuraRange then
						local targetHum = obj:FindFirstChildOfClass("Humanoid")
						if targetHum then targetHum.Health = 0 end
						pcall(function() obj:Destroy() end)
					end
				end
			end
		end
	end
 
	if States.AutoEquipDefense and hrp and LocalPlayer:FindFirstChild("Backpack") then
		local threatNear = false
		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj ~= char then
				local n = string.lower(obj.Name)
				if (string.find(n, "anomaly") or string.find(n, "monster") or string.find(n, "mimic") or obj:GetAttribute("IsBad")) then
					local tp = obj:FindFirstChildOfClass("BasePart")
					if tp and (tp.Position - hrp.Position).Magnitude < 30 then
						threatNear = true
						break
					end
				end
			end
		end
		if threatNear then
			for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
				if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "gun") or string.find(string.lower(tool.Name), "weapon") or string.find(string.lower(tool.Name), "bat") or string.find(string.lower(tool.Name), "taser")) then
					tool.Parent = char
					break
				end
			end
		end
	end
end)
 
task.spawn(function()
	while task.wait(0.4) do
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
 
		for _, prompt in pairs(Workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				if States.FastInteract then prompt.HoldDuration = 0 end
				if States.AutoPromptAura and hrp and prompt.Parent and prompt.Parent:IsA("BasePart") then
					if (prompt.Parent.Position - hrp.Position).Magnitude <= States.PromptRange then
						fireproximityprompt(prompt)
					end
				end
				if States.InstantSafeCracker and prompt.Parent and string.find(string.lower(prompt.Parent.Name), "safe") then
					prompt.HoldDuration = 0
					if hrp and (prompt.Parent.Position - hrp.Position).Magnitude < 20 then
						fireproximityprompt(prompt)
					end
				end
			end
		end
 
		if States.AutoCleanHazards then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") or obj:IsA("Model") then
					local n = string.lower(obj.Name)
					if string.find(n, "slime") or string.find(n, "puddle") or string.find(n, "goop") or string.find(n, "parasite") or string.find(n, "hazard") or string.find(n, "eye") or obj:GetAttribute("IsHazard") then
						pcall(function() obj:Destroy() end)
					end
				end
			end
		end
 
		if States.AutoCollectMeds and hrp then
			for _, item in pairs(Workspace:GetDescendants()) do
				if (item:IsA("Tool") or item:IsA("BasePart")) and not item:IsDescendantOf(char) then
					local n = string.lower(item.Name)
					if string.find(n, "med") or string.find(n, "bandage") or string.find(n, "herb") or string.find(n, "syrup") or string.find(n, "ointment") or string.find(n, "thermo") or string.find(n, "cure") or string.find(n, "kit") then
						local part = item:IsA("Tool") and item:FindFirstChild("Handle") or item
						if part and part:IsA("BasePart") and not part.Anchored and (part.Position - hrp.Position).Magnitude < 120 then
							part.CFrame = hrp.CFrame
						end
					end
				end
			end
		end
 
		if States.InfiniteSyringeUse and char then
			for _, tool in pairs(char:GetChildren()) do
				if tool:IsA("Tool") then
					pcall(function()
						tool:SetAttribute("Uses", 999)
						tool:SetAttribute("Ammo", 999)
						tool:SetAttribute("Quantity", 999)
					end)
				end
			end
		end
 
		if States.NoPatientDegradation then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") and (string.find(string.lower(obj.Name), "patient") or obj:GetAttribute("IsPatient")) then
					pcall(function()
						obj:SetAttribute("DegradationRate", 0)
						if obj:GetAttribute("Health") and obj:GetAttribute("Health") < 50 then
							obj:SetAttribute("Health", 80)
						end
					end)
				end
			end
		end
 
		if States.SmartDiagnosisXRay then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") and obj ~= char and (string.find(string.lower(obj.Name), "patient") or obj:GetAttribute("IsPatient")) then
					local head = obj:FindFirstChild("Head") or obj:FindFirstChildOfClass("BasePart")
					if head and not head:FindFirstChild("DiagnosisUI") then
						local bg = Instance.new("BillboardGui")
						bg.Name = "DiagnosisUI"
						bg.Adornee = head
						bg.Size = UDim2.new(0, 130, 0, 45)
						bg.Stubbornness = 1
						bg.AlwaysOnTop = true
						bg.Parent = head
 
						local lbl = Instance.new("TextLabel")
						lbl.Size = UDim2.new(1, 0, 1, 0)
						lbl.BackgroundTransparency = 0.3
						lbl.BackgroundColor3 = Color3.fromRGB(15, 20, 18)
						lbl.TextColor3 = Color3.fromRGB(0, 255, 120)
						lbl.TextSize = 11
						lbl.Font = Enum.Font.GothamBold
						lbl.Text = "Diagnosis: Scanning..."
						lbl.Parent = bg
						Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 4)
					elseif head and head:FindFirstChild("DiagnosisUI") then
						local lbl = head.DiagnosisUI:FindFirstChildOfClass("TextLabel")
						if lbl then
							local sick = obj:GetAttribute("Sickness") or obj:GetAttribute("Disease") or "Needs Checkup"
							local hp = obj:GetAttribute("Health") or 100
							lbl.Text = "Status: " .. tostring(sick) .. "\nHP: " .. tostring(hp) .. "%"
							if string.find(string.lower(tostring(sick)), "anomaly") or string.find(string.lower(tostring(sick)), "mimic") then
								lbl.TextColor3 = Color3.fromRGB(255, 50, 50)
								lbl.Text = "⚠️ FAKE / ANOMALY ⚠️"
							else
								lbl.TextColor3 = Color3.fromRGB(0, 255, 120)
							end
						end
					end
				end
			end
		end
 
		if States.PatientESP then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") and obj ~= LocalPlayer.Character then
					local lowerName = string.lower(obj.Name)
					if string.find(lowerName, "patient") or string.find(lowerName, "animal") or obj:GetAttribute("IsPatient") then
						local isAnomaly = string.find(lowerName, "anomaly") or string.find(lowerName, "mimic") or obj:GetAttribute("IsBad")
						CreateHighlight(obj, "Patient", isAnomaly and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(40, 200, 255), Color3.fromRGB(255, 255, 255))
					end
				end
			end
		end
 
		if States.HospitalsAnomalyESP then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") or obj:IsA("BasePart") then
					local lowerName = string.lower(obj.Name)
					if string.find(lowerName, "hazard") or string.find(lowerName, "slime") or string.find(lowerName, "parasite") or obj:GetAttribute("IsHazard") then
						CreateHighlight(obj, "HospitalAnomaly", Color3.fromRGB(200, 50, 255), Color3.fromRGB(255, 255, 255))
					end
				end
			end
		end
 
		if States.ItemsESP then
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Tool") or (obj:IsA("Model") and (string.find(string.lower(obj.Name), "safe") or string.find(string.lower(obj.Name), "med") or string.find(string.lower(obj.Name), "chest"))) then
					CreateHighlight(obj, "Item", Color3.fromRGB(255, 200, 40), Color3.fromRGB(255, 255, 255))
				end
			end
		end
	end
end)