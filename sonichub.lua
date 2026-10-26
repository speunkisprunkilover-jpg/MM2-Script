-- [[ Sonic Hub - Delta Executor Mobile Compatible ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration Table
local Settings = {
    AimbotEnabled = false,
    Smoothness = 5,
    SilentAimEnabled = false,
    HitChance = 100,
    FOVSize = 100,
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    HitboxExpander = false,
    CFrameSpeed = false,
    SpeedMultiplier = 0,
    JumpBoostEnabled = false,
    JumpPowerVal = 50,
    FlightEnabled = false,
    FlightSpeed = 50,
    SpinBotEnabled = false,
    SpinBotSpeed = 25,
    ChatSpyEnabled = false,
    InfJump = false,
    Noclip = false,
    AutoTeleport = false,
    SelectedTeleportPlayer = nil,
    TargetTacoPlayer = "",
    TargetFlingPlayer = "",
    TargetAvatarName = "",
    CustomNameText = "",
    VerifiedBadgeEnabled = false,
    -- MM2 Specific ESP
    MM2_EspMurderer = false,
    MM2_EspSheriff = false,
    MM2_EspInnocent = false
}

-- FOV Circle Visualizer
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7

-- Target acquisition for Aimbot / Silent Aim
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance <= Settings.FOVSize and distance < shortestDistance then
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
RainbowBorder.Size = UDim2.new(0, 324, 0, 440)
RainbowBorder.Position = UDim2.new(0.3, 0, 0.15, 0)
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
Title.Text = "⚡ Sonic Hub (MM2 / Universal) ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Scrolling Frame for Features
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1600)
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

-- UI Builders
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

-- Feature Setup
CreateToggle("Aimbot", function(state) Settings.AimbotEnabled = state end)
CreateSlider("Smoothness (1-100)", 1, 100, 5, function(val) Settings.Smoothness = val end)

CreateToggle("Silent Aim", function(state) Settings.SilentAimEnabled = state end)
CreateSlider("Hit Chance (0-100)", 0, 100, 100, function(val) Settings.HitChance = val end)
CreateSlider("FOV Size (0-500)", 0, 500, 100, function(val) Settings.FOVSize = val end)

CreateToggle("ESP", function(state) Settings.ESPEnabled = state end)

-- MM2 Specific ESP Section
local MM2Header = Instance.new("TextLabel")
MM2Header.Size = UDim2.new(1, -10, 0, 25)
MM2Header.BackgroundColor3 = Color3.fromRGB(45, 30, 60)
MM2Header.Text = "--- MM2 Role ESP ---"
MM2Header.TextColor3 = Color3.fromRGB(255, 170, 255)
MM2Header.Font = Enum.Font.SourceSansBold
MM2Header.TextSize = 14
MM2Header.Parent = Scroll

CreateToggle("MM2 ESP Murderer", function(state) Settings.MM2_EspMurderer = state end)
CreateToggle("MM2 ESP Sheriff", function(state) Settings.MM2_EspSheriff = state end)
CreateToggle("MM2 ESP Innocent", function(state) Settings.MM2_EspInnocent = state end)

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
    btn.MouseButton1Click:Connect(function() Settings.ESPColor = c.Color end)
end

CreateToggle("Hitbox Expander", function(state) Settings.HitboxExpander = state end)
CreateToggle("CFrame Speed Boost", function(state) Settings.CFrameSpeed = state end)
CreateSlider("CFrame Speed (0-10)", 0, 10, 0, function(val) Settings.SpeedMultiplier = val end)

CreateToggle("Jump Boost", function(state) Settings.JumpBoostEnabled = state end)
CreateSlider("Jump Boost (0-100)", 0, 100, 50, function(val) Settings.JumpPowerVal = val end)

CreateToggle("Flight", function(state) Settings.FlightEnabled = state end)
CreateSlider("Flight Speed (0-100)", 0, 100, 50, function(val) Settings.FlightSpeed = val end)

CreateToggle("Spin Bot", function(state) Settings.SpinBotEnabled = state end)
CreateSlider("Spin Bot Speed (0-50)", 0, 50, 25, function(val) Settings.SpinBotSpeed = val end)

CreateToggle("Roblox Chat Spy", function(state) Settings.ChatSpyEnabled = state end)

-- Give Someone Taco Section
local TacoFrame = Instance.new("Frame")
TacoFrame.Size = UDim2.new(1, -10, 0, 75)
TacoFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TacoFrame.Parent = Scroll

local TacoLbl = Instance.new("TextLabel")
TacoLbl.Size = UDim2.new(1, 0, 0, 20)
TacoLbl.BackgroundTransparency = 1
TacoLbl.Text = "Give Taco (Search Username)"
TacoLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TacoLbl.Font = Enum.Font.SourceSans
TacoLbl.TextSize = 13
TacoLbl.Parent = TacoFrame

local TacoBox = Instance.new("TextBox")
TacoBox.Size = UDim2.new(1, -10, 0, 25)
TacoBox.Position = UDim2.new(0, 5, 0, 22)
TacoBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
TacoBox.Text = ""
TacoBox.PlaceholderText = "Type player name..."
TacoBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TacoBox.TextSize = 12
TacoBox.Parent = TacoFrame

TacoBox.FocusLost:Connect(function()
    Settings.TargetTacoPlayer = TacoBox.Text
end)

local TacoBtn = Instance.new("TextButton")
TacoBtn.Size = UDim2.new(1, -10, 0, 22)
TacoBtn.Position = UDim2.new(0, 5, 0, 50)
TacoBtn.BackgroundColor3 = Color3.fromRGB(255, 128, 0)
TacoBtn.Text = "Give Taco"
TacoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TacoBtn.Font = Enum.Font.SourceSansBold
TacoBtn.TextSize = 13
TacoBtn.Parent = TacoFrame

TacoBtn.MouseButton1Click:Connect(function()
    local query = TacoBox.Text ~= "" and TacoBox.Text or Settings.TargetTacoPlayer
    for _, p in ipairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, string.len(query)) == string.lower(query) then
            print("[SonicHub] Gave taco to: " .. p.Name)
            -- Insert game specific tool/item give remote event code here if supported
        end
    end
end)

