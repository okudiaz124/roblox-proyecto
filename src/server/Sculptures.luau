--!strict

local AssetService = game:GetService("AssetService")

local Sculptures = {}
local pale = Color3.fromRGB(190, 174, 145)
local worn = Color3.fromRGB(101, 83, 68)
local tooth = Color3.fromRGB(224, 211, 180)
local boar = Color3.fromRGB(168, 140, 128)
local crease = Color3.fromRGB(54, 42, 44)

type Sample = (number, number) -> (Vector3, Color3)

local function ellipsoid(center: Vector3, size: Vector3, color: Color3, roll: number?): Sample
	local transform = CFrame.new(center) * CFrame.Angles(0, 0, roll or 0)
	return function(latitude: number, yaw: number): (Vector3, Color3)
		local elevation = -math.pi * 0.5 + latitude * math.pi
		local ring = math.max(math.cos(elevation), 0.0001)
		return transform:PointToWorldSpace(Vector3.new(
			size.X * math.sin(yaw) * ring, size.Y * math.sin(elevation), -size.Z * math.cos(yaw) * ring
		)), color
	end
end

local function surface(mesh: EditableMesh, vertical: number, radial: number, sample: Sample)
	local previous: { { vertex: number, color: number, normal: number } } = {}
	for index = 0, vertical do
		local current = {}
		for j = 0, radial - 1 do
			local pos, hue = sample(index / vertical, math.pi * 2 * j / radial)
			current[j] = { vertex = mesh:AddVertex(pos), color = mesh:AddColor(hue, 1), normal = mesh:AddNormal() }
		end
		if index > 0 then
			for j = 0, radial - 1 do
				local nextJ = (j + 1) % radial
				local a, b, c, d = previous[j], current[j], current[nextJ], previous[nextJ]
				local first = mesh:AddTriangle(a.vertex, b.vertex, c.vertex)
				local second = mesh:AddTriangle(a.vertex, c.vertex, d.vertex)
				mesh:SetFaceColors(first, { a.color, b.color, c.color })
				mesh:SetFaceColors(second, { a.color, c.color, d.color })
				mesh:SetFaceNormals(first, { a.normal, b.normal, c.normal })
				mesh:SetFaceNormals(second, { a.normal, c.normal, d.normal })
			end
		end
		previous = current
	end
end

local function well(x: number, y: number, centerX: number, centerY: number, width: number, height: number): number
	local d = ((x - centerX) / width)^2 + ((y - centerY) / height)^2
	return math.max(1 - d, 0)^1.6
end

local function construct(draw: (EditableMesh) -> (), name: string, material: Enum.Material): MeshPart?
	local ok, result = pcall(function()
		local mesh = AssetService:CreateEditableMesh()
		if not mesh then return nil end
		draw(mesh)
		local model = AssetService:CreateMeshPartAsync(Content.fromObject(mesh))
		model.Name, model.Material = name, material
		model.Color = Color3.new(1, 1, 1)
		model.Anchored, model.CanCollide, model.CanTouch, model.CanQuery = true, false, false, false
		return model
	end)
	if ok then return result end
	return nil
end

function Sculptures.skull(): MeshPart?
	return construct(function(mesh)
		local profile = {
			{ -0.39, 0.34, 0.37, 0.38 }, { -0.29, 0.47, 0.51, 0.39 }, { -0.05, 0.57, 0.62, 0.48 },
			{ 0.16, 0.61, 0.64, 0.65 }, { 0.4, 0.63, 0.53, 0.7 }, { 0.64, 0.50, 0.44, 0.57 },
			{ 0.79, 0.32, 0.31, 0.37 }, { 0.88, 0.005, 0.005, 0.005 },
		}
		surface(mesh, 24, 36, function(t, yaw)
			local progress = t * (#profile - 1)
			local index = math.min(math.floor(progress) + 1, #profile - 1)
			local f = progress - index + 1
			local p, q = profile[index], profile[index + 1]
			local y = p[1] + (q[1] - p[1]) * f
			local x = (p[2] + (q[2] - p[2]) * f) * math.sin(yaw)
			local front = math.cos(yaw)
			local zSize = if front >= 0 then p[3] + (q[3] - p[3]) * f else p[4] + (q[4] - p[4]) * f
			local socket = if front > 0 then math.max(well(x, y, -0.25, 0.12, 0.21, 0.193),
				well(x, y, 0.25, 0.12, 0.21, 0.193), well(x, y, 0, -0.12, 0.106, 0.19) * 0.86) else 0
			local seam = math.sin(y * 42 + math.sin(x * 9) * 1.3 + yaw * 9) * 0.028
			return Vector3.new(x, y, -zSize * front + socket * 0.41),
				pale:Lerp(worn, math.clamp(socket * 0.84 + seam + 0.03, 0, 1))
		end)
		surface(mesh, 9, 20, ellipsoid(Vector3.new(0, -0.55, -0.22), Vector3.new(0.46, 0.16, 0.41), pale:Lerp(worn, 0.14)))
		for index = -3, 3 do
			local x = index * 0.1
			surface(mesh, 4, 8, ellipsoid(Vector3.new(x, -0.41, -0.61 + x*x * 0.65),
				Vector3.new(0.047, 0.071, 0.049), tooth))
		end
	end, "Cráneo modelado", Enum.Material.Limestone)
end

function Sculptures.mask(): MeshPart?
	return construct(function(mesh)
		surface(mesh, 28, 42, function(t, yaw)
			local elevation = -math.pi * 0.5 + math.pi * t
			local ring = math.max(math.cos(elevation), 0.0001)
			local front = math.cos(yaw)
			local x = 0.64 * math.sin(yaw) * ring
			local y = 0.67 * math.sin(elevation)
			local snout = if front > 0 then well(x, y, 0, -0.18, 0.57, 0.46) else 0
			local eyes = if front > 0 then math.max(well(x, y, 0.36, 0.16, 0.15, 0.17), well(x, y, -0.36, 0.16, 0.15, 0.17)) else 0
			local nostril = if front > 0 then math.max(well(x, y, 0.15, -0.14, 0.104, 0.095), well(x, y, -0.15, -0.14, 0.104, 0.095)) else 0
			local mottle = math.abs(math.sin(x * 31 + yaw * 2.4) * math.sin(y * 34)) * 0.16
			return Vector3.new(x, y, -0.55 * front * ring - snout * 0.64 + eyes * 0.21 + nostril * 0.12),
				boar:Lerp(crease, math.clamp(mottle + eyes * 0.73 + nostril * 0.78, 0, 1))
		end)
		for _, side in { -1, 1 } do
			surface(mesh, 12, 16, ellipsoid(Vector3.new(side * 0.635, 0.25, 0.14), Vector3.new(0.21, 0.48, 0.13),
				boar:Lerp(crease, 0.42), side * 0.74))
		end
		surface(mesh, 10, 18, ellipsoid(Vector3.new(0, -0.53, 0.28), Vector3.new(0.48, 0.56, 0.28), boar:Lerp(crease, 0.26), 0.16))
	end, "Máscara orgánica", Enum.Material.Leather)
end

return Sculptures
