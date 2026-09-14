--[========================================================================================[
    PROJECT: SCRIPT SENSE ULTIMATE SUITE - ENTERPRISE EDITION
    VERSION: 6.6.5 [FULL INTEGRATION WITH AUTO JUMP IN MAIN GUI]
--]========================================================================================]

local ScriptSense = {}
ScriptSense.Version = "6.6.5"
ScriptSense.Active = true

-- Services Retrieval
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() LocalPlayer = Players.LocalPlayer until LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Check if player is actively typing in a chat or text box
local function IsTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

-- Global Configuration Registry
ScriptSense.Config = {
    AimbotEnabled = false,
    WallhackEnabled = false,
    GodmodeEnabled = false,
    FlyEnabled = false,
    SkeletonEspEnabled = false,
    AntiAimEnabled = false,
    AutoJumpEnabled = false,
    SpeedhackEnabled = false,
    TouchFlingEnabled = false,

    FlySpeed = 50,
    SpinSpeed = 25,
    SpeedhackSpeed = 50,
    JumpInterval = 0.07,
    
    AimbotSmoothness = 4,
    AimbotFovRadius = 150,
    AimbotMaxBlocks = 10,
    CurrentSpinAngle = 0,

    Keybinds = {
        Wallhack = Enum.KeyCode.G,
        Aimbot = Enum.KeyCode.R,
        Godmode = Enum.KeyCode.C,
        Fly = Enum.KeyCode.F,
        Skeleton = Enum.KeyCode.X,
        AntiAim = Enum.KeyCode.U,
        AutoJump = Enum.KeyCode.J,
        Speedhack = Enum.KeyCode.V,
        TouchFling = Enum.KeyCode.K,
        MenuToggle = Enum.KeyCode.Backquote,
    }
}

local function SafeDestroy(instance)
    if instance and typeof(instance) == "Instance" then
        pcall(function() instance:Destroy() end)
    end
end

-- Full Cleanup
local successHui, huiContainer = pcall(gethui)
if successHui and huiContainer then
    for _, child in ipairs(huiContainer:GetChildren()) do
        if child.Name == "ScriptSenseEnterpriseGUI" or child.Name == "ScriptSenseFlingGUI" or child.Name == "KilasikFlingGUI" then SafeDestroy(child) end
    end
end
for _, child in ipairs(CoreGui:GetChildren()) do
    if child.Name == "ScriptSenseEnterpriseGUI" or child.Name == "ScriptSenseFlingGUI" or child.Name == "KilasikFlingGUI" then SafeDestroy(child) end
end

local SuccessContainer, RootGuiParent = pcall(function() return gethui() or CoreGui end)
if not SuccessContainer or not RootGuiParent then
    RootGuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptSenseEnterpriseGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = RootGuiParent

local IsMobileDevice = UserInputService.TouchEnabled

-- Watermark Container
local WatermarkContainer = Instance.new("Frame")
WatermarkContainer.Name = "WatermarkContainer"
WatermarkContainer.AnchorPoint = Vector2.new(0.5, 0.5)
WatermarkContainer.Size = UDim2.new(0, 0, 0, 45)
WatermarkContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
WatermarkContainer.BackgroundTransparency = 1
WatermarkContainer.AutomaticSize = Enum.AutomaticSize.X
WatermarkContainer.Parent = ScreenGui

local WatermarkLayout = Instance.new("UIListLayout")
WatermarkLayout.FillDirection = Enum.FillDirection.Horizontal
WatermarkLayout.SortOrder = Enum.SortOrder.LayoutOrder
WatermarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WatermarkLayout.Padding = UDim.new(0, 8)
WatermarkLayout.Parent = WatermarkContainer

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Name = "WatermarkLabel"
WatermarkLabel.Size = UDim2.new(0, 0, 1, 0)
WatermarkLabel.AutomaticSize = Enum.AutomaticSize.X
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.TextSize = 28
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.RichText = true
WatermarkLabel.Text = "<font color=\"#FF5050\">SCRIPT</font> SENSE"
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WatermarkLabel.TextTransparency = 0
WatermarkLabel.LayoutOrder = 1
WatermarkLabel.Parent = WatermarkContainer

