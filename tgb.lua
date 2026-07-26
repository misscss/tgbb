local HoldClick = true
local Hotkey = "v"
local HotkeyToggle = true
local EnableHotkey = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Toggle = (Hotkey ~= "")
local CurrentlyPressed = false

local function GetKeyText(key)
	return tostring(key):gsub("Enum.KeyCode.", "")
end

local function IsValidTarget(target)
	if not target or not target.Parent then
		return false
	end

	local character = target.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local targetPlayer = Players:GetPlayerFromCharacter(character)

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	if targetPlayer == LocalPlayer then
		return false
	end

	return true
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if not EnableHotkey then
		return
	end

	if input.KeyCode.Name:lower() == Hotkey:lower() then
		if HotkeyToggle then
			Toggle = not Toggle
		else
			Toggle = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if not EnableHotkey then
		return
	end

	if not HotkeyToggle and input.KeyCode.Name:lower() == Hotkey:lower() then
		Toggle = false
	end
end)

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Mi Script",
	LoadingTitle = "Mi Script",
	LoadingSubtitle = "by TuNombre",
	Theme = "Light",

	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false,

	ConfigurationSaving = {
		Enabled = true,
		FolderName = "MiScript",
		FileName = "Config"
	}
})

local Main = Window:CreateTab("Main", 4483362458)
local Settings = Window:CreateTab("Settings", 4483362458)

Main:CreateSection("Funciones")
Settings:CreateSection("Configuración")

Main:CreateParagraph({
	Title = "Triggerbot",
	Content = "Hotkey: V"
})

Main:CreateToggle({
	Name = "Activar hotkey",
	CurrentValue = true,
	Flag = "EnableHotkey",
	Callback = function(Value)
		EnableHotkey = Value
	end
})

Main:CreateToggle({
	Name = "Hold click",
	CurrentValue = true,
	Flag = "HoldClick",
	Callback = function(Value)
		HoldClick = Value
	end
})

Settings:CreateParagraph({
	Title = "Estilo",
	Content = "Rayfield ya usa un estilo limpio; para un efecto más neon/blanco, usa Theme = Light."
})

RunService.RenderStepped:Connect(function()
	if not EnableHotkey then
		return
	end

	if Toggle and Mouse.Target and IsValidTarget(Mouse.Target) then
		if HoldClick then
			if not CurrentlyPressed then
				CurrentlyPressed = true
				mouse1press()
			end
		else
			mouse1click()
		end
	else
		if HoldClick then
			CurrentlyPressed = false
			mouse1release()
		end
	end
end)
