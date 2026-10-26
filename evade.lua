-- Evade C-Frame Speed Boost & ESP Script
-- Designed for Delta Executor & Mobile/PC Compatibility

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configuration & State
local ESP_Enabled = false
local SpeedBoost_Enabled = false
local SpeedMultiplier = 10 -- C-Frame Speed Boost Multiplier
local Highlights = {}

----------------------------------------------------------------
-- ESP Management (Highlight Players)
----------------------------------------------------------------
local function removeHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function updateHighlight(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        removeHighlight(player)
        return
    end

    if not ESP_Enabled then
        removeHighlight(player)
        return
    end

    local highlight = Highlights[player]
    if not highlight or highlight.Parent ~= character then
        removeHighlight(player)
        highlight = Instance.new("Highlight")
        highlight.Name = "Evade_ESP_Highlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.1
        highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Green Theme Accent
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Red Theme Accent
        highlight.Adornee = character
        highlight.Parent = character
        Highlights[player] = highlight
    end

    highlight.Enabled = ESP_Enabled
end

Players.PlayerRemoving:Connect(removeHighlight)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateHighlight(player)
        end
    end
end)

----------------------------------------------------------------
-- C-Frame Speed Boost Loop
----------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    if not SpeedBoost_Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if humanoidRootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
        -- Apply C-Frame translation offset based on move direction
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + (humanoid.MoveDirection * SpeedMultiplier * dt * 10)
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

-- Main Window (Dark background with Red/Green styling)
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

-- Top Title Bar (Green accent)
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

-- Fix title corner clipping at the bottom
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = Title

-- ESP Toggle Button (Red Theme Default)
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

-- Speed Boost Toggle Button (Red Theme Default)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Name = "SpeedBtn"
SpeedBtn.Size = UDim2.new(0.85, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
SpeedBtn.Text = "Speed Boost (10x): OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 13
SpeedBtn.Font = Enum.Font.SourceSansSemibold
SpeedBtn.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedBtn

----------------------------------------------------------------
-- Button Logic & Color Feedback (Green = ON, Red = OFF)
----------------------------------------------------------------
ESPBtn.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    if ESP_Enabled then
        ESPBtn.Text = "ESP: ON"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        ESPBtn.Text = "ESP: OFF"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        for _, highlight in pairs(Highlights) do
            highlight.Enabled = false
        end
    end
end)

SpeedBtn.MouseButton1Click:Connect(function()
    SpeedBoost_Enabled = not SpeedBoost_Enabled
    if SpeedBoost_Enabled then
        SpeedBtn.Text = "Speed Boost (10x): ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        SpeedBtn.Text = "Speed Boost (10x): OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)