local MenuToggleArrow = Instance.new("TextButton")
MenuToggleArrow.Name = "MenuToggleArrow"
MenuToggleArrow.Size = UDim2.new(0, 26, 0, 26)
MenuToggleArrow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuToggleArrow.BackgroundTransparency = 1
MenuToggleArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleArrow.TextTransparency = 1
MenuToggleArrow.TextSize = 13
MenuToggleArrow.Font = Enum.Font.GothamBold
MenuToggleArrow.Text = (not IsMobileDevice) and "▼" or "▲"
MenuToggleArrow.LayoutOrder = 2
MenuToggleArrow.Parent = WatermarkContainer

local ArrowStroke = Instance.new("UIStroke")
ArrowStroke.Color = Color3.fromRGB(60, 60, 60)
ArrowStroke.Thickness = 1
ArrowStroke.Transparency = 1
ArrowStroke.Parent = MenuToggleArrow

-- Main Control Panel Frame
local MainControlPanel = Instance.new("ScrollingFrame")
MainControlPanel.Name = "MainControlPanel"
MainControlPanel.Size = UDim2.new(0, 260, 0, 520)
MainControlPanel.Position = UDim2.new(0, 20, 0, 65)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainControlPanel.BorderSizePixel = 0
MainControlPanel.ScrollBarThickness = 4
MainControlPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainControlPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
MainControlPanel.Visible = false
MainControlPanel.Parent = ScreenGui

local PanelLayout = Instance.new("UIListLayout")
PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
PanelLayout.Padding = UDim.new(0, 6)
PanelLayout.Parent = MainControlPanel

local PanelPadding = Instance.new("UIPadding")
PanelPadding.PaddingTop = UDim.new(0, 10)
PanelPadding.PaddingBottom = UDim.new(0, 10)
PanelPadding.PaddingLeft = UDim.new(0, 10)
PanelPadding.PaddingRight = UDim.new(0, 10)
PanelPadding.Parent = MainControlPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(50, 50, 50)
PanelStroke.Thickness = 2
PanelStroke.Transparency = 1
PanelStroke.Parent = MainControlPanel

local isPanelVisible = false
local function ToggleMenuVisibility()
    isPanelVisible = not isPanelVisible
    MainControlPanel.Visible = isPanelVisible
    MenuToggleArrow.Text = isPanelVisible and "▼" or "▲"
end

MenuToggleArrow.MouseButton1Click:Connect(ToggleMenuVisibility)

-- Keybinds Menu Window
local KeybindsMenuWindow = Instance.new("Frame")
KeybindsMenuWindow.Name = "KeybindsMenuWindow"
KeybindsMenuWindow.Size = UDim2.new(0, 300, 0, 420)
KeybindsMenuWindow.Position = UDim2.new(0.5, -150, 0.5, -210)
KeybindsMenuWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeybindsMenuWindow.BorderSizePixel = 0
KeybindsMenuWindow.Visible = false
KeybindsMenuWindow.Parent = ScreenGui

local KbStroke = Instance.new("UIStroke")
KbStroke.Color = Color3.fromRGB(70, 70, 70)
KbStroke.Thickness = 2
KbStroke.Parent = KeybindsMenuWindow

local KbTitle = Instance.new("TextLabel")
KbTitle.Size = UDim2.new(1, 0, 0, 40)
KbTitle.BackgroundTransparency = 1
KbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KbTitle.TextSize = 14
KbTitle.Font = Enum.Font.GothamBold
KbTitle.Text = "   KEYBIND MANAGER"
KbTitle.TextXAlignment = Enum.TextXAlignment.Left
KbTitle.Parent = KeybindsMenuWindow

local KbContainer = Instance.new("ScrollingFrame")
KbContainer.Size = UDim2.new(1, 0, 1, -40)
KbContainer.Position = UDim2.new(0, 0, 0, 40)
KbContainer.BackgroundTransparency = 1
KbContainer.BorderSizePixel = 0
KbContainer.ScrollBarThickness = 4
KbContainer.Parent = KeybindsMenuWindow

local KbListLayout = Instance.new("UIListLayout")
KbListLayout.SortOrder = Enum.SortOrder.LayoutOrder
KbListLayout.Padding = UDim.new(0, 4)
KbListLayout.Parent = KbContainer

local controlRowFrames = {}
local UpdatePanelUI

