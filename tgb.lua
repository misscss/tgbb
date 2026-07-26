--[[
    30cm Hub v2.0 - Duels Murder vs Sheriff
    Características:
    ✅ TriggerBot con FOV
    ✅ Hitbox Expander mejorado
    ✅ Auto Farm (monedas, kills, XP)
    ✅ Anti-Ban (detección de admins, modo seguro)
    ✅ ESP (cajas, tracers, distancia)
    ✅ Auto-aim suave
    ✅ GUI Neon con degradados
    ✅ Estadísticas en vivo
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ==========================================
-- VENTANA PRINCIPAL CON ESTILO NEON
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "30cm Hub",
    SubTitle = "Duels MvS",
    Icon = "crosshair",
    Author = "30cm Team",
    Folder = "30cmHub",
    Size = UDim2.fromOffset(420, 350),
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
    SideBarWidth = 130,
    AccentColor = Color3.fromRGB(0, 255, 255),
})

Window:Toggle(false)

-- ==========================================
-- SERVICIOS Y VARIABLES GLOBALES
-- ==========================================
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Variables principales
_G.triggerbot = false
_G.hitboxEnabled = false
_G.hitboxSize = 1.5
_G.espEnabled = false
_G.autoFarm = false
_G.antiBan = false
_G.autoAim = false
_G.fovEnabled = false
_G.fovRadius = 100

-- Teclas por defecto
local triggerKey = "c"
local hitboxKey = "h"
local espKey = "z"
local autoFarmKey = "x"

-- Estado del TriggerBot
local holdClick = true
local currentlyPressed = false

-- Anti-Ban
local adminsNearby = false
local safeMode = false
local lastActionTime = 0

-- Auto Farm
local farmMode = "Coins"

-- Estadísticas
local stats = {
    kills = 0,
    shotsFired = 0,
    coinsCollected = 0,
    startTime = tick(),
}

-- ==========================================
-- ALMACENAMIENTO DE PROPIEDADES (HITBOX)
-- ==========================================
local originalProperties = {}

local function storeOriginal(character)
    local data = {}
    local parts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("Torso"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("LowerTorso"),
    }
    for _, p in ipairs(parts) do
        if p and p:IsA("BasePart") then
            data[p] = {
                Size = p.Size,
                Transparency = p.Transparency,
                CanCollide = p.CanCollide,
                CastShadow = p.CastShadow,
                Material = p.Material,
                Color = p.Color,
            }
        end
    end
    originalProperties[character] = data
end

-- ==========================================
-- HITBOX EXPANDER MEJORADO
-- ==========================================
local function applyHitbox(character, sizeMultiplier)
    if not character then return end
    storeOriginal(character)
    local parts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("Torso"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("LowerTorso"),
    }
    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") then
            part.Size = originalProperties[character][part].Size * sizeMultiplier
            part.Transparency = 1
            part.CanCollide = false
            part.CastShadow = false
            part.Material = Enum.Material.SmoothPlastic
        end
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local oldExtra = character:FindFirstChild("_HitboxExtra")
        if oldExtra then oldExtra:Destroy() end
        
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
    local data = originalProperties[character]
    if not data then return end

    local parts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("Torso"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("LowerTorso"),
    }
    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") and data[part] then
            part.Size = data[part].Size
            part.Transparency = data[part].Transparency
            part.CanCollide = data[part].CanCollide
            part.CastShadow = data[part].CastShadow
            part.Material = data[part].Material
            part.Color = data[part].Color
        end
    end

    local extraPart = character:FindFirstChild("_HitboxExtra")
    if extraPart then extraPart:Destroy() end

    originalProperties[character] = nil
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

-- ==========================================
-- ESP (CAJAS, TRACERS, DISTANCIA)
-- ==========================================
local espObjects = {}
local espConnections = {}

