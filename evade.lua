-- Evade Script: Speed Boost (5x), Fixed ESP, Infinite Jump, Noclip
-- Designed for Delta Executor & Mobile/PC Compatibility

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configuration & State
local ESP_Enabled = false
local SpeedBoost_Enabled = false
local InfJump_Enabled = false
local Noclip_Enabled = false

local SpeedMultiplier = 5
local ESP_Objects = {}

----------------------------------------------------------------
-- 1. Fixed ESP Management
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
                if not ESP_Objects[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "Evade_ESP"
                    highlight.Adornee = character
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(0, 255, 100)
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0.1
                    highlight.Parent = character
                    
                    ESP_Objects[player] = { Highlight = highlight }
                else
                    if ESP_Objects[player].Highlight.Adornee ~= character then
                        ESP_Objects[player].Highlight.Adornee = character
                        ESP_Objects[player].Highlight.Parent = character
                    end
                    ESP_Objects[player].Highlight.Enabled = true
                end
            else
                if ESP_Objects[player] and ESP_Objects[player].Highlight then
                    ESP_Objects[player].Highlight.Enabled = false
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(removeESP)

----------------------------------------------------------------
-- 2. Infinite Jump Logic
----------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if InfJump_Enabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

----------------------------------------------------------------
-- 3. Main Heartbeat Loop (Speed, Noclip, ESP)
----------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    -- Speed Boost
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
    
    -- Noclip
    if Noclip_Enabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
    
    -- ESP Update
    if ESP_Enabled then
        updateESP()
    end
end)

----------------------------------------------------------------
-- 4. Red & Green Themed Expanded GUI
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
MainFrame.Size = UDim2.new(0, 220, 0, 310)
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

-- Helper function to create styled toggle buttons
local function createButton(name, posY, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

-- Create UI Elements
local ESPBtn   = createButton("ESPBtn", 50, "ESP")
local SpeedBtn = createButton("SpeedBtn", 95, "Speed Boost (5x)")
local JumpBtn  = createButton("JumpBtn", 140, "Infinite Jump")
local NoclipBtn = createButton("NoclipBtn", 185, "Noclip")

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

JumpBtn.MouseButton1Click:Connect(function()
    InfJump_Enabled = not InfJump_Enabled
    if InfJump_Enabled then
        JumpBtn.Text = "Infinite Jump: ON"
        JumpBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        JumpBtn.Text = "Infinite Jump: OFF"
        JumpBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    Noclip_Enabled = not Noclip_Enabled
    if Noclip_Enabled then
        NoclipBtn.Text = "Noclip: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        NoclipBtn.Text = "Noclip: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)
