--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(shared:WaitForChild("AudioAssets"))
local Maze = require(script.Parent.Maze)
local Sculptures = require(script.Parent.Sculptures)

local Hunter = {}
local farFrom = Vector3.new(0, -1000, 0)

function Hunter.create(layout: Maze.Layout, parent: Instance, round: Folder)
	local model = Instance.new("Model")
	model.Name = "HombreCerdo"
	local coat, skin = Color3.fromRGB(51, 49, 42), Color3.fromRGB(151, 144, 125)
	local pig, dark = Color3.fromRGB(142, 113, 98), Color3.fromRGB(30, 24, 24)
	local paletteModule = shared:FindFirstChild("ArtPalette")
	if paletteModule and paletteModule:IsA("ModuleScript") then
		local palette = require(paletteModule)
		coat, skin, pig, dark = palette.pigCoat, palette.pigPale, palette.pigSkin, palette.pigShadow
	end

	local headPieces = {} :: { { part: BasePart, offset: CFrame } }
	local function part(name: string, size: Vector3, color: Color3, material: Enum.Material, ball: boolean?): Part
		local piece = Maze.part(model, name, size, CFrame.new(farFrom), color, material, false)
		if ball then piece.Shape = Enum.PartType.Ball end
		return piece
	end
	local function face(name: string, size: Vector3, offset: CFrame, color: Color3, ball: boolean?)
		local piece = part(name, size, color, Enum.Material.Leather, ball)
		table.insert(headPieces, { part = piece, offset = offset })
	end

	local root = part("Root", Vector3.new(0.15, 0.15, 0.15), dark, Enum.Material.SmoothPlastic)
	root.Transparency = 1
	model.PrimaryPart = root
	local chest = part("Espalda encorvada", Vector3.new(1.29, 2.2, 0.74), coat, Enum.Material.Fabric)
	local hip = part("Cintura", Vector3.new(0.88, 0.65, 0.58), coat, Enum.Material.Fabric)
	local arms = {} :: { { sleeve: Part, forearm: Part, hand: Part } }
	local legs = {} :: { { thigh: Part, calf: Part, boot: Part } }
	for index = 1, 2 do
		arms[index] = {
			sleeve = part("Manga desgastada", Vector3.new(0.39, 1.55, 0.41), coat, Enum.Material.Fabric),
			forearm = part("Antebrazo", Vector3.new(0.26, 1.25, 0.28), skin, Enum.Material.Leather),
			hand = part("Mano", Vector3.new(0.37, 0.65, 0.24), skin, Enum.Material.Leather, true),
		}
		legs[index] = {
			thigh = part("Pantalón", Vector3.new(0.45, 1.57, 0.5), coat, Enum.Material.Fabric),
			calf = part("Pernera", Vector3.new(0.36, 1.45, 0.44), coat, Enum.Material.Fabric),
			boot = part("Bota", Vector3.new(0.4, 0.31, 0.75), dark, Enum.Material.Leather),
		}
	end
	face("Capucha de piel envejecida", Vector3.new(1.23, 1.22, 1.27), CFrame.new(0, 0, 0.15), pig, true)
	face("Mandíbula de la máscara", Vector3.new(1.04, 0.56, 1.04), CFrame.new(0, -0.42, -0.03), pig:Lerp(dark, 0.19), true)
	face("Hocico", Vector3.new(0.74, 0.5, 0.96), CFrame.new(0, -0.13, -0.67), pig, true)
	for _, side in { -1, 1 } do
		face("Oreja caída", Vector3.new(0.35, 0.84, 0.25),
			CFrame.new(side * 0.64, 0.29, 0.13) * CFrame.Angles(0.2, 0.1, -side * 0.71), pig:Lerp(dark, 0.24), true)
		face("Cuenca hundida", Vector3.new(0.32, 0.26, 0.17), CFrame.new(side * 0.33, 0.15, -0.46), dark, true)
		face("Orificio nasal", Vector3.new(0.13, 0.16, 0.055), CFrame.new(side * 0.17, -0.11, -1.12), dark, true)
	end
	face("Pliegue de la piel", Vector3.new(0.68, 1, 0.25), CFrame.new(0, -0.53, 0.55), pig:Lerp(dark, 0.13), true)
	local sculptedMask = Sculptures.mask()
	if sculptedMask then
		for _, piece in headPieces do piece.part:Destroy() end
		table.clear(headPieces)
		sculptedMask.CFrame = CFrame.new(farFrom)
		sculptedMask.Parent = model
		table.insert(headPieces, { part = sculptedMask, offset = CFrame.new(0, -0.2, -0.14) })
	end

	local audio = Instance.new("Sound")
	audio.Name = "Vocalización porcina"
	audio.RollOffMode, audio.RollOffMinDistance, audio.RollOffMaxDistance = Enum.RollOffMode.InverseTapered, 6, 100
	audio.Parent = root
	local volumeGroup = Instance.new("SoundGroup")
	volumeGroup.Name = "CatacombsWorldAudio"
	volumeGroup.Parent = SoundService
	audio.SoundGroup = volumeGroup
	local footAnchor = part("FootEmitter", Vector3.one * 0.1, dark, Enum.Material.SmoothPlastic)
	footAnchor.Transparency = 1
	local tread = Instance.new("Sound")
	tread.Name, tread.SoundId, tread.SoundGroup = "Pisada en la piedra", Assets.HunterStep, volumeGroup
	tread.RollOffMinDistance, tread.RollOffMaxDistance = 5, 50
	tread.Parent = footAnchor
	local reverb = Instance.new("ReverbSoundEffect")
	reverb.DecayTime, reverb.Density, reverb.Diffusion, reverb.DryLevel, reverb.WetLevel = 1.7, 0.63, 0.71, -1, -12
	reverb.Parent = audio
	local eq = Instance.new("EqualizerSoundEffect")
	eq.LowGain, eq.MidGain, eq.HighGain = 2, -2, -7
	eq.Parent = audio
	local function vocal(id: string, volume: number, speed: number)
		audio:Stop()
		audio.SoundId, audio.Volume, audio.PlaybackSpeed = id, volume, speed
		audio:Play()
	end

	local point = layout.reveal.position
	local facing = Vector3.xAxis
	local state = "Dormant"
	local stateStart = 0
	local memory: Vector3? = nil
	local target: Player? = nil
	local waypoints: { Vector3 } = {}
	local cursor = 1
	local lastGoal: Vector3? = nil
	local lastPlan = 0
	local lastSensedAt = 0
	local lastAttack = 0
	local lastGrunt = 0
	local lastSearch = 0
	local lastStep = 0
	local tickAt = 0
	local poseAt = 0
	local turn = 0
	local clock = Random.new(514)
	local patrolIndex = layout.reveal.id
	local escapeNode = layout.reveal
	for _, index in layout.reveal.links do
		if index ~= layout.gate.id then escapeNode = layout.nodes[index]; break end
	end

	local function transition(nextState: string, time: number)
		if state == nextState then return end
		state, stateStart = nextState, time
		model:SetAttribute("State", state)
		round:SetAttribute("HunterState", state)
		round:SetAttribute("TargetUserId", if target then target.UserId else 0)
		if state == "Suspect" then vocal(Assets.PigGrunt, 0.56, 0.79) end
		if state == "Chase" then vocal(Assets.PigSqueal, 0.58, 0.78) end
	end

	local function see(from: Vector3, to: Vector3, character: Model): boolean
		local ray = RaycastParams.new()
		ray.FilterType = Enum.RaycastFilterType.Exclude
		ray.FilterDescendantsInstances = { model, character }
		return Workspace:Raycast(from, to - from, ray) == nil
	end

	local function scan(): (Player?, Vector3?, Player?, Vector3?)
		local seen, heard: Player? = nil, nil
		local sightPoint, earPoint: Vector3? = nil, nil
		local sightDistance, earDistance = 60, 25
		for _, candidate in Players:GetPlayers() do
			local character = candidate.Character
			local anchor = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if character and anchor and humanoid and humanoid.Health > 0 and candidate:GetAttribute("CatacombsReady") then
				local center = anchor.Position
				if center.X >= layout.entrance.position.X - 3 then
					local delta = Vector3.new(center.X - point.X, 0, center.Z - point.Z)
					local distance = delta.Magnitude
					local inCone = distance < 8 or (distance > 0 and facing:Dot(delta.Unit) > 0.49)
					if distance < sightDistance and inCone and see(point + Vector3.yAxis * 5.5, center, character) then
						sightDistance, seen, sightPoint = distance, candidate, center
					end
					local velocity = anchor.AssemblyLinearVelocity
					local noise = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
					if distance < earDistance and noise > 6
						and (distance < 12 or see(point + Vector3.yAxis * 3.5, center, character)) then
						earDistance, heard, earPoint = distance, candidate, center
					end
				end
			end
		end
		return seen, sightPoint, heard, earPoint
	end

	local function plan(goal: Vector3, time: number)
		if lastGoal and (goal - lastGoal).Magnitude < 6 and time - lastPlan < 2 then return end
		lastGoal, lastPlan, cursor = goal, time, 1
		waypoints = layout.route(point, goal)
	end

	local function choosePatrol(time: number)
		local seed = layout.nodes[patrolIndex]
		local links = {}
		for _, index in seed.links do table.insert(links, index) end
		if #links == 0 then return end
		patrolIndex = links[clock:NextInteger(1, #links)]
		plan(layout.nodes[patrolIndex].position, time)
	end

	local function logic(time: number)
		if state == "Reveal" then
			local elapsed = time - stateStart
			if elapsed > 9.8 then
				transition("Patrol", time)
				patrolIndex = layout.nearest(point).id
				choosePatrol(time)
			elseif elapsed > 7.1 and escapeNode ~= layout.reveal and not lastGoal then
				plan(escapeNode.position, time)
			end
			return
		end
		local seen, sight, heard, noise = scan()
		if seen and sight then
			memory, lastSensedAt, target = sight, time, seen
			if round:GetAttribute("TargetUserId") ~= seen.UserId then round:SetAttribute("TargetUserId", seen.UserId) end
			if state ~= "Chase" and state ~= "Attack" and state ~= "Suspect" then transition("Suspect", time) end
			if state == "Suspect" and time - stateStart > 1.1 then transition("Chase", time) end
			if state == "Attack" and time - stateStart > 0.64 then transition("Chase", time) end
			if state == "Chase" then
				plan(sight, time)
				local distance = (Vector3.new(sight.X, point.Y, sight.Z) - point).Magnitude
				if distance < 4.2 and time - lastAttack > 1.35 then
					lastAttack = time
					transition("Attack", time)
					local humanoid = seen.Character and seen.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then humanoid:TakeDamage(29) end
				end
			end
		elseif state == "Attack" and time - stateStart > 0.65 then
			transition("Search", time)
		elseif state == "Chase" and time - lastSensedAt > 2.6 then
			transition("Search", time)
		elseif state == "Suspect" and time - stateStart > 1.6 then
			transition("Investigate", time)
		elseif heard and noise and (state == "Patrol" or state == "Search") then
			target, memory = nil, noise
			transition("Investigate", time)
		end
		if state == "Investigate" or state == "Search" then
			if memory and cursor > #waypoints then
				if lastGoal == nil or (lastGoal - memory).Magnitude > 2 then plan(memory, time) end
			elseif memory and state == "Investigate" then
				plan(memory, time)
			end
			if time - stateStart > (if state == "Search" then 8 else 6) then
				target, memory, lastGoal = nil, nil, nil
				transition("Patrol", time)
				patrolIndex = layout.nearest(point).id
				choosePatrol(time)
			elseif time - lastSearch > 3.3 then
				lastSearch = time
				vocal(Assets.PigGrunt, 0.42, 0.8)
			end
		elseif state == "Patrol" and cursor > #waypoints then
			choosePatrol(time)
		end
		if state == "Patrol" and time - lastGrunt > 6.8 then
			lastGrunt = time
			vocal(Assets.PigBreath, 0.34, 0.71)
		elseif state == "Chase" and time - lastGrunt > 2.7 then
			lastGrunt = time
			vocal(Assets.PigGrunt, 0.53, 0.85)
		end
	end

	local function pose(now: number, speed: number)
		local stride = if speed > 10 then 1 else if speed > 0 then 0.52 else 0
		local phase = now * (if speed > 10 then 12 else 6)
		local breath = math.sin(now * 2.2) * 0.045
		local lunge = if state == "Attack" then math.sin(math.clamp((now - stateStart) / 0.56, 0, 1) * math.pi) else 0
		local cf = CFrame.lookAt(point, point + facing)
		root.CFrame = cf * CFrame.new(0, 5.6, 0)
		footAnchor.CFrame = cf * CFrame.new(0, 0.25, 0)
		hip.CFrame = cf * CFrame.new(0, 3.05 + breath, 0)
		chest.CFrame = cf * CFrame.new(0, 4.4 + breath, -0.19) * CFrame.Angles(-0.23 - lunge * 0.42, 0, 0.065)
		local twitch = if state == "Reveal" or state == "Suspect" then math.sin(now * 2.4) * 0.38 else math.sin(now * 1.1) * 0.14
		local head = cf * CFrame.new(0.13, 5.58 + breath, -0.45 - lunge * 0.42) * CFrame.Angles(0.14, turn + twitch, -0.2 + breath)
		for _, item in headPieces do item.part.CFrame = head * item.offset end
		for index = 1, 2 do
			local side = if index == 1 then -1 else 1
			local swing = math.sin(phase + index * math.pi + (index - 1) * 0.25) * stride
			local shoulder = cf * CFrame.new(side * 0.77, 4.92 - (if index == 1 then 0.19 else 0), -0.2)
				* CFrame.Angles(swing * 0.48 + lunge * 1.3, 0, side * 0.11)
			local elbow = shoulder * CFrame.new(0, -1.49, 0) * CFrame.Angles(0.18 - swing * 0.24, 0, side * 0.08)
			arms[index].sleeve.CFrame = shoulder * CFrame.new(0, -0.73, 0)
			arms[index].forearm.CFrame = elbow * CFrame.new(0, -0.58, 0)
			arms[index].hand.CFrame = elbow * CFrame.new(0, -1.32, -0.08)
			local leg = cf * CFrame.new(side * 0.27, 2.97, 0) * CFrame.Angles(-swing * 0.51, 0, 0)
			local knee = leg * CFrame.new(0, -1.48, 0) * CFrame.Angles(math.abs(swing) * 0.31, 0, 0)
			legs[index].thigh.CFrame = leg * CFrame.new(0, -0.72, 0)
			legs[index].calf.CFrame = knee * CFrame.new(0, -0.69, 0)
			legs[index].boot.CFrame = knee * CFrame.new(0, -1.34, -0.18)
		end
	end

	return function()
		if state ~= "Dormant" then return end
		facing = (layout.gate.position - point).Unit
		local now = Workspace:GetServerTimeNow()
		transition("Reveal", now)
		pose(now, 0)
		model.Parent = parent
		task.delay(3.25, function()
			if state == "Reveal" then vocal(Assets.PigBreath, 0.49, 0.75) end
		end)
		task.delay(4.9, function()
			if state == "Reveal" then vocal(Assets.PigGrunt, 0.68, 0.69) end
		end)
		RunService.Heartbeat:Connect(function(dt)
			local time = Workspace:GetServerTimeNow()
			if time - tickAt >= 0.25 then tickAt = time; logic(time) end
			local speed = if state == "Chase" then 15.4 elseif state == "Patrol" then 6
				elseif state == "Reveal" and lastGoal then 5.6
				elseif state == "Investigate" or state == "Search" then 7.2 else 0
			local goal = waypoints[cursor]
			if state == "Suspect" and memory then
				local direction = Vector3.new(memory.X - point.X, 0, memory.Z - point.Z)
				if direction.Magnitude > 0.1 then facing = facing:Lerp(direction.Unit, 0.11).Unit end
			elseif goal and speed > 0 then
				local direction = Vector3.new(goal.X - point.X, 0, goal.Z - point.Z)
				local length = direction.Magnitude
				if length < 0.65 then
					cursor += 1
				else
					local aim = direction.Unit
					local mixed = facing:Lerp(aim, math.min(dt * 7.5, 0.8))
					if mixed.Magnitude > 0.001 then facing = mixed.Unit end
					point += aim * math.min(length, speed * math.min(dt, 0.09))
				end
			end
			if time - poseAt >= 1 / 18 then poseAt = time; pose(time, if goal then speed else 0) end
			if goal and speed > 0 and time - lastStep > (if speed > 10 then 0.48 else 0.95) then
				lastStep = time
				tread.Volume = if speed > 10 then 0.32 else 0.2
				tread.PlaybackSpeed = if speed > 10 then 1.36 else 0.93
				tread:Stop()
				tread:Play()
			end
		end)
	end
end

return Hunter
