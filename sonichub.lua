-- Sonic Hub Script (Updated with Silent Aim, Wall Check, Themes, Configs & Credits)
-- Made by: ZIALonoid | Suggested by: totallynotahacker029

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configuration Table
local Config = {
    Aimbot_Enabled = false,
    SilentAim_Enabled = false,
    WallCheck_Enabled = false,
    Aimbot_Smoothness = 50,
    HitChance = 100,
    ESP_Enabled = false,
    ESP_Color = "Green",
    Hitbox_Enabled = false,
    Speed_Enabled = false,
    Speed_Multiplier = 5,
    InfJump_Enabled = false,
    Noclip_Enabled = false,
    Theme = "Rainbow"
}

local CONFIG_FILENAME = "SonicHub_Config.json"
local Hub_Open = true

-- Utility: Save & Load Configs
local function saveConfig()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Config)
    end)
    if success and writefile then
        writefile(CONFIG_FILENAME, encoded)
    end
end

local function loadConfig()
    if readfile and listfiles then
        for _, file in ipairs(listfiles("")) do
            if file == CONFIG_FILENAME or file:match("/" .. CONFIG_FILENAME) then
                local success, decoded = pcall(function()
                    return HttpService:JSONDecode(readfile(CONFIG_FILENAME))
                end)
                if success and type(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        Config[k] = v
                    end
                end
            end
        end
    end
end

loadConfig() -- Auto load config on execution

-- State Variables mapped to Config
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
-- 1. Advanced Aimbot & Silent Aim Logic (with Wall Check & Hit Chance)
----------------------------------------------------------------
local function isVisible(targetPart)
    if not Config.WallCheck_Enabled then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        local hitPart = result.Instance
        return hitPart:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function getClosestPlayer()
    local target = nil
    local shortestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character.HumanoidRootPart
            if humanoid and humanoid.Health > 0 and isVisible(hrp) then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = hrp
                    end
                end
            end
        end
    end
    return target
end

-- Silent Aim Hook using __namecall redirection if available
local mt = getrawmetatable(game)
if mt and setreadonly then
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if Config.SilentAim_Enabled and method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
            if math.random(1, 100) <= Config.HitChance then
                local target = getClosestPlayer()
                if target and method == "Raycast" then
                    args[2] = (target.Position - args[1]).Unit * 1000
                    return workspace:Raycast(unpack(args))
                end
            end
        end
        return oldNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)
end

RunService.RenderStepped:Connect(function()
    if Config.Aimbot_Enabled and not Config.SilentAim_Enabled then
        local targetPart = getClosestPlayer()
        if targetPart and math.random(1, 100) <= Config.HitChance then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            local alpha = math.clamp((101 - Config.Aimbot_Smoothness) / 100, 0.01, 1)
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
            if character and character:FindFirstChild("HumanoidRootPart") and Config.ESP_Enabled then
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
                local col = ESP_Colors[Config.ESP_Color] or Color3.fromRGB(50, 255, 50)
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
                if Config.Hitbox_Enabled then
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
    if Config.InfJump_Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if Config.Speed_Enabled and Config.Speed_Multiplier > 0 then
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * Config.Speed_Multiplier * dt * 10)
            end
        end
    end
    
    if Config.Noclip_Enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    if Config.ESP_Enabled then updateESP() end
    if Config.Hitbox_Enabled then updateHitboxes() end
end)

----------------------------------------------------------------
-- 5. GUI Construction & Theme Handling
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
MainFrame.Size = UDim2.new(0, 270, 0, 480)
MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 3
MainStroke.Parent = MainFrame

-- Update Theme Styling
local function applyTheme()
    if Config.Theme == "Rainbow" then
        -- Managed by RenderStepped
    elseif Config.Theme == "Blue" then
        MainStroke.Color = Color3.fromRGB(50, 100, 255)
        IconStroke.Color = Color3.fromRGB(50, 100, 255)
    elseif Config.Theme == "Light Blue" then
        MainStroke.Color = Color3.fromRGB(100, 200, 255)
        IconStroke.Color = Color3.fromRGB(100, 200, 255)
    end
end

RunService.RenderStepped:Connect(function()
    if Config.Theme == "Rainbow" then
        local rainbowColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        MainStroke.Color = rainbowColor
        IconStroke.Color = rainbowColor
    end
end)
applyTheme()

-- Title Bar with Requested Credit Text
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "⚡ Sonic Hub ⚡\nmade by: ZIALonoid\nsuggested by: totallynotahacker029"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 10
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
Scroll.Size = UDim2.new(1, -10, 1, -60)
Scroll.Position = UDim2.new(0, 5, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 720)
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainFrame

