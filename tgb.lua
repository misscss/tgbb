local HoldClick = true
local Hotkey = "t"
local HotkeyToggle = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Toggle = (Hotkey ~= "")
local CurrentlyPressed = false
local KeyConnection

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

local function BindHotkey()
	if KeyConnection then
		KeyConnection:Disconnect()
	end

	KeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
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

		if not HotkeyToggle and input.KeyCode.Name:lower() == Hotkey:lower() then
			Toggle = false
		end
	end)
end

BindHotkey()

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "30cm Hub",
	Icon = "rocket",
	Author = "30cm Hub",
	Folder = "30cm Hub",
	Size = UDim2.fromOffset(380, 290),
	Transparent = true,
	Theme = "Dark",
	Resizable = true,
	SideBarWidth = 200,
})

local MainTab = Window:Tab({
	Title = "Main",
	Icon = "home",
})

MainTab:Section({
	Title = "Asignación",
})

MainTab:Button({
	Title = "Asignar tecla",
	Callback = function()
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode ~= Enum.KeyCode.Unknown then
				Hotkey = input.KeyCode.Name:lower()
				Toggle = (Hotkey ~= "")
				BindHotkey()
				conn:Disconnect()
			end
		end)
	end
})

RunService.RenderStepped:Connect(function()
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
