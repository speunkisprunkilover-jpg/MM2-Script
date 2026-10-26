-- Sonic Hub Script (Key System, Teleport, Fly, Fly Speed, Fixed Aimbot & GUI)
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
    Fly_Enabled = false,
    Fly_Speed = 50,
    InfJump_Enabled = false,
    Noclip_Enabled = false,
    Theme = "Rainbow"
}

local CONFIG_FILENAME = "SonicHub_Config.json"
local CorrectKey = "SONICHUB"
local KeyUnlocked = false

----------------------------------------------------------------
-- Key System GUI
----------------------------------------------------------------
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "SonicHub_KeySys"
KeyGui.ResetOnSpawn = false

if gethui then KeyGui.Parent = gethui()
elseif syn and syn.protect_gui then syn.protect_gui(KeyGui); KeyGui.Parent = CoreGui
else KeyGui.Parent = CoreGui end

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 260, 0, 160)
KeyFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KeyGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 10)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Thickness = 3
KeyStroke.Color = Color3.fromRGB(50, 100, 255)
KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
KeyTitle.Text = "⚡ Sonic Hub - Key Required ⚡"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 13
KeyTitle.Font = Enum.Font.SourceSansBold
KeyTitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 35)
KeyBox.Position = UDim2.new(0.075, 0, 0.35, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
KeyBox.PlaceholderText = "Enter Key (SONICHUB)"
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 13
KeyBox.Parent = KeyFrame
local kbCorner = Instance.new("UICorner"); kbCorner.CornerRadius = UDim.new(0, 6); kbCorner.Parent = KeyBox

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.85, 0, 0, 35)
SubmitBtn.Position = UDim2.new(0.075, 0, 0.68, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
SubmitBtn.Text = "Unlock Hub"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.Parent = KeyFrame
local subCorner = Instance.new("UICorner"); subCorner.CornerRadius = UDim.new(0, 6); subCorner.Parent = SubmitBtn

----------------------------------------------------------------
-- Main Hub Initialization (After Key Success)
----------------------------------------------------------------
SubmitBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == CorrectKey then
        KeyUnlocked = true
        KeyGui:Destroy()
        initSonicHub()
    else
        SubmitBtn.Text = "Wrong Key!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        task.wait(1)
        SubmitBtn.Text = "Unlock Hub"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    end
end)