local function createToggle(name, yPos, text, initialVal, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = initialVal and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    btn.Text = text .. (initialVal and ": ON" or ": OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local active = initialVal
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

local yOffset = 10

createToggle("AimbotBtn", yOffset, "Aimbot", Config.Aimbot_Enabled, function(state) Config.Aimbot_Enabled = state end)
yOffset = yOffset + 42

createToggle("SilentAimBtn", yOffset, "Silent Aim", Config.SilentAim_Enabled, function(state) Config.SilentAim_Enabled = state end)
yOffset = yOffset + 42

createToggle("WallCheckBtn", yOffset, "Wall Check", Config.WallCheck_Enabled, function(state) Config.WallCheck_Enabled = state end)
yOffset = yOffset + 42

-- Smoothness Slider
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0.9, 0, 0, 18)
SmoothLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Aimbot Smoothness: " .. Config.Aimbot_Smoothness
SmoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SmoothLabel.TextSize = 12
SmoothLabel.Parent = Scroll
yOffset = yOffset + 20

local SmoothBox = Instance.new("TextBox")
SmoothBox.Size = UDim2.new(0.9, 0, 0, 26)
SmoothBox.Position = UDim2.new(0.05, 0, 0, yOffset)
SmoothBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SmoothBox.Text = tostring(Config.Aimbot_Smoothness)
SmoothBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothBox.TextSize = 13
SmoothBox.Parent = Scroll
local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(0, 4); sbCorner.Parent = SmoothBox
yOffset = yOffset + 32

SmoothBox.FocusLost:Connect(function()
    local val = tonumber(SmoothBox.Text)
    if val then
        Config.Aimbot_Smoothness = math.clamp(val, 1, 100)
        SmoothBox.Text = tostring(Config.Aimbot_Smoothness)
        SmoothLabel.Text = "Aimbot Smoothness: " .. Config.Aimbot_Smoothness
    else
        SmoothBox.Text = tostring(Config.Aimbot_Smoothness)
    end
end)

-- Hit Chance Slider (5-100)
local HitChanceLabel = Instance.new("TextLabel")
HitChanceLabel.Size = UDim2.new(0.9, 0, 0, 18)
HitChanceLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
HitChanceLabel.BackgroundTransparency = 1
HitChanceLabel.Text = "Hit Chance (5-100): " .. Config.HitChance
HitChanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HitChanceLabel.TextSize = 12
HitChanceLabel.Parent = Scroll
yOffset = yOffset + 20

local HitChanceBox = Instance.new("TextBox")
HitChanceBox.Size = UDim2.new(0.9, 0, 0, 26)
HitChanceBox.Position = UDim2.new(0.05, 0, 0, yOffset)
HitChanceBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
HitChanceBox.Text = tostring(Config.HitChance)
HitChanceBox.TextColor3 = Color3.fromRGB(255, 255, 255)
HitChanceBox.TextSize = 13
HitChanceBox.Parent = Scroll
local hcCorner = Instance.new("UICorner"); hcCorner.CornerRadius = UDim.new(0, 4); hcCorner.Parent = HitChanceBox
yOffset = yOffset + 32

HitChanceBox.FocusLost:Connect(function()
    local val = tonumber(HitChanceBox.Text)
    if val then
        Config.HitChance = math.clamp(val, 5, 100)
        HitChanceBox.Text = tostring(Config.HitChance)
        HitChanceLabel.Text = "Hit Chance (5-100): " .. Config.HitChance
    else
        HitChanceBox.Text = tostring(Config.HitChance)
    end
end)

createToggle("ESPBtn", yOffset, "ESP", Config.ESP_Enabled, function(state) Config.ESP_Enabled = state end)
yOffset = yOffset + 42

-- ESP Color Dropdown
local ESPColorLabel = Instance.new("TextLabel")
ESPColorLabel.Size = UDim2.new(0.9, 0, 0, 18)
ESPColorLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
ESPColorLabel.BackgroundTransparency = 1
ESPColorLabel.Text = "ESP Color: " .. Config.ESP_Color
ESPColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ESPColorLabel.TextSize = 12
ESPColorLabel.Parent = Scroll
yOffset = yOffset + 20

local colorsList = {"Green", "Red", "Blue", "Yellow", "Dark Blue", "Light Blue"}
local colorIdx = 1
for i, c in ipairs(colorsList) do if c == Config.ESP_Color then colorIdx = i end end

local ColorBtn = Instance.new("TextButton")
ColorBtn.Size = UDim2.new(0.9, 0, 0, 28)
ColorBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
ColorBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
ColorBtn.Text = "Change ESP Color [ " .. Config.ESP_Color .. " ]"
ColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorBtn.TextSize = 12
ColorBtn.Parent = Scroll
local cbCorner = Instance.new("UICorner"); cbCorner.CornerRadius = UDim.new(0, 4); cbCorner.Parent = ColorBtn
yOffset = yOffset + 36

ColorBtn.MouseButton1Click:Connect(function()
    colorIdx = colorIdx % #colorsList + 1
    Config.ESP_Color = colorsList[colorIdx]
    ColorBtn.Text = "Change ESP Color [ " .. Config.ESP_Color .. " ]"
    ESPColorLabel.Text = "ESP Color: " .. Config.ESP_Color
end)

createToggle("HitboxBtn", yOffset, "Hitbox Expander (26x25x28)", Config.Hitbox_Enabled, function(state) Config.Hitbox_Enabled = state end)
yOffset = yOffset + 42

createToggle("SpeedBtn", yOffset, "Speed Boost (C-Frame)", Config.Speed_Enabled, function(state) Config.Speed_Enabled = state end)
yOffset = yOffset + 42

-- Speed Multiplier Slider (0-10)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 18)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "C-Frame Speed (0-10): " .. Config.Speed_Multiplier
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 12
SpeedLabel.Parent = Scroll
yOffset = yOffset + 20

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0.9, 0, 0, 26)
SpeedBox.Position = UDim2.new(0.05, 0, 0, yOffset)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedBox.Text = tostring(Config.Speed_Multiplier)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 13
SpeedBox.Parent = Scroll
local spCorner = Instance.new("UICorner"); spCorner.CornerRadius = UDim.new(0, 4); spCorner.Parent = SpeedBox
yOffset = yOffset + 32

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        Config.Speed_Multiplier = math.clamp(val, 0, 10)
        SpeedBox.Text = tostring(Config.Speed_Multiplier)
        SpeedLabel.Text = "C-Frame Speed (0-10): " .. Config.Speed_Multiplier
    else
        SpeedBox.Text = tostring(Config.Speed_Multiplier)
    end
