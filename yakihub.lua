--// SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

--// SETTINGS
local settings = {
    Mags = false,
    ReachDistance = 280,
    WalkSpeedEnabled = false,
    WalkSpeedAmount = 16,
    AimbotType = "low",
    ShotDelay = 0.32,
    Arc = 0,
    YAxis = 0,
    CamlockEnabled = false,
}

--// RAYFIELD UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nevcit/UI-Library/main/Loadstring/RayfieldLib"))()

local Window = Rayfield:CreateWindow({
    Name = "Yaki Hub",
    LoadingTitle = "Yaki Hub",
    SaveConfig = true,
    ConfigFolder = "YakiHubConfigs"
})

local Tab_Shooting = Window:CreateTab("Shooting")
local Tab_Tracking = Window:CreateTab("Tracking")
local Tab_Physics  = Window:CreateTab("Physics")
local Tab_Settings = Window:CreateTab("Settings")

--// UI ELEMENTS --

-- Shooting Tab

Tab_Shooting:CreateDropdown({
    Name = "Aimbot Type",
    Options = {"None", "Low", "High", "Random"},
    CurrentOption = settings.AimbotType:gsub("^%l", string.upper),
    Flag = "AimbotType",
    Callback = function(val)
        settings.AimbotType = val:lower()
        _G.Aimbot = settings.AimbotType
    end,
})

Tab_Shooting:CreateSlider({
    Name = "Shot Delay",
    Range = {0, 0.5},
    Increment = 0.01,
    CurrentValue = settings.ShotDelay,
    Flag = "ShotDelay",
    Callback = function(val)
        settings.ShotDelay = val
        _G.ShotDelay = val
    end,
})

Tab_Shooting:CreateSlider({
    Name = "Arc Amount",
    Range = {0, 15},
    Increment = 1,
    CurrentValue = settings.Arc,
    Flag = "ArcAmount",
    Callback = function(val)
        settings.Arc = val
        _G.Arc = val
    end,
})

Tab_Shooting:CreateSlider({
    Name = "Y Axis",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = settings.YAxis,
    Flag = "YAxis",
    Callback = function(val)
        settings.YAxis = val
        _G.YAxis = val
    end,
})

Tab_Shooting:CreateToggle({
    Name = "Enable Camlock",
    CurrentValue = settings.CamlockEnabled,
    Flag = "Camlock",
    Callback = function(state)
        settings.CamlockEnabled = state
    end,
})

-- Tracking Tab (Placeholder for future)

-- Physics Tab

Tab_Physics:CreateToggle({
    Name = "Enable Magnet",
    CurrentValue = settings.Mags,
    Flag = "Magnet",
    Callback = function(state)
        settings.Mags = state
    end,
})

Tab_Physics:CreateSlider({
    Name = "Magnet Distance",
    Range = {0, 300},
    Increment = 1,
    CurrentValue = settings.ReachDistance,
    Flag = "MagnetDistance",
    Callback = function(val)
        settings.ReachDistance = val
    end,
})

Tab_Physics:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = settings.WalkSpeedEnabled,
    Flag = "WalkSpeedToggle",
    Callback = function(state)
        settings.WalkSpeedEnabled = state
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = state and settings.WalkSpeedAmount or 16
        end
    end,
})

Tab_Physics:CreateSlider({
    Name = "Speed Amount",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = settings.WalkSpeedAmount,
    Flag = "WalkSpeedAmount",
    Callback = function(val)
        settings.WalkSpeedAmount = val
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid and settings.WalkSpeedEnabled then
            Humanoid.WalkSpeed = val
        end
    end,
})

--// FUNCTIONALITY

RunService.RenderStepped:Connect(function()
    if settings.CamlockEnabled then
        local goal = workspace:FindFirstChild("Goal")
        if goal then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, goal.Position)
        end
    end
end)

Character:WaitForChild("Humanoid").Jumping:Connect(function()
    if Character:FindFirstChild("Basketball") then
        local closestGoal, closestDist, power = nil, math.huge, 75
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Swish" and obj.Parent:IsA("BasePart") then
                local dist = (HumanoidRootPart.Position - obj.Parent.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestGoal = obj.Parent
                    if dist >= 58 and dist <= 62 then power = 75
                    elseif dist > 62 and dist <= 68 then power = 80
                    elseif dist > 68 and dist <= 74 then power = 85 end
                end
            end
        end
        if closestGoal then
            LocalPlayer:SetAttribute("Power", power)
            local adjustY = 0
            if closestDist >= 58 and closestDist <= 62 then adjustY = 31
            elseif closestDist > 62 and closestDist <= 68 then adjustY = 48
            elseif closestDist > 68 and closestDist <= 73 then adjustY = 58 end
            local adjustedPos = closestGoal.Position + Vector3.new(0, adjustY, 0)

            Camera.CFrame = CFrame.new(Camera.CFrame.Position, adjustedPos)

            task.wait(settings.ShotDelay)

            VirtualInputManager:SendMouseButtonEvent(
                workspace.CurrentCamera.ViewportSize.X / 2,
                workspace.CurrentCamera.ViewportSize.Y / 2 + settings.YAxis,
                0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(
                workspace.CurrentCamera.ViewportSize.X / 2,
                workspace.CurrentCamera.ViewportSize.Y / 2 + settings.YAxis,
                0, false, game, 1)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if settings.Mags then
        local ball, dist = nil, math.huge
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name == "Basketball" or v.Name == "Ball") then
                local d = (HumanoidRootPart.Position - v.Position).Magnitude
                if d < dist then
                    ball = v
                    dist = d
                end
            end
        end
        if ball and dist <= settings.ReachDistance then
            local closestPart, closestDist = nil, math.huge
            for _, p in ipairs(Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    local d = (p.Position - ball.Position).Magnitude
                    if d < closestDist then
                        closestPart = p
                        closestDist = d
                    end
                end
            end
            if closestPart then
                firetouchinterest(closestPart, ball, 0)
                task.wait()
                firetouchinterest(closestPart, ball, 1)
            end
        end
    end
end)
