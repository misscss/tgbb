_G.triggerbot = false
_G.clickCooldown = 0.7

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Clicked = false
local lastClick = 0

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TriggerbotIndicator"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0, 50, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "OFF"
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 9.5
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = ScreenGui

local function updateIndicator()
    if _G.triggerbot then
        StatusLabel.Text = "ON"
    else
        StatusLabel.Text = "OFF"
    end
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then
        return
    end

    if Input.KeyCode == Enum.KeyCode.C then
        _G.triggerbot = not _G.triggerbot
        updateIndicator()
    end
end)

RunService.RenderStepped:Connect(function()
    local target = mouse.Target
    
    if target then
        local character = target.Parent
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if not humanoid and character.Parent then
            character = character.Parent
            humanoid = character:FindFirstChildOfClass("Humanoid")
        end
        
        if humanoid and humanoid.Health > 0 and character:FindFirstChild("Head") then
            local targetPlayer = game:GetService("Players"):FindFirstChild(character.Name)
            
            if targetPlayer and targetPlayer ~= player then
                local sameTeam = false
                if player.Team and targetPlayer.Team == player.Team then
                    sameTeam = true
                end
                
                if not sameTeam and _G.triggerbot then
                    local currentTime = tick()
                    if currentTime - lastClick >= _G.clickCooldown then
                        mouse1press()
                        lastClick = currentTime
                        Clicked = false
                    end
                end
            end
        end
    end
    
    if _G.triggerbot and not Clicked then
        mouse1release()
    end
end)
