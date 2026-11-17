--!strict

local RunService = game:GetService("RunService")
local Maze = {}
local Sculptures = require(script.Parent.Sculptures)
local size, span = 15, 17
local directions = { Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0), Vector2.new(0, -1) }
local stone = Color3.fromRGB(66, 61, 59)
local damp = Color3.fromRGB(43, 44, 44)
local bone = Color3.fromRGB(157, 145, 120)
local ember = Color3.fromRGB(226, 135, 76)

export type Node = {
	id: number, x: number, z: number, position: Vector3, links: { [number]: number }, depth: number,
}
export type Layout = {
	folder: Folder, nodes: { Node }, entrance: Node, gate: Node, reveal: Node,
	rubies: { Node }, rituals: { Node }, route: (Vector3, Vector3) -> { Vector3 },
	nearest: (Vector3) -> Node,
}

function Maze.part(parent: Instance, name: string, size3: Vector3, cf: CFrame, color: Color3, material: Enum.Material, collide: boolean?): Part
	local part = Instance.new("Part")
	part.Name, part.Size, part.CFrame = name, size3, cf
	part.Color, part.Material, part.Anchored = color, material, true
	part.CanCollide = collide ~= false
	part.CanTouch = false
	part.CanQuery = collide ~= false
	part.Parent = parent
	return part
end

local function position(parent: Instance, name: string, size3: Vector3, pos: Vector3, color: Color3, material: Enum.Material, collide: boolean?): Part
	return Maze.part(parent, name, size3, CFrame.new(pos), color, material, collide)
end

local function decorateRitual(parent: Instance, node: Node, alternate: boolean)
	local center = node.position + Vector3.new(4.2, 0, -4.4)
	position(parent, "Dosel del altar", Vector3.new(5.1, 0.9, 3.5), center + Vector3.new(0, 0.45, 0), stone, Enum.Material.Slate, false)
	position(parent, "Mesa ritual", Vector3.new(3.5, 0.8, 2.1), center + Vector3.new(0, 1.3, 0), damp, Enum.Material.Slate)
	for _, x in { -1.26, 1.26 } do
		local candleAt = center + Vector3.new(x, 1.98, -0.69)
		position(parent, "Vela de sebo", Vector3.new(0.16, 0.54, 0.16), candleAt, bone, Enum.Material.SmoothPlastic, false)
		local flame = position(parent, "Llama", Vector3.new(0.11, 0.16, 0.11), candleAt + Vector3.yAxis * 0.34, ember, Enum.Material.Neon, false)
		local light = Instance.new("PointLight")
		light.Color, light.Range, light.Brightness = ember, 9, 0.72
		light.Parent = flame
	end
	for index = 1, 6 do
		local fragment = Maze.part(parent, "Restos antiguos", Vector3.new(0.13, 0.14, 0.72),
			CFrame.new(center + Vector3.new((index - 3.5) * 0.26, 1.76, 0.22)) * CFrame.Angles(0, index * 0.62, 0),
			bone, Enum.Material.Limestone, false)
		fragment.Shape = Enum.PartType.Cylinder
	end
	if alternate then
		for index = 1, 3 do
			position(parent, "Escalón de la hornacina", Vector3.new(4.8, index * 0.35, 1.05),
				center + Vector3.new(0, index * 0.175, 4.9 - index), stone, Enum.Material.Cobblestone)
		end
	end
end