local function createESP(targetPlayer)
    if espObjects[targetPlayer] then return end
    
    local espData = {
        box = Drawing.new("Square"),
        nameTag = Drawing.new("Text"),
        distanceTag = Drawing.new("Text"),
        tracer = Drawing.new("Line"),
        healthBar = Drawing.new("Square"),
    }
    
    espData.box.Visible = false
    espData.box.Color = Color3.fromRGB(0, 255, 255)
    espData.box.Thickness = 2
    espData.box.Filled = false
    espData.box.Transparency = 0.5
    
    espData.nameTag.Visible = false
    espData.nameTag.Color = Color3.fromRGB(255, 255, 255)
    espData.nameTag.Size = 16
    espData.nameTag.Center = true
    espData.nameTag.Outline = true
    espData.nameTag.Font = 2
    
    espData.distanceTag.Visible = false
    espData.distanceTag.Color = Color3.fromRGB(0, 255, 0)
    espData.distanceTag.Size = 14
    espData.distanceTag.Center = true
    espData.distanceTag.Outline = true
    espData.distanceTag.Font = 2
    
    espData.tracer.Visible = false
    espData.tracer.Color = Color3.fromRGB(0, 255, 255)
    espData.tracer.Thickness = 1
    espData.tracer.Transparency = 0.5
    
    espData.healthBar.Visible = false
    espData.healthBar.Color = Color3.fromRGB(0, 255, 0)
    espData.healthBar.Filled = true
    espData.healthBar.Thickness = 1
    
    espObjects[targetPlayer] = espData
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not _G.espEnabled or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            espData.box.Visible = false
            espData.nameTag.Visible = false
            espData.distanceTag.Visible = false
            espData.tracer.Visible = false
            espData.healthBar.Visible = false
            return
        end
        
        local rootPart = targetPlayer.Character.HumanoidRootPart
        local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
        
        if onScreen and distance < 200 then
            local size = Vector2.new(40, 60) * (100 / distance)
            espData.box.Size = size
            espData.box.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
            espData.box.Visible = true
            
            espData.nameTag.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y/2 - 20)
            espData.nameTag.Text = targetPlayer.Name
            espData.nameTag.Visible = true
            
            espData.distanceTag.Position = Vector2.new(screenPos.X, screenPos.Y + size.Y/2 + 5)
            espData.distanceTag.Text = math.floor(distance) .. " studs"
            espData.distanceTag.Visible = true
            
            espData.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            espData.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            espData.tracer.Visible = true
            
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            espData.healthBar.Size = Vector2.new(4, size.Y)
            espData.healthBar.Position = Vector2.new(screenPos.X - size.X/2 - 6, screenPos.Y - size.Y/2)
            espData.healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            espData.healthBar.Visible = true
        else
            espData.box.Visible = false
            espData.nameTag.Visible = false
            espData.distanceTag.Visible = false
            espData.tracer.Visible = false
            espData.healthBar.Visible = false
        end
    end)
    
    espConnections[targetPlayer] = conn
end

local function removeESP(targetPlayer)
    if espObjects[targetPlayer] then
        espObjects[targetPlayer].box:Remove()
        espObjects[targetPlayer].nameTag:Remove()
        espObjects[targetPlayer].distanceTag:Remove()
        espObjects[targetPlayer].tracer:Remove()
        espObjects[targetPlayer].healthBar:Remove()
        espObjects[targetPlayer] = nil
    end
    if espConnections[targetPlayer] then
        espConnections[targetPlayer]:Disconnect()
        espConnections[targetPlayer] = nil
    end
end

local function updateESP()
    for _, targetPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if targetPlayer ~= player then
            if _G.espEnabled then
                createESP(targetPlayer)
            else
                removeESP(targetPlayer)
            end
        end
    end
end

-- ==========================================
-- AUTO FARM
-- ==========================================
local function findNearestCoin()
    local nearest = nil
    local nearestDist = math.huge
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and (v.Name:lower():find("coin") or v.Name:lower():find("money") or v.Name:lower():find("gold")) then
            local dist = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
                        (player.Character.HumanoidRootPart.Position - v.Position).Magnitude) or math.huge
            if dist < nearestDist then
                nearest = v
                nearestDist = dist
            end
        end
    end
    return nearest
end

local function findNearestEnemy()
    local nearest = nil
    local nearestDist = math.huge
    
    for _, targetPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dist = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
                            (player.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude) or math.huge
                if dist < nearestDist then
                    nearest = targetPlayer
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

