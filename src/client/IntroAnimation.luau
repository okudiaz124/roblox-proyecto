--!strict

local Art = {}
local offset = Vector3.new(600, 56, 0)
local amber = Color3.fromRGB(241, 157, 80)
local pavement = Color3.fromRGB(62, 65, 73)
local limestone = Color3.fromRGB(108, 98, 84)
local cave = Color3.fromRGB(57, 52, 48)

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

	local function beam(name: string, a: Vector3, b: Vector3, width: number, color: Color3, material: Enum.Material?)
		local length = (a - b).Magnitude
		local part = piece(name, Vector3.new(width, width, length), (a + b) * 0.5, color, material)
		part.CFrame = CFrame.lookAt(part.Position, offset + b)
		return part
	end

	local function lightAt(name: string, pos: Vector3, color: Color3, range: number, brightness: number)
		local bulb = piece(name, Vector3.new(0.27, 0.32, 0.27), pos, color, Enum.Material.Neon)
		local light = Instance.new("PointLight")
		light.Color = color
		light.Range = range
		light.Brightness = brightness
		light.Parent = bulb
		return bulb, light
	end

	piece("Mirador de París", Vector3.new(54, 1, 65), Vector3.new(0, -0.55, 4), pavement, Enum.Material.Cobblestone)
	piece("Muro del mirador", Vector3.new(31, 1.15, 0.9), Vector3.new(-12, 0.58, -19.5), limestone, Enum.Material.Limestone)
	piece("Remate del mirador", Vector3.new(31.5, 0.24, 1.15), Vector3.new(-12, 1.27, -19.5), limestone)
	for _, z in { 22, 5, -12 } do
		for _, x in { -10, 11 } do
			piece("Farol parisino", Vector3.new(0.19, 7, 0.19), Vector3.new(x, 3.5, z), pavement, Enum.Material.Metal)
			lightAt("Luz del farol", Vector3.new(x, 6.9, z), amber, 23, 1.7)
		end
	end

	local random = Random.new(1889)
	for row = 1, 2 do
		for index = -5, 5 do
			local x = index * 13 + row * 3
			local z = -66 - 24 * row
			local h = random:NextNumber(6, 14)
			local visibleTop = -3.5 + h
			local wall = Color3.fromRGB(80 + row * 6, 83 + row * 4, 102 + row * 3)
			piece("Fachada parisina", Vector3.new(11.5, h, 9), Vector3.new(x, visibleTop - h / 2, z), wall)
			for _, side in { -1, 1 } do
				local roof = piece("Mansarda", Vector3.new(11.9, 0.6, 6.3),
					Vector3.new(x, visibleTop + 1.1, z + side * 2.24), Color3.fromRGB(47, 51, 72), Enum.Material.Slate)
				roof.Orientation = Vector3.new(side * 26, 0, 0)
			end
			for window = -2, 2 do
				for level = 0, 1 do
					local lit = random:NextNumber() > 0.42
					piece("Ventana", Vector3.new(0.72, 1.05, 0.09), Vector3.new(x + window * 1.88, visibleTop - 1.6 - level * 2, z + 4.53),
						if lit then Color3.fromRGB(185, 132, 89) else Color3.fromRGB(53, 56, 73),
						if lit then Enum.Material.Neon else nil)
				end
			end
		end
	end

	local tower = Vector3.new(-27, -11, -128)
	local iron = Color3.fromRGB(104, 85, 72)
	local gold = Color3.fromRGB(220, 153, 78)
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			local foot = tower + Vector3.new(10 * x, 0, 9 * z)
			local gallery = tower + Vector3.new(5 * x, 17, 4.5 * z)
			local second = tower + Vector3.new(2.5 * x, 29, 2.25 * z)
			local tip = tower + Vector3.new(0.75 * x, 49, 0.75 * z)
			beam("Pata Eiffel", foot, gallery, 1.45, iron, Enum.Material.Metal)
			beam("Diagonal Eiffel", foot + Vector3.new(0, 2, 0), gallery + Vector3.new(-x * 2.5, 0, -z * 2.25), 0.52, gold, Enum.Material.Neon)
			beam("Costilla Eiffel", gallery, second, 1.08, gold, Enum.Material.Neon)
			beam("Aguja Eiffel", second, tip, 0.7, gold, Enum.Material.Neon)
		end
	end
	piece("Primera plataforma de la torre", Vector3.new(12, 1, 10), tower + Vector3.new(0, 17, 0), iron)
	piece("Segunda plataforma de la torre", Vector3.new(6, 0.65, 5.5), tower + Vector3.new(0, 29, 0), gold, Enum.Material.Neon)
	piece("Antena", Vector3.new(0.45, 7, 0.45), tower + Vector3.new(0, 52, 0), iron)
	lightAt("Faro de la torre", tower + Vector3.new(0, 56, 0), gold, 11, 1)

	-- El descenso y las dos galerías esconden el fondo de París tras el umbral.
	for _, side in { -1, 1 } do
		piece("Pilastra del acceso", Vector3.new(2.5, 8, 1.4), Vector3.new(12 + side * 4.2, 4, -22), limestone, Enum.Material.Limestone)
		piece("Fachada del acceso", Vector3.new(6.3, 7.5, 1.2), Vector3.new(12 + side * 7.5, 3.75, -22), limestone, Enum.Material.Limestone)
	end
	piece("Dintel del acceso", Vector3.new(12, 1.5, 1.65), Vector3.new(12, 7.2, -22), limestone, Enum.Material.Limestone)
	piece("Escalón del umbral", Vector3.new(8, 0.4, 2), Vector3.new(12, -0.2, -21.5), cave)
	for step = 0, 15 do
		local y, z = -step * 0.75, -22.5 - step * 1.85
		piece("Peldaño", Vector3.new(8, 0.8, 1.88), Vector3.new(12, y - 0.43, z), cave, Enum.Material.Cobblestone)
		piece("Bóveda de descenso", Vector3.new(8, 0.85, 1.88), Vector3.new(12, y + 6.95, z), cave, Enum.Material.Cobblestone)
		for _, side in { -1, 1 } do
			piece("Piedra del descenso", Vector3.new(0.85, 8, 1.88), Vector3.new(12 + side * 4, y + 3.55, z), cave, Enum.Material.Cobblestone)
		end
		if step % 5 == 2 then lightAt("Lámpara de descenso", Vector3.new(8.5, y + 4.1, z), amber, 14, 1.3) end
	end
	local floorY = -11.85
	piece("Piso de galería", Vector3.new(9, 1, 40), Vector3.new(12, floorY - 0.5, -69), cave, Enum.Material.Cobblestone)
	piece("Bóveda del temblor", Vector3.new(9, 1, 40), Vector3.new(12, floorY + 7, -69), cave, Enum.Material.Cobblestone)
	piece("Muro izquierdo", Vector3.new(1, 7, 40), Vector3.new(8, floorY + 3.5, -69), cave, Enum.Material.Cobblestone)
	for _, span in { { 20, -59 }, { 9, -84.5 } } do
		piece("Muro derecho", Vector3.new(1, 7, span[1]), Vector3.new(16, floorY + 3.5, span[2]), cave, Enum.Material.Cobblestone)
	end
	piece("Abertura hacia el desvío", Vector3.new(12, 1, 11), Vector3.new(22, floorY - 0.5, -74.5), cave, Enum.Material.Cobblestone)
	piece("Piedra al fondo", Vector3.new(9, 7, 1), Vector3.new(12, floorY + 3.5, -89), cave, Enum.Material.Cobblestone)
	for _, z in { -55, -67, -76 } do
		lightAt("Luz del túnel", Vector3.new(8.55, floorY + 4.9, z), amber, 17, 1.65)
	end
	local _, sideLight = lightAt("Lámpara del desvío", Vector3.new(21, floorY + 4.4, -74), Color3.fromRGB(223, 126, 74), 17, 1.65)

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
		local bag = piece("Equipo", Vector3.new(0.68, 0.9, 0.43), Vector3.zero, badge, nil, folder)
		local map = if holdsMap then piece("Mapa doblado", Vector3.new(0.59, 0.42, 0.05), Vector3.zero,
			Color3.fromRGB(215, 187, 136), Enum.Material.SmoothPlastic, folder) else nil
		local arm = {} :: { Part }
		local leg = {} :: { Part }
		for index = 1, 2 do
			arm[index] = piece("Brazo", Vector3.new(0.3, 1.17, 0.34), Vector3.zero, coat, nil, folder)
			leg[index] = piece("Pierna", Vector3.new(0.43, 1.45, 0.43), Vector3.zero, Color3.fromRGB(47, 44, 48), nil, folder)
		end
		return function(pos: Vector3, turn: number, stride: number, time: number, point: number, falling: number)
			local gait = math.sin(time * 8.8) * stride
			local root = CFrame.new(offset + pos + Vector3.new(0, math.abs(gait) * 0.065, 0))
				* CFrame.Angles(0, turn, falling)
			torso.CFrame = root * CFrame.new(0, 2.15, 0)
			head.CFrame = root * CFrame.new(0, 3.15, 0)
			hair.CFrame = root * CFrame.new(0, 3.47, 0.035)
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

	local ines = actor("Inés", Color3.fromRGB(105, 57, 60), Color3.fromRGB(81, 78, 96))
	local leo = actor("Leo", Color3.fromRGB(60, 104, 107), Color3.fromRGB(80, 70, 55), true)
	local guide = actor("Guía", Color3.fromRGB(94, 78, 55), Color3.fromRGB(165, 98, 54))
	local rocks = {}
	for index = 1, 26 do
		local size = Vector3.new(random:NextNumber(0.55, 2.6), random:NextNumber(0.55, 2.3), random:NextNumber(0.65, 2.5))
		local stack = Vector3.new(random:NextNumber(8.8, 15.2), floorY + size.Y / 2 + (index % 5) * 0.75, random:NextNumber(-83, -77))
		local rock = piece("Piedra desprendida", size, stack + Vector3.new(0, 15, 0), limestone, Enum.Material.Cobblestone)
		table.insert(rocks, { part = rock, stack = stack, time = 25.1 + (index % 10) * 0.17, turn = random:NextNumber(-1.8, 1.8) })
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

	local function render(time: number): CFrame
		local eye, target = cameraAt(time)
		local march = if time < 24.1 then 0.86 else 0.16
		local z = math.max(-74.8, eye.Z - 5)
		local stepFloor = if z > -22 then 0 elseif z > -50 then math.max(floorY, (z + 22.5) * 0.405) else floorY
		local leadX = if time < 12 then math.clamp(eye.X + 1.4, -4, 13) else 12
		local turn = if time > 29 then -math.pi / 2 * smooth(math.clamp((time - 29) / 3, 0, 1)) else 0
		local turnX = math.max(0, time - 30.4)
		ines(v(leadX - 1.28 + turnX * 0.64, stepFloor, z), turn, march, time, 0, 0)
		leo(v(leadX + 1.2 + turnX * 0.86, stepFloor, z - 0.7), turn, march, time + 0.19, 0, 0)

		local guideZ = if time < 10 then -17 elseif time < 17 then math.max(-57, eye.Z - 9) else math.max(-79.5, eye.Z - 10.8)
		local guideY = if guideZ > -22 then 0 elseif guideZ > -50 then math.max(floorY, (guideZ + 22.5) * 0.405) else floorY
		local warning = if time > 17 and time < 24.1 then math.sin((time - 17) / 7.1 * math.pi) else 0
		local buried = smooth(math.clamp((time - 25.6) / 1.75, 0, 1))
		guide(v(12, guideY - buried * 3.1, guideZ), warning * 2.8, if time < 20 then 0.7 else 0,
			time, warning * 1.42, buried * 1.36)

		for _, debris in rocks do
			local travel = math.clamp((time - debris.time) / 0.86, 0, 1)
			local pos = debris.stack + v(0, (1 - travel * travel) * 14.2, 0)
			debris.part.CFrame = CFrame.new(offset + pos) * CFrame.Angles(travel * debris.turn, debris.turn, travel * 0.55)
		end
		local outside = time < 8
		for _, mote in dust do
			mote.part.Transparency = if outside then 0.44 elseif time > 24 then 0.49 else 1
			local point = if outside then mote.courtyard else mote.tunnel
			local fallingDust = if outside then 0 else math.clamp(time - 24, 0, 5) * 0.34
			mote.part.Position = offset + point + v(
				math.sin(time * 1.6 + mote.phase) * 0.42,
				math.sin(time * 1.25 + mote.phase) * 0.17 - fallingDust,
				math.cos(time + mote.phase) * 0.33
			)
		end
		local impact = math.clamp((time - 23.95) * 3, 0, 1) * math.clamp((30 - time) / 2, 0, 1)
		local tremor = v(math.sin(time * 38) * 0.18, math.cos(time * 46) * 0.15, math.sin(time * 41) * 0.12) * impact
		sideLight.Brightness = 1.65 - impact * (0.45 + math.abs(math.sin(time * 25)) * 0.8)
		local headBob = v(0, math.sin(time * 8) * 0.035 * march, 0)
		return CFrame.lookAt(offset + eye + tremor + headBob, offset + target + tremor * 0.34)
			* CFrame.Angles(0, 0, math.sin(time * 31) * 0.038 * impact)
	end

	render(0)
	scene.Parent = workspace
	return { scene = scene, render = render }
end

return Art
