--!strict

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Flashlight = {}
local warm = Color3.fromRGB(255, 194, 112)
local dim = Color3.fromRGB(111, 103, 90)

local function label(parent: Instance, name: string, size: UDim2, position: UDim2, font: Enum.Font, textSize: number): TextLabel
	local result = Instance.new("TextLabel")
	result.Name = name
	result.Size = size
	result.Position = position
	result.BackgroundTransparency = 1
	result.Font = font
	result.TextSize = textSize
	result.TextXAlignment = Enum.TextXAlignment.Left
	result.TextColor3 = Color3.fromRGB(250, 240, 222)
	result.Parent = parent
	return result
end

function Flashlight.mount(gui: ScreenGui)
	local card = Instance.new("TextButton")
	card.Name = "FlashlightSlot"
	card.AnchorPoint = Vector2.new(0.5, 1)
	card.Position = UDim2.new(0.5, 0, 1, 94)
	card.Size = UDim2.fromOffset(262, 70)
	card.Text = ""
	card.AutoButtonColor = false
	card.Selectable = false
	card.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
	card.BackgroundTransparency = 0.13
	card.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 11)
	corner.Parent = card
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = 1.5
	stroke.Color = dim
	stroke.Transparency = 0.15
	stroke.Parent = card
	local scale = Instance.new("UIScale")
	scale.Parent = card

	local binding = label(card, "Binding", UDim2.fromOffset(34, 38), UDim2.fromOffset(12, 16), Enum.Font.GothamBold, 16)
	binding.BackgroundTransparency = 0
	binding.BackgroundColor3 = Color3.fromRGB(48, 40, 32)
	binding.TextXAlignment = Enum.TextXAlignment.Center
	binding.TextColor3 = warm
	local bindingCorner = Instance.new("UICorner")
	bindingCorner.CornerRadius = UDim.new(0, 6)
	bindingCorner.Parent = binding

	local title = label(card, "ItemName", UDim2.fromOffset(190, 31), UDim2.fromOffset(58, 8), Enum.Font.GothamBlack, 26)
	title.Text = "LINTERNA"
	local state = label(card, "ItemState", UDim2.fromOffset(177, 22), UDim2.fromOffset(59, 39), Enum.Font.GothamMedium, 13)
	local indicator = Instance.new("Frame")
	indicator.Name = "PowerIndicator"
	indicator.Size = UDim2.fromOffset(6, 6)
	indicator.Position = UDim2.fromOffset(240, 47)
	indicator.BorderSizePixel = 0
	indicator.Parent = card
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = indicator

	local model = Instance.new("Model")
	model.Name = "LocalFlashlight"
	local function part(name: string, size: Vector3, color: Color3, material: Enum.Material): Part
		local piece = Instance.new("Part")
		piece.Name = name
		piece.Size = size
		piece.Color = color
		piece.Material = material
		piece.Anchored = true
		piece.CanCollide = false
		piece.CanTouch = false
		piece.CanQuery = false
		piece.CastShadow = false
		piece.Parent = model
		return piece
	end

	local grip = part("Grip", Vector3.new(0.68, 0.15, 0.15), Color3.fromRGB(39, 39, 42), Enum.Material.Metal)
	grip.Shape = Enum.PartType.Cylinder
	local bezel = part("Bezel", Vector3.new(0.22, 0.22, 0.22), Color3.fromRGB(151, 106, 60), Enum.Material.Metal)
	bezel.Shape = Enum.PartType.Cylinder
	local lens = part("Lens", Vector3.new(0.024, 0.16, 0.16), warm, Enum.Material.SmoothPlastic)
	lens.Shape = Enum.PartType.Cylinder
	local emitter = part("BeamOrigin", Vector3.new(0.05, 0.05, 0.05), warm, Enum.Material.SmoothPlastic)
	emitter.Transparency = 1
	local attachment = Instance.new("Attachment")
	attachment.Parent = emitter
	local beam = Instance.new("SpotLight")
	beam.Face = Enum.NormalId.Front
	beam.Range = 42
	beam.Angle = 61
	beam.Brightness = 3.8
	beam.Color = Color3.fromRGB(255, 222, 174)
	beam.Shadows = true
	beam.Parent = attachment
	local spill = Instance.new("PointLight")
	spill.Range = 12
	spill.Brightness = 0.58
	spill.Color = beam.Color
	spill.Parent = attachment

	local enabled = true
	local accentTween: Tween? = nil
	local pulseTween: Tween? = nil
	local function update(animate: boolean)
		beam.Enabled = enabled
		spill.Enabled = enabled
		lens.Material = if enabled then Enum.Material.Neon else Enum.Material.SmoothPlastic
		state.Text = if enabled then "Encendida" else "Apagada"
		state.TextColor3 = if enabled then warm else Color3.fromRGB(190, 182, 169)
		local accent = if enabled then warm else dim
		indicator.BackgroundColor3 = accent
		if accentTween then accentTween:Cancel() end
		if pulseTween then pulseTween:Cancel() end
		if animate then
			accentTween = TweenService:Create(stroke, TweenInfo.new(0.16), { Color = accent })
			accentTween:Play()
			scale.Scale = 0.94
			pulseTween = TweenService:Create(scale, TweenInfo.new(0.27, Enum.EasingStyle.Back), { Scale = 1 })
			pulseTween:Play()
		else
			stroke.Color = accent
		end
	end

	local function showBinding(input: Enum.UserInputType)
		if input == Enum.UserInputType.Touch then
			binding.Text = "⏻"
		elseif input.Name:match("^Gamepad") then
			binding.Text = "X"
		else
			binding.Text = "1"
		end
	end

	local function toggle()
		enabled = not enabled
		update(true)
	end

	showBinding(UserInputService:GetLastInputType())
	UserInputService.LastInputTypeChanged:Connect(showBinding)
	card.Activated:Connect(toggle)
	ContextActionService:BindAction("ToggleCatacombsFlashlight", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then toggle() end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.One, Enum.KeyCode.F, Enum.KeyCode.ButtonX)

	local axis = CFrame.Angles(0, math.pi / 2, 0)
	RunService:BindToRenderStep("CatacombsFlashlight", Enum.RenderPriority.Camera.Value + 1, function()
		local camera = Workspace.CurrentCamera
		if not camera then return end
		model.Parent = camera
		local view = camera.CFrame
		emitter.CFrame = view * CFrame.new(0.04, -0.04, -0.35)
		local hold = view * CFrame.new(0.44, -0.40, -0.85) * CFrame.Angles(math.rad(5), math.rad(-8), 0)
		grip.CFrame = hold * axis
		bezel.CFrame = hold * CFrame.new(0, 0, -0.36) * axis
		lens.CFrame = hold * CFrame.new(0, 0, -0.475) * axis
	end)
	update(false)
	TweenService:Create(card, TweenInfo.new(0.46, Enum.EasingStyle.Quint), { Position = UDim2.new(0.5, 0, 1, -22) }):Play()
end

return Flashlight
