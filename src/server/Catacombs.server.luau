--!strict

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local world = Workspace:WaitForChild("World")

local stone = Color3.fromRGB(65, 64, 59)
local limestone = Color3.fromRGB(92, 87, 75)
local wetStone = Color3.fromRGB(45, 43, 41)
local amber = Color3.fromRGB(244, 157, 78)
local random = Random.new(1786)

local section = Instance.new("Model")
section.Name = "Catacombs"

local function block(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.Parent = section
	return part
end

local function masonry(name: string, size: Vector3, position: Vector3, color: Color3?): Part
	return block(name, size, position, color or stone, Enum.Material.Cobblestone)
end

local function lamp(position: Vector3, direction: Enum.NormalId)
	local lens = block("Lámpara de emergencia", Vector3.new(0.85, 0.32, 0.34), position, amber, Enum.Material.Neon)
	lens.CanCollide = false
	local light = Instance.new("SurfaceLight")
	light.Face = direction
	light.Color = amber
	light.Range = 11
	light.Brightness = 0.9
	light.Angle = 130
	light.Shadows = true
	light.Parent = lens
end

-- Pasillo principal, abertura lateral y galería en escuadra.
masonry("Piso del acceso", Vector3.new(12, 1, 52), Vector3.new(0, -0.5, -16), wetStone)
masonry("Techo del acceso", Vector3.new(12, 1, 52), Vector3.new(0, 8.5, -16))
masonry("Muro oeste", Vector3.new(1, 8, 52), Vector3.new(-6, 4, -16))
masonry("Muro este anterior", Vector3.new(1, 8, 29), Vector3.new(6, 4, -4.5))
masonry("Muro este posterior", Vector3.new(1, 8, 15), Vector3.new(6, 4, -34.5))
masonry("Derrumbe tras el grupo", Vector3.new(12, 8, 1), Vector3.new(0, 4, 10))
masonry("Túnel principal sepultado", Vector3.new(12, 8, 4), Vector3.new(0, 4, -40), wetStone)

masonry("Piso del desvío", Vector3.new(26, 1, 8), Vector3.new(19, -0.5, -23), wetStone)
masonry("Techo del desvío", Vector3.new(26, 1, 8), Vector3.new(19, 8.5, -23))
masonry("Lado sur del desvío", Vector3.new(26, 8, 1), Vector3.new(19, 4, -19))
masonry("Lado norte del desvío", Vector3.new(18, 8, 1), Vector3.new(15, 4, -27))

masonry("Piso de galería", Vector3.new(8, 1, 29), Vector3.new(28, -0.5, -41.5), wetStone)
masonry("Techo de galería", Vector3.new(8, 1, 29), Vector3.new(28, 8.5, -41.5))
masonry("Muro oeste de galería", Vector3.new(1, 8, 29), Vector3.new(24, 4, -41.5))
masonry("Muro este de galería", Vector3.new(1, 8, 37), Vector3.new(32, 4, -37.5))
masonry("Puerta del osario", Vector3.new(8, 8, 1), Vector3.new(28, 4, -56), wetStone)

for _ = 1, 16 do
	local size = Vector3.new(random:NextNumber(1, 3.5), random:NextNumber(0.5, 2.5), random:NextNumber(1, 3))
	local position = Vector3.new(random:NextNumber(-5, 5), size.Y * 0.5, random:NextNumber(-38, -32))
	local debris = masonry("Piedra caída", size, position, limestone)
	debris.Orientation = Vector3.new(0, random:NextNumber(-40, 40), 0)
end

for _, z in { 4, -7, -18, -30 } do
	for _, x in { -5.5, 5.5 } do
		masonry("Pilar", Vector3.new(0.7, 8, 1.2), Vector3.new(x, 4, z), limestone)
	end
	masonry("Dintel", Vector3.new(12, 0.7, 1.2), Vector3.new(0, 7.7, z), limestone)
end

lamp(Vector3.new(0, 7.85, 2), Enum.NormalId.Bottom)
lamp(Vector3.new(6.7, 7.85, -23), Enum.NormalId.Bottom)
lamp(Vector3.new(28, 7.85, -52), Enum.NormalId.Bottom)

local bone = Color3.fromRGB(190, 173, 141)
for _, z in { -32, -39, -46 } do
	masonry("Repisa del osario", Vector3.new(1.2, 0.28, 4.2), Vector3.new(24.65, 2.5, z), limestone)
	for index = -1, 1 do
		local skull = block("Restos del osario", Vector3.new(0.49, 0.57, 0.53),
			Vector3.new(24.97, 2.91, z + index * 1.12), bone, Enum.Material.Slate)
		skull.Shape = Enum.PartType.Ball
		skull.CanCollide = false
		for _, offset in { -0.11, 0.11 } do
			local socket = block("Cuenca", Vector3.new(0.036, 0.13, 0.11),
				skull.Position + Vector3.new(0.226, 0.045, offset), wetStone, Enum.Material.Slate)
			socket.Shape = Enum.PartType.Ball
			socket.CanCollide = false
		end
	end
end

for index = -1, 1 do
	local mark = block("Marca tallada", Vector3.new(0.075, 0.71, 0.035),
		Vector3.new(28 + index * 0.22, 4.8, -55.48), Color3.fromRGB(144, 128, 103), Enum.Material.Slate)
	mark.Orientation = Vector3.new(0, 0, -15)
	mark.CanCollide = false
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Tras el derrumbe"
spawn.Size = Vector3.new(6, 0.15, 5)
spawn.Position = Vector3.new(0, 0.1, 6)
spawn.Anchored = true
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Neutral = true
spawn.Duration = 0
spawn.Parent = section

Lighting.Ambient = Color3.fromRGB(24, 23, 27)
Lighting.OutdoorAmbient = Color3.fromRGB(47, 49, 56)
Lighting.Brightness = 1.2
Lighting.ClockTime = 19.6
Lighting.GlobalShadows = true
section.Parent = world