-- UI Builders
local function CreateControlRow(initialText, callback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 32)
    rowFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    rowFrame.BackgroundTransparency = 0
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = MainControlPanel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Parent = rowFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 12
    button.Font = Enum.Font.GothamMedium
    button.Text = initialText
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = rowFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = button

    if callback then
        button.MouseButton1Click:Connect(callback)
    end

    table.insert(controlRowFrames, {Frame = rowFrame, Elements = {button}})
    return rowFrame, button
end

local function CreateControlInputRow(labelText, initialValue, callback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 32)
    rowFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = MainControlPanel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Parent = rowFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.Text = "   " .. labelText
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = rowFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.4, -10, 1, -6)
    textBox.Position = UDim2.new(0.6, 0, 0, 3)
    textBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 12
    textBox.Font = Enum.Font.GothamBold
    textBox.Text = tostring(initialValue)
    textBox.ClearTextOnFocus = false
    textBox.Parent = rowFrame

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(60, 60, 60)
    boxStroke.Thickness = 1
    boxStroke.Parent = textBox

    textBox.FocusLost:Connect(function()
        local num = tonumber(textBox.Text)
        if num then callback(num) else textBox.Text = tostring(initialValue) end
    end)

    table.insert(controlRowFrames, {Frame = rowFrame, Elements = {label, textBox}})
    return rowFrame, textBox, label
end

-- Integrated Fling Window
local FlingGuiInstance = nil
local function BuildAndToggleFlingGUI()
    if FlingGuiInstance and FlingGuiInstance.Parent then
        local mainFrame = FlingGuiInstance:FindFirstChild("MainFrame")
        if mainFrame then
            mainFrame.Visible = not mainFrame.Visible
        end
        return
    end

    local ScriptSenseFlingScreenGui = Instance.new("ScreenGui")
    ScriptSenseFlingScreenGui.Name = "ScriptSenseFlingGUI"
    ScriptSenseFlingScreenGui.ResetOnSpawn = false
    ScriptSenseFlingScreenGui.Parent = RootGuiParent
    FlingGuiInstance = ScriptSenseFlingScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScriptSenseFlingScreenGui

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SCRIPT SENSE MULTI FLING"
    Title.TextColor3 = Color3.fromRGB(255, 80, 80)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Position = UDim2.new(0, 10, 0, 40)
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Select targets to fling"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.TextSize = 16
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    local SelectionFrame = Instance.new("Frame")
    SelectionFrame.Position = UDim2.new(0, 10, 0, 70)
    SelectionFrame.Size = UDim2.new(1, -20, 0, 200)
    SelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SelectionFrame.BorderSizePixel = 0
    SelectionFrame.Parent = MainFrame

    local PlayerScrollFrame = Instance.new("ScrollingFrame")
    PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
    PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
    PlayerScrollFrame.BackgroundTransparency = 1
    PlayerScrollFrame.BorderSizePixel = 0
    PlayerScrollFrame.ScrollBarThickness = 6
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerScrollFrame.Parent = SelectionFrame

    local StartButton = Instance.new("TextButton")
    StartButton.Position = UDim2.new(0, 10, 0, 280)
    StartButton.Size = UDim2.new(0.5, -15, 0, 40)
    StartButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    StartButton.BorderSizePixel = 0
    StartButton.Text = "START FLING"
    StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartButton.Font = Enum.Font.SourceSansBold
    StartButton.TextSize = 18
    StartButton.Parent = MainFrame

    local StopButton = Instance.new("TextButton")
    StopButton.Position = UDim2.new(0.5, 5, 0, 280)
    StopButton.Size = UDim2.new(0.5, -15, 0, 40)
    StopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    StopButton.BorderSizePixel = 0
    StopButton.Text = "STOP FLING"
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.Font = Enum.Font.SourceSansBold
    StopButton.TextSize = 18
    StopButton.Parent = MainFrame

    local SelectedTargets = {}
    local PlayerCheckboxes = {}
    local FlingActive = false

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
end

-- Auto Jump Engine
local autoJumpRunning = false
local function ToggleAutoJumpThread()
    if ScriptSense.Config.AutoJumpEnabled then
        if not autoJumpRunning then
            autoJumpRunning = true
            task.spawn(function()
                while ScriptSense.Config.AutoJumpEnabled do
                    local char = LocalPlayer.Character
                    if char then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            humanoid.Jump = true
                        end
                    end
                    task.wait(ScriptSense.Config.JumpInterval)
                end
                autoJumpRunning = false
            end)
        end
    end
