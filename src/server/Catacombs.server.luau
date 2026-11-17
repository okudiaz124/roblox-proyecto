--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Location = require(shared:WaitForChild("Location"))
local Maze = require(script.Parent.Maze)
local Scenery = require(script.Parent.ParisScenery)
local Hunter = require(script.Parent.Hunter)
local world = Workspace:WaitForChild("World")
local stone = Color3.fromRGB(86, 79, 70)
local ink = Color3.fromRGB(33, 31, 32)
local garnet = Color3.fromRGB(193, 22, 46)
local warmth = Color3.fromRGB(234, 188, 125)

local section = Instance.new("Folder")
section.Name = "Catacombs"
local openingSet = Instance.new("Model")
openingSet.Name = "ParisAndPassage"
openingSet.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
Scenery.build(openingSet)
openingSet.Parent = section

local function terrain(parent: Instance, name: string, dimensions: Vector3, pos: Vector3, color: Color3, material: Enum.Material, collide: boolean?): Part
	return Maze.part(parent, name, dimensions, CFrame.new(pos), color, material, collide)
end

local function rockfall(name: string, z: number, seed: number): Model
	local group = Instance.new("Model")
	group.Name = name
	group.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	group.Parent = section
	local blocker = terrain(group, "Muro sepultado", Vector3.new(9, 7.5, 2.6), Vector3.new(12, 3.75, z), ink, Enum.Material.Cobblestone)
	blocker.Transparency = 1
	local rng = Random.new(seed)
	for height = 0, 3 do
		for width = 0, 3 do
			local rock = Maze.part(group, "Escombro fijo", Vector3.new(rng:NextNumber(2.5, 3.5), rng:NextNumber(2.3, 3.1), rng:NextNumber(2, 3.7)),
				CFrame.new(8.7 + width * 2.07, 0.72 + height * 1.86, z + rng:NextNumber(-0.55, 0.55))
				* CFrame.Angles(rng:NextNumber(-0.21, 0.21), rng:NextNumber(-0.5, 0.5), rng:NextNumber(-0.23, 0.23)),
				stone:Lerp(ink, rng:NextNumber(0, 0.48)), Enum.Material.Cobblestone, false)
			rock.CanQuery = false
		end
	end
	return group
end

local forward = rockfall("ForwardCollapse", -80.5, 1791)
rockfall("ReturnCollapse", -60.5, 1797)
terrain(forward, "Mochila del guía", Vector3.new(0.87, 0.38, 0.71), Vector3.new(10.4, 0.22, -77.85),
	Color3.fromRGB(88, 62, 45), Enum.Material.Fabric, false)
local broken = terrain(forward, "Linterna dañada", Vector3.new(0.84, 0.23, 0.23), Vector3.new(11.72, 0.17, -78.03),
	Color3.fromRGB(58, 55, 55), Enum.Material.Metal, false)
broken.Shape = Enum.PartType.Cylinder
broken.Orientation = Vector3.new(0, 31, 0)
terrain(forward, "Marca oscura bajo el polvo", Vector3.new(1.35, 0.013, 0.71), Vector3.new(11.1, 0.011, -78.18),
	Color3.fromRGB(54, 30, 32), Enum.Material.Slate, false)

local assets = ServerStorage:WaitForChild("GameAssets")
local art = assets:FindFirstChild("Art")
local signTemplate = art and art:FindFirstChild("ForbiddenEntrance")
if signTemplate and signTemplate:IsA("Model") then
	local sign = signTemplate:Clone()
	local panel = sign:FindFirstChild("Panel")
	if panel and panel:IsA("BasePart") then sign.PrimaryPart = panel end
	local position = Vector3.new(20.5, 4.06, -79.28)
	sign:PivotTo(CFrame.lookAt(position, position + Vector3.zAxis))
	sign.Parent = section
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Tras el derrumbe"
spawn.Size = Vector3.new(0.3, 0.15, 0.3)
spawn.CFrame = CFrame.lookAt(Location.Spawn + Vector3.yAxis * 0.1, Location.Spawn + Vector3.yAxis * 0.1 + Location.Look)
spawn.Anchored, spawn.CanCollide, spawn.Neutral = true, false, true
spawn.Transparency, spawn.Duration = 1, 0
spawn.Parent = section

Lighting.Ambient = Color3.fromRGB(25, 24, 28)
Lighting.OutdoorAmbient = Color3.fromRGB(50, 53, 67)
Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 1.35, 19.6, true

