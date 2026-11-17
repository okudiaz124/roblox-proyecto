--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Flashlight = require(script.Parent.Flashlight)
local OpeningSettings = require(script.Parent.OpeningSettings)
local Atmosphere = require(script.Parent.Atmosphere)
local ExpeditionHUD = require(script.Parent.ExpeditionHUD)
local lockMovement = require(script.Parent.MovementLock)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Location = require(shared:WaitForChild("Location"))
local dialogue = require(shared:WaitForChild("Dialogue"))
local round = shared:WaitForChild("Expedition") :: Folder
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GameUI") :: ScreenGui
local options = OpeningSettings.mount(gui)
local duration = Location.Duration
local audio = Atmosphere.start(round, player, options)
audio.prepare(dialogue)

local function hideDefaultInventory()
	for _ = 1, 15 do
		if pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Backpack, false) then return end
		task.wait(0.15)
	end
end
task.spawn(hideDefaultInventory)

player.CameraMode = Enum.CameraMode.LockFirstPerson

local fade = Instance.new("Frame")
fade.Name = "OpeningFade"
fade.Size = UDim2.fromScale(1, 1)
fade.BackgroundColor3 = Color3.new(0, 0, 0)
fade.BorderSizePixel = 0
fade.ZIndex = 20
fade.Parent = gui

local caption = Instance.new("TextLabel")
caption.Name = "OpeningSubtitle"
caption.AnchorPoint = Vector2.new(0.5, 1)
caption.Position = UDim2.fromScale(0.5, 0.9)
caption.Size = UDim2.new(0.84, 0, 0, 75)
caption.BackgroundTransparency = 1
caption.Text = ""
caption.TextColor3 = Color3.fromRGB(255, 242, 222)
caption.TextStrokeColor3 = Color3.new(0, 0, 0)
caption.TextStrokeTransparency = 0.08
caption.TextWrapped = true
caption.TextScaled = true
caption.Font = Enum.Font.GothamMedium
caption.ZIndex = 19
caption.Parent = gui
local limits = Instance.new("UITextSizeConstraint")
limits.MinTextSize = 12
limits.MaxTextSize = 24
limits.Parent = caption

local phone = Instance.new("TextLabel")
phone.Name = "PhoneNoSignal"
phone.AnchorPoint = Vector2.new(0.5, 0.5)
phone.Position, phone.Size = UDim2.fromScale(0.64, 0.67), UDim2.fromOffset(119, 154)
phone.BackgroundColor3, phone.BorderSizePixel = Color3.fromRGB(24, 26, 29), 0
phone.Text, phone.TextColor3 = "SIN SEÑAL", Color3.fromRGB(228, 224, 211)
phone.Font, phone.TextSize, phone.ZIndex = Enum.Font.GothamBold, 14, 18
phone.Rotation, phone.Visible = -7, false
phone.Parent = gui
local phoneCorner = Instance.new("UICorner")
phoneCorner.CornerRadius, phoneCorner.Parent = UDim.new(0, 12), phone
local phoneBorder = Instance.new("UIStroke")
phoneBorder.Color, phoneBorder.Thickness, phoneBorder.Parent = Color3.fromRGB(94, 93, 98), 3, phone

local function swapFade(value: number, seconds: number): Tween
	local tween = TweenService:Create(fade, TweenInfo.new(seconds, Enum.EasingStyle.Quad), { BackgroundTransparency = value })
	tween:Play()
	return tween
end

local character = player.Character or player.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
character:WaitForChild("HumanoidRootPart")
while not Workspace.CurrentCamera do Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait() end

local camera = Workspace.CurrentCamera :: Camera
local artModule = script.Parent:FindFirstChild("IntroAnimation")
local scene: Folder? = nil
local map = Workspace:WaitForChild("World"):WaitForChild("Catacombs")
local forward = map:WaitForChild("ForwardCollapse")
local rear = map:WaitForChild("ReturnCollapse")
local sharedCover = map:WaitForChild("ParisAndPassage"):WaitForChild("OpenManhole") :: BasePart
local function showBlockers(group: Instance, visible: boolean)
	for _, item in group:GetDescendants() do
		if item:IsA("BasePart") then item.LocalTransparencyModifier = if visible then 0 else 1 end
	end