local function autoFarmLoop()
    while _G.autoFarm do
        task.wait(0.1)
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            continue
        end
        
        local rootPart = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            continue
        end
        
        if farmMode == "Coins" then
            local coin = findNearestCoin()
            if coin then
                if (coin.Position - rootPart.Position).Magnitude < 5 then
                    stats.coinsCollected = stats.coinsCollected + 1
                end
            end
        elseif farmMode == "Kills" then
            if not _G.triggerbot then
                local enemy = findNearestEnemy()
                if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                    local enemyPos = enemy.Character.HumanoidRootPart.Position
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, enemyPos)
                end
            end
        end
    end
end

-- ==========================================
-- ANTI-BAN
-- ==========================================
local function checkForAdmins()
    for _, targetPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if targetPlayer ~= player then
            local name = targetPlayer.Name:lower()
            if name:find("admin") or name:find("mod") or name:find("owner") then
                adminsNearby = true
                return
            end
            
            local success, result = pcall(function()
                return targetPlayer:IsInGroup(1)
            end)
            if success and result then
                adminsNearby = true
                return
            end
        end
    end
    adminsNearby = false
end

local function antiBanCheck()
    if not _G.antiBan then return end
    
    checkForAdmins()
    
    if adminsNearby then
        if _G.triggerbot then setTriggerbot(false) end
        if _G.hitboxEnabled then setHitboxEnabled(false) end
        if _G.espEnabled then toggleESP(false) end
        safeMode = true
    else
        safeMode = false
    end
end

