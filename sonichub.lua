-- [[ Sonic Hub - Delta Executor Mobile Compatible ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration Table
local Settings = {
    AimbotEnabled = false,
    Smoothness = 5, -- Slider range 1-100 mapped
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    HitboxExpander = false,
    HitboxSize = 10,
    CFrameSpeed = false,
    SpeedMultiplier = 0, -- Slider range 0-10
    InfJump = false,
    Noclip = false
}

-- Target acquisition for Aimbot
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonicHubGui"
ScreenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Rainbow Outline Frame
local RainbowBorder = Instance.new("Frame")
RainbowBorder.Name = "RainbowBorder"
RainbowBorder.Size = UDim2.new(0, 324, 0, 424)
RainbowBorder.Position = UDim2.new(0.3, 0, 0.2, 0)
RainbowBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RainbowBorder.BorderSizePixel = 0
RainbowBorder.Active = true
RainbowBorder.Draggable = true
RainbowBorder.Parent = ScreenGui

-- Main Container Inside Border
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -8, 1, -8)
MainFrame.Position = UDim2.new(0, 4, 0, 4)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = RainbowBorder

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "⚡ Sonic Hub ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Scrolling Frame for Features
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

-- Open / Close Toggle Button (Floating Icon)
local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "SonicToggleIcon"
ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
ToggleIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleIcon.Text = "⚡"
ToggleIcon.TextSize = 24
ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.Active = true
ToggleIcon.Draggable = true
ToggleIcon.Parent = ScreenGui

local IconBorder = Instance.new("UIStroke")
IconBorder.Thickness = 2
IconBorder.Color = Color3.fromRGB(0, 170, 255)
IconBorder.Parent = ToggleIcon

ToggleIcon.MouseButton1Click:Connect(function()
    RainbowBorder.Visible = not RainbowBorder.Visible
end)

-- Helper Functions to Build Controls
local function CreateToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = Scroll

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": ON" or ": OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
    return btn
end

local function CreateSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = Scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Parent = frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -20, 0, 15)
    sliderBtn.Position = UDim2.new(0, 10, 0, 22)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    sliderBtn.Text = ""
    sliderBtn.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBtn

    local dragging = false
    local function UpdateVal(input)
        local posX = math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(posX, 0, 1, 0)
        local val = math.floor(min + (max - min) * posX)
        label.Text = name .. ": " .. tostring(val)
        callback(val)
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateVal(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateVal(input)
        end
    end)
end

-- Feature Controls Setup
CreateToggle("Aimbot", function(state) Settings.AimbotEnabled = state end)

CreateSlider("Smoothness (1-100)", 1, 100, 5, function(val)
    Settings.Smoothness = val
end)

CreateToggle("ESP", function(state) Settings.ESPEnabled = state end)

-- ESP Colors Selection
local ColorFrame = Instance.new("Frame")
ColorFrame.Size = UDim2.new(1, -10, 0, 40)
ColorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ColorFrame.Parent = Scroll

local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(1, 0, 0, 15)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "ESP Color"
ColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorLabel.Font = Enum.Font.SourceSans
ColorLabel.TextSize = 13
ColorLabel.Parent = ColorFrame

local colors = {
    {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Blue", Color = Color3.fromRGB(0, 0, 255)},
    {Name = "Yellow", Color = Color3.fromRGB(255, 255, 0)},
    {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Dark Blue", Color = Color3.fromRGB(0, 0, 139)},
    {Name = "Light Blue", Color = Color3.fromRGB(173, 216, 230)}
}

for i, c in ipairs(colors) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/6, -2, 0, 20)
    btn.Position = UDim2.new((i-1)*(1/6), 1, 0, 18)
    btn.BackgroundColor3 = c.Color
    btn.Text = ""
    btn.Parent = ColorFrame
    btn.MouseButton1Click:Connect(function()
        Settings.ESPColor = c.Color
    end)
end

CreateToggle("Hitbox Expander", function(state) Settings.HitboxExpander = state end)
CreateToggle("CFrame Speed Boost", function(state) Settings.CFrameSpeed = state end)

CreateSlider("CFrame Speed (0-10)", 0, 10, 0, function(val)
    Settings.SpeedMultiplier = val
end)

CreateToggle("Infinite Jump", function(state) Settings.InfJump = state end)
CreateToggle("Noclip", function(state) Settings.Noclip = state end)

-- Main Loop (Aimbot, CFrame, Noclip, Hitboxes)
RunService.RenderStepped:Connect(function()
    -- Rainbow Border Logic
    local hue = (tick() % 3) / 3
    RainbowBorder.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

    -- Aimbot Loop
    if Settings.AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPos = target.Character.Head.Position
            local currentCamCFrame = Camera.CFrame
            local smoothFactor = math.clamp(1 / (Settings.Smoothness * 0.5), 0.01, 1)
            Camera.CFrame = currentCamCFrame:Lerp(CFrame.new(currentCamCFrame.Position, targetPos), smoothFactor)
        end
    end

    -- CFrame Speed Boost Loop
    if Settings.CFrameSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local moveDir = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDir * (Settings.SpeedMultiplier * 0.2))
        end
    end

    -- Noclip Loop
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- ESP & Hitbox Expander Loop
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Hitbox Expander
                if Settings.HitboxExpander then
                    hrp.Size = Vector3.new(12, 12, 12)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end

                -- ESP Highlight
                local highlight = player.Character:FindFirstChild("SonicESP")
                if Settings.ESPEnabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "SonicESP"
                        highlight.Parent = player.Character
                    end
                    highlight.FillColor = Settings.ESPColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Enabled = true
                else
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end)

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
