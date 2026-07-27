local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local mouse = Player:GetMouse()

_G.triggerbot = false
_G.hitboxSize = 2
_G.espEnabled = false
_G.espColor = Color3.fromRGB(255, 0, 0)
_G.speedEnabled = false
_G.speedValue = 16
_G.noclipEnabled = false
local Clicked = false

local function safeMouse1Press()
    if mouse1press then
        pcall(mouse1press)
    end
end

local function safeMouse1Release()
    if mouse1release then
        pcall(mouse1release)
    end
end

local function getTargetInfo()
    local target = mouse.Target
    if not target then
        return nil, nil
    end

    local character = target.Parent
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid, character
    end

    local grandparent = character and character.Parent
    humanoid = grandparent and grandparent:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid, grandparent
    end

    return nil, nil
end

local function isLocalCharacter(character)
    return character and character.Name == Player.Name
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then
        return
    end

    if Input.KeyCode == Enum.KeyCode.E then
        _G.triggerbot = not _G.triggerbot
    end
end)

RunService.RenderStepped:Connect(function()
    local humanoid, character = getTargetInfo()

    local triggerAllowed = _G.triggerbot
    if _G.espEnabled then
        if character and character:FindFirstChild("CustomESP_Highlight") then
            local hl = character:FindFirstChild("CustomESP_Highlight")
            if not hl.Enabled then
                triggerAllowed = false
            end
        end
    end

    if humanoid and humanoid.Health > 0 and triggerAllowed and not isLocalCharacter(character) then
        safeMouse1Press()
        Clicked = false
    elseif _G.triggerbot and not Clicked then
        safeMouse1Release()
    elseif not _G.triggerbot and humanoid then
        Clicked = true
    end

    if _G.hitboxSize and _G.hitboxSize > 0 then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= Player and otherPlayer.Character then
                local hrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(_G.hitboxSize, _G.hitboxSize, _G.hitboxSize)
                    hrp.Transparency = 0.5
                    hrp.CanCollide = false
                end
            end
        end
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local char = otherPlayer.Character
            local hl = char:FindFirstChild("CustomESP_Highlight")
            
            if _G.espEnabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "CustomESP_Highlight"
                    hl.Adornee = char
                    hl.Parent = char
                end
                hl.FillColor = _G.espColor
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Enabled = true
            else
                if hl then
                    hl.Enabled = false
                end
            end
        end
    end

    if _G.speedEnabled and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = _G.speedValue
        end
    end

    if _G.noclipEnabled and Player.Character then
        for _, part in ipairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "CustomGui"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 140)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = Gui

local MiniFrame = Instance.new("Frame")
MiniFrame.Name = "MiniFrame"
MiniFrame.Size = UDim2.new(0, 48, 0, 48)
MiniFrame.Position = UDim2.new(0.5, -24, 0, 46)
MiniFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
MiniFrame.BackgroundTransparency = 1
MiniFrame.BorderSizePixel = 0
MiniFrame.Visible = false
MiniFrame.ZIndex = 1
MiniFrame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 12)
MiniCorner.Parent = MiniFrame

local MiniGradient = Instance.new("UIGradient")
MiniGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 0, 0))
})
MiniGradient.Rotation = 90
MiniGradient.Parent = MiniFrame

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(255, 60, 60)
MiniStroke.Thickness = 2.5
MiniStroke.Transparency = 0.15
MiniStroke.Parent = MiniFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 60, 60)
Stroke.Thickness = 2
Stroke.Transparency = 0.1
Stroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 0, 0)
TopBar.BackgroundTransparency = 0.05
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local MiniTitle = Instance.new("TextLabel")
MiniTitle.Name = "MiniTitle"
MiniTitle.BackgroundTransparency = 1
MiniTitle.Size = UDim2.new(1, 0, 1, 0)
MiniTitle.Position = UDim2.new(0, 0, 0, 0)
MiniTitle.Font = Enum.Font.GothamBold
MiniTitle.Text = "30cm\nhub"
MiniTitle.TextColor3 = Color3.fromRGB(255, 235, 235)
MiniTitle.TextSize = 12
MiniTitle.TextWrapped = true
MiniTitle.TextYAlignment = Enum.TextYAlignment.Center
MiniTitle.TextXAlignment = Enum.TextXAlignment.Center
MiniTitle.Visible = false
MiniTitle.Parent = MiniFrame