local function rat(parent: Instance, center: Vector3, seed: number)
	local fur = Color3.fromRGB(55, 48, 47)
	local torso = position(parent, "Rata", Vector3.new(0.37, 0.32, 0.66), center, fur, Enum.Material.Fabric, false)
	local muzzle = position(parent, "Hocico de rata", Vector3.new(0.25, 0.2, 0.32), center, fur, Enum.Material.Fabric, false)
	local tail = position(parent, "Cola de rata", Vector3.new(0.055, 0.055, 0.64), center, Color3.fromRGB(85, 65, 61), Enum.Material.SmoothPlastic, false)
	torso.Shape, muzzle.Shape = Enum.PartType.Ball, Enum.PartType.Ball
	local pause = 0
	RunService.Heartbeat:Connect(function(dt)
		pause += dt
		if pause < 0.09 then return end
		pause = 0
		local t = os.clock() * 0.83 + seed * 8.1
		local here = center + Vector3.new(math.sin(t) * 2.15, 0.16, math.cos(t * 1.7) * 1.42)
		local aim = Vector3.new(math.cos(t) * 2.15, 0, -math.sin(t * 1.7) * 2.414)
		if aim.Magnitude < 0.01 then return end
		local pose = CFrame.lookAt(here, here + aim)
		torso.CFrame = pose
		muzzle.CFrame = pose * CFrame.new(0, -0.01, -0.4)
		tail.CFrame = pose * CFrame.new(0, -0.07, 0.61) * CFrame.Angles(0, math.sin(t * 7) * 0.25, 0)
	end)
end

