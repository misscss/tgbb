local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "30cm Hub",
    Icon = "crosshair",
    Author = "",
    Folder = "30cmHub",
    Size = UDim2.fromOffset(380, 290), -- Tamaño exacto de la captura
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
    SideBarWidth = 120,
})

-- Ocultar al inicio
Window:Toggle(false)

-- Variables
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
_G.triggerbot = false
_G.hitboxEnabled = false
_G.hitboxSize = 1.5
local triggerKey = Enum.KeyCode.C
local hitboxKey = Enum.KeyCode.H

-- Abrir/cerrar GUI con Control Derecho
local guiVisible = false
game:GetService("UserInputService").InputBegan:connect(function(Input, GPE)
    if GPE then return end
    if Input.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        Window:Toggle(guiVisible)
    end
    
    -- Teclas rápidas
    if Input.KeyCode == triggerKey and not guiVisible then
        _G.triggerbot = not _G.triggerbot
    end
    
    if Input.KeyCode == hitboxKey and not guiVisible then
        _G.hitboxEnabled = not _G.hitboxEnabled
        updateHitboxes()
    end
end)

-- ==========================================
-- HITBOX EXPANDER SILENCIOSO (NO SE VE EN CLIPS)
-- ==========================================
local function applyHitbox(character, sizeMultiplier)
    if not character then return end
    
    local hitboxParts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("Torso"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("LowerTorso"),
    }
    
    for _, part in pairs(hitboxParts) do
        if part and part:IsA("BasePart") then
            part.Size = part.Size * sizeMultiplier
            part.Transparency = 1
            part.CanCollide = false
            part.CastShadow = false
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local extraPart = Instance.new("Part")
        extraPart.Name = "_HitboxExtra"
        extraPart.Size = Vector3.new(8, 8, 8) * sizeMultiplier
        extraPart.Transparency = 1
        extraPart.CanCollide = false
        extraPart.CastShadow = false
        extraPart.Anchored = false
        extraPart.Parent = character
        
        local weld = Instance.new("Weld")
        weld.Part0 = rootPart
        weld.Part1 = extraPart
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = extraPart
    end
end

local function removeHitbox(character)
    if not character then return end
    
    local hitboxParts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("Torso"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("LowerTorso"),
    }
    
    for _, part in pairs(hitboxParts) do
        if part and part:IsA("BasePart") then
            part.Transparency = 0
            part.Size = part.Size / _G.hitboxSize
        end
    end
    
    local extraPart = character:FindFirstChild("_HitboxExtra")
    if extraPart then extraPart:Destroy() end
end

local function updateHitboxes()
    for _, targetPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            if _G.hitboxEnabled then
                applyHitbox(targetPlayer.Character, _G.hitboxSize)
            else
                removeHitbox(targetPlayer.Character)
            end
        end
    end
end

game:GetService("Players").PlayerAdded:Connect(function(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if _G.hitboxEnabled and targetPlayer ~= player then
            applyHitbox(character, _G.hitboxSize)
        end
    end)
end)

-- ==========================================
-- ELEMENTOS DE LA GUI (WINDUI)
-- ==========================================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

MainTab:Toggle({
    Title = "TriggerBot [C]",
    Default = false,
    Callback = function(Value)
        _G.triggerbot = Value
    end
})

MainTab:Toggle({
    Title = "Hitbox Expander [H]",
    Default = false,
    Callback = function(Value)
        _G.hitboxEnabled = Value
        updateHitboxes()
    end
})

MainTab:Slider({
    Title = "Tamaño Hitbox",
    Value = {
        Min = 1.0,
        Max = 3.0,
        Default = 1.5,
    },
    Callback = function(Value)
        _G.hitboxSize = Value
        if _G.hitboxEnabled then updateHitboxes() end
    end
})

MainTab:Label({
    Title = "[Ctrl Der] Abrir/Cerrar menú",
})

-- ==========================================
-- TRIGGERBOT PRINCIPAL
-- ==========================================
game:GetService("RunService").RenderStepped:Connect(function()
    if mouse.Target and mouse.Target.Parent then
        local humanoid = mouse.Target.Parent:FindFirstChildOfClass("Humanoid") or 
                        (mouse.Target.Parent.Parent and mouse.Target.Parent.Parent:FindFirstChildOfClass("Humanoid"))
        
        if humanoid and _G.triggerbot and mouse.Target.Parent.Name ~= player.Name then
            local targetPlayer = game.Players:GetPlayerFromCharacter(mouse.Target.Parent)
            if targetPlayer and targetPlayer ~= player and humanoid.Health >= 1 then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                task.wait(0.01)
                mouse1press()
                task.wait(0.05)
                mouse1release()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Two, false, game)
            end
        end
    end
end)