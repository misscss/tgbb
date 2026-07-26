local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

_G.triggerbot = false

local Clicked = false
local mouse1press = _G.mouse1press
local mouse1release = _G.mouse1release
local VirtualInputManager = game:GetService("VirtualInputManager")

local function pressMouse1()
	if type(mouse1press) == "function" then
		mouse1press()
		return
	end
	if type(_G.mouse1press) == "function" then
		_G.mouse1press()
		return
	end
	if syn and syn.mouse1click then
		syn.mouse1click()
		return
	end
	if VirtualInputManager and VirtualInputManager.SendMouseButtonEvent then
		local pos = UserInputService:GetMouseLocation()
		VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
	end
end

local function releaseMouse1()
	if type(mouse1release) == "function" then
		mouse1release()
		return
	end
	if type(_G.mouse1release) == "function" then
		_G.mouse1release()
		return
	end
	if syn and syn.mouse1release then
		syn.mouse1release()
		return
	end
	if VirtualInputManager and VirtualInputManager.SendMouseButtonEvent then
		local pos = UserInputService:GetMouseLocation()
		VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
	end
end

local function createRounded(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function createStroke(instance, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency
	stroke.Parent = instance
	return stroke
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "CustomGui"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 170)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -85)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = Gui

createRounded(MainFrame, 8)
createStroke(MainFrame, Color3.fromRGB(255, 60, 60), 2, 0.1)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 0, 0)
TopBar.BackgroundTransparency = 0.05
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopGradient = Instance.new("UIGradient")
TopGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 0, 0))
})
TopGradient.Rotation = 90
TopGradient.Parent = TopBar

createRounded(TopBar, 8)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "30cm Hub"
Title.TextColor3 = Color3.fromRGB(255, 235, 235)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 28, 0, 24)
MinBtn.Position = UDim2.new(1, -66, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
MinBtn.Text = "_"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
createRounded(MinBtn, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
createRounded(CloseBtn, 6)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -34)
Content.Position = UDim2.new(0, 0, 0, 34)
Content.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
Content.BorderSizePixel = 0
Content.Parent = MainFrame
createRounded(Content, 8)
createStroke(Content, Color3.fromRGB(255, 60, 60), 1, 0.35)

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 12)
Padding.PaddingLeft = UDim.new(0, 12)
Padding.PaddingRight = UDim.new(0, 12)
Padding.Parent = Content

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

local Card = Instance.new("Frame")
Card.Size = UDim2.new(1, -4, 0, 88)
Card.BackgroundColor3 = Color3.fromRGB(24, 4, 4)
Card.BorderSizePixel = 0
Card.Parent = Content
createRounded(Card, 8)
createStroke(Card, Color3.fromRGB(255, 90, 90), 1, 0.25)

local CardTitle = Instance.new("TextLabel")
CardTitle.BackgroundTransparency = 1
CardTitle.Size = UDim2.new(1, -20, 0, 24)
CardTitle.Position = UDim2.new(0, 10, 0, 10)
CardTitle.Font = Enum.Font.GothamBold
CardTitle.Text = "Triggerbot Key (E)"
CardTitle.TextColor3 = Color3.fromRGB(255, 245, 245)
CardTitle.TextSize = 15
CardTitle.TextXAlignment = Enum.TextXAlignment.Left
CardTitle.Parent = Card

local confirmFrame
local Minimized = false

local function closeGui()
	Gui:Destroy()
end

local function setMinimized(state)
	Minimized = state
	Content.Visible = not state
	local targetSize = state and UDim2.new(0, 320, 0, 34) or UDim2.new(0, 320, 0, 170)
	local targetPos = state and UDim2.new(0, 8, 0, 8) or UDim2.new(0.5, -160, 0.5, -85)
	TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = targetSize,
		Position = targetPos
	}):Play()
end

MinBtn.MouseButton1Click:Connect(function()
	setMinimized(not Minimized)
end)

