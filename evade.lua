-- Evade C-Frame Speed Boost (5x) & Fixed ESP Script
-- Designed for Delta Executor & Mobile/PC Compatibility

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configuration & State
local ESP_Enabled = false
local SpeedBoost_Enabled = false
local SpeedMultiplier = 5 -- Adjusted to 5x Speed Boost
local ESP_Objects = {}

----------------------------------------------------------------
-- Fixed ESP Management (Box / Highlight Alternative)
----------------------------------------------------------------
local function removeESP(player)
    if ESP_Objects[player] then
        if ESP_Objects[player].Highlight then
            ESP_Objects[player].Highlight:Destroy()
        end
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and ESP_Enabled then
                -- Create highlight if it doesn't exist
                if not ESP_Objects[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "Evade_ESP"
                    highlight.Adornee = character
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Green Fill
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Red Outline
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0.1
                    highlight.Parent = character
                    
                    ESP_Objects[player] = { Highlight = highlight }
                else
                    -- Update existing highlight adornee in case character respawned
                    if ESP_Objects[player].Highlight.Adornee ~= character then
                        ESP_Objects[player].Highlight.Adornee = character
                        ESP_Objects[player].Highlight.Parent = character
                    end
                    ESP_Objects[player].Highlight.Enabled = true
                end
            else
                -- Remove or hide if ESP is disabled or character is dead
                if ESP_Objects[player] and ESP_Objects[player].Highlight then
                    ESP_Objects[player].Highlight.Enabled = false
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(removeESP)

----------------------------------------------------------------
-- C-Frame Speed Boost Loop (5x)
----------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    if SpeedBoost_Enabled then
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * SpeedMultiplier * dt * 10)
            end
        end
    end
    
    -- Run ESP check inside heartbeat for stability
    if ESP_Enabled then
        updateESP()
    end
end)

----------------------------------------------------------------
-- Red & Green Themed GUI
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Evade_Menu"
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
MainFrame.Size = UDim2.new(0, 210, 0, 180)
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
Title.Text = "Evade Script | Hub"
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

-- ESP Toggle Button
local ESPBtn = Instance.new("TextButton")
ESPBtn.Name = "ESPBtn"
ESPBtn.Size = UDim2.new(0.85, 0, 0, 40)
ESPBtn.Position = UDim2.new(0.075, 0, 0.28, 0)
ESPBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ESPBtn.Text = "ESP: OFF"
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.TextSize = 14
ESPBtn.Font = Enum.Font.SourceSansSemibold
ESPBtn.Parent = MainFrame

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 6)
ESPCorner.Parent = ESPBtn

-- Speed Boost Toggle Button
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Name = "SpeedBtn"
SpeedBtn.Size = UDim2.new(0.85, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
SpeedBtn.Text = "Speed Boost (5x): OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 13
SpeedBtn.Font = Enum.Font.SourceSansSemibold
SpeedBtn.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedBtn

----------------------------------------------------------------
-- Button Logic
----------------------------------------------------------------
ESPBtn.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    if ESP_Enabled then
        ESPBtn.Text = "ESP: ON"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        ESPBtn.Text = "ESP: OFF"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        for _, obj in pairs(ESP_Objects) do
            if obj.Highlight then
                obj.Highlight.Enabled = false
            end
        end
    end
end)

SpeedBtn.MouseButton1Click:Connect(function()
    SpeedBoost_Enabled = not SpeedBoost_Enabled
    if SpeedBoost_Enabled then
        SpeedBtn.Text = "Speed Boost (5x): ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        SpeedBtn.Text = "Speed Boost (5x): OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)