end

-- Populate UI Rows
local _, wallhackRowBtn = CreateControlRow("wallhack: off", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    UpdatePanelUI()
end)

local _, aimbotRowBtn = CreateControlRow("aimbot: off", function()
    if not IsTyping() then
        ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
        UpdatePanelUI()
    end
end)

local _, aimbotFovBox = CreateControlInputRow("aimbot fov size:", ScriptSense.Config.AimbotFovRadius, function(val)
    ScriptSense.Config.AimbotFovRadius = val
end)

local _, aimbotDistBox = CreateControlInputRow("aimbot max blocks:", ScriptSense.Config.AimbotMaxBlocks, function(val)
    ScriptSense.Config.AimbotMaxBlocks = val
end)

local _, godmodeRowBtn = CreateControlRow("godmode: off", function()
    ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
    UpdatePanelUI()
end)

local _, flyRowBtn = CreateControlRow("fly: off", function()
    ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
    UpdatePanelUI()
end)

local _, skeletonRowBtn = CreateControlRow("skeleton esp: off", function()
    ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
    UpdatePanelUI()
end)

local _, antiAimRowBtn = CreateControlRow("anti-aim (spin): off", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
    UpdatePanelUI()
end)

-- INTEGRATED AUTO JUMP BUTTON
local _, autoJumpRowBtn = CreateControlRow("autojump: off", function()
    ScriptSense.Config.AutoJumpEnabled = not ScriptSense.Config.AutoJumpEnabled
    ToggleAutoJumpThread()
    UpdatePanelUI()
end)

local _, speedhackRowBtn = CreateControlRow("speedhack: off", function()
    ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
    UpdatePanelUI()
end)

local _, touchFlingRowBtn = CreateControlRow("touch fling: off", function()
    ScriptSense.Config.TouchFlingEnabled = not ScriptSense.Config.TouchFlingEnabled
    UpdatePanelUI()
end)

local _, multiFlingGuiBtn = CreateControlRow("open multi-fling gui", function()
    BuildAndToggleFlingGUI()
end)

local _, keybindsMenuBtn = CreateControlRow("keybind manager", function()
    KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
end)

-- Dynamic Update function for text on UI
UpdatePanelUI = function()
    wallhackRowBtn.Text = "wallhack: " .. (ScriptSense.Config.WallhackEnabled and "on" or "off")
    aimbotRowBtn.Text = "aimbot: " .. (ScriptSense.Config.AimbotEnabled and "on" or "off")
    godmodeRowBtn.Text = "godmode: " .. (ScriptSense.Config.GodmodeEnabled and "on" or "off")
    flyRowBtn.Text = "fly: " .. (ScriptSense.Config.FlyEnabled and "on" or "off")
    skeletonRowBtn.Text = "skeleton esp: " .. (ScriptSense.Config.SkeletonEspEnabled and "on" or "off")
    antiAimRowBtn.Text = "anti-aim (spin): " .. (ScriptSense.Config.AntiAimEnabled and "on" or "off")
    autoJumpRowBtn.Text = "autojump: " .. (ScriptSense.Config.AutoJumpEnabled and "on" or "off")
    speedhackRowBtn.Text = "speedhack: " .. (ScriptSense.Config.SpeedhackEnabled and "on" or "off")
    touchFlingRowBtn.Text = "touch fling: " .. (ScriptSense.Config.TouchFlingEnabled and "on" or "off")
end

-- Keybinds handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or IsTyping() then return end
    
    if input.KeyCode == ScriptSense.Config.Keybinds.MenuToggle then
        ToggleMenuVisibility()
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Wallhack then
        ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
        UpdatePanelUI()
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Aimbot then
        ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
        UpdatePanelUI()
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Fly then
        ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
        UpdatePanelUI()
    elseif input.KeyCode == ScriptSense.Config.Keybinds.AutoJump then
        ScriptSense.Config.AutoJumpEnabled = not ScriptSense.Config.AutoJumpEnabled
        ToggleAutoJumpThread()
        UpdatePanelUI()
    end
end)

UpdatePanelUI()