local round = Instance.new("Folder")
round.Name = "Expedition"
round:SetAttribute("Phase", "Explore")
round:SetAttribute("Rubies", 0)
round:SetAttribute("Bandages", 0)
round:SetAttribute("DoorOpen", false)
round:SetAttribute("HunterState", "Dormant")
local ready = Instance.new("RemoteEvent")
ready.Name, ready.Parent = "Ready", round
local heal = Instance.new("RemoteEvent")
heal.Name, heal.Parent = "Heal", round
local notice = Instance.new("RemoteEvent")
notice.Name, notice.Parent = "Notice", round
local reveal = Instance.new("RemoteEvent")
reveal.Name, reveal.Parent = "Reveal", round

local layout = Maze.build(section, Location.Entrance)
for index, cell in layout.rituals do round:SetAttribute("Ritual" .. index, cell.position) end
local showHunter = Hunter.create(layout, layout.folder, round)
local rubyCount, bandages = 0, 0
local lastHeal: { [Player]: number } = {}
local elapsedSinceJoin: { [Player]: number } = {}
local function onJoin(player: Player)
	elapsedSinceJoin[player] = os.clock()
	player:SetAttribute("CatacombsReady", false)
end
Players.PlayerAdded:Connect(onJoin)
Players.PlayerRemoving:Connect(function(player)
	elapsedSinceJoin[player], lastHeal[player] = nil, nil
end)
for _, player in Players:GetPlayers() do onJoin(player) end
ready.OnServerEvent:Connect(function(player)
	local joined = elapsedSinceJoin[player]
	if joined and os.clock() - joined >= Location.Duration - 4 then player:SetAttribute("CatacombsReady", true) end
end)

local function alive(player: Player): (Humanoid?, BasePart?)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then return humanoid, root end
	return nil, nil
end

local function reach(player: Player, item: BasePart, limit: number): boolean
	local _, root = alive(player)
	if not root or not player:GetAttribute("CatacombsReady") then return false end
	local delta = item.Position - root.Position
	if delta.Magnitude > limit then return false end
	local filter = RaycastParams.new()
	filter.FilterType = Enum.RaycastFilterType.Exclude
	filter.FilterDescendantsInstances = { player.Character :: Model }
	local hit = Workspace:Raycast(root.Position, delta, filter)
	return hit == nil or hit.Instance == item or (hit.Position - item.Position).Magnitude < 0.9
end

local function prompt(target: BasePart, label: string, action: string): ProximityPrompt
	local trigger = Instance.new("ProximityPrompt")
	trigger.ObjectText, trigger.ActionText = label, action
	trigger.KeyboardKeyCode, trigger.GamepadKeyCode = Enum.KeyCode.E, Enum.KeyCode.ButtonY
	trigger.HoldDuration, trigger.MaxActivationDistance = 0.22, 9
	trigger.RequiresLineOfSight = true
	trigger.Parent = target
	return trigger
end

for index, cell in layout.rubies do
	local location = cell.position + Vector3.new(-3.8, 1.12, 3.7)
	local fragment = Maze.part(layout.folder, "Fragmento de rubí " .. index, Vector3.new(0.67, 0.86, 0.46),
		CFrame.new(location) * CFrame.Angles(0.25, index * 0.38, 0.52), garnet, Enum.Material.Glass, false)
	local glow = Instance.new("PointLight")
	glow.Color, glow.Brightness, glow.Range = garnet, 0.88, 7
	glow.Parent = fragment
	local collectible = prompt(fragment, "Fragmento de rubí", "Recoger")
	local coinsClaimed = false
	collectible.Triggered:Connect(function(player)
		if coinsClaimed or not reach(player, fragment, 10) then return end
		if round:GetAttribute("Phase") ~= "Hunt" then
			notice:FireClient(player, "Aún no sabes para qué sirve. Busca la puerta.")
			return
		end
		coinsClaimed, collectible.Enabled = true, false
		rubyCount += 1
		round:SetAttribute("Rubies", rubyCount)
		notice:FireAllClients("Fragmento recuperado · " .. rubyCount .. "/3")
		local absorption = TweenService:Create(fragment, TweenInfo.new(0.52, Enum.EasingStyle.Quad), {
			CFrame = fragment.CFrame * CFrame.new(0, 0.85, 0) * CFrame.Angles(0, math.pi, 0),
			Size = Vector3.one * 0.1, Transparency = 1,
		})
		absorption.Completed:Once(function() fragment:Destroy() end)
		absorption:Play()
	end)
end

