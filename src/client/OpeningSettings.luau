--!strict

local ContextActionService = game:GetService("ContextActionService")

local Settings = {}

function Settings.mount(gui: ScreenGui)
	local options = {
		subtitles = true,
		reducedShake = false,
		volume = 0.75,
		effects = true,
	}

	local function button(name: string, parent: Instance, size: UDim2, position: UDim2): TextButton
		local control = Instance.new("TextButton")
		control.Name = name
		control.Size = size
		control.Position = position
		control.BackgroundColor3 = Color3.fromRGB(38, 36, 38)
		control.TextColor3 = Color3.fromRGB(248, 230, 202)
		control.Font = Enum.Font.GothamMedium
		control.TextSize = 14
		control.ZIndex = 23
		control.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = control
		return control
	end

	local open = button("OpeningSettings", gui, UDim2.fromOffset(106, 36), UDim2.new(1, -14, 0, 12))
	open.AnchorPoint = Vector2.new(1, 0)
	open.Text = "Ajustes  [O]"

	local panel = Instance.new("Frame")
	panel.Name = "OpeningOptions"
	panel.AnchorPoint = Vector2.new(1, 0)
	panel.Position = UDim2.new(1, -14, 0, 56)
	panel.Size = UDim2.fromOffset(243, 212)
	panel.BackgroundColor3 = Color3.fromRGB(21, 20, 23)
	panel.ZIndex = 22
	panel.Visible = false
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(116, 89, 57)
	stroke.Parent = panel

	local subtitles = button("SubtitleToggle", panel, UDim2.new(1, -20, 0, 42), UDim2.fromOffset(10, 10))
	local shake = button("ShakeToggle", panel, UDim2.new(1, -20, 0, 42), UDim2.fromOffset(10, 60))
	local volume = button("Volume", panel, UDim2.new(1, -20, 0, 42), UDim2.fromOffset(10, 110))
	local quality = button("VisualEffects", panel, UDim2.new(1, -20, 0, 42), UDim2.fromOffset(10, 160))
	subtitles.Modal = true
	shake.Modal = true

	local function refresh()
		subtitles.Text = if options.subtitles then "Subtítulos · Activados" else "Subtítulos · Desactivados"
		shake.Text = if options.reducedShake then "Temblor · Reducido" else "Temblor · Estándar"
		volume.Text = string.format("Volumen · %d%%", options.volume * 100)
		quality.Text = if options.effects then "Efectos gráficos · Completos" else "Efectos gráficos · Reducidos"
	end

	subtitles.Activated:Connect(function()
		options.subtitles = not options.subtitles
		refresh()
	end)
	shake.Activated:Connect(function()
		options.reducedShake = not options.reducedShake
		refresh()
	end)
	volume.Activated:Connect(function()
		options.volume = if options.volume >= 1 then 0 else options.volume + 0.25
		refresh()
	end)
	quality.Activated:Connect(function()
		options.effects = not options.effects
		refresh()
	end)
	open.Activated:Connect(function()
		panel.Visible = not panel.Visible
	end)
	ContextActionService:BindAction("ShowCatacombsSettings", function(_, state)
		if state == Enum.UserInputState.Begin then
			panel.Visible = not panel.Visible
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.O)
	refresh()

	return options
end

return Settings
