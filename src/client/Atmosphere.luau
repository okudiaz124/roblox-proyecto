--!strict

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(shared:WaitForChild("AudioAssets"))

local Atmosphere = {}
type Cue = { start: number, finish: number, speaker: string, line: string }
type Options = { volume: number }

function Atmosphere.start(round: Folder, player: Player, options: Options)
	local audio = Instance.new("Folder")
	audio.Name = "CatacombsAudio"
	audio.Parent = SoundService
	local function makeSound(name: string, id: string, looped: boolean): Sound
		local sound = Instance.new("Sound")
		sound.Name, sound.SoundId, sound.Looped, sound.Volume = name, id, looped, 0
		sound.Parent = audio
		return sound
	end
	local exploration = makeSound("Exploración", Assets.Exploration, true)
	local ritual = makeSound("Ritual", Assets.Ritual, true)
	local threat = makeSound("Amenaza", Assets.Threat, true)
	local pursuit = makeSound("Persecución", Assets.Pursuit, true)
	local rumble = makeSound("Temblor", Assets.Rumble, false)
	local collapse = makeSound("Derrumbe", Assets.Collapse, false)
	local lid = makeSound("Tapa", Assets.Lid, false)
	local layers = { exploration, ritual, threat, pursuit }
	local worldGroup = SoundService:WaitForChild("CatacombsWorldAudio", 5)
	for _, layer in layers do layer:Play() end
	task.spawn(function() pcall(ContentProvider.PreloadAsync, ContentProvider, { rumble, collapse, lid }) end)

	local duckUntil = 0
	local loaded = {} :: { [number]: AudioTextToSpeech }
	local cues = {} :: { Cue }
	local nextIndex, lastPlaying = 1, nil :: AudioTextToSpeech?
	local preloading, open = false, true
	local output = Instance.new("AudioDeviceOutput")
	output.Parent = audio
	local function voice(cue: Cue): AudioTextToSpeech
		local speech = Instance.new("AudioTextToSpeech")
		speech.Name, speech.Text = cue.speaker, cue.line
		speech.AutoLocalize = false
		speech.VoiceId = if cue.speaker == "Hikari" then "102" else "101"
		speech.Pitch = if cue.speaker == "Guía" then -0.09 else 0.03
		speech.Volume = 0.8 * options.volume
		speech.Parent = audio
		local wire = Instance.new("Wire")
		wire.SourceInstance, wire.TargetInstance = speech, output
		wire.Parent = speech
		return speech
	end
	local function prime(untilIndex: number)
		if preloading or not open then return end
		preloading = true
		task.spawn(function()
			while open and cues[nextIndex] and nextIndex <= untilIndex do
				local i = nextIndex
				nextIndex += 1
				if cues[i].speaker ~= "" then
					local speech = voice(cues[i])
					local ok, status = pcall(speech.LoadAsync, speech)
					if open and ok and status == Enum.AssetFetchStatus.Success then
						loaded[i] = speech
					else
						speech:Destroy()
					end
				end
			end
			preloading = false
		end)
	end

	local controller = {}
	local effectSequence: { [Sound]: number } = {}
	function controller.prepare(captions: { Cue })
		cues = captions
		prime(6)
	end

	function controller.cue(index: number)
		prime(index + 5)
		if lastPlaying then lastPlaying:Pause() end
		local info = cues[index]
		if not info or info.speaker == "" then return end
		local seconds = info.finish - info.start
		local speech = loaded[index]
		if speech then
			speech.PlaybackSpeed = math.clamp(speech.TimeLength / math.max(seconds - 0.15, 0.6), 0.73, 1.38)
			speech.TimePosition = 0
			speech:Play()
			lastPlaying = speech
			duckUntil = os.clock() + seconds + 0.35
		end
	end

	function controller.endOpening()
		open = false
		if lastPlaying then lastPlaying:Pause(); lastPlaying = nil end
		for _, speech in loaded do speech:Destroy() end
		table.clear(loaded)
	end

	function controller.say(line: string, speaker: string)
		task.spawn(function()
			local speech = voice({ start = 0, finish = 3, speaker = speaker, line = line })
			local ok, status = pcall(speech.LoadAsync, speech)
			if ok and status == Enum.AssetFetchStatus.Success then
				duckUntil = os.clock() + speech.TimeLength + 0.4
				speech:Play()
				task.delay(math.max(2, speech.TimeLength + 1), function() speech:Destroy() end)
			else
				speech:Destroy()
			end
		end)
	end

	function controller.effect(name: string)
		local effect = if name == "Lid" then lid elseif name == "Collapse" then collapse else rumble
		local generation = (effectSequence[effect] or 0) + 1
		effectSequence[effect] = generation
		effect.Volume = (if name == "Collapse" then 0.4 else 0.24) * options.volume
		effect:Stop()
		effect:Play()
		if name ~= "Collapse" then
			task.delay(if name == "Lid" then 1.4 else 5.2, function()
				if effectSequence[effect] == generation then effect:Stop() end
			end)
		end
	end

	RunService.Heartbeat:Connect(function(dt)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local world = Workspace:FindFirstChild("World")
		local catacombs = world and world:FindFirstChild("Catacombs")
		local maze = catacombs and catacombs:FindFirstChild("Labyrinth")
		local monster = maze and maze:FindFirstChild("HombreCerdo")
		local hunterRoot = monster and monster:FindFirstChild("Root")
		local proximity, ritualWeight = 0, 0
		if root and root:IsA("BasePart") then
			for index = 1, 2 do
				local point = round:GetAttribute("Ritual" .. index)
				if typeof(point) == "Vector3" then
					ritualWeight = math.max(ritualWeight, math.clamp((26 - (point - root.Position).Magnitude) / 15, 0, 1))
				end
			end
			if hunterRoot and hunterRoot:IsA("BasePart") then
				proximity = math.clamp((85 - (hunterRoot.Position - root.Position).Magnitude) / 72, 0, 1)
			end
		end
		local mode = round:GetAttribute("HunterState")
		local chased = round:GetAttribute("TargetUserId") == player.UserId and (mode == "Chase" or mode == "Attack")
		local revealing = round:GetAttribute("Phase") == "Reveal"
		local duck = if os.clock() < duckUntil then 0.42 else 1
		local targets = { 0.13 - proximity * 0.04, ritualWeight * 0.09,
			math.max(proximity * 0.16, if revealing then 0.085 else 0),
			if chased then 0.18 else 0 }
		local blend = math.min(dt * (if chased then 1.7 else 0.9), 1)
		for index, layer in layers do
			layer.Volume += (targets[index] * duck * options.volume - layer.Volume) * blend
		end
		if lastPlaying then lastPlaying.Volume = 0.8 * options.volume end
		if worldGroup and worldGroup:IsA("SoundGroup") then worldGroup.Volume = options.volume end
	end)
	return controller
end

return Atmosphere