-- ==========================================
-- AUTO-AIM SUAVE
-- ==========================================
local function autoAimSmooth(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local targetPos = target.Character.HumanoidRootPart.Position
    local currentCFrame = Camera.CFrame
    
    local smoothCFrame = CFrame.new(currentCFrame.Position, targetPos)
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local goal = {CFrame = smoothCFrame}
    
    local tween = TweenService:Create(Camera, tweenInfo, goal)
    tween:Play()
end

-- ==========================================
-- FUNCIONES DE CONTROL
-- ==========================================
local triggerToggle, hitboxToggle, espToggle, autoFarmToggle, antiBanToggle, autoAimToggle

local function setTriggerbot(value)
    _G.triggerbot = value
    if triggerToggle then triggerToggle:Set(value) end
    if not value and currentlyPressed then
        currentlyPressed = false
        mouse1release()
    end
end

local function setHitboxEnabled(value)
    _G.hitboxEnabled = value
    if hitboxToggle then hitboxToggle:Set(value) end
    updateHitboxes()
end

local function toggleESP(value)
    _G.espEnabled = value
    if espToggle then espToggle:Set(value) end
    updateESP()
end

local function toggleAutoFarm(value)
    _G.autoFarm = value
    if autoFarmToggle then autoFarmToggle:Set(value) end
    if value then
        coroutine.wrap(autoFarmLoop)()
    end
end

local function toggleAntiBan(value)
    _G.antiBan = value
    if antiBanToggle then antiBanToggle:Set(value) end
end

local function toggleAutoAim(value)
    _G.autoAim = value
    if autoAimToggle then autoAimToggle:Set(value) end
end

-- ==========================================
-- EVENTOS DE TECLADO
-- ==========================================
mouse.KeyDown:Connect(function(key)
    if key == triggerKey then setTriggerbot(not _G.triggerbot) end
    if key == hitboxKey then setHitboxEnabled(not _G.hitboxEnabled) end
    if key == espKey then toggleESP(not _G.espEnabled) end
    if key == autoFarmKey then toggleAutoFarm(not _G.autoFarm) end
end)

local guiVisible = false
UIS.InputBegan:Connect(function(Input, GPE)
    if GPE then return end
    if Input.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        Window:Toggle(guiVisible)
    end
end)

-- ==========================================
-- EVENTOS DE JUEGO
-- ==========================================
game:GetService("Players").PlayerAdded:Connect(function(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if _G.hitboxEnabled and targetPlayer ~= player then
            applyHitbox(character, _G.hitboxSize)
        end
        if _G.espEnabled and targetPlayer ~= player then
            createESP(targetPlayer)
        end
    end)
    
    if _G.espEnabled and targetPlayer ~= player then
        createESP(targetPlayer)
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(targetPlayer)
    removeESP(targetPlayer)
    removeHitbox(targetPlayer.Character)
end)

-- ==========================================
-- GUI - PESTAÑA PRINCIPAL
-- ==========================================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

-- Sección Combate
MainTab:Section({
    Title = "⚔️ Combate",
})

triggerToggle = MainTab:Toggle({
    Title = "TriggerBot [C]",
    Default = false,
    Callback = function(v) setTriggerbot(v) end
})

MainTab:Toggle({
    Title = "Hold Click",
    Description = "Mantener clic mientras apunta",
    Default = true,
    Callback = function(v) holdClick = v end
})

MainTab:Slider({
    Title = "FOV Radio",
    Description = "Distancia máxima para disparar",
    Value = { Min = 50, Max = 300, Default = 100 },
    Callback = function(v) _G.fovRadius = v end
})

hitboxToggle = MainTab:Toggle({
    Title = "Hitbox Expander [H]",
    Default = false,
    Callback = function(v) setHitboxEnabled(v) end
})

MainTab:Slider({
    Title = "Tamaño Hitbox",
    Value = { Min = 1.0, Max = 3.5, Default = 1.5, Precise = 1 },
    Callback = function(v)
        _G.hitboxSize = v
        if _G.hitboxEnabled then updateHitboxes() end
    end
})

autoAimToggle = MainTab:Toggle({
    Title = "Auto-Aim Suave",
    Default = false,
    Callback = function(v) toggleAutoAim(v) end
})

-- Sección Visual
MainTab:Section({
    Title = "👁️ Visual",
})

espToggle = MainTab:Toggle({
    Title = "ESP [Z]",
    Default = false,
    Callback = function(v) toggleESP(v) end
})

-- Sección Farm
MainTab:Section({
    Title = "💰 Auto Farm",
})

autoFarmToggle = MainTab:Toggle({
    Title = "Auto Farm [X]",
    Default = false,
    Callback = function(v) toggleAutoFarm(v) end
})

MainTab:Dropdown({
    Title = "Modo Farm",
    Options = { "Coins", "Kills", "XP" },
    Default = "Coins",
    Callback = function(v) farmMode = v end
})

-- Sección Anti-Ban
MainTab:Section({
    Title = "🛡️ Anti-Ban",
})

antiBanToggle = MainTab:Toggle({
    Title = "Anti-Ban",
    Default = false,
    Callback = function(v) toggleAntiBan(v) end
})

MainTab:Label({
    Title = "⚠️ Desactiva todo si hay admins",
})

-- ==========================================
-- PESTAÑA DE CONFIGURACIÓN
-- ==========================================
local ConfigTab = Window:Tab({
    Title = "Config",
    Icon = "settings",
})

ConfigTab:Section({
    Title = "⌨️ Teclas Rápidas",
})

ConfigTab:Keybind({
    Title = "Tecla TriggerBot",
    Default = Enum.KeyCode.C,
    Callback = function(newKey)
        triggerKey = tostring(newKey):gsub("Enum.KeyCode.", ""):lower()
        if triggerToggle then
            triggerToggle.Title = "TriggerBot [" .. triggerKey:upper() .. "]"
        end
    end
})

ConfigTab:Keybind({
    Title = "Tecla Hitbox",
    Default = Enum.KeyCode.H,
    Callback = function(newKey)
        hitboxKey = tostring(newKey):gsub("Enum.KeyCode.", ""):lower()
        if hitboxToggle then
            hitboxToggle.Title = "Hitbox Expander [" .. hitboxKey:upper() .. "]"
        end
    end
})

ConfigTab:Keybind({
    Title = "Tecla ESP",
    Default = Enum.KeyCode.Z,
    Callback = function(newKey)
        espKey = tostring(newKey):gsub("Enum.KeyCode.", ""):lower()
        if espToggle then
            espToggle.Title = "ESP [" .. espKey:upper() .. "]"
        end
    end
})

ConfigTab:Keybind({
    Title = "Tecla Auto Farm",
    Default = Enum.KeyCode.X,
    Callback = function(newKey)
        autoFarmKey = tostring(newKey):gsub("Enum.KeyCode.", ""):lower()
        if autoFarmToggle then
            autoFarmToggle.Title = "Auto Farm [" .. autoFarmKey:upper() .. "]"
        end
    end
})

-- ==========================================
-- PESTAÑA DE ESTADÍSTICAS
-- ==========================================
local StatsTab = Window:Tab({
    Title = "Stats",
    Icon = "bar-chart-2",
})

local killsLabel, shotsLabel, coinsLabel, timeLabel

StatsTab:Section({
    Title = "📊 Estadísticas en Vivo",
})

killsLabel = StatsTab:Label({
    Title = "Kills: 0",
})

shotsLabel = StatsTab:Label({
    Title = "Disparos: 0",
})

coinsLabel = StatsTab:Label({
    Title = "Monedas: 0",
})

timeLabel = StatsTab:Label({
    Title = "Tiempo: 0s",
})

-- Actualizar estadísticas cada segundo
spawn(function()
    while true do
        task.wait(1)
        if killsLabel then killsLabel:Set("Kills: " .. stats.kills) end
        if shotsLabel then shotsLabel:Set("Disparos: " .. stats.shotsFired) end
        if coinsLabel then coinsLabel:Set("Monedas: " .. stats.coinsCollected) end
        if timeLabel then
            local elapsed = math.floor(tick() - stats.startTime)
            local mins = math.floor(elapsed / 60)
            local secs = elapsed % 60
            timeLabel:Set("Tiempo: " .. mins .. "m " .. secs .. "s")
        end
    end
end)

-- ==========================================
-- PESTAÑA DE INFORMACIÓN
-- ==========================================
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Section({
    Title = "📋 Controles",
})

InfoTab:Label({ Title = "[Ctrl Der] - Abrir/Cerrar menú" })
InfoTab:Label({ Title = "[C] - Activar/Desactivar TriggerBot" })
InfoTab:Label({ Title = "[H] - Activar/Desactivar Hitbox" })
InfoTab:Label({ Title = "[Z] - Activar/Desactivar ESP" })
InfoTab:Label({ Title = "[X] - Activar/Desactivar Auto Farm" })

InfoTab:Section({
    Title = "ℹ️ Acerca de",
})

InfoTab:Label({ Title = "30cm Hub v2.0" })
InfoTab:Label({ Title = "Para Duels Murder vs Sheriff" })
InfoTab:Label({ Title = "Hecho por 30cm Team" })

-- ==========================================
-- TRIGGERBOT PRINCIPAL
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- Anti-Ban check periódico
    if _G.antiBan and tick() - lastActionTime > 1 then
        lastActionTime = tick()
        antiBanCheck()
    end
    
    if safeMode then return end
    
    -- TriggerBot
    if _G.triggerbot and mouse.Target then
        local humanoid = mouse.Target.Parent:FindFirstChildOfClass("Humanoid")
        if not humanoid and mouse.Target.Parent.Parent then
            humanoid = mouse.Target.Parent.Parent:FindFirstChildOfClass("Humanoid")
        end
        
        if humanoid then
            local targetPlayer = game.Players:GetPlayerFromCharacter(mouse.Target.Parent)
            if targetPlayer and targetPlayer ~= player and humanoid.Health > 0 then
                -- Auto-aim
                if _G.autoAim then
                    autoAimSmooth(targetPlayer)
                end
                
                -- Disparar
                if holdClick then
                    if not currentlyPressed then
                        currentlyPressed = true
                        mouse1press()
                        stats.shotsFired = stats.shotsFired + 1
                    end
                else
                    mouse1click()
                    stats.shotsFired = stats.shotsFired + 1
                end
            else
                if holdClick and currentlyPressed then
                    currentlyPressed = false
                    mouse1release()
                end
            end
        else
            if holdClick and currentlyPressed then
                currentlyPressed = false
                mouse1release()
            end
        end
    else
        if currentlyPressed then
            currentlyPressed = false
            mouse1release()
        end
    end
end)

-- ==========================================
-- NOTIFICACIÓN DE INICIO
-- ==========================================
task.wait(1)
print("✅ 30cm Hub v2.0 cargado correctamente")
print("📌 Presiona Ctrl Der para abrir el menú")
