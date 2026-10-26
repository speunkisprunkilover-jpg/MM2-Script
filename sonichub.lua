-- Sonic Hub Script (Mobile & Delta Optimized with Sonic Image Icon)
-- Features: Aimbot (1-100), ESP with Color Picker, Hitbox Expander,
-- C-Frame Speed (0-10), Inf Jump, Noclip, Rainbow UI, Sonic Image Toggle Icon

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- State Variables
local Hub_Open = true
local Aimbot_Enabled = false
local Aimbot_Smoothness = 50
local ESP_Enabled = false
local ESP_ColorName = "Green"
local Hitbox_Enabled = false
local Speed_Enabled = false
local Speed_Multiplier = 5
local InfJump_Enabled = false
local Noclip_Enabled = false

local ESP_Objects = {}
local Hitbox_OriginalSizes = {}

local ESP_Colors = {
    ["Red"]        = Color3.fromRGB(255, 50, 50),
    ["Blue"]       = Color3.fromRGB(50, 100, 255),
    ["Yellow"]     = Color3.fromRGB(255, 220, 50),
    ["Green"]      = Color3.fromRGB(50, 255, 50),
    ["Dark Blue"]  = Color3.fromRGB(10, 30, 120),
    ["Light Blue"] = Color3.fromRGB(100, 200, 255)
}

----------------------------------------------------------------
-- 1. Aimbot Logic
----------------------------------------------------------------
local function getClosestPlayer()
    local target = nil
    local shortestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = player.Character.HumanoidRootPart
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Aimbot_Enabled then
        local targetPart = getClosestPlayer()
        if targetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            local alpha = math.clamp((101 - Aimbot_Smoothness) / 100, 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
        end
    end
end)

----------------------------------------------------------------
-- 2. ESP Logic
----------------------------------------------------------------
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and ESP_Enabled then
                if not ESP_Objects[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "SonicHub_ESP"
                    highlight.Adornee = character
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0.1
                    highlight.Parent = character
                    ESP_Objects[player] = highlight
                end
                local col = ESP_Colors[ESP_ColorName] or Color3.fromRGB(50, 255, 50)
                ESP_Objects[player].FillColor = col
                ESP_Objects[player].OutlineColor = col
                ESP_Objects[player].Enabled = true
            else
                if ESP_Objects[player] then
                    ESP_Objects[player].Enabled = false
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if ESP_Objects[player] then
        ESP_Objects[player]:Destroy()
        ESP_Objects[player] = nil
    end
end)

----------------------------------------------------------------
-- 3. Hitbox Expander Logic (26x25x28 Invisible)
----------------------------------------------------------------
local function updateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and humanoid and humanoid.Health > 0 then
                if not Hitbox_OriginalSizes[player] then
                    Hitbox_OriginalSizes[player] = hrp.Size
                end
                if Hitbox_Enabled then
                    hrp.Size = Vector3.new(26, 25, 28)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                else
                    if Hitbox_OriginalSizes[player] then
                        hrp.Size = Hitbox_OriginalSizes[player]
                    end
                    hrp.Transparency = 1
                end
            end
        end
    end
end

----------------------------------------------------------------
-- 4. Speed, Inf Jump, Noclip
----------------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if InfJump_Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if Speed_Enabled and Speed_Multiplier > 0 then
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * Speed_Multiplier * dt * 10)
            end
        end
    end
    
    if Noclip_Enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    if ESP_Enabled then updateESP() end
    if Hitbox_Enabled then updateHitboxes() end
end)

----------------------------------------------------------------
-- 5. GUI Construction (Sonic Image Icon & Rainbow Outline)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonicHub_Gui"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- Floating Image Button (Sonic Icon)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleIcon"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
-- Verified working Roblox Sonic/Game Decal Asset ID
ToggleButton.Image = "rbxassetid://1380757657" 
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = ToggleButton

local IconStroke = Instance.new("UIStroke")
IconStroke.Thickness = 3
IconStroke.Parent = ToggleButton