function initSonicHub()
    local function saveConfig()
        local success, encoded = pcall(function() return HttpService:JSONEncode(Config) end)
        if success and writefile then writefile(CONFIG_FILENAME, encoded) end
    end

    local function loadConfig()
        if readfile and listfiles then
            for _, file in ipairs(listfiles("")) do
                if file == CONFIG_FILENAME or file:match("/" .. CONFIG_FILENAME) then
                    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILENAME)) end)
                    if success and type(decoded) == "table" then
                        for k, v in pairs(decoded) do Config[k] = v end
                    end
                end
            end
        end
    end
    loadConfig()

    local ESP_Objects = {}
    local Hitbox_OriginalSizes = {}
    local Palette = {
        ["Red"]        = Color3.fromRGB(255, 50, 50),
        ["Blue"]       = Color3.fromRGB(50, 100, 255),
        ["Light Blue"] = Color3.fromRGB(100, 200, 255),
        ["Yellow"]     = Color3.fromRGB(255, 220, 50),
        ["Green"]      = Color3.fromRGB(50, 255, 50),
        ["Dark Blue"]  = Color3.fromRGB(10, 30, 120)
    }

    -- Teleport to Player Function
    local function teleportToPlayer(nameQuery)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Name:lower():sub(1, #nameQuery) == nameQuery:lower() then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end

    -- Fly Logic Variables
    local flyPart, bodyGyro, bodyVelocity

    local function toggleFly(state)
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        
        if state then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp

            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = hrp
        else
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end

    -- Aimbot & Silent Aim
    local function isVisible(targetPart)
        if not Config.WallCheck_Enabled then return true end
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        local result = workspace:Raycast(origin, direction, raycastParams)
        if result then return result.Instance:IsDescendantOf(targetPart.Parent) end
        return true
    end

    local function getClosestPlayer()
        local target, shortestDist = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character.HumanoidRootPart
                if humanoid and humanoid.Health > 0 and isVisible(hrp) then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if dist < shortestDist then shortestDist = dist; target = hrp end
                    end
                end
            end
        end
        return target
    end

    RunService.RenderStepped:Connect(function()
        if Config.Aimbot_Enabled and not Config.SilentAim_Enabled then
            local targetPart = getClosestPlayer()
            if targetPart and math.random(1, 100) <= Config.HitChance then
                local currentCamCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCamCFrame.Position, targetPart.Position)
                local alpha = math.clamp(1 / (Config.Aimbot_Smoothness / 5), 0.05, 1)
                Camera.CFrame = currentCamCFrame:Lerp(targetCFrame, alpha)
            end
        end
    end)

    -- ESP Update
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
                    local col = Palette[Config.ESP_Color] or Color3.fromRGB(50, 255, 50)
                    ESP_Objects[player].FillColor = col
                    ESP_Objects[player].OutlineColor = col
                    ESP_Objects[player].Enabled = true
                else
                    if ESP_Objects[player] then ESP_Objects[player].Enabled = false end
                end
            end
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        if ESP_Objects[player] then ESP_Objects[player]:Destroy(); ESP_Objects[player] = nil end
    end)

    -- Hitbox Expander Logic
    local function updateHitboxes()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if hrp and humanoid and humanoid.Health > 0 then
                    if not Hitbox_OriginalSizes[player] then Hitbox_OriginalSizes[player] = hrp.Size end
                    if Config.Hitbox_Enabled then
                        hrp.Size = Vector3.new(26, 25, 28)
                        hrp.Transparency = 1
                        hrp.CanCollide = false
                    else
                        if Hitbox_OriginalSizes[player] then hrp.Size = Hitbox_OriginalSizes[player] end
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end

    UserInputService.JumpRequest:Connect(function()
        if Config.InfJump_Enabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
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

        if Config.Fly_Enabled then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and bodyVelocity and bodyGyro then
                local hrp = character.HumanoidRootPart
                bodyGyro.CFrame = Camera.CFrame
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                bodyVelocity.Velocity = moveDir * (Config.Fly_Speed * 2)
            end
        end
        
        if Config.Noclip_Enabled and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
        
        if Config.ESP_Enabled then updateESP() end
        if Config.Hitbox_Enabled then updateHitboxes() end
    end)

    -- Main Hub GUI Construction
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SonicHub_Gui"
    ScreenGui.ResetOnSpawn = false
    if gethui then ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = CoreGui
    else ScreenGui.Parent = CoreGui end

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 20, 0.3, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleButton.Text = "🌀"
    ToggleButton.TextSize = 24
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Active = true
    ToggleButton.Draggable = true
    ToggleButton.Parent = ScreenGui

    local IconCorner = Instance.new("UICorner"); IconCorner.CornerRadius = UDim.new(1, 0); IconCorner.Parent = ToggleButton
    local IconStroke = Instance.new("UIStroke"); IconStroke.Thickness = 3; IconStroke.Parent = ToggleButton

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 270, 0, 480)
    MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 10); MainCorner.Parent = MainFrame
    local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 3; MainStroke.Parent = MainFrame

    local function applyTheme()
        if Config.Theme ~= "Rainbow" then
            local col = Palette[Config.Theme] or Color3.fromRGB(50, 100, 255)
            MainStroke.Color = col
            IconStroke.Color = col
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

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Title.Text = "⚡ Sonic Hub ⚡\nmade by: ZIALonoid\nsuggested by: totallynotahacker029"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 10
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 10); TitleCorner.Parent = Title
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 10); TitleFix.Position = UDim2.new(0, 0, 1, -10)
    TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40); TitleFix.BorderSizePixel = 0; TitleFix.Parent = Title

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -10, 1, -60)
    Scroll.Position = UDim2.new(0, 5, 0, 55)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 920)
    Scroll.ScrollBarThickness = 4
    Scroll.Parent = MainFrame

    local function createToggle(yPos, text, initialVal, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 36)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.BackgroundColor3 = initialVal and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
        btn.Text = text .. (initialVal and ": ON" or ": OFF")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.SourceSansSemibold
        btn.Parent = Scroll

        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = btn
        local active = initialVal
        btn.MouseButton1Click:Connect(function()
            active = not active
            btn.Text = text .. (active and ": ON" or ": OFF")
            btn.BackgroundColor3 = active and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
            callback(active)
        end)
        return btn
    end

    local yOffset = 10

    createToggle(yOffset, "Aimbot", Config.Aimbot_Enabled, function(state) Config.Aimbot_Enabled = state end); yOffset = yOffset + 42
    createToggle(yOffset, "Silent Aim", Config.SilentAim_Enabled, function(state) Config.SilentAim_Enabled = state end); yOffset = yOffset + 42
    createToggle(yOffset, "Wall Check", Config.WallCheck_Enabled, function(state) Config.WallCheck_Enabled = state end); yOffset = yOffset + 42

    -- Teleport to Player Search Input
    local TpBox = Instance.new("TextBox")
    TpBox.Size = UDim2.new(0.9, 0, 0, 30)
    TpBox.Position = UDim2.new(0.05, 0, 0, yOffset)
    TpBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    TpBox.PlaceholderText = "Type Player Name & Enter"
    TpBox.Text = ""
    TpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TpBox.TextSize = 12
    TpBox.Parent = Scroll
    local tpCorner = Instance.new("UICorner"); tpCorner.CornerRadius = UDim.new(0, 6); tpCorner.Parent = TpBox
    yOffset = yOffset + 38

    TpBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and TpBox.Text ~= "" then
            teleportToPlayer(TpBox.Text)
            TpBox.Text = "Teleported!"
            task.wait(1)
            TpBox.Text = ""
        end
    end)

    -- Fly Toggle & Speed Slider
    createToggle(yOffset, "Fly", Config.Fly_Enabled, function(state)
        Config.Fly_Enabled = state
        toggleFly(state)
    end)
    yOffset = yOffset + 42

    local FlySpeedLabel = Instance.new("TextLabel")
    FlySpeedLabel.Size = UDim2.new(0.9, 0, 0, 18)
    FlySpeedLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
    FlySpeedLabel.BackgroundTransparency = 1
    FlySpeedLabel.Text = "Fly Speed (0-100): " .. Config.Fly_Speed
    FlySpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    FlySpeedLabel.TextSize = 12
    FlySpeedLabel.Parent = Scroll
    yOffset = yOffset + 20

    local FlySpeedBox = Instance.new("TextBox")
    FlySpeedBox.Size = UDim2.new(0.9, 0, 0, 26)
    FlySpeedBox.Position = UDim2.new(0.05, 0, 0, yOffset)
    FlySpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    FlySpeedBox.Text = tostring(Config.Fly_Speed)
    FlySpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlySpeedBox.TextSize = 13
    FlySpeedBox.Parent = Scroll
    local fsCorner = Instance.new("UICorner"); fsCorner.CornerRadius = UDim.new(0, 4); fsCorner.Parent = FlySpeedBox
    yOffset = yOffset + 32

    FlySpeedBox.FocusLost:Connect(function()
        local val = tonumber(FlySpeedBox.Text)
        if val then
            C        if val then
            Config.Fly_Speed = math.clamp(val, 0, 100)
            FlySpeedBox.Text = tostring(Config.Fly_Speed)
            FlySpeedLabel.Text = "Fly Speed (0-100): " .. Config.Fly_Speed
        else
            FlySpeedBox.Text = tostring(Config.Fly_Speed)
        end
    end)

    -- Smoothness Slider
    local SmoothLabel = Instance.new("TextLabel")
    SmoothLabel.Size = UDim2.new(0.9, 0, 0, 18); SmoothLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
    SmoothLabel.BackgroundTransparency = 1; SmoothLabel.Text = "Aimbot Smoothness: " .. Config.Aimbot_Smoothness
    SmoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200); SmoothLabel.TextSize = 12; SmoothLabel.Parent = Scroll
    yOffset = yOffset + 20

    local SmoothBox = Instance.new("TextBox")
    SmoothBox.Size = UDim2.new(0.9, 0, 0, 26); SmoothBox.Position = UDim2.new(0.05, 0, 0, yOffset)
    SmoothBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50); SmoothBox.Text = tostring(Config.Aimbot_Smoothness)
    SmoothBox.TextColor3 = Color3.fromRGB(255, 255, 255); SmoothBox.TextSize = 13; SmoothBox.Parent = Scroll
    local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(0, 4); sbCorner.Parent = SmoothBox
    yOffset = yOffset + 32

    SmoothBox.FocusLost:Connect(function()
        local val = tonumber(SmoothBox.Text)
        if val then Config.Aimbot_Smoothness = math.clamp(val, 1, 100); SmoothBox.Text = tostring(Config.Aimbot_Smoothness); SmoothLabel.Text = "Aimbot Smoothness: " .. Config.Aimbot_Smoothness end
    end)

    -- Hit Chance Slider
    local HitChanceLabel = Instance.new("TextLabel")
    HitChanceLabel.Size = UDim2.new(0.9, 0, 0, 18); HitChanceLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
    HitChanceLabel.BackgroundTransparency = 1; HitChanceLabel.Text = "Hit Chance (5-100): " .. Config.HitChance
    HitChanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200); HitChanceLabel.TextSize = 12; HitChanceLabel.Parent = Scroll
    yOffset = yOffset + 20

    local HitChanceBox = Instance.new("TextBox")
    HitChanceBox.Size = UDim2.new(0.9, 0, 0, 26); HitChanceBox.Position = UDim2.new(0.05, 0, 0, yOffset)
    HitChanceBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50); HitChanceBox.Text = tostring(Config.HitChance)
    HitChanceBox.TextColor3 = Color3.fromRGB(255, 255, 255); HitChanceBox.TextSize = 13; HitChanceBox.Parent = Scroll
    local hcCorner = Instance.new("UICorner"); hcCorner.CornerRadius = UDim.new(0, 4); hcCorner.Parent = HitChanceBox
    yOffset = yOffset + 32

    HitChanceBox.FocusLost:Connect(function()
        local val = tonumber(HitChanceBox.Text)
        if val then Config.HitChance = math.clamp(val, 5, 100); HitChanceBox.Text = tostring(Config.HitChance); HitChanceLabel.Text = "Hit Chance (5-100): " .. Config.HitChance end
    end)

    createToggle(yOffset, "ESP", Config.ESP_Enabled, function(state) Config.ESP_Enabled = state end); yOffset = yOffset + 42

    local ESPColorLabel = Instance.new("TextLabel")
    ESPColorLabel.Size = UDim2.new(0.9, 0, 0, 18); ESPColorLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
    ESPColorLabel.BackgroundTransparency = 1; ESPColorLabel.Text = "ESP Color: " .. Config.ESP_Color
    ESPColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200); ESPColorLabel.TextSize = 12; ESPColorLabel.Parent = Scroll
    yOffset = yOffset + 20

    local colorsList = {"Green", "Red", "Blue", "Yellow", "Dark Blue", "Light Blue"}
    local colorIdx = 1
    for i, c in ipairs(colorsList) do if c == Config.ESP_Color then colorIdx = i end end

    local ColorBtn = Instance.new("TextButton")
    ColorBtn.Size = UDim2.new(0.9, 0, 0, 28); ColorBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
    ColorBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150); ColorBtn.Text = "Change ESP Color [ " .. Config.ESP_Color .. " ]"
    ColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ColorBtn.TextSize = 12; ColorBtn.Parent = Scroll
    local cbCorner = Instance.new("UICorner"); cbCorner.CornerRadius = UDim.new(0, 4); cbCorner.Parent = ColorBtn
    yOffset = yOffset + 36

    ColorBtn.MouseButton1Click:Connect(function()
        colorIdx = colorIdx % #colorsList + 1
        Config.ESP_Color = colorsList[colorIdx]
        ColorBtn.Text = "Change ESP Color [ " .. Config.ESP_Color .. " ]"
        ESPColorLabel.Text = "ESP Color: " .. Config.ESP_Color
    end)

    createToggle(yOffset, "Hitbox Expander (26x25x28)", Config.Hitbox_Enabled, function(state) Config.Hitbox_Enabled = state end); yOffset = yOffset + 42
    createToggle(yOffset, "Speed Boost (C-Frame)", Config.Speed_Enabled, function(state) Config.Speed_Enabled = state end); yOffset = yOffset + 42

    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(0.9, 0, 0, 18); SpeedLabel.Position = UDim2.new(0.05, 0, 0, yOffset)
    SpeedLabel.BackgroundTransparency = 1; SpeedLabel.Text = "C-Frame Speed (0-10): " .. Config.Speed_Multiplier
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200); SpeedLabel.TextSize = 12; SpeedLabel.Parent = Scroll
    yOffset = yOffset + 20

    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size = UDim2.new(0.9, 0, 0, 26); SpeedBox.Position = UDim2.new(0.05, 0, 0, yOffset)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50); SpeedBox.Text = tostring(Config.Speed_Multiplier)
    SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255); SpeedBox.TextSize = 13; SpeedBox.Parent = Scroll
    local spCorner = Instance.new("UICorner"); spCorner.CornerRadius = UDim.new(0, 4); spCorner.Parent = SpeedBox
    yOffset = yOffset + 32

    SpeedBox.FocusLost:Connect(function()
        local val = tonumber(SpeedBox.Text)
        if val then Config.Speed_Multiplier = math.clamp(val, 0, 10); SpeedBox.Text = tostring(Config.Speed_Multiplier); SpeedLabel.Text = "C-Frame Speed (0-10): " .. Config.Speed_Multiplier end
    end)

    createToggle(yOffset, "Infinite Jump", Config.InfJump_Enabled, function(state) Config.InfJump_Enabled = state end); yOffset = yOffset + 42
    createToggle(yOffset, "Noclip", Config.Noclip_Enabled, function(state) Config.Noclip_Enabled = state end); yOffset = yOffset + 42

    local ThemeBtn = Instance.new("TextButton")
    ThemeBtn.Size = UDim2.new(0.9, 0, 0, 32); ThemeBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
    ThemeBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120); ThemeBtn.Text = "GUI Theme: " .. Config.Theme
    ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ThemeBtn.TextSize = 12; ThemeBtn.Font = Enum.Font.SourceSansSemibold; ThemeBtn.Parent = Scroll
    local thCorner = Instance.new("UICorner"); thCorner.CornerRadius = UDim.new(0, 6); thCorner.Parent = ThemeBtn
    yOffset = yOffset + 40

    local themes = {"Rainbow", "Blue", "Light Blue", "Red", "Green"}
    local themeIdx = 1
    for i, t in ipairs(themes) do if t == Config.Theme then themeIdx = i end end

    ThemeBtn.MouseButton1Click:Connect(function()
        themeIdx = themeIdx % #themes + 1
        Config.Theme = themes[themeIdx]
        ThemeBtn.Text = "GUI Theme: " .. Config.Theme
        applyTheme()
    end)

    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(0.43, 0, 0, 32); SaveBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
    SaveBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80); SaveBtn.Text = "Save Config"; SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255); SaveBtn.TextSize = 12; SaveBtn.Parent = Scroll
    local svCorner = Instance.new("UICorner"); svCorner.CornerRadius = UDim.new(0, 6); svCorner.Parent = SaveBtn

    SaveBtn.MouseButton1Click:Connect(function() saveConfig(); SaveBtn.Text = "Saved!"; task.wait(1); SaveBtn.Text = "Save Config" end)

    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(0.43, 0, 0, 32); LoadBtn.Position = UDim2.new(0.52, 0, 0, yOffset)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 40); LoadBtn.Text = "Load Config"; LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255); LoadBtn.TextSize = 12; LoadBtn.Parent = Scroll
    local ldCorner = Instance.new("UICorner"); ldCorner.CornerRadius = UDim.new(0, 6); ldCorner.Parent = LoadBtn

    LoadBtn.MouseButton1Click:Connect(function() loadConfig(); LoadBtn.Text = "Loaded!"; task.wait(1); LoadBtn.Text = "Load Config" end)

    ToggleButton.MouseButton1Click:Connect(function()
        Hub_Open = not Hub_Open
        MainFrame.Visible = Hub_Open
    end)
    end