function Maze.build(parent: Instance, origin: Vector3): Layout
	local rng = Random.new(187592)
	local folder = Instance.new("Folder")
	folder.Name = "Labyrinth"
	local carvedSkull = Sculptures.skull()
	local nodes: { Node } = {}
	local function get(x: number, z: number): Node?
		if x < 1 or z < 1 or x > size or z > size then return nil end
		return nodes[(z - 1) * size + x]
	end
	for z = 1, size do
		for x = 1, size do
			table.insert(nodes, { id = #nodes + 1, x = x, z = z,
				position = origin + Vector3.new((x - 1) * span, 0, -(z - 1) * span), links = {}, depth = -1 })
		end
	end

	local function neighbor(node: Node, direction: number): Node?
		local delta = directions[direction]
		return get(node.x + delta.X, node.z + delta.Y)
	end
	local function join(a: Node, b: Node, direction: number)
		a.links[direction] = b.id
		b.links[(direction + 1) % 4 + 1] = a.id
	end
	local entry = nodes[1]
	local visited = { [entry.id] = true }
	local stack = { entry }
	while #stack > 0 do
		local current = stack[#stack]
		local candidates = {}
		for direction = 1, 4 do
			local node = neighbor(current, direction)
			if node and not visited[node.id] then
				table.insert(candidates, { node = node, direction = direction })
			end
		end
		if #candidates == 0 then
			table.remove(stack)
		else
			local edge = candidates[rng:NextInteger(1, #candidates)]
			join(current, edge.node, edge.direction)
			visited[edge.node.id] = true
			table.insert(stack, edge.node)
		end
	end
	for _, node in nodes do
		for direction = 1, 2 do
			local other = neighbor(node, direction)
			if other and not node.links[direction] and rng:NextNumber() < 0.18 then
				join(node, other, direction)
			end
		end
	end
	local function traverse(first: Node): ({ [number]: number }, { [number]: number })
		local queue = { first }
		local prev = { [first.id] = 0 }
		local distance = { [first.id] = 0 }
		local cursor = 1
		while queue[cursor] do
			local here = queue[cursor]
			cursor += 1
			for _, child in here.links do
				if prev[child] == nil then
					prev[child] = here.id
					distance[child] = distance[here.id] + 1
					table.insert(queue, nodes[child])
				end
			end
		end
		return prev, distance
	end
	local previous, depths = traverse(entry)
	local gate = entry
	for _, node in nodes do
		node.depth = depths[node.id]
		if node.x == size and node.depth > gate.depth then gate = node end
	end
	local reveal = nodes[previous[gate.id]] or entry
	local function nearest(point: Vector3): Node
		local x = math.clamp(math.round((point.X - origin.X) / span) + 1, 1, size)
		local z = math.clamp(math.round((origin.Z - point.Z) / span) + 1, 1, size)
		return nodes[(z - 1) * size + x]
	end
	local function route(from: Vector3, destination: Vector3): { Vector3 }
		local first, last = nearest(from), nearest(destination)
		local path = {}
		if first == last then
			return { destination }
		end
		local predecessors = traverse(first)
		local id = last.id
		while id and id ~= 0 do
			table.insert(path, 1, nodes[id].position)
			id = predecessors[id]
		end
		table.insert(path, destination)
		return path
	end

	local targetZones = { Vector2.new(2, 12), Vector2.new(8, 3), Vector2.new(13, 12) }
	local rubies = {}
	local rituals = {}
	for _, target in targetZones do
		local best, score = entry, math.huge
		for _, node in nodes do
			local degree = 0
			for _ in node.links do degree += 1 end
			local cost = (Vector2.new(node.x, node.z) - target).Magnitude - (if degree == 1 then 2.2 else 0)
			if node.depth >= 7 and node ~= gate and node ~= reveal and cost < score then
				best, score = node, cost
			end
		end
		table.insert(rubies, best)
	end
	rituals = { rubies[1], rubies[3] }

	for _, node in nodes do
		local bay = Instance.new("Folder")
		bay.Name = string.format("Galería %02d-%02d", node.x, node.z)
		bay.Parent = folder
		local pos = node.position
		position(bay, "Suelo húmedo", Vector3.new(span, 1, span), pos - Vector3.yAxis * 0.5, damp, Enum.Material.Cobblestone)
		position(bay, "Bóveda", Vector3.new(span, 1, span), pos + Vector3.yAxis * 8.5, stone, Enum.Material.Slate)
		for direction, delta in directions do
			local neighborCell = neighbor(node, direction)
			local entryGap = node == entry and direction == 3
			local gateGap = node == gate and direction == 1
			local secretGap = node.z == size and direction == 2 and (node.x == 3 or node.x == 8 or node.x == 12)
			local side = Vector3.new(delta.X, 0, -delta.Y)
			local at = pos + side * (span / 2) + Vector3.yAxis * 4
			local buildBoundary = not neighborCell or direction <= 2
			if buildBoundary then
				local width = if direction % 2 == 1 then Vector3.new(1, 8, span + 1) else Vector3.new(span + 1, 8, 1)
				if secretGap then
					for _, sign in { -1, 1 } do
						position(bay, "Entrada oculta", Vector3.new(7, 8, 1), at + Vector3.xAxis * sign * 5.2, stone, Enum.Material.Cobblestone)
					end
					local chamber = pos + Vector3.new(0, 0, -14)
					position(bay, "Suelo de la cámara oculta", Vector3.new(10, 1, 11), chamber - Vector3.yAxis * 0.5, damp, Enum.Material.Slate)
					position(bay, "Techo de la cámara oculta", Vector3.new(10, 1, 11), chamber + Vector3.yAxis * 7.5, stone, Enum.Material.Slate)
					for _, sign in { -1, 1 } do
						position(bay, "Pared de la cámara oculta", Vector3.new(1, 7, 11), chamber + Vector3.new(5 * sign, 3.5, 0), stone, Enum.Material.Cobblestone)
					end
					position(bay, "Nicho sellado", Vector3.new(10, 7, 1), chamber + Vector3.new(0, 3.5, -5.5), stone, Enum.Material.Slate)
					position(bay, "Escalón del nicho", Vector3.new(4, 0.42, 2), chamber + Vector3.new(0, 0.21, -3.1), stone, Enum.Material.Slate)
				elseif not (entryGap or gateGap or node.links[direction]) then
					position(bay, "Piedra de separación", width, at, stone, Enum.Material.Cobblestone)
				elseif not entryGap and not gateGap then
					local along = Vector3.new(side.Z, 0, -side.X)
					local jamb = if direction % 2 == 1 then Vector3.new(1, 8, 4.75) else Vector3.new(4.75, 8, 1)
					for _, sign in { -1, 1 } do
						position(bay, "Pilastra", jamb, at + along * sign * 6.65, stone, Enum.Material.Limestone)
					end
					position(bay, "Dintel", Vector3.new(width.X, 1.5, width.Z), at + Vector3.yAxis * 3.25, stone, Enum.Material.Limestone)
				end
			end
		end
		if node.id % 14 == 0 or node == entry or node == gate then
			local lamp = position(bay, "Vela de orientación", Vector3.new(0.18, 0.31, 0.18),
				pos + Vector3.new(-5.5, 2.4, 5.5), ember, Enum.Material.Neon, false)
			local light = Instance.new("PointLight")
			light.Color, light.Brightness, light.Range = ember, 0.62, 11
			light.Parent = lamp
		end
		if node.id % 12 == 0 or node == reveal then
			for index = 1, 5 do
				Maze.part(bay, "Resto de expedición", Vector3.new(0.14, 0.15, 0.56),
					CFrame.new(pos + Vector3.new(5 + rng:NextNumber() * 1.6, 0.14, -5 + rng:NextNumber() * 2.2)) *
					CFrame.Angles(0, index, 0), bone, Enum.Material.Limestone, false)
			end
			if carvedSkull then
				local skull = carvedSkull:Clone()
				skull.Size *= 0.63
				skull.CFrame = CFrame.new(pos + Vector3.new(5.8, 0.46, -5.8)) * CFrame.Angles(0, -0.9 + (node.id % 3) * 0.45, 0.1)
				skull.Parent = bay
			end
		end
	end
	for index, node in rituals do
		decorateRitual(folder, node, index == 2)
		rat(folder, node.position + Vector3.new(3.1, 0, -5), index)
		if carvedSkull then
			local skull = carvedSkull:Clone()
			skull.Size *= 0.8
			skull.CFrame = CFrame.new(node.position + Vector3.new(4.25, 2.33, -4.7)) * CFrame.Angles(0, math.pi, 0)
			skull.Parent = folder
		end
		local bundle = position(folder, "Restos cubiertos", Vector3.new(2.7, 0.55, 0.68),
			node.position + Vector3.new(4.6, 0.25, -6.4), Color3.fromRGB(100, 85, 72), Enum.Material.Fabric, false)
		bundle.Shape = Enum.PartType.Ball
		for _, side in { -1, 1 } do
			Maze.part(folder, "Cuerno gastado", Vector3.new(0.19, 0.27, 0.54),
				bundle.CFrame * CFrame.new(-1.12, 0.12, side * 0.22) * CFrame.Angles(0, side * 0.65, -0.32),
				bone, Enum.Material.Limestone, false)
		end
	end
	if carvedSkull then carvedSkull:Destroy() end
	local endPos = gate.position + Vector3.new(19, 0, 0)
	position(folder, "Cámara del umbral", Vector3.new(21, 1, span), endPos - Vector3.yAxis * 0.5, damp, Enum.Material.Slate)
	position(folder, "Cubierta del umbral", Vector3.new(21, 1, span), endPos + Vector3.yAxis * 8.5, stone, Enum.Material.Slate)
	for _, sign in { -1, 1 } do
		position(folder, "Jamba del umbral", Vector3.new(21, 8, 1), endPos + Vector3.new(0, 4, sign * 8.5), stone, Enum.Material.Cobblestone)
	end
	position(folder, "Límite de la cámara", Vector3.new(1, 8, span), endPos + Vector3.new(10.5, 4, 0), stone, Enum.Material.Slate)
	for _, sign in { -1, 1 } do
		position(folder, "Monolito tras el umbral", Vector3.new(1.3, 7.3, 1.4),
			endPos + Vector3.new(6.2, 3.65, sign * 3.5), Color3.fromRGB(46, 44, 52), Enum.Material.Slate)
	end
	local glimmer = position(folder, "Resplandor profundo", Vector3.new(0.17, 1.5, 1),
		endPos + Vector3.new(9.86, 4.3, 0), Color3.fromRGB(143, 73, 44), Enum.Material.Neon, false)
	local light = Instance.new("PointLight")
	light.Color, light.Brightness, light.Range = glimmer.Color, 1.05, 13
	light.Parent = glimmer
	folder:SetAttribute("CellCount", #nodes)
	folder.Parent = parent
	return { folder = folder, nodes = nodes, entrance = entry, gate = gate, reveal = reveal,
		rubies = rubies, rituals = rituals, route = route, nearest = nearest }
end

return Maze
