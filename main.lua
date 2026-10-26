-- MM2 ESP Script with GUI Toggle
-- Designed for Delta Executor & Mobile/PC Compatibility

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configuration & State
local ESP_Enabled = true
local Highlights = {}

-- Color Palette for Roles
local COLORS = {
    Murderer = Color3.fromRGB(255, 50, 50),   -- Red
    Sheriff  = Color3.fromRGB(50, 150, 255),  -- Blue
    Hero     = Color3.fromRGB(255, 220, 0),   -- Yellow (if someone picks up gun)
    Innocent = Color3.fromRGB(50, 255, 50),   -- Green
    Unknown  = Color3.fromRGB(200, 200, 200)  -- Light Gray
}

----------------------------------------------------------------
-- Role Detection Logic
----------------------------------------------------------------
local function getPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    
    -- Check Backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") then return "Murderer" end
        if backpack:FindFirstChild("Gun") then return "Sheriff" end
    end
    
    -- Check Character (currently held items)
    local char = player.Character
    if char:FindFirstChild("Knife") then return "Murderer" end
    if char:FindFirstChild("Gun") then return "Sheriff" end
    
    return "Innocent"
end

----------------------------------------------------------------
-- ESP Management
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

    -- Determine Role and corresponding color
    local role = getPlayerRole(player)
    local roleColor = COLORS[role] or COLORS.Innocent

    -- Create or update Highlight object
    local highlight = Highlights[player]
    if not highlight or highlight.Parent ~= character then
        removeHighlight(player)
        highlight = Instance.new("Highlight")
        highlight.Name = "MM2_ESP_Highlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.1
        highlight.Adornee = character
        highlight.Parent = character
        Highlights[player] = highlight
    end

    highlight.FillColor = roleColor
    highlight.OutlineColor = roleColor
    highlight.Enabled = ESP_Enabled
end

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(removeHighlight)

-- Main Loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateHighlight(player)
        end
    end
end)

----------------------------------------------------------------
-- User Interface (GUI)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_ESP_GUI"
ScreenGui.ResetOnSpawn = false

-- Attach GUI safely across execution environments
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Allows moving the GUI on screen
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Role ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "ESP: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.SourceSansSemibold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- Legend / Color Guide
local Legend = Instance.new("TextLabel")
Legend.Name = "Legend"
Legend.Size = UDim2.new(1, -20, 0, 40)
Legend.Position = UDim2.new(0, 10, 0.68, 0)
Legend.BackgroundTransparency = 1
Legend.Text = "🔴 Murderer  |  🔵 Sheriff\n🟢 Innocent"
Legend.TextColor3 = Color3.fromRGB(180, 180, 180)
Legend.TextSize = 12
Legend.Font = Enum.Font.SourceSans
Legend.Parent = MainFrame

-- Button Toggle Logic
ToggleBtn.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    if ESP_Enabled then
        ToggleBtn.Text = "ESP: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    else
        ToggleBtn.Text = "ESP: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        for _, highlight in pairs(Highlights) do
            highlight.Enabled = false
        end
    end
end)