for index, cell in layout.rituals do
	local bandage = terrain(layout.folder, "Venda " .. index, Vector3.new(0.52, 0.21, 0.39),
		cell.position + Vector3.new(3.5, 1.82, -4), Color3.fromRGB(193, 182, 155), Enum.Material.Fabric, false)
	local pickup = prompt(bandage, "Venda del grupo", "Guardar")
	local taken = false
	pickup.Triggered:Connect(function(player)
		if taken or not reach(player, bandage, 10) then return end
		taken = true
		bandages += 1
		round:SetAttribute("Bandages", bandages)
		bandage:Destroy()
		notice:FireAllClients("El grupo recuperó una venda.")
	end)
end

heal.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if now - (lastHeal[player] or -10) < 0.8 or not player:GetAttribute("CatacombsReady") then return end
	lastHeal[player] = now
	local humanoid = alive(player)
	if not humanoid then return end
	if humanoid.Health >= humanoid.MaxHealth then notice:FireClient(player, "Ya tienes toda la salud."); return end
	if bandages == 0 then notice:FireClient(player, "El grupo se quedó sin vendas."); return end
	bandages -= 1
	humanoid.Health = math.min(humanoid.Health + 35, humanoid.MaxHealth)
	round:SetAttribute("Bandages", bandages)
	notice:FireClient(player, "Herida vendada.")
end)

local gateAt = layout.gate.position + Vector3.new(8.42, 4.1, 0)
local gate = terrain(layout.folder, "Puerta de piedra", Vector3.new(1.05, 8.1, 16.9), gateAt, stone, Enum.Material.Slate)
local inscription = Instance.new("SurfaceGui")
inscription.Name, inscription.Face = "Inscription", Enum.NormalId.Left
inscription.SizingMode, inscription.PixelsPerStud, inscription.LightInfluence = Enum.SurfaceGuiSizingMode.PixelsPerStud, 48, 0.42
inscription.Parent = gate
local lettering = Instance.new("TextLabel")
lettering.Size, lettering.Position = UDim2.fromScale(0.74, 0.44), UDim2.fromScale(0.13, 0.23)
lettering.BackgroundTransparency, lettering.TextWrapped, lettering.TextScaled = 1, true, true
lettering.TextColor3, lettering.Font = warmth, Enum.Font.GothamBold
lettering.Text = "RECOLECTA LOS 3 FRAGMENTOS DE RUBÍ PARA ABRIR LA PUERTA."
lettering.Parent = inscription
local mechanism = prompt(gate, "Inscripción", "Leer")
local sockets = {}
for index = 1, 3 do
	local socket = terrain(layout.folder, "Engaste " .. index, Vector3.new(0.28, 0.62, 0.62),
		gateAt + Vector3.new(-0.64, -1.57, (index - 2) * 1.1), ink, Enum.Material.Metal, false)
	table.insert(sockets, socket)
end

mechanism.Triggered:Connect(function(player)
	if not reach(player, gate, 12) or round:GetAttribute("DoorOpen") then return end
	local phase = round:GetAttribute("Phase")
	if phase == "Explore" then
		round:SetAttribute("Phase", "Reveal")
		mechanism.Enabled = false
		showHunter()
		local pigSpot = layout.reveal.position + Vector3.yAxis * 5.5
		for _, nearby in Players:GetPlayers() do
			local _, root = alive(nearby)
			if root and (root.Position - gateAt).Magnitude < 35 and nearby:GetAttribute("CatacombsReady") then
				reveal:FireClient(nearby, gateAt, pigSpot)
			end
		end
		task.delay(9.95, function()
			round:SetAttribute("Phase", "Hunt")
			mechanism.ObjectText, mechanism.ActionText, mechanism.Enabled = "Puerta del osario", "Insertar rubíes", true
		end)
		return
	end
	if phase ~= "Hunt" then return end
	if rubyCount < 3 then notice:FireClient(player, "Aún faltan " .. (3 - rubyCount) .. " fragmentos."); return end
	round:SetAttribute("DoorOpen", true)
	round:SetAttribute("Phase", "Beyond")
	mechanism.Enabled = false
	task.spawn(function()
		for _, socket in sockets do
			socket.Color, socket.Material = garnet, Enum.Material.Neon
			task.wait(0.45)
		end
		local opening = TweenService:Create(gate, TweenInfo.new(2.85, Enum.EasingStyle.Sine), { Position = gateAt + Vector3.yAxis * 8.25 })
		opening.Completed:Once(function()
			gate.CanCollide = false
			notice:FireAllClients("La puerta se abre. El túnel continúa.")
		end)
		opening:Play()
	end)
end)

section.Parent = world
round.Parent = shared
