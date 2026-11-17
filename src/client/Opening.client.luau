--!strict

local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Flashlight = require(script.Parent.Flashlight)
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GameUI") :: ScreenGui
local duration = 35

local dialogue = {
	{ start = 0.7, finish = 3.4, speaker = "", line = "PARÍS · ANOCHECER" },
	{ start = 4, finish = 7.1, speaker = "Inés", line = "Mira la ciudad. ¿Seguro que quieres pasar la noche debajo de ella?" },
	{ start = 7.2, finish = 9.7, speaker = "Leo", line = "Solo si encontramos la salida antes del desayuno." },
	{ start = 10, finish = 14.3, speaker = "Guía", line = "Por aquí. Bajamos juntos y volvemos por este mismo arco." },
	{ start = 15, finish = 18.6, speaker = "Guía", line = "Hace años, una cuadrilla encontró un arco marcado con tres rayas." },
	{ start = 18.7, finish = 23.6, speaker = "Guía", line = "Siguieron las marcas. Al día siguiente había comida en sus platos, pero de ellos no quedó rastro." },
	{ start = 23.7, finish = 25.5, speaker = "Guía", line = "Si ven esas rayas… no las sigan." },
	{ start = 26.1, finish = 27.5, speaker = "Guía", line = "¡Atrás, el techo!" },
	{ start = 28.3, finish = 30.4, speaker = "Leo", line = "¡El guía! No responde…" },
	{ start = 30.8, finish = 34.8, speaker = "Inés", line = "La entrada está sepultada. Hay un paso a la derecha. No estaba en el mapa." },
}

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
if artModule and artModule:IsA("ModuleScript") then
	local tunnelTime = Lighting.ClockTime
	local tunnelAmbient = Lighting.Ambient
	local tunnelOutdoors = Lighting.OutdoorAmbient
	local duskAmbient = Color3.fromRGB(82, 75, 90)
	local duskOutdoors = Color3.fromRGB(122, 119, 143)

	local chatAvailable, chatWasEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat)
	if chatAvailable and chatWasEnabled then
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat, false)
	end

	ContextActionService:BindActionAtPriority("CatacombsIntroMovement", function()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value,
		Enum.PlayerActions.CharacterForward, Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft, Enum.PlayerActions.CharacterRight, Enum.PlayerActions.CharacterJump)

	local ok, err = pcall(function()
		local art = require(artModule).create()
		scene = art.scene
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = art.render(0)
		Lighting.ClockTime = 17.8
		Lighting.Ambient = duskAmbient
		Lighting.OutdoorAmbient = duskOutdoors
		swapFade(1, 1.25)

		local elapsed = 0
		local nextLine = 1
		while elapsed < duration do
			elapsed += RunService.RenderStepped:Wait()
			camera.CFrame = art.render(math.min(elapsed, duration))
			camera.Focus = camera.CFrame * CFrame.new(0, 0, -14)
			if elapsed >= 11 and elapsed < 16 then
				local underground = math.clamp((elapsed - 11) / 4, 0, 1)
				Lighting.ClockTime = 17.8 + (tunnelTime - 17.8) * underground
				Lighting.Ambient = duskAmbient:Lerp(tunnelAmbient, underground)
				Lighting.OutdoorAmbient = duskOutdoors:Lerp(tunnelOutdoors, underground)
			end

			while dialogue[nextLine] and elapsed >= dialogue[nextLine].finish do
				nextLine += 1
			end
			local cue = dialogue[nextLine]
			if cue and elapsed >= cue.start then
				caption.Text = if cue.speaker == "" then cue.line else cue.speaker .. "  ·  " .. cue.line
			else
				caption.Text = ""
			end
		end
		swapFade(0, 0.48).Completed:Wait()
	end)
	if scene then scene:Destroy() end
	Lighting.ClockTime = tunnelTime
	Lighting.Ambient = tunnelAmbient
	Lighting.OutdoorAmbient = tunnelOutdoors
	ContextActionService:UnbindAction("CatacombsIntroMovement")
	if chatAvailable and chatWasEnabled then
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Chat, true)
	end
	if not ok then warn("No se pudo reproducir la introducción:", err) end
end

local activeCamera = Workspace.CurrentCamera
if activeCamera then
	local activeCharacter = player.Character
	local humanoid = activeCharacter and activeCharacter:FindFirstChildOfClass("Humanoid")
	if humanoid then activeCamera.CameraSubject = humanoid end
	activeCamera.CameraType = Enum.CameraType.Custom
	local head = activeCharacter and activeCharacter:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		local eyes = head.Position
		activeCamera.CFrame = CFrame.lookAt(eyes, eyes - Vector3.zAxis)
		activeCamera.Focus = CFrame.new(eyes - 12 * Vector3.zAxis)
	end
end
player.CameraMode = Enum.CameraMode.LockFirstPerson
Flashlight.mount(gui)
swapFade(1, 0.6).Completed:Wait()
fade:Destroy()

caption.Text = "Sigue por el paso lateral."
task.delay(5, function()
	local exit = TweenService:Create(caption, TweenInfo.new(0.42), { TextTransparency = 1, TextStrokeTransparency = 1 })
	exit.Completed:Once(function() caption:Destroy() end)
	exit:Play()
end)