end
if artModule and artModule:IsA("ModuleScript") then
	local tunnelTime = Lighting.ClockTime
	local tunnelAmbient = Lighting.Ambient
	local tunnelOutdoors = Lighting.OutdoorAmbient
	local duskAmbient = Color3.fromRGB(57, 54, 71)
	local duskOutdoors = Color3.fromRGB(86, 94, 129)
	local mist = Instance.new("Atmosphere")
	mist.Name = "Bruma nocturna"
	mist.Density, mist.Offset, mist.Haze = 0.15, 0.04, 1.25
	mist.Color, mist.Decay = Color3.fromRGB(125, 133, 163), Color3.fromRGB(48, 52, 78)
	local lamps = {} :: { [PointLight]: number }
	for _, item in map:GetDescendants() do
		if item:IsA("PointLight") and item.Parent and (item.Parent.Name == "Luz del túnel" or item.Parent.Name == "Lámpara del desvío") then
			lamps[item] = item.Brightness
		end
	end

	local chatAvailable, chatWasEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat)
	if chatAvailable and chatWasEnabled then
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat, false)
	end

	local unlock = lockMovement(player, "CatacombsIntroMovement")

	local ok, err = pcall(function()
		local art = require(artModule).create()
		scene = art.scene
		showBlockers(forward, false)
		showBlockers(rear, false)
		sharedCover.LocalTransparencyModifier = 1
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = art.render(0)
		Lighting.ClockTime = 22.2
		Lighting.Ambient = duskAmbient
		Lighting.OutdoorAmbient = duskOutdoors
		mist.Parent = Lighting
		swapFade(1, 1.25)

		local elapsed = 0
		local nextLine = 1
		local spoken = 0
		local opened, rumbled, firstFell, rearFell = false, false, false, false
		while elapsed < duration do
			elapsed += RunService.RenderStepped:Wait()
			while dialogue[nextLine] and elapsed >= dialogue[nextLine].finish do nextLine += 1 end
			local cue = dialogue[nextLine]
			local speaker = if cue and elapsed >= cue.start then cue.speaker else nil
			camera.CFrame = art.render(math.min(elapsed, duration), if options.reducedShake then 0.18 else 1, speaker, options.effects)
			if elapsed >= duration - 2.8 then
				local current = player.Character
				local eyes = current and current:FindFirstChild("Head")
				if eyes and eyes:IsA("BasePart") then
					local blend = math.clamp((elapsed - duration + 2.8) / 2.75, 0, 1)
					camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(eyes.Position, eyes.Position + Location.Look), blend)
				end
			end
			camera.Focus = camera.CFrame * CFrame.new(0, 0, -14)
			if elapsed >= 11 and elapsed < 16 then
				local underground = math.clamp((elapsed - 11) / 4, 0, 1)
				Lighting.ClockTime = 22.2 + (tunnelTime - 22.2) * underground
				Lighting.Ambient = duskAmbient:Lerp(tunnelAmbient, underground)
				Lighting.OutdoorAmbient = duskOutdoors:Lerp(tunnelOutdoors, underground)
				mist.Density = 0.15 * (1 - underground)
			end
			local mistTarget = if elapsed < 15 and options.effects then Lighting else nil
			if mist.Parent ~= mistTarget then mist.Parent = mistTarget end
			if not opened and elapsed >= 10.2 then opened = true; audio.effect("Lid") end
			if not rumbled and elapsed >= Location.CollapseAt - 2 then rumbled = true; audio.effect("Rumble") end
			if not firstFell and elapsed >= Location.CollapseAt + 1.1 then
				firstFell = true
				showBlockers(forward, true)
				audio.effect("Collapse")
			end
			if not rearFell and elapsed >= Location.ReturnAt + 0.7 then
				rearFell = true
				showBlockers(rear, true)
				audio.effect("Collapse")
			end
			local quaking = (elapsed > Location.CollapseAt - 1.5 and elapsed < Location.CollapseAt + 4)
				or (elapsed > Location.ReturnAt - 1 and elapsed < Location.ReturnAt + 4)
			for lamp, base in lamps do
				lamp.Brightness = if quaking then base * (0.16 + 0.82 * math.abs(math.sin(elapsed * 15))) else base
			end
			phone.Visible = elapsed >= duration - 6.5 and elapsed < duration - 2.5

			if cue and elapsed >= cue.start and spoken ~= nextLine then
				spoken = nextLine
				audio.cue(nextLine)
			end
			if options.subtitles and cue and elapsed >= cue.start then
				caption.Text = if cue.speaker == "" then cue.line else cue.speaker .. "  ·  " .. cue.line
			else
				caption.Text = ""
			end
		end
	end)
	mist:Destroy()
	for lamp, base in lamps do lamp.Brightness = base end
	showBlockers(forward, true)
	showBlockers(rear, true)
	sharedCover.LocalTransparencyModifier = 0
	if scene then scene:Destroy() end
	Lighting.ClockTime = tunnelTime
	Lighting.Ambient = tunnelAmbient
	Lighting.OutdoorAmbient = tunnelOutdoors
	unlock()
	if chatAvailable and chatWasEnabled then
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat, true)
	end
	if not ok then warn("No se pudo reproducir la introducción:", err) end
end
audio.endOpening()
phone:Destroy()

local activeCamera = Workspace.CurrentCamera
if activeCamera then
	local activeCharacter = player.Character
	local humanoid = activeCharacter and activeCharacter:FindFirstChildOfClass("Humanoid")
	if humanoid then activeCamera.CameraSubject = humanoid end
	activeCamera.CameraType = Enum.CameraType.Custom
	local head = activeCharacter and activeCharacter:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		local eyes = head.Position
		activeCamera.CFrame = CFrame.lookAt(eyes, eyes + Location.Look)
		activeCamera.Focus = CFrame.new(eyes + 12 * Location.Look)
	end
end
player.CameraMode = Enum.CameraMode.LockFirstPerson
Flashlight.mount(gui, options)
ExpeditionHUD.mount(gui, player, round, options, audio)
local ready = round:WaitForChild("Ready") :: RemoteEvent
task.spawn(function()
	while not player:GetAttribute("CatacombsReady") do
		ready:FireServer()
		task.wait(1.25)
	end
end)
swapFade(1, 0.6).Completed:Wait()
fade:Destroy()

caption.Text = "Sigue por el paso lateral."
task.delay(5, function()
	local exit = TweenService:Create(caption, TweenInfo.new(0.42), { TextTransparency = 1, TextStrokeTransparency = 1 })
	exit.Completed:Once(function() caption:Destroy() end)
	exit:Play()
end)