-- Fling Player Section
local FlingFrame = Instance.new("Frame")
FlingFrame.Size = UDim2.new(1, -10, 0, 75)
FlingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
FlingFrame.Parent = Scroll

local FlingLbl = Instance.new("TextLabel")
FlingLbl.Size = UDim2.new(1, 0, 0, 20)
FlingLbl.BackgroundTransparency = 1
FlingLbl.Text = "Fling Player (Search Username)"
FlingLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingLbl.Font = Enum.Font.SourceSans
FlingLbl.TextSize = 13
FlingLbl.Parent = FlingFrame

local FlingBox = Instance.new("TextBox")
FlingBox.Size = UDim2.new(1, -10, 0, 25)
FlingBox.Position = UDim2.new(0, 5, 0, 22)
FlingBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
FlingBox.Text = ""
FlingBox.PlaceholderText = "Type player name..."
FlingBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBox.TextSize = 12
FlingBox.Parent = FlingFrame

FlingBox.FocusLost:Connect(function()
    Settings.TargetFlingPlayer = FlingBox.Text
end)

local FlingBtn = Instance.new("TextButton")
FlingBtn.Size = UDim2.new(1, -10, 0, 22)
FlingBtn.Position = UDim2.new(0, 5, 0, 50)
FlingBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FlingBtn.Text = "Fling Target"
FlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBtn.Font = Enum.Font.SourceSansBold
FlingBtn.TextSize = 13
FlingBtn.Parent = FlingFrame

FlingBtn.MouseButton1Click:Connect(function()
    local query = FlingBox.Text ~= "" and FlingBox.Text or Settings.TargetFlingPlayer
    for _, p in ipairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, string.len(query)) == string.lower(query) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = p.Character.HumanoidRootPart
                local myHrp = LocalPlayer.Character.HumanoidRootPart
                local bav = Instance.new("BodyAngularVelocity")
                bav.MaxTorque = Vector3.new(0, math.huge, 0)
                bav.AngularVelocity = Vector3.new(0, 9999, 0)
                bav.Parent = myHrp
                myHrp.CFrame = targetHrp.CFrame
                task.wait(0.2)
                bav:Destroy()
            end
        end
    end
end)

-- Avatar Changer Section
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(1, -10, 0, 80)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AvatarFrame.Parent = Scroll

local AvatarLbl = Instance.new("TextLabel")
AvatarLbl.Size = UDim2.new(1, 0, 0, 20)
AvatarLbl.BackgroundTransparency = 1
AvatarLbl.Text = "Avatar Changer (Target Username)"
AvatarLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarLbl.Font = Enum.Font.SourceSans
AvatarLbl.TextSize = 13
AvatarLbl.Parent = AvatarFrame