CloseBtn.MouseButton1Click:Connect(function()
	if confirmFrame then return end

	confirmFrame = Instance.new("Frame")
	confirmFrame.Size = UDim2.new(0, 220, 0, 100)
	confirmFrame.Position = UDim2.new(0.5, -110, 0.5, -50)
	confirmFrame.BackgroundColor3 = Color3.fromRGB(25, 0, 0)
	confirmFrame.BorderSizePixel = 0
	confirmFrame.Parent = Gui
	createRounded(confirmFrame, 8)
	createStroke(confirmFrame, Color3.fromRGB(255, 60, 60), 2, 0.1)

	local Msg = Instance.new("TextLabel")
	Msg.BackgroundTransparency = 1
	Msg.Size = UDim2.new(1, 0, 0, 40)
	Msg.Position = UDim2.new(0, 0, 0, 10)
	Msg.Font = Enum.Font.GothamBold
	Msg.Text = "¿Estás seguro?"
	Msg.TextColor3 = Color3.fromRGB(255, 235, 235)
	Msg.TextSize = 16
	Msg.Parent = confirmFrame

	local Yes = Instance.new("TextButton")
	Yes.Size = UDim2.new(0, 80, 0, 26)
	Yes.Position = UDim2.new(0, 22, 1, -36)
	Yes.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	Yes.Text = "Sí"
	Yes.Font = Enum.Font.GothamBold
	Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
	Yes.TextSize = 14
	Yes.BorderSizePixel = 0
	Yes.Parent = confirmFrame
	createRounded(Yes, 6)

	local No = Instance.new("TextButton")
	No.Size = UDim2.new(0, 80, 0, 26)
	No.Position = UDim2.new(1, -102, 1, -36)
	No.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
	No.Text = "No"
	No.Font = Enum.Font.GothamBold
	No.TextColor3 = Color3.fromRGB(255, 255, 255)
	No.TextSize = 14
	No.BorderSizePixel = 0
	No.Parent = confirmFrame
	createRounded(No, 6)

	Yes.MouseButton1Click:Connect(closeGui)
	No.MouseButton1Click:Connect(function()
		confirmFrame:Destroy()
		confirmFrame = nil
	end)
end)

local Dragging = false
local DragStart
local StartPos

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = input.Position
		StartPos = MainFrame.Position
	end
end)

TopBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - DragStart
		MainFrame.Position = UDim2.new(
			StartPos.X.Scale,
			StartPos.X.Offset + delta.X,
			StartPos.Y.Scale,
			StartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	if GameProcessedEvent then
		return
	end

	if Input.KeyCode == Enum.KeyCode.E then
		_G.triggerbot = not _G.triggerbot
	end
end)

RunService.RenderStepped:Connect(function()
	if Mouse.Target and Mouse.Target.Parent and (Mouse.Target.Parent:FindFirstChildOfClass("Humanoid") or (Mouse.Target.Parent.Parent and Mouse.Target.Parent.Parent:FindFirstChildOfClass("Humanoid"))) and _G.triggerbot and Mouse.Target.Parent.Name ~= Player.Name then
		local humanoid = Mouse.Target.Parent:FindFirstChildOfClass("Humanoid") or (Mouse.Target.Parent.Parent and Mouse.Target.Parent.Parent:FindFirstChildOfClass("Humanoid"))

		if humanoid and humanoid.Health >= 1 then
			pressMouse1()
			Clicked = false
		end
	elseif _G.triggerbot and not Clicked then
		releaseMouse1()
	elseif not _G.triggerbot and Mouse.Target and Mouse.Target.Parent and (Mouse.Target.Parent:FindFirstChildOfClass("Humanoid") or (Mouse.Target.Parent.Parent and Mouse.Target.Parent.Parent:FindFirstChildOfClass("Humanoid"))) then
		Clicked = true
	end
end)
