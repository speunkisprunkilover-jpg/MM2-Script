-- [[ Sonic Hub - Delta Executor ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration Settings
local Settings = {
    Aimbot = false,
    SilentAim = false,
    FOV = 150,
    ESP = false,
    Noclip = false,
    InfJump = false,
    Fly = false,
    FlySpeed = 50,
    CFrameSpeed = false,
    CFrameSpeedValue = 10,
    HitboxExpander = false,
    HitboxSize = 5,
    JumpBoost = false,
    JumpBoostValue = 50,
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonicHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Rainbow Outer Frame
local Outline = Instance.new("Frame")
Outline.Size = UDim2.new(0, 350, 0, 520)
Outline.Position = UDim2.new(0.5, -175, 0.5, -260)
Outline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Outline.Active = true
Outline.Draggable = true
Outline.Parent = ScreenGui

local OutlineCorner = Instance.new("UICorner")
OutlineCorner.CornerRadius = UDim.new(0, 10)
OutlineCorner.Parent = Outline

-- Main GUI Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(1, -4, 1, -4)
Main.Position = UDim2.new(0, 2, 0, 2)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.Parent = Outline

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Sonic Hub ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Main

-- Scroll Canvas
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -50)
Scroll.Position = UDim2.new(0, 8, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 820)
Scroll.ScrollBarThickness = 4
Scroll.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

-- Rainbow Outline Cycling Loop
local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 0.005) % 1
    Outline.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
end)

-- UI Toggle Creator Helper
local function CreateToggle(text, callback)
    local state = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 15
    btn.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
    return btn
end

-- UI Slider Creator Helper
local function CreateSlider(text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 48)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 22)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.Parent = Frame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(0.9, 0, 0, 12)
    SliderBar.Position = UDim2.new(0.05, 0, 0, 28)
    SliderBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SliderBar.Text = ""
    SliderBar.Parent = Frame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar

    local dragging = false
    local function update(input)
        local delta = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * delta)
        Fill.Size = UDim2.new(delta, 0, 1, 0)
        Label.Text = text .. ": " .. value
        callback(value)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- FOV Circle Visual
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.Aimbot or Settings.SilentAim
end)

-- Target Selection (Closest to Mouse within FOV)
local function GetClosestTarget()
    local closest = nil
    local shortestDist = Settings.FOV
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = plr.Character.HumanoidRootPart
                end
            end
        end
    end
    return closest
end

-- --- UI CONTROLS DEFINITION --- --

-- Combat / Aiming
CreateToggle("Aimbot", function(v) Settings.Aimbot = v end)
CreateToggle("Silent Aim", function(v) Settings.SilentAim = v end)
CreateSlider("FOV Size", 0, 500, 150, function(v) Settings.FOV = v end)

-- ESP & Visuals
CreateToggle("ESP", function(v) Settings.ESP = v end)

-- Hitbox Modifications
CreateToggle("Hitbox Expander", function(v) Settings.HitboxExpander = v end)
CreateSlider("Hitbox Size", 1, 500, 5, function(v) Settings.HitboxSize = v end)

-- Movement Modifiers
CreateToggle("Noclip", function(v) Settings.Noclip = v end)
CreateToggle("Infinite Jump", function(v) Settings.InfJump = v end)
CreateToggle("Fly Hacks", function(v) Settings.Fly = v end)
CreateSlider("Fly Speed", 10, 200, 50, function(v) Settings.FlySpeed = v end)

CreateToggle("CFrame Speed Boost", function(v) Settings.CFrameSpeed = v end)
CreateSlider("CFrame Speed", 1, 150, 10, function(v) Settings.CFrameSpeedValue = v end)

CreateToggle("Jump Boost", function(v) Settings.JumpBoost = v end)
CreateSlider("Jump Boost Power", 5, 100, 50, function(v) Settings.JumpBoostValue = v end)

-- --- CORE FUNCTIONALITIES --- --

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        local target = GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Silent Aim Raycast Hooking
local rawmetatable = getrawmetatable(game)
local oldNamecall = rawmetatable.__namecall
setreadonly(rawmetatable, false)

rawmetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if Settings.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = GetClosestTarget()
        if target then
            return target
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(rawmetatable, true)

-- ESP Implementation
local function applyESP(plr)
    if plr == LocalPlayer then return end
    local function setupHighlight(char)
        if not char:FindFirstChild("SonicESP") then
            local hl = Instance.new("Highlight")
            hl.Name = "SonicESP"
            hl.FillColor = Color3.fromRGB(0, 200, 255)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.Enabled = Settings.ESP
            hl.Parent = char
        end
    end
    if plr.Character then setupHighlight(plr.Character) end
    plr.CharacterAdded:Connect(setupHighlight)
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("SonicESP") then
            p.Character.SonicESP.Enabled = Settings.ESP
        end
    end
end)

-- Hitbox Expander Loop
RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if Settings.HitboxExpander then
                hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Really blue")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump Hook
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fly System
local bodyGyro, bodyVelocity
RunService.RenderStepped:Connect(function()
    if Settings.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.P = 9e4
            bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.cframe = hrp.CFrame
        end
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity", hrp)
            bodyVelocity.velocity = Vector3.new(0, 0, 0)
            bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        end

        bodyGyro.cframe = Camera.CFrame
        bodyVelocity.velocity = Camera.CFrame.LookVector * Settings.FlySpeed
    else
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    end
end)

-- CFrame Speed Boost Loop
RunService.RenderStepped:Connect(function()
    if Settings.CFrameSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (hum.MoveDirection * (Settings.CFrameSpeedValue / 10))
        end
    end
end)

-- Jump Boost Loop
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true
        if Settings.JumpBoost then
            hum.JumpPower = Settings.JumpBoostValue
        else
            hum.JumpPower = 50
        end
    end
end)

print("Sonic Hub Loaded Successfully!")
