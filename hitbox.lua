-- Hitbox Expander Script (Completely Invisible)
-- Dimensions: Sides (26), Top/Bottom (25), Forward/Backward (28)
-- Designed for Delta Executor & Mobile/PC Compatibility

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configuration & State
local Hitbox_Enabled = false

-- Requested Custom Dimensions
local SizeX = 26 -- Sides (Width)
local SizeY = 25 -- Top and Bottom (Height)
local SizeZ = 28 -- Forward and Backward (Depth)

local OriginalSizes = {}

----------------------------------------------------------------
-- Hitbox Expansion Logic (Completely Invisible)
----------------------------------------------------------------
local function updateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if humanoidRootPart and humanoid and humanoid.Health > 0 then
                    -- Save original size once
                    if not OriginalSizes[player] then
                        OriginalSizes[player] = humanoidRootPart.Size
                    end
                    
                    if Hitbox_Enabled then
                        humanoidRootPart.Size = Vector3.new(SizeX, SizeY, SizeZ)
                        humanoidRootPart.Transparency = 1 -- Completely invisible
                        humanoidRootPart.CanCollide = false -- Prevent physics interference
                    else
                        if OriginalSizes[player] then
                            humanoidRootPart.Size = OriginalSizes[player]
                        end
                        humanoidRootPart.Transparency = 1
                        humanoidRootPart.CanCollide = false
                    end
                end
            end
        end
    end
end

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
    OriginalSizes[player] = nil
end)

-- Run Loop
RunService.RenderStepped:Connect(function()
    if Hitbox_Enabled then
        updateHitboxes()
    end
end)

----------------------------------------------------------------
-- Red & Green Themed GUI
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Hitbox_Menu"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
Title.Text = "Hitbox Expander"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = Title

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Text = "Hitbox: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.SourceSansSemibold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

----------------------------------------------------------------
-- Button Toggle Logic
----------------------------------------------------------------
ToggleBtn.MouseButton1Click:Connect(function()
    Hitbox_Enabled = not Hitbox_Enabled
    if Hitbox_Enabled then
        ToggleBtn.Text = "Hitbox: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        ToggleBtn.Text = "Hitbox: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        -- Revert hitboxes immediately when turned off
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and OriginalSizes[player] then
                    hrp.Size = OriginalSizes[player]
                    hrp.Transparency = 1
                end
            end
        end
    end
end)
