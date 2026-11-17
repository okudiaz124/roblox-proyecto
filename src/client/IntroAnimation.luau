--!strict

local Art = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Location = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Location"))
local offset = Location.Origin
local amber = Color3.fromRGB(241, 157, 80)
local limestone = Color3.fromRGB(108, 98, 84)

function Art.create()
	local scene = Instance.new("Folder")
	scene.Name = "ParisOpening"

	local function piece(name: string, size: Vector3, position: Vector3, color: Color3,
		material: Enum.Material?, parent: Instance?): Part
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Position = offset + position
		part.Color = color
		part.Material = material or Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Parent = parent or scene
		return part
	end

	local floorY = -11.85
	local random = Random.new(1889)

	local function actor(name: string, coat: Color3, badge: Color3, holdsMap: boolean?)
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = scene
		local skin = Color3.fromRGB(195, 149, 116)
		local torso = piece("Chaqueta", Vector3.new(1.08, 1.35, 0.55), Vector3.zero, coat, nil, folder)
		local head = piece("Cabeza", Vector3.new(0.68, 0.75, 0.65), Vector3.zero, skin, nil, folder)
		head.Shape = Enum.PartType.Ball
		local hair = piece("Pelo", Vector3.new(0.69, 0.29, 0.66), Vector3.zero, Color3.fromRGB(45, 30, 27), nil, folder)
		hair.Shape = Enum.PartType.Ball
		local mouth = piece("Boca", Vector3.new(0.18, 0.05, 0.023), Vector3.zero, Color3.fromRGB(70, 40, 41), nil, folder)
		local eyes = {} :: { Part }
		for index = 1, 2 do
			eyes[index] = piece("Ojo", Vector3.new(0.055, 0.05, 0.02), Vector3.zero, Color3.fromRGB(33, 30, 30), nil, folder)
			eyes[index].Shape = Enum.PartType.Ball
		end
		local bag = piece("Equipo", Vector3.new(0.68, 0.9, 0.43), Vector3.zero, badge, nil, folder)
		local map = if holdsMap then piece("Mapa doblado", Vector3.new(0.59, 0.42, 0.05), Vector3.zero,
			Color3.fromRGB(215, 187, 136), Enum.Material.SmoothPlastic, folder) else nil
		local arm = {} :: { Part }
		local leg = {} :: { Part }
		for index = 1, 2 do
			arm[index] = piece("Brazo", Vector3.new(0.3, 1.17, 0.34), Vector3.zero, coat, nil, folder)
			leg[index] = piece("Pierna", Vector3.new(0.43, 1.45, 0.43), Vector3.zero, Color3.fromRGB(47, 44, 48), nil, folder)
		end
		return function(pos: Vector3, turn: number, stride: number, time: number, point: number, falling: number, talking: boolean?, glance: number?)
			local gait = math.sin(time * 8.8) * stride
			local root = CFrame.new(offset + pos + Vector3.new(0, math.abs(gait) * 0.065, 0))
				* CFrame.Angles(0, turn, falling)
			torso.CFrame = root * CFrame.new(0, 2.15, 0)
			local face = root * CFrame.new(0, 3.15, 0) * CFrame.Angles(0, glance or 0, 0)
			head.CFrame = face
			hair.CFrame = face * CFrame.new(0, 0.32, 0.035)
			mouth.Size = Vector3.new(0.18, if talking then 0.04 + math.abs(math.sin(time * 17)) * 0.083 else 0.033, 0.023)
			mouth.CFrame = face * CFrame.new(0, -0.15, -0.302)
			for index = 1, 2 do
				eyes[index].CFrame = face * CFrame.new((index - 1.5) * 0.24, 0.045, -0.301)
			end
			bag.CFrame = root * CFrame.new(0, 2.22, 0.42)
			if map then
				map.Transparency = if time < 11 then 0 else 1
				map.CFrame = root * CFrame.new(0.61, 1.96, -0.43) * CFrame.Angles(-0.6, 0.4, 0.22)
			end
			for index = 1, 2 do
				local sign = if index == 1 then -1 else 1
				arm[index].CFrame = root * CFrame.new(sign * 0.68, 2.67, 0)
					* CFrame.Angles(sign * gait * 0.6 - (if index == 2 then point else 0), 0, sign * 0.085)
					* CFrame.new(0, -0.53, 0)
				leg[index].CFrame = root * CFrame.new(sign * 0.25, 1.43, 0)
					* CFrame.Angles(-sign * gait * 0.63, 0, 0) * CFrame.new(0, -0.7, 0)
			end
		end
	end

	local hikari = actor("Hikari", Color3.fromRGB(105, 57, 60), Color3.fromRGB(81, 78, 96))
	local matthew = actor("Matthew", Color3.fromRGB(60, 104, 107), Color3.fromRGB(80, 70, 55), true)
	local guide = actor("Guía", Color3.fromRGB(94, 78, 55), Color3.fromRGB(165, 98, 54))
	local lid = piece("Tapa de alcantarilla", Vector3.new(0.16, 4.18, 4.18), Vector3.zero,
		Color3.fromRGB(57, 52, 47), Enum.Material.CorrodedMetal)
	lid.Shape = Enum.PartType.Cylinder
	local rocks = {}
	for index = 1, 26 do
		local size = Vector3.new(random:NextNumber(0.55, 2.6), random:NextNumber(0.55, 2.3), random:NextNumber(0.65, 2.5))
		local stack = Vector3.new(random:NextNumber(8.8, 15.2), floorY + size.Y / 2 + (index % 5) * 0.75, random:NextNumber(-83, -77))
		local rock = piece("Piedra desprendida", size, stack + Vector3.new(0, 15, 0), limestone, Enum.Material.Cobblestone)
		table.insert(rocks, { part = rock, stack = stack, time = 25.1 + (index % 10) * 0.17, turn = random:NextNumber(-1.8, 1.8) })
	end
	local returnRocks = {}
	for index = 1, 18 do
		local size = Vector3.new(random:NextNumber(0.65, 3.8), random:NextNumber(0.7, 3), random:NextNumber(0.85, 3))
		local stack = Vector3.new(random:NextNumber(8.7, 15.2), floorY + size.Y / 2 + (index % 5) * 0.8, random:NextNumber(-62, -59))
		local rock = piece("Derrumbe de la salida", size, stack + Vector3.new(0, 13, 0), limestone, Enum.Material.Cobblestone)
		table.insert(returnRocks, { part = rock, stack = stack, time = Location.ReturnAt - 0.48 + (index % 8) * 0.18, turn = random:NextNumber(-1.8, 1.8) })
	end
	local dust = {}
	for index = 1, 24 do
		local mote = piece("Polvo en la luz", Vector3.one * random:NextNumber(0.03, 0.08), Vector3.zero,
			Color3.fromRGB(217, 163, 99), Enum.Material.Neon)
		mote.Shape = Enum.PartType.Ball
		table.insert(dust, { part = mote, phase = index * 0.41,
			courtyard = Vector3.new(random:NextNumber(-10, 8), random:NextNumber(1.1, 6.1), random:NextNumber(6, 22)),
			tunnel = Vector3.new(random:NextNumber(9, 18), floorY + random:NextNumber(1.8, 6.6), random:NextNumber(-78, -70)) })
	end

	local function v(x: number, y: number, z: number): Vector3
		return Vector3.new(x, y, z)
	end

	local shots = {
		{ t = 0, eye = v(-4.5, 3.15, 24), target = v(-16, 7.5, -55) },
		{ t = 3.6, eye = v(-4, 3.15, 20.5), target = v(-11, 4.1, -34) },
		{ t = 7.8, eye = v(4, 3.2, 9), target = v(6.3, 2.7, -9) },
		{ t = 11.5, eye = v(10.2, 3.1, -10), target = v(12.2, 2.8, -23) },
		{ t = 15.3, eye = v(12, 1.35, -28), target = v(12, -4, -44) },
		{ t = 17.9, eye = v(12.4, -5.8, -45), target = v(12.5, -9.1, -63) },
		{ t = 20.8, eye = v(11.5, -8.65, -59), target = v(12, -8.9, -72) },
		{ t = 24.1, eye = v(12.4, -8.65, -68), target = v(12.6, -8.8, -77) },
		{ t = 27.4, eye = v(11.8, -8.9, -69.5), target = v(12.1, -9.65, -79) },
		{ t = 30.3, eye = v(11.8, -8.7, -71.6), target = v(13.3, -9.05, -78.8) },
		{ t = 35, eye = v(13.4, -8.65, -73.5), target = v(22.7, -9.05, -74.8) },
	}

	local function smooth(value: number): number
		return value * value * (3 - 2 * value)
	end

	local function cameraAt(time: number): (Vector3, Vector3)
		for index = 2, #shots do
			local last, nextShot = shots[index - 1], shots[index]
			if time <= nextShot.t then
				local u = smooth(math.clamp((time - last.t) / (nextShot.t - last.t), 0, 1))
				return last.eye:Lerp(nextShot.eye, u), last.target:Lerp(nextShot.target, u)
			end
		end
		return shots[#shots].eye, shots[#shots].target
	end

	local function render(elapsed: number, shakeScale: number?, speaker: string?, effects: boolean?): CFrame
		local time = if elapsed < 17 then elapsed
			elseif elapsed < Location.CollapseAt then 17 + 7 * (elapsed - 17) / (Location.CollapseAt - 17)
			elseif elapsed < Location.ReturnAt then 24 + 5 * (elapsed - Location.CollapseAt) / (Location.ReturnAt - Location.CollapseAt)
			else 29 + 6 * math.clamp((elapsed - Location.ReturnAt) / (Location.Duration - Location.ReturnAt), 0, 1)
		local eye, target = cameraAt(time)
		local swing = smooth(math.clamp((elapsed - 10) / 3, 0, 1))
		lid.CFrame = CFrame.new(offset + v(12 + swing * 2.4, 0.06 + swing * 1.4, -20.7))
			* CFrame.Angles(0, 0, math.pi * 0.5 - swing * 1.3)
		local rear = Location.ReturnAt
		if elapsed >= rear - 2 and elapsed < rear + 6 then
			local turnBack = math.min(smooth(math.clamp((elapsed - rear + 2) / 2, 0, 1)), smooth(math.clamp((rear + 6 - elapsed) / 2, 0, 1)))
			local direction = (target - eye).Unit
			local angle = math.atan2(direction.X, -direction.Z) + turnBack * math.pi
			target = eye + v(math.sin(angle) * 11, -0.2, -math.cos(angle) * 11)
		end
		local march = if elapsed < 17 then 0.86 elseif elapsed < Location.CollapseAt then 0.33 else 0.17
		local z = math.max(-74.8, eye.Z - 5)
		local stepFloor = if z > -22 then 0 elseif z > -50 then math.max(floorY, (z + 22.5) * 0.405) else floorY
		local leadX = if time < 12 then math.clamp(eye.X + 1.4, -4, 13) else 12
		local turn = if time > 29 then -math.pi / 2 * smooth(math.clamp((time - 29) / 3, 0, 1)) else 0
		local turnX = math.min(2.8, math.max(0, time - 30.4))
		local survey = math.clamp((elapsed - 3) / 2, 0, 1) * math.clamp((10 - elapsed) / 2, 0, 1)
		local lift = math.clamp((elapsed - 9.4) * 2, 0, 1) * math.clamp((13.2 - elapsed), 0, 1)
		hikari(v(leadX - 1.28 + turnX * 0.64, stepFloor, z), turn, march, elapsed, 0, 0, speaker == "Hikari", -survey * 1.1)
		matthew(v(leadX + 1.2 + turnX * 0.86, stepFloor, z - 0.7), turn, march, elapsed + 0.19, lift * 0.9, 0,
			speaker == "Matthew", survey * 0.85)

		local guideZ = if time < 10 then -17 elseif time < 17 then math.max(-57, eye.Z - 9) else math.max(-79.5, eye.Z - 10.8)
		local guideY = if guideZ > -22 then 0 elseif guideZ > -50 then math.max(floorY, (guideZ + 22.5) * 0.405) else floorY
		local warning = if time > 17 and time < 24.1 then math.sin((time - 17) / 7.1 * math.pi) else 0
		local buried = smooth(math.clamp((time - 25.6) / 1.75, 0, 1))
		guide(v(12, guideY - buried * 3.1, guideZ), warning * 2.8, if time < 20 then 0.63 else 0,
			elapsed, warning * 1.42 + lift * 0.7, buried * 1.36, speaker == "Guía", math.sin(elapsed * 0.37) * warning * 0.33)

		for _, debris in rocks do
			local travel = math.clamp((time - debris.time) / 0.86, 0, 1)
			local pos = debris.stack + v(0, (1 - travel * travel) * 14.2, 0)
			debris.part.CFrame = CFrame.new(offset + pos) * CFrame.Angles(travel * debris.turn, debris.turn, travel * 0.55)
		end
		for _, debris in returnRocks do
			local travel = math.clamp((elapsed - debris.time) / 0.78, 0, 1)
			debris.part.CFrame = CFrame.new(offset + debris.stack + v(0, (1 - travel * travel) * 13, 0))
				* CFrame.Angles(debris.turn * travel, debris.turn, 0.68 * travel)
		end
		local outside = time < 8
		for _, mote in dust do
			mote.part.Transparency = if effects == false then 1 elseif outside then 0.44 elseif time > 24 then 0.49 else 1
			local point = if outside then mote.courtyard else mote.tunnel
			local fallingDust = if outside then 0 else math.clamp(time - 24, 0, 5) * 0.34
			mote.part.Position = offset + point + v(
				math.sin(time * 1.6 + mote.phase) * 0.42,
				math.sin(time * 1.25 + mote.phase) * 0.17 - fallingDust,
				math.cos(time + mote.phase) * 0.33
			)
		end
		local firstImpact = math.clamp((elapsed - Location.CollapseAt + 1) * 1.4, 0, 1) * math.clamp((Location.CollapseAt + 5 - elapsed) / 2, 0, 1)
		local secondImpact = math.clamp((elapsed - Location.ReturnAt + 1) * 1.4, 0, 1) * math.clamp((Location.ReturnAt + 5 - elapsed) / 3, 0, 1)
		local impact = math.max(firstImpact, secondImpact)
		local cameraImpact = impact * (shakeScale or 1)
		local tremor = v(math.sin(elapsed * 38) * 0.18, math.cos(elapsed * 46) * 0.15, math.sin(elapsed * 41) * 0.12) * cameraImpact
		local headBob = v(0, math.sin(time * 8) * 0.035 * march, 0)
		return CFrame.lookAt(offset + eye + tremor + headBob, offset + target + tremor * 0.34)
			* CFrame.Angles(0, 0, math.sin(elapsed * 31) * 0.038 * cameraImpact)
	end

	render(0)
	scene.Parent = workspace
	return { scene = scene, render = render }
end

return Art