local MiniRestoreBtn = Instance.new("TextButton")
MiniRestoreBtn.Name = "MiniRestoreBtn"
MiniRestoreBtn.Size = UDim2.new(1, 0, 1, 0)
MiniRestoreBtn.Position = UDim2.new(0, 0, 0, 0)
MiniRestoreBtn.BackgroundTransparency = 1
MiniRestoreBtn.AutoButtonColor = false
MiniRestoreBtn.Text = ""
MiniRestoreBtn.Parent = MiniFrame

local Minimized = false
local function setMinimized(state)
    Minimized = state
    MainFrame.Visible = not state
    MiniFrame.Visible = state
    MiniTitle.Visible = state
end

local function restoreMiniFrame()
    if Minimized then
        setMinimized(false)
    end
end

MiniRestoreBtn.MouseButton1Click:Connect(function()
    restoreMiniFrame()
end)

local TopGradient = Instance.new("UIGradient")
TopGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 0, 0))
})
TopGradient.Rotation = 90
TopGradient.Parent = TopBar

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

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

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 24)
CloseBtn.Position = UDim2.new(1, -66, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 28, 0, 24)
MinBtn.Position = UDim2.new(1, -34, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = Color3.fromRGB(255, 90, 90)
MinStroke.Thickness = 1
MinStroke.Transparency = 0.2
MinStroke.Parent = MinBtn

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -34)
Content.Position = UDim2.new(0, 0, 0, 34)
Content.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = Content

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = Color3.fromRGB(255, 60, 60)
ContentStroke.Thickness = 1
ContentStroke.Transparency = 0.35
ContentStroke.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 12)
Padding.PaddingLeft = UDim.new(0, 12)
Padding.PaddingRight = UDim.new(0, 12)
Padding.Parent = Content

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 24)
end)

local Modules = {}

local function updateSize()
    local totalY = 34 + 12 + #Modules * 42 + math.max(0, (#Modules - 1) * 10) + 12
    MainFrame.Size = UDim2.new(0, 320, 0, math.clamp(totalY, 140, 350))
end

local function setVisualState(frame, enabled)
    local bg = enabled and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(18, 0, 0)
    TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = bg}):Play()
end

local function addModule(moduleName, callback)
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Name = moduleName
    ModuleFrame.Size = UDim2.new(1, 0, 0, 42)
    ModuleFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
    ModuleFrame.BorderSizePixel = 0
    ModuleFrame.Parent = Content

    local MFCorner = Instance.new("UICorner")
    MFCorner.CornerRadius = UDim.new(0, 8)
    MFCorner.Parent = ModuleFrame

    local MFStroke = Instance.new("UIStroke")
    MFStroke.Color = Color3.fromRGB(255, 60, 60)
    MFStroke.Thickness = 1
    MFStroke.Transparency = 0.25
    MFStroke.Parent = ModuleFrame

    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency = 1
    Text.Size = UDim2.new(1, -70, 1, 0)
    Text.Position = UDim2.new(0, 12, 0, 0)
    Text.Font = Enum.Font.Gotham
    Text.Text = moduleName
    Text.TextColor3 = Color3.fromRGB(255, 230, 230)
    Text.TextSize = 14
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = ModuleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 54, 0, 26)
    ToggleBtn.Position = UDim2.new(1, -66, 0.5, -13)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ModuleFrame

    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(1, 0)
    TBCorner.Parent = ToggleBtn

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new(0, 3, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 245, 245)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn

    local KCorner = Instance.new("UICorner")
    KCorner.CornerRadius = UDim.new(1, 0)
    KCorner.Parent = Knob

    local Enabled = false

    local function setToggle(state)
        Enabled = state
        local goalPos = state and UDim2.new(0, 31, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local goalColor = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(255, 0, 0)
        TweenService:Create(Knob, TweenInfo.new(0.15), {Position = goalPos}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = goalColor}):Play()
        setVisualState(ModuleFrame, state)
        if callback then
            callback(state)
        end
    end

    setToggle(false)

    ToggleBtn.MouseButton1Click:Connect(function()
        setToggle(not Enabled)
    end)

    table.insert(Modules, ModuleFrame)
    updateSize()
end

addModule("triggerbot", function(state)
    _G.triggerbot = state
end)