end)

createToggle("JumpBtn", yOffset, "Infinite Jump", Config.InfJump_Enabled, function(state) Config.InfJump_Enabled = state end)
yOffcreateToggle("JumpBtn", yOffset, "Infinite Jump", Config.InfJump_Enabled, function(state) Config.InfJump_Enabled = state end)
yOffset = yOffset + 42

createToggle("NoclipBtn", yOffset, "Noclip", Config.Noclip_Enabled, function(state) Config.Noclip_Enabled = state end)
yOffset = yOffset + 42

-- Theme Selector Button
local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Size = UDim2.new(0.9, 0, 0, 32)
ThemeBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
ThemeBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
ThemeBtn.Text = "Theme: " .. Config.Theme
ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeBtn.TextSize = 12
ThemeBtn.Font = Enum.Font.SourceSansSemibold
ThemeBtn.Parent = Scroll
local thCorner = Instance.new("UICorner"); thCorner.CornerRadius = UDim.new(0, 6); thCorner.Parent = ThemeBtn
yOffset = yOffset + 40

local themes = {"Rainbow", "Blue", "Light Blue"}
local themeIdx = 1
for i, t in ipairs(themes) do if t == Config.Theme then themeIdx = i end end

ThemeBtn.MouseButton1Click:Connect(function()
    themeIdx = themeIdx % #themes + 1
    Config.Theme = themes[themeIdx]
    ThemeBtn.Text = "Theme: " .. Config.Theme
    applyTheme()
end)

-- Config Save & Load Buttons
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.43, 0, 0, 32)
SaveBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
SaveBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
SaveBtn.Text = "Save Config"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.TextSize = 12
SaveBtn.Parent = Scroll
local svCorner = Instance.new("UICorner"); svCorner.CornerRadius = UDim.new(0, 6); svCorner.Parent = SaveBtn

SaveBtn.MouseButton1Click:Connect(function()
    saveConfig()
    SaveBtn.Text = "Saved!"
    task.wait(1)
    SaveBtn.Text = "Save Config"
end)

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.43, 0, 0, 32)
LoadBtn.Position = UDim2.new(0.52, 0, 0, yOffset)
LoadBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 40)
LoadBtn.Text = "Load Config"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.TextSize = 12
LoadBtn.Parent = Scroll
local ldCorner = Instance.new("UICorner"); ldCorner.CornerRadius = UDim.new(0, 6); ldCorner.Parent = LoadBtn

LoadBtn.MouseButton1Click:Connect(function()
    loadConfig()
    LoadBtn.Text = "Loaded!"
    task.wait(1)
    LoadBtn.Text = "Load Config"
end)

-- Toggle Hub Open/Close via Sonic Icon
ToggleButton.MouseButton1Click:Connect(function()
    Hub_Open = not Hub_Open
    MainFrame.Visible = Hub_Open
end)
