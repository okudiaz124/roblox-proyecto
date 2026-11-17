--!strict

local ContextActionService = game:GetService("ContextActionService")

return function(player: Player, action: string): () -> ()
	local controls
	local scripts = player:FindFirstChild("PlayerScripts")
	local module = scripts and scripts:FindFirstChild("PlayerModule")
	if module and module:IsA("ModuleScript") then
		local ok, result = pcall(function() return require(module):GetControls() end)
		if ok then controls = result end
	end
	if controls then controls:Disable() end
	ContextActionService:BindActionAtPriority(action, function()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value,
		Enum.PlayerActions.CharacterForward, Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft, Enum.PlayerActions.CharacterRight, Enum.PlayerActions.CharacterJump)
	return function()
		ContextActionService:UnbindAction(action)
		if controls then controls:Enable() end
	end
end