do
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Name = "hitbox"
    ModuleFrame.Size = UDim2.new(1, 0, 0, 42)
    ModuleFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
    ModuleFrame.BorderSizePixel = 0
    ModuleFrame.Parent = Content

    local MFCorner = Instance.new("UICorner")
    MFCorner.CornerRadius = UDim.new(0, 8)
    MFCorner.Parent = ModuleFrame

    local MFStroke = Instance.new("UIStroke")
    MFStroke.Color = Color3.fromRGB(255, 60, 60)
    MFStroke.Thickness = 1
    MFStroke.Transparency = 0.25
    MFStroke.Parent = ModuleFrame

    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency = 1
    Text.Size = UDim2.new(1, -110, 1, 0)
    Text.Position = UDim2.new(0, 12, 0, 0)
    Text.Font = Enum.Font.Gotham
    Text.Text = "hitbox"
    Text.TextColor3 = Color3.fromRGB(255, 230, 230)
    Text.TextSize = 14
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = ModuleFrame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 36, 0, 24)
    Box.Position = UDim2.new(1, -118, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.Text = tostring(_G.hitboxSize)
    Box.ClearTextOnFocus = false
    Box.Parent = ModuleFrame

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = Box

    Box.FocusLost:Connect(function()
        local val = tonumber(Box.Text)
        if val then
            _G.hitboxSize = math.clamp(val, 0, 100)
            Box.Text = tostring(_G.hitboxSize)
        else
            Box.Text = tostring(_G.hitboxSize)
        end
    end)

    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0, 50, 0, 24)
    ResetBtn.Position = UDim2.new(1, -74, 0.5, -12)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
    ResetBtn.Text = "Reset"
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.TextSize = 11
    ResetBtn.Parent = ModuleFrame

    local RCorner = Instance.new("UICorner")
    RCorner.CornerRadius = UDim.new(0, 4)
    RCorner.Parent = ResetBtn

    ResetBtn.MouseButton1Click:Connect(function()
        _G.hitboxSize = 2
        Box.Text = "2"
    end)

    table.insert(Modules, ModuleFrame)
    updateSize()
end

do
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Name = "ESP Color"
    ModuleFrame.Size = UDim2.new(1, 0, 0, 42)
    ModuleFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
    ModuleFrame.BorderSizePixel = 0
    ModuleFrame.Parent = Content

    local MFCorner = Instance.new("UICorner")
    MFCorner.CornerRadius = UDim.new(0, 8)
    MFCorner.Parent = ModuleFrame

    local MFStroke = Instance.new("UIStroke")
    MFStroke.Color = Color3.fromRGB(255, 60, 60)
    MFStroke.Thickness = 1
    MFStroke.Transparency = 0.25
    MFStroke.Parent = ModuleFrame

    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency = 1
    Text.Size = UDim2.new(1, -190, 1, 0)
    Text.Position = UDim2.new(0, 12, 0, 0)
    Text.Font = Enum.Font.Gotham
    Text.Text = "ESP Color"
    Text.TextColor3 = Color3.fromRGB(255, 230, 230)
    Text.TextSize = 14
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = ModuleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -196, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ModuleFrame

    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(1, 0)
    TBCorner.Parent = ToggleBtn

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 245, 245)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn

    local KCorner = Instance.new("UICorner")
    KCorner.CornerRadius = UDim.new(1, 0)
    KCorner.Parent = Knob

    local Enabled = false

    local function setToggle(state)
        Enabled = state
        _G.espEnabled = state
        local goalPos = state and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local goalColor = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(255, 0, 0)
        TweenService:Create(Knob, TweenInfo.new(0.15), {Position = goalPos}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = goalColor}):Play()
        setVisualState(ModuleFrame, state)
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        setToggle(not Enabled)
    end)

    local colors = {
        {Name = "Rojo", Color = Color3.fromRGB(255, 0, 0)},
        {Name = "Verde", Color = Color3.fromRGB(0, 255, 0)},
        {Name = "Morado", Color = Color3.fromRGB(128, 0, 128)}
    }

    for i, colData in ipairs(colors) do
        local ColorBox = Instance.new("TextButton")
        ColorBox.Size = UDim2.new(0, 20, 0, 20)
        ColorBox.Position = UDim2.new(1, - (4 - i) * 24 - 4, 0.5, -10)
        ColorBox.BackgroundColor3 = colData.Color
        ColorBox.Text = ""
        ColorBox.Parent = ModuleFrame

        local CBCorner = Instance.new("UICorner")
        CBCorner.CornerRadius = UDim.new(0, 4)
        CBCorner.Parent = ColorBox

        local CBStroke = Instance.new("UIStroke")
        CBStroke.Color = Color3.fromRGB(255, 255, 255)
        CBStroke.Thickness = 1
        CBStroke.Transparency = 0.5
        CBStroke.Parent = ColorBox

        ColorBox.MouseButton1Click:Connect(function()
            _G.espColor = colData.Color
        end)
    end

    table.insert(Modules, ModuleFrame)
    updateSize()
end

