--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Location = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Location"))
local Palette = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ArtPalette"))
local offset = Location.Origin
local amber = Color3.fromRGB(241, 157, 80)
local pavement = Color3.fromRGB(62, 65, 73)
local limestone = Color3.fromRGB(108, 98, 84)
local cave = Color3.fromRGB(57, 52, 48)

local Scenery = {}

function Scenery.build(scene: Instance)
	local function piece(name: string, size: Vector3, position: Vector3, color: Color3,
		material: Enum.Material?, parent: Instance?): Part
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Position = offset + position
		part.Color = color
		part.Material = material or Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = true
		part.CanQuery = true
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

	piece("Mirador de París", Vector3.new(54, 1, 52), Vector3.new(0, -0.55, 5), pavement, Enum.Material.Cobblestone)
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
			local wall = Palette.facade:Lerp(Color3.fromRGB(72, 78, 99), row * 0.23)
			piece("Fachada parisina", Vector3.new(11.5, h, 9), Vector3.new(x, visibleTop - h / 2, z), wall)
			piece("Cornisa de caliza", Vector3.new(11.8, 0.22, 9.28), Vector3.new(x, visibleTop - 0.24, z), wall:Lerp(limestone, 0.33), Enum.Material.Limestone)
			piece("Balcón corrido", Vector3.new(9.67, 0.18, 0.71), Vector3.new(x, visibleTop - 2.31, z + 4.71), Palette.metal, Enum.Material.Metal)
			piece("Baranda", Vector3.new(9.5, 0.09, 0.075), Vector3.new(x, visibleTop - 1.91, z + 5.04), Palette.metal, Enum.Material.Metal)
			for _, chimney in { -3.2, 3.6 } do
				piece("Chimenea de zinc", Vector3.new(0.67, 1.83, 0.65), Vector3.new(x + chimney, visibleTop + 2.42, z + 0.68),
					wall:Lerp(Palette.roof, 0.43), Enum.Material.Brick)
			end
			for _, side in { -1, 1 } do
				local roof = piece("Mansarda", Vector3.new(11.9, 0.6, 6.3),
					Vector3.new(x, visibleTop + 1.1, z + side * 2.24), Palette.roof, Enum.Material.Slate)
				roof.Orientation = Vector3.new(side * 26, 0, 0)
			end
			for window = -2, 2 do
				for level = 0, 1 do
					local lit = random:NextNumber() > 0.42
					piece("Ventana", Vector3.new(0.72, 1.05, 0.09), Vector3.new(x + window * 1.88, visibleTop - 1.6 - level * 2, z + 4.53),
						if lit then Palette.window else Color3.fromRGB(53, 56, 73),
						if lit then Enum.Material.Neon else nil)
				end
			end
		end
	end

	local tower = Vector3.new(-29, -9, -112)
	local iron = Color3.fromRGB(104, 85, 72)
	local gold = Color3.fromRGB(220, 153, 78)
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			local foot = tower + Vector3.new(15 * x, 0, 12 * z)
			local gallery = tower + Vector3.new(7 * x, 25, 6 * z)
			local second = tower + Vector3.new(3.3 * x, 42, 3 * z)
			local tip = tower + Vector3.new(0.75 * x, 69, 0.75 * z)
			beam("Pata Eiffel", foot, gallery, 1.45, iron, Enum.Material.Metal)
			beam("Diagonal Eiffel", foot + Vector3.new(0, 2, 0), gallery + Vector3.new(-x * 2.5, 0, -z * 2.25), 0.52, gold, Enum.Material.Neon)
			beam("Costilla Eiffel", gallery, second, 1.08, gold, Enum.Material.Neon)
			beam("Aguja Eiffel", second, tip, 0.7, gold, Enum.Material.Neon)
		end
	end
	piece("Primera plataforma de la torre", Vector3.new(12, 1, 10), tower + Vector3.new(0, 25, 0), iron)
	piece("Segunda plataforma de la torre", Vector3.new(6, 0.65, 5.5), tower + Vector3.new(0, 42, 0), gold, Enum.Material.Neon)
	for level = 0, 6 do
		local y = 26 + level * 5.6
		local width = 6.7 - level * 0.78
		local nextWidth = width - 0.58
		for _, side in { -1, 1 } do
			beam("Riostra de hierro", tower + Vector3.new(-width, y, side * width * 0.82),
				tower + Vector3.new(nextWidth, y + 4.95, side * nextWidth * 0.82), 0.34, gold, Enum.Material.Neon)
			beam("Riostra cruzada", tower + Vector3.new(width, y, side * width * 0.82),
				tower + Vector3.new(-nextWidth, y + 4.95, side * nextWidth * 0.82), 0.28, iron, Enum.Material.Metal)
		end
	end
	piece("Antena", Vector3.new(0.45, 7, 0.45), tower + Vector3.new(0, 72, 0), iron)
	lightAt("Faro de la torre", tower + Vector3.new(0, 76, 0), gold, 11, 1)

	-- El descenso y las dos galerías esconden el fondo de París tras el umbral.
	local iron = Color3.fromRGB(57, 51, 47)
	for index = 0, 11 do
		local angle = index * math.pi / 6
		local point = Vector3.new(12 + math.cos(angle) * 2.35, 0.07, -20.85 + math.sin(angle) * 2.35)
		local rim = piece("Aro de alcantarilla", Vector3.new(1.3, 0.14, 0.37), point, iron, Enum.Material.CorrodedMetal)
		rim.CFrame = CFrame.new(rim.Position) * CFrame.Angles(0, -angle - math.pi / 2, 0)
	end
	local cover = piece("OpenManhole", Vector3.new(0.16, 4.18, 4.18),
		Vector3.new(14.4, 1.46, -20.7), iron, Enum.Material.CorrodedMetal)
	cover.Shape = Enum.PartType.Cylinder
	cover.CFrame = CFrame.new(cover.Position) * CFrame.Angles(0, 0, math.pi * 0.5 - 1.3)
	piece("Boca de alcantarilla", Vector3.new(4.2, 0.18, 4.4), Vector3.new(12, -0.36, -20.9), cave)
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
	lightAt("Lámpara del desvío", Vector3.new(21, floorY + 4.4, -74), Color3.fromRGB(223, 126, 74), 17, 1.65)

	piece("Techo del desvío", Vector3.new(12, 1, 11), Vector3.new(22, floorY + 7, -74.5), cave, Enum.Material.Cobblestone)
	for _, z in { -80, -69 } do
		piece("Muro del paso", Vector3.new(12, 7, 1), Vector3.new(22, floorY + 3.5, z), cave, Enum.Material.Cobblestone)
	end
end

return Scenery