local AvatarBox = Instance.new("TextBox")
AvatarBox.Size = UDim2.new(1, -10, 0, 25)
AvatarBox.Position = UDim2.new(0, 5, 0, 22)
AvatarBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
AvatarBox.Text = ""
AvatarBox.PlaceholderText = "Enter username here..."
AvatarBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarBox.TextSize = 12
AvatarBox.Parent = AvatarFrame

AvatarBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        Settings.TargetAvatarName = AvatarBox.Text
    end
end)

local AvatarBtn = Instance.new("TextButton")
AvatarBtn.Size = UDim2.new(1, -10, 0, 25)
AvatarBtn.Position = UDim2.new(0, 5, 0, 50)
AvatarBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
AvatarBtn.Text = "Apply Avatar (Yes)"
AvatarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarBtn.Font = Enum.Font.SourceSansBold
AvatarBtn.TextSize = 13
AvatarBtn.Parent = AvatarFrame

AvatarBtn.MouseButton1Click:Connect(function()
    local targetName = AvatarBox.Text ~= "" and AvatarBox.Text or Settings.TargetAvatarName
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(targetName)
    end)
    if success and userId and LocalPlayer.Character then
        local successHumanoid, err = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(userId)
        end)
        if successHumanoid and err and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ApplyDescription(err)
        end
    end
end)

-- Name Changer Section
local NameFrame = Instance.new("Frame")
NameFrame.Size = UDim2.new(1, -10, 0, 60)
NameFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
NameFrame.Parent = Scroll

local NameLbl = Instance.new("TextLabel")
NameLbl.Size = UDim2.new(1, 0, 0, 20)
NameLbl.BackgroundTransparency = 1
NameLbl.Text = "Name Changer (Display Name)"
NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLbl.Font = Enum.Font.SourceSans
NameLbl.TextSize = 13
NameLbl.Parent = NameFrame

local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(1, -10, 0, 28)
NameBox.Position = UDim2.new(0, 5, 0, 25)
NameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
NameBox.Text = ""
NameBox.PlaceholderText = "Type custom name..."
NameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NameBox.TextSize = 12
NameBox.Parent = NameFrame

NameBox.Changed:Connect(function()
    Settings.CustomNameText = NameBox.Text
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local char = LocalPlayer.Character
        if char:FindFirstChild("Head") and char.Head:FindFirstChildOfClass("BillboardGui") then
            local tag = char.Head:FindFirstChildOfClass("BillboardGui")
            for _, label in ipairs(tag:GetDescendants()) do
                if label:IsA("TextLabel") then
                    label.Text = Settings.CustomNameText .. (Settings.VerifiedBadgeEnabled and " [✔]" or "")
                end
            end
        end
    end
end)

CreateToggle("Fake Verified Badge", function(state)
    Settings.VerifiedBadgeEnabled = state
end)

CreateToggle("Infinite Jump", function(state) Settings.InfJump = state end)
CreateToggle("Noclip", function(state) Settings.Noclip = state end)
CreateToggle("Auto Teleport to Target", function(state) Settings.AutoTeleport = state end)

-- Teleport to Player UI Section
local TpFrame = Instance.new("Frame")
TpFrame.Size = UDim2.new(1, -10, 0, 75)
TpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TpFrame.Parent = Scroll

local TpLabel = Instance.new("TextLabel")
TpLabel.Size = UDim2.new(1, 0, 0, 20)
TpLabel.BackgroundTransparency = 1
TpLabel.Text = "Teleport to Player: None Selected"
TpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TpLabel.Font = Enum.Font.SourceSans
TpLabel.TextSize = 13
TpLabel.Parent = TpFrame

local TpScroll = Instance.new("ScrollingFrame")
TpScroll.Size = UDim2.new(1, -10, 0, 25)
TpScroll.Position = UDim2.new(0, 5, 0, 22)
TpScroll.BackgroundTransparency = 1
TpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TpScroll.ScrollBarThickness = 4
TpScroll.Parent = TpFrame

local TpListLayout = Instance.new("UIListLayout")
TpListLayout.FillDirection = Enum.FillDirection.Horizontal
TpListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TpListLayout.Parent = TpScroll