-- Main Hub Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Position = UDim2.new(0.15, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Rainbow Outline for Main Menu & Icon
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 3
MainStroke.Parent = MainFrame

RunService.RenderStepped:Connect(function()
    local rainbowColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    MainStroke.Color = rainbowColor
    IconStroke.Color = rainbowColor
end)

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "⚡ Sonic Hub ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = Title

-- Scrolling Container for Features
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainFrame

local function createToggle(name, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        end
        callback(active)
    end)
    return btn
end

-- Feature Controls
createToggle("AimbotBtn", 10, "Aimbot", function(state) Aimbot_Enabled = state end)

local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0.9, 0, 0, 20)
SmoothLabel.Position = UDim2.new(0.05, 0, 0, 52)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Aimbot Smoothness: 50"
SmoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SmoothLabel.TextSize = 12
SmoothLabel.Parent = Scroll

local SmoothBox = Instance.new("TextBox")
SmoothBox.Size = UDim2.new(0.9, 0, 0, 28)
SmoothBox.Position = UDim2.new(0.05, 0, 0, 74)
SmoothBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SmoothBox.Text = "50"
SmoothBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothBox.TextSize = 13
SmoothBox.Parent = Scroll
local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(0, 4); sbCorner.Parent = SmoothBox

SmoothBox.FocusLost:Connect(function()
    local val = tonumber(SmoothBox.Text)
    if val then
        Aimbot_Smoothness = math.clamp(val, 1, 100)
        SmoothBox.Text = tostring(Aimbot_Smoothness)
        SmoothLabel.Text = "Aimbot Smoothness: " .. Aimbot_Smoothness
    else
        SmoothBox.Text = tostring(Aimbot_Smoothness)
    end
end)

createToggle("ESPBtn", 110, "ESP", function(state) ESP_Enabled = state end)

local ESPColorLabel = Instance.new("TextLabel")
ESPColorLabel.Size = UDim2.new(0.9, 0, 0, 20)
ESPColorLabel.Position = UDim2.new(0.05, 0, 0, 152)
ESPColorLabel.BackgroundTransparency = 1
ESPColorLabel.Text = "ESP Color: Green"
ESPColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ESPColorLabel.TextSize = 12
ESPColorLabel.Parent = Scroll

local colorsList = {"Green", "Red", "Blue", "Yellow", "Dark Blue", "Light Blue"}
local colorIdx = 1
local ColorBtn = Instance.new("TextButton")
ColorBtn.Size = UDim2.new(0.9, 0, 0, 28)
ColorBtn.Position = UDim2.new(0.05, 0, 0, 174)
ColorBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
ColorBtn.Text = "Change ESP Color [ Green ]"
ColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorBtn.TextSize = 12
ColorBtn.Parent = Scroll
local cbCorner = Instance.new("UICorner"); cbCorner.CornerRadius = UDim.new(0, 4); cbCorner.Parent = ColorBtn

ColorBtn.MouseButton1Click:Connect(function()
    colorIdx = colorIdx % #colorsList + 1
    ESP_ColorName = colorsList[colorIdx]
    ColorBtn.Text = "Change ESP Color [ " .. ESP_ColorName .. " ]"
    ESPColorLabel.Text = "ESP Color: " .. ESP_ColorName
end)

createToggle("HitboxBtn", 210, "Hitbox Expander (26x25x28)", function(state) Hitbox_Enabled = state end)

createToggle("SpeedBtn", 255, "Speed Boost (C-Frame)", function(state) Speed_Enabled = state end)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 297)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed Multiplier (0-10): 5"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 12
SpeedLabel.Parent = Scroll

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0.9, 0, 0, 28)
SpeedBox.Position = UDim2.new(0.05, 0, 0, 319)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedBox.Text = "5"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 13
SpeedBox.Parent = Scroll
local spCorner = Instance.new("UICorner"); spCorner.CornerRadius = UDim.new(0, 4); spCorner.Parent = SpeedBox

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        Speed_Multiplier = math.clamp(val, 0, 10)
        SpeedBox.Text = tostring(Speed_Multiplier)
        SpeedLabel.Text = "Speed Multiplier (0-10): " .. Speed_Multiplier
    else
        SpeedBox.Text = tostring(Speed_Multiplier)
    end
end)

createToggle("JumpBtn", 355, "Infinite Jump", function(state) InfJump_Enabled = state end)
createToggle("NoclipBtn", 400, "Noclip", function(state) Noclip_Enabled = state end)

-- Toggle Hub Open/Close via Sonic Image Icon
ToggleButton.MouseButton1Click:Connect(function()
    Hub_Open = not Hub_Open
    MainFrame.Visible = Hub_Open
end)