do
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Name = "speed"
    ModuleFrame.Size = UDim2.new(1, 0, 0, 42)
    ModuleFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
    ModuleFrame.BorderSizePixel = 0
    ModuleFrame.Parent = Content

    local MFCorner = Instance.new("UICorner")
    MFCorner.CornerRadius = UDim.new(0, 8)
    MFCorner.Parent = ModuleFrame

    local MFStroke = Instance.new("UIStroke")
    MFStroke.Color = Color3.fromRGB(255, 60, 60)
    MFStroke.Thickness = 1
    MFStroke.Transparency = 0.25
    MFStroke.Parent = ModuleFrame

    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency = 1
    Text.Size = UDim2.new(1, -150, 1, 0)
    Text.Position = UDim2.new(0, 12, 0, 0)
    Text.Font = Enum.Font.Gotham
    Text.Text = "speed"
    Text.TextColor3 = Color3.fromRGB(255, 230, 230)
    Text.TextSize = 14
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = ModuleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -156, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ModuleFrame

    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(1, 0)
    TBCorner.Parent = ToggleBtn

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 245, 245)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn

    local KCorner = Instance.new("UICorner")
    KCorner.CornerRadius = UDim.new(1, 0)
    KCorner.Parent = Knob

    local Enabled = false

    local function setToggle(state)
        Enabled = state
        _G.speedEnabled = state
        local goalPos = state and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local goalColor = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(255, 0, 0)
        TweenService:Create(Knob, TweenInfo.new(0.15), {Position = goalPos}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = goalColor}):Play()
        setVisualState(ModuleFrame, state)
        if not state and Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        setToggle(not Enabled)
    end)

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 36, 0, 24)
    Box.Position = UDim2.new(1, -110, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.Text = tostring(_G.speedValue)
    Box.ClearTextOnFocus = false
    Box.Parent = ModuleFrame

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = Box

    Box.FocusLost:Connect(function()
        local val = tonumber(Box.Text)
        if val then
            _G.speedValue = math.clamp(val, 0, 100)
            Box.Text = tostring(_G.speedValue)
        else
            Box.Text = tostring(_G.speedValue)
        end
    end)

    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0, 50, 0, 24)
    ResetBtn.Position = UDim2.new(1, -66, 0.5, -12)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
    ResetBtn.Text = "Reset"
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.TextSize = 11
    ResetBtn.Parent = ModuleFrame

    local RCorner = Instance.new("UICorner")
    RCorner.CornerRadius = UDim.new(0, 4)
    RCorner.Parent = ResetBtn

    ResetBtn.MouseButton1Click:Connect(function()
        _G.speedValue = 16
        Box.Text = "16"
        if _G.speedEnabled and Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end)

    table.insert(Modules, ModuleFrame)
    updateSize()
end

addModule("noclip", function(state)
    _G.noclipEnabled = state
    if not state and Player.Character then
        for _, part in ipairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    setMinimized(true)
end)

local confirmFrame

local function closeGui()
    Gui:Destroy()
end

CloseBtn.MouseButton1Click:Connect(function()
    if confirmFrame then return end

    confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0, 220, 0, 100)
    confirmFrame.Position = UDim2.new(0.5, -110, 0.5, -50)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(25, 0, 0)
    confirmFrame.BorderSizePixel = 0
    confirmFrame.Parent = Gui

    local CFCorner = Instance.new("UICorner")
    CFCorner.CornerRadius = UDim.new(0, 8)
    CFCorner.Parent = confirmFrame

    local CFStroke = Instance.new("UIStroke")
    CFStroke.Color = Color3.fromRGB(255, 60, 60)
    CFStroke.Thickness = 2
    CFStroke.Parent = confirmFrame

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

    local TheNCorner = Instance.new("UICorner")
    TheNCorner.CornerRadius = UDim.new(0, 6)
    TheNCorner.Parent = Yes

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

    local NoCorner = Instance.new("UICorner")
    NoCorner.CornerRadius = UDim.new(0, 6)
    NoCorner.Parent = No

    Yes.MouseButton1Click:Connect(closeGui)
    No.MouseButton1Click:Connect(function()
        confirmFrame:Destroy()
        confirmFrame = nil
    end)
end)

local Dragging = false
local DragStart
local StartPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + delta.Y
        )
    end
end)

local MiniDragging = false
local MiniDragStart
local MiniStartPos

MiniFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MiniDragging = true
        MiniDragStart = input.Position
        MiniStartPos = MiniFrame.Position
    end
end)

MiniFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MiniDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if MiniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - MiniDragStart
        MiniFrame.Position = UDim2.new(
            MiniStartPos.X.Scale,
            MiniStartPos.X.Offset + delta.X,
            MiniStartPos.Y.Scale,
            MiniStartPos.Y.Offset + delta.Y
        )
    end
end)