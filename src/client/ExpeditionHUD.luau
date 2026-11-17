--!strict

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local lockMovement = require(script.Parent.MovementLock)

local HUD = {}
local parchment = Color3.fromRGB(248, 229, 200)

local function textPanel(parent: Instance, name: string, size: UDim2, position: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name, label.Size, label.Position = name, size, position
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.BackgroundColor3, label.BackgroundTransparency = Color3.fromRGB(20, 18, 18), 0.22
	label.TextColor3, label.Font, label.TextSize = parchment, Enum.Font.GothamMedium, 15
	label.TextWrapped = true
	label.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0, 8), label
	return label
end

function HUD.mount(gui: ScreenGui, player: Player, round: Folder, options, audio)
	local heading = textPanel(gui, "ExpeditionObjective", UDim2.new(0.67, 0, 0, 46), UDim2.fromScale(0.5, 0.02))
	local width = Instance.new("UISizeConstraint")
	width.MaxSize = Vector2.new(390, 50)
	width.Parent = heading
	local message = textPanel(gui, "ExpeditionNotice", UDim2.new(0.74, 0, 0, 47), UDim2.fromScale(0.5, 0.8))
	message.Text, message.Visible = "", false
	message.ZIndex = 11

	local button = Instance.new("TextButton")
	button.Name = "UseBandage"
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = UDim2.new(1, -18, 1, -119)
	button.Size = UDim2.fromOffset(136, 43)
	button.BackgroundColor3 = Color3.fromRGB(66, 53, 41)
	button.TextColor3 = parchment
	button.TextSize, button.Font = 14, Enum.Font.GothamMedium
	button.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0, 8), button

	local identifier = 0
	local function announce(line: string, seconds: number?)
		identifier += 1
		local this = identifier
		message.Text, message.Visible = line, true
		task.delay(seconds or 3.4, function()
			if identifier == this then message.Visible = false end
		end)
	end
	local heal = round:WaitForChild("Heal") :: RemoteEvent
	local notice = round:WaitForChild("Notice") :: RemoteEvent
	local reveal = round:WaitForChild("Reveal") :: RemoteEvent
	local function handleHeal()
		if (round:GetAttribute("Bandages") :: number? or 0) > 0 then heal:FireServer() end
	end
	button.Activated:Connect(handleHeal)
	ContextActionService:BindAction("UseExpeditionBandage", function(_, state)
		if state == Enum.UserInputState.Begin then handleHeal() end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.H, Enum.KeyCode.ButtonL1)
	local function refresh()
		local phase = round:GetAttribute("Phase")
		local rubies = round:GetAttribute("Rubies") or 0
		local supplies = round:GetAttribute("Bandages") :: number? or 0
		heading.Text = if phase == "Beyond" then "Cruza el umbral"
			elseif phase == "Hunt" and rubies == 3 then "3/3 rubíes · Regresa a la puerta"
			elseif phase == "Hunt" then "Fragmentos de rubí · " .. rubies .. "/3"
			elseif phase == "Reveal" then "Escucha…" else "Explora el laberinto y encuentra la puerta"
		button.Visible = supplies > 0
		button.Text = "Venda [H] · " .. supplies
	end
	for _, attribute in { "Phase", "Rubies", "Bandages" } do
		round:GetAttributeChangedSignal(attribute):Connect(refresh)
	end
	notice.OnClientEvent:Connect(announce)
	refresh()

	local playing = false
	reveal.OnClientEvent:Connect(function(gateAt: Vector3, pigAt: Vector3)
		if playing then return end
		local camera = Workspace.CurrentCamera
		local character = player.Character
		local head = character and character:FindFirstChild("Head")
		if not camera or not head or not head:IsA("BasePart") then return end
		playing = true
		local unlock = lockMovement(player, "ExpeditionRevealMovement")
		local accepted, problem = pcall(function()
			local eyes = head.Position
			local held, turned = CFrame.lookAt(eyes, gateAt), CFrame.lookAt(eyes, pigAt)
			local instruction = "Recolecta los tres fragmentos de rubí para abrir la puerta."
			camera.CameraType, camera.CFrame = Enum.CameraType.Scriptable, held
			audio.say(instruction, "Matthew")
			if options.subtitles then announce("Matthew · " .. instruction, 3.2) end
			local elapsed = 0
			while elapsed < 9.7 and character == player.Character do
				elapsed += RunService.RenderStepped:Wait()
				local turn = math.clamp((elapsed - 4.95) / 1.85, 0, 1)
				camera.CFrame = held:Lerp(turned, TweenService:GetValue(turn, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
				camera.Focus = camera.CFrame * CFrame.new(0, 0, -12)
			end
		end)
		unlock()
		if Workspace.CurrentCamera == camera then camera.CameraType = Enum.CameraType.Custom end
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		playing = false
		if not accepted then warn("Secuencia de la puerta:", problem) end
	end)
end

return HUD