local function RefreshPlayerList()
    for _, child in ipairs(TpScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local totalWidth = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(0, 90, 1, 0)
            pBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            pBtn.Text = p.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 12
            pBtn.Parent = Tplocal function RefreshPlayerList()
    for _, child in ipairs(TpScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local totalWidth = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(0, 90, 1, 0)
            pBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            pBtn.Text = p.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 12
            pBtn.Parent = TpScroll
            pBtn.MouseButton1Click:Connect(function()
                Settings.SelectedTeleportPlayer = p
                TpLabel.Text = "Target: " .. p.Name
            end)
            totalWidth = totalWidth + 95
        end
    end
    TpScroll.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)
RefreshPlayerList()

local TpBtn = Instance.new("TextButton")
TpBtn.Size = UDim2.new(1, -10, 0, 22)
TpBtn.Position = UDim2.new(0, 5, 0, 50)
TpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TpBtn.Text = "Teleport Now"
TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBtn.Font = Enum.Font.SourceSansBold
TpBtn.TextSize = 14
TpBtn.Parent = TpFrame

TpBtn.MouseButton1Click:Connect(function()
    if Settings.SelectedTeleportPlayer and Settings.SelectedTeleportPlayer.Character then
        local targetHrp = Settings.SelectedTeleportPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp and myHrp then
            myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- Chat Spy Listener Integration
local function SetupChatSpy(player)
    player.Chatted:Connect(function(msg)
        if Settings.ChatSpyEnabled then
            print("[SonicHub ChatSpy] " .. player.Name .. ": " .. msg)
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    SetupChatSpy(p)
end
Players.PlayerAdded:Connect(SetupChatSpy)

-- Main Engine Loop
RunService.RenderStepped:Connect(function()
    -- Rainbow Border Logic
    local hue = (tick() % 3) / 3
    RainbowBorder.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

    -- FOV Circle Drawing Update
    if Settings.AimbotEnabled or Settings.SilentAimEnabled then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.FOVSize
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        FOVCircle.Visible = false
    end

    -- Auto Teleport Loop
    if Settings.AutoTeleport and Settings.SelectedTeleportPlayer and Settings.SelectedTeleportPlayer.Character then
        local targetHrp = Settings.SelectedTeleportPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp and myHrp then
            myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
        end
    end

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

    -- Spin Bot Loop
    if Settings.SpinBotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinBotSpeed * 4), 0)
    end

    -- Jump Boost Loop
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true
        if Settings.JumpBoostEnabled then
            hum.JumpPower = 50 + (Settings.JumpPowerVal * 2.5)
        else
            hum.JumpPower = 50
        end
    end

    -- Flight Loop
    if Settings.FlightEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.PlatformStand = true
        local camCFrame = Camera.CFrame
        local moveVector = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
            moveVector = moveVector + camCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
            moveVector = moveVector - camCFrame.LookVector
        end
        hrp.Velocity = moveVector * (Settings.FlightSpeed * 2)
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and not Settings.FlightEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end

    -- Noclip Loop
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Hitbox, General ESP & MM2 Role ESP Loop
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Settings.HitboxExpander then
                    hrp.Size = Vector3.new(25, 25, 28)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end

                -- MM2 Role Detection / ESP Logic
                local isMurderer = false
                local isSheriff = false
                local isInnocent = false

                local backpack = player:FindFirstChildOfClass("Backpack")
                local function checkItem(item)
                    local name = string.lower(item.Name)
                    if name:find("knife") or name:find("revolver") or name:find("gun") then
                        if name:find("knife") then isMurderer = true end
                        if name:find("gun") or name:find("revolver") then isSheriff = true end
                    end
                end
                
                if player.Character then
                    for _, item in ipairs(player.Character:GetChildren()) do checkItem(item) end
                end
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do checkItem(item) end
                end
                
                if not isMurderer and not isSheriff then
                    isInnocent = true
                end

                local highlight = player.Character:FindFirstChild("SonicESP")
                local activeEsp = false
                local roleColor = Settings.ESPColor

                if Settings.MM2_EspMurderer and isMurderer then
                    roleColor = Color3.fromRGB(255, 0, 0)
                    activeEsp = true
                elseif Settings.MM2_EspSheriff and isSheriff then
                    roleColor = Color3.fromRGB(0, 0, 255)
                    activeEsp = true
                elseif Settings.MM2_EspInnocent and isInnocent then
                    roleColor = Color3.fromRGB(0, 255, 0)
                    activeEsp = true
                elseif Settings.ESPEnabled then
                    roleColor = Settings.ESPColor
                    activeEsp = true
                end

                if activeEsp then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "SonicESP"
                        highlight.Parent = player.Character
                    end
                    highlight.FillColor = roleColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Enabled = true
                else
                    if highlight then highlight:Destroy() end
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
            
