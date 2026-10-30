-- [[ JAIDEN Hub - Delta Mobile Edition ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration Settings
local Settings = {
    FakeLag = false,
    FakeLagValue = 50,
    ESP = false,
    ESPBox = false,
    ESPHighlight = false,
    SizeChanger = false,
    SizeValue = 5, -- Default normal size
}

-- UI Setup (Mobile Friendly ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JaidenHubMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Mobile Toggle Open/Close Button (Floater)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Text = "J"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
ToggleBtnCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(255, 0, 255)
ToggleStroke.Parent = ToggleButton

-- Outer Window Frame (Compact Size: 260x340)
local Outline = Instance.new("Frame")
Outline.Size = UDim2.new(0, 260, 0, 340)
Outline.Position = UDim2.new(0.5, -130, 0.5, -170)
Outline.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
Outline.Active = true
Outline.Draggable = true
Outline.Parent = ScreenGui

local OutlineCorner = Instance.new("UICorner")
OutlineCorner.CornerRadius = UDim.new(0, 8)
OutlineCorner.Parent = Outline

-- Main GUI Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(1, -4, 1, -4)
Main.Position = UDim2.new(0, 2, 0, 2)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.Parent = Outline

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = Main

-- Title Bar with Close Button
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundTransparency = 1
Title.Text = "🔥 JAIDEN Hub 🔥"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Outline.Visible = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    Outline.Visible = not Outline.Visible
end)

-- Scroll Canvas
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -38)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
Scroll.ScrollBarThickness = 4
Scroll.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Helper: Toggle Creator
local function CreateToggle(text, callback)
    local state = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
    return btn
end

-- Helper: Slider Creator
local function CreateSlider(text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 12
    Label.Parent = Frame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(0.9, 0, 0, 12)
    SliderBar.Position = UDim2.new(0.05, 0, 0, 24)
    SliderBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SliderBar.Text = ""
    SliderBar.Parent = Frame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
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

-- --- UI CONTROLS --- --
CreateToggle("Fake Lag", function(v) Settings.FakeLag = v end)
CreateSlider("Fake Lag Intensity", 1, 250, 50, function(v) Settings.FakeLagValue = v end)

CreateToggle("Size Changer", function(v) Settings.SizeChanger = v end)
CreateSlider("Character Size", 0, 500, 5, function(v) Settings.SizeValue = v end)

CreateToggle("ESP Master", function(v) Settings.ESP = v end)
CreateToggle("ESP Box", function(v) Settings.ESPBox = v end)
CreateToggle("ESP Highlight", function(v) Settings.ESPHighlight = v end)

-- --- FUNCTIONALITY LOOPS --- --

-- Fake Lag Rubber-band Loop (Teleports your replicated position backward to make others see you lagging while you move freely)
task.spawn(function()
    while true do
        if Settings.FakeLag and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local realPos = hrp.CFrame
            
            -- Wait based on user intensity slider
            task.wait(Settings.FakeLagValue / 80)
            
            if Settings.FakeLag and hrp then
                local laggedPos = hrp.CFrame
                -- Snap back to simulate network delay freeze for others
                hrp.CFrame = realPos
                task.wait(Settings.FakeLagValue / 160)
            end
        else
            task.wait(0.2)
        end
    end
end)

-- Size Changer Loop
RunService.RenderStepped:Connect(function()
    if Settings.SizeChanger and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- Scale character parts dynamically based on slider value
            pcall(function()
                local scale = math.clamp(Settings.SizeValue / 10, 0.1, 50)
                if char:FindFirstChild("HumanoidRootPart") then
                    -- Adjust character height / proportions safely using scale properties if available
                    for _, v in pairs(char:GetChildren()) do
                        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                            v.Size = Vector3.new(2, 2, 1) * scale
                        end
                    end
                end
            end)
        end
    end
end)

-- ESP System (Boxes & Highlights)
local espDrawings = {}

local function removeESP(plr)
    if espDrawings[plr] then
        if espDrawings[plr].Box then espDrawings[plr].Box:Remove() end
        espDrawings[plr] = nil
    end
    if plr.Character and plr.Character:FindFirstChild("JaidenHighlight") then
        plr.Character.JaidenHighlight:Destroy()
    end
end

RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            -- Highlight ESP
            if Settings.ESP and Settings.ESPHighlight then
                if plr.Character and not plr.Character:FindFirstChild("JaidenHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "JaidenHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = plr.Character
                elseif plr.Character and plr.Character:FindFirstChild("JaidenHighlight") then
                    plr.Character.JaidenHighlight.Enabled = true
                end
            else
                if plr.Character and plr.Character:FindFirstChild("JaidenHighlight") then
                    plr.Character.JaidenHighlight.Enabled = false
                end
            end

            -- Box ESP (Drawing API)
            if Settings.ESP and Settings.ESPBox then
                if not espDrawings[plr] then
                    local box = Drawing.new("Square")
                    box.Visible = false
                    box.Color = Color3.fromRGB(255, 0, 255)
                    box.Thickness = 1
                    box.Filled = false
                    espDrawings[plr] = {Box = box}
                end
                
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local hrp = char.HumanoidRootPart
                    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local box = espDrawings[plr].Box
                        box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                        box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
                        box.Visible = true
                    else
                        espDrawings[plr].Box.Visible = false
                    end
                else
                    if espDrawings[plr] then espDrawings[plr].Box.Visible = false end
                end
            else
                if espDrawings[plr] then espDrawings[plr].Box.Visible = false end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(removeESP)

print("JAIDEN Hub Loaded Successfully!")
