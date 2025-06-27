--// SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

--// WINDUI BASE
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Yaki Hub",
    Icon = "star",
    Author = "Yaki Hub",
    Folder = "Yaki Hub",
    Size = UDim2.fromOffset(545, 376),
    Theme = "Light",
})

local Tab1 = Window:Tab({ Title = "Shooting", Icon = "target" })
local Tab2 = Window:Tab({ Title = "Tracking", Icon = "crosshair" })
local Tab3 = Window:Tab({ Title = "Physics", Icon = "atom" })
local Tab4 = Window:Tab({ Title = "Settings", Icon = "settings-2" })

-- SETTINGS
local settings = {
    Mags = false,
    ReachDistance = 280,
    WalkSpeedEnabled = false,
    WalkSpeedAmount = 16,
    AimbotType = 'low',
    ShotDelay = 0.32,
    Arc = 0,
    YAxis = 0,
    CamlockEnabled = false
}

-- Aimbot Type
Tab1:Dropdown({
    Title = "Aimbot Type",
    Values = { "None", "Low", "High", "Random" },
    Value = "Low",
    Multi = false,
    AllowNone = false,
    Callback = function(val)
        settings.AimbotType = val:lower()
        _G.Aimbot = settings.AimbotType
    end
})

-- Shot Delay
Tab1:Slider({
    Title = "Shot Delay",
    Step = 0.01,
    Min = 0,
    Max = 0.5,
    Default = settings.ShotDelay,
    Callback = function(val)
        settings.ShotDelay = val
        _G.ShotDelay = val
    end
})

-- Arc Amount
Tab1:Slider({
    Title = "Arc Amount",
    Step = 1,
    Min = 0,
    Max = 15,
    Default = settings.Arc,
    Callback = function(val)
        settings.Arc = val
        _G.Arc = val
    end
})

-- Y Axis
Tab1:Slider({
    Title = "Y Axis",
    Step = 1,
    Min = 0,
    Max = 100,
    Default = settings.YAxis,
    Callback = function(val)
        settings.YAxis = val
        _G.YAxis = val
    end
})

-- Camlock Toggle
Tab1:Toggle({
    Title = "Enable Camlock",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        settings.CamlockEnabled = state
    end
})

RunService.RenderStepped:Connect(function()
    if settings.CamlockEnabled then
        local goal = workspace:FindFirstChild("Goal")
        if goal then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, goal.Position)
        end
    end
end)

-- Silent Aim Jump Trigger
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

-- Magnet Toggle
Tab3:Toggle({
    Title = "Enable Magnet",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        settings.Mags = state
    end
})

-- Magnet Distance Slider
Tab3:Slider({
    Title = "Magnet Distance",
    Step = 1,
    Min = 0,
    Max = 300,
    Default = settings.ReachDistance,
    Callback = function(val)
        settings.ReachDistance = val
    end
})

-- Magnet Behavior
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

-- WalkSpeed Toggle
Tab3:Toggle({
    Title = "Enable WalkSpeed",
    Type = "Checkbox",
    Default = false,
    Callback = function(state)
        settings.WalkSpeedEnabled = state
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = state and settings.WalkSpeedAmount or 16
        end
    end
})

-- WalkSpeed Slider
Tab3:Slider({
    Title = "Speed Amount",
    Step = 1,
    Min = 16,
    Max = 100,
    Default = settings.WalkSpeedAmount,
    Callback = function(val)
        settings.WalkSpeedAmount = val
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid and settings.WalkSpeedEnabled then
            Humanoid.WalkSpeed = val
        end
    end
})
