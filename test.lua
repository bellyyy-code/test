--[========================================================================================[
    PROJECT: SCRIPT SENSE ULTIMATE SUITE - ENTERPRISE EDITION
    VERSION: 6.6.3 [FULL FIX & INTEGRATION]
    DESCRIPTION: Fixed Fly + ESP compatibility, white Skeleton & Box ESP integration, 
                 fixed Auto Jump, updated Aimbot block-distance detection (10 blocks = 40 studs).
--]========================================================================================]

local ScriptSense = {}
ScriptSense.Version = "6.6.3"
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

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() LocalPlayer = Players.LocalPlayer until LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Robust Event-Driven Roblox Menu Tracking
local isRobloxMenuOpen = false
GuiService.MenuOpened:Connect(function() isRobloxMenuOpen = true end)
GuiService.MenuClosed:Connect(function() isRobloxMenuOpen = false end)

local function IsRobloxMenuOpen()
    if isRobloxMenuOpen then return true end
    local success, isOpen = pcall(function() return GuiService:IsMenuOpen() end)
    return success and isOpen or false
end

-- Global Configuration Registry
ScriptSense.Config = {
    AimbotEnabled = false,
    WallhackEnabled = false,
    GodmodeEnabled = false,
    FlyEnabled = false,
    SkeletonEspEnabled = false, -- Включает скелет и белый бокс вместе
    AntiAimEnabled = false,
    AutoJumpEnabled = false,
    SpeedhackEnabled = false,
    TouchFlingEnabled = false,

    FlySpeed = 50,
    SpinSpeed = 25,
    SpeedhackSpeed = 50,
    
    AimbotSmoothness = 4,
    AimbotFovRadius = 150,
    AimbotMaxBlocks = 10, -- 10 блоков (40 studs)
    CurrentSpinAngle = 0,

    Keybinds = {
        Wallhack = Enum.KeyCode.G,
        Aimbot = Enum.KeyCode.R,
        Godmode = Enum.KeyCode.C,
        Fly = Enum.KeyCode.F,
        Skeleton = Enum.KeyCode.X,
        AntiAim = Enum.KeyCode.U,
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
        if child.Name == "ScriptSenseEnterpriseGUI" then SafeDestroy(child) end
    end
end
for _, child in ipairs(CoreGui:GetChildren()) do
    if child.Name == "ScriptSenseEnterpriseGUI" then SafeDestroy(child) end
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
WatermarkLabel.Text = ""
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
    rowFrame.BackgroundTransparency = 1
    rowFrame.BorderSizePixel = 0
    rowFrame.Visible = false
    rowFrame.Parent = MainControlPanel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = rowFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextTransparency = 1
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
    rowFrame.BackgroundTransparency = 1
    rowFrame.BorderSizePixel = 0
    rowFrame.Visible = false
    rowFrame.Parent = MainControlPanel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = rowFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 1
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.Text = "   " .. labelText
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = rowFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.4, -10, 1, -6)
    textBox.Position = UDim2.new(0.6, 0, 0, 3)
    textBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextTransparency = 1
    textBox.TextSize = 12
    textBox.Font = Enum.Font.GothamBold
    textBox.Text = tostring(initialValue)
    textBox.ClearTextOnFocus = false
    textBox.Parent = rowFrame

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(60, 60, 60)
    boxStroke.Thickness = 1
    boxStroke.Transparency = 1
    boxStroke.Parent = textBox

    textBox.FocusLost:Connect(function()
        local num = tonumber(textBox.Text)
        if num then callback(num) else textBox.Text = tostring(initialValue) end
    end)

    table.insert(controlRowFrames, {Frame = rowFrame, Elements = {label, textBox}})
    return rowFrame, textBox, label
end

local function CreateBlackIndicatorRow(labelText, callback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 32)
    rowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    rowFrame.BackgroundTransparency = 0
    rowFrame.BorderSizePixel = 0
    rowFrame.Visible = false
    rowFrame.Parent = MainControlPanel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = rowFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = rowFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextTransparency = 1
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.Text = labelText
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = rowFrame

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(1, -22, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 0
    indicator.Parent = rowFrame

    local indStroke = Instance.new("UIStroke")
    indStroke.Color = Color3.fromRGB(100, 100, 100)
    indStroke.Thickness = 1
    indStroke.Transparency = 0
    indStroke.Parent = indicator

    btn.MouseButton1Click:Connect(callback)

    table.insert(controlRowFrames, {Frame = rowFrame, Elements = {label}})
    return rowFrame, indicator
end

local activeRebindKey = nil
local function GetKeyName(keyCode)
    if keyCode.Name == "Backquote" then return "`" end
    return string.lower(keyCode.Name)
end
local startFlingThread
local PopulateKeybindsDisplay

-- Populate UI Rows
local _, wallhackRowBtn = CreateControlRow("wallhack: off", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    UpdatePanelUI()
end)

local _, aimbotRowBtn = CreateControlRow("aimbot: off", function()
    if not IsRobloxMenuOpen() then
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

local autoJumpRow, autoJumpInd = CreateBlackIndicatorRow("auto jump", function()
    ScriptSense.Config.AutoJumpEnabled = not ScriptSense.Config.AutoJumpEnabled
    UpdatePanelUI()
end)

local _, spinSpeedBox = CreateControlInputRow("spin speed:", ScriptSense.Config.SpinSpeed, function(val)
    ScriptSense.Config.SpinSpeed = val
end)

local _, speedhackRowBtn = CreateControlRow("speedhack: off", function()
    ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
    UpdatePanelUI()
end)

local _, speedhackSpeedBox = CreateControlInputRow("speedhack speed:", ScriptSense.Config.SpeedhackSpeed, function(val)
    ScriptSense.Config.SpeedhackSpeed = val
end)

local _, touchFlingRowBtn = CreateControlRow("touchfling: off", function()
    ScriptSense.Config.TouchFlingEnabled = not ScriptSense.Config.TouchFlingEnabled
    if ScriptSense.Config.TouchFlingEnabled then startFlingThread() end
    UpdatePanelUI()
end)

CreateControlRow("keybinds manager", function()
    KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
    if KeybindsMenuWindow.Visible then PopulateKeybindsDisplay() end
end)

UpdatePanelUI = function()
    wallhackRowBtn.Text = "wallhack: " .. (ScriptSense.Config.WallhackEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Wallhack) .. "]"
    aimbotRowBtn.Text = "aimbot: " .. (ScriptSense.Config.AimbotEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Aimbot) .. "]"
    godmodeRowBtn.Text = "godmode: " .. (ScriptSense.Config.GodmodeEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Godmode) .. "]"
    flyRowBtn.Text = "fly: " .. (ScriptSense.Config.FlyEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Fly) .. "]"
    skeletonRowBtn.Text = "skeleton esp: " .. (ScriptSense.Config.SkeletonEspEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Skeleton) .. "]"
    antiAimRowBtn.Text = "anti-aim (spin): " .. (ScriptSense.Config.AntiAimEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.AntiAim) .. "]"
    
    if autoJumpRow then 
        autoJumpRow.Visible = true 
        autoJumpInd.BackgroundColor3 = ScriptSense.Config.AutoJumpEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(20, 20, 20)
    end

    spinSpeedBox.Text = tostring(ScriptSense.Config.SpinSpeed)
    speedhackRowBtn.Text = "speedhack: " .. (ScriptSense.Config.SpeedhackEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Speedhack) .. "]"
    speedhackSpeedBox.Text = tostring(ScriptSense.Config.SpeedhackSpeed)
    touchFlingRowBtn.Text = "touchfling: " .. (ScriptSense.Config.TouchFlingEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.TouchFling) .. "]"
end

UpdatePanelUI()

-- Intro Sequence
task.spawn(function()
    local fullText = "SCRIPT SENSE [v6.6.3]"
    local totalChars = #fullText
    local charDelay = 2.0 / totalChars

    local function getPartialText(count)
        local scriptPart = string.sub("SCRIPT", 1, math.min(count, 6))
        local res = '<font color="#FFFFFF">' .. scriptPart .. '</font>'
        if count > 6 then res = res .. '<font color="#FF0000">' .. string.sub(" SENSE", 1, count - 6) .. '</font>' end
        if count > 12 then res = res .. '<font color="#AAAAAA">' .. string.sub(" [v6.6.3]", 1, count - 12) .. '</font>' end
        return res
    end

    for i = 1, totalChars do
        WatermarkLabel.Text = getPartialText(i)
        task.wait(charDelay)
    end
    WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">[v6.6.3]</font>'

    local currentAbsPos = WatermarkContainer.AbsolutePosition
    WatermarkContainer.AnchorPoint = Vector2.new(0, 0)
    WatermarkContainer.Position = UDim2.new(0, currentAbsPos.X, 0, currentAbsPos.Y)

    local transInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(WatermarkContainer, transInfo, { Position = UDim2.new(0, 20, 0, 20) }):Play()

    local textSizeVal = Instance.new("NumberValue")
    textSizeVal.Value = 28
    textSizeVal.Changed:Connect(function(v) WatermarkLabel.TextSize = v end)
    TweenService:Create(textSizeVal, transInfo, { Value = 16 }):Play()
    task.delay(0.45, function() SafeDestroy(textSizeVal) end)

    TweenService:Create(MenuToggleArrow, transInfo, { TextTransparency = 0, BackgroundTransparency = 0 }):Play()
    TweenService:Create(ArrowStroke, transInfo, { Transparency = 0 }):Play()

    task.wait(0.4)

    if not IsMobileDevice then
        MainControlPanel.Visible = true
        isPanelVisible = true
    end

    TweenService:Create(PanelStroke, transInfo, { Transparency = 0 }):Play()

    local delayIndex = 0
    for _, data in ipairs(controlRowFrames) do
        delayIndex = delayIndex + 1
        task.delay((delayIndex - 1) * 0.03, function()
            data.Frame.Visible = true
            local rowTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            if data.Frame ~= autoJumpRow then
                TweenService:Create(data.Frame, rowTween, { BackgroundTransparency = 0.2 }):Play()
            else
                TweenService:Create(data.Frame, rowTween, { BackgroundTransparency = 0 }):Play()
            end
            
            local stroke = data.Frame:FindFirstChildOfClass("UIStroke")
            if stroke then TweenService:Create(stroke, rowTween, { Transparency = 0 }):Play() end

            for _, child in ipairs(data.Elements) do
                if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("TextBox") then
                    TweenService:Create(child, rowTween, { TextTransparency = 0 }):Play()
                    if child:IsA("TextBox") then
                        TweenService:Create(child, rowTween, { BackgroundTransparency = 0.5 }):Play()
                        local bStroke = child:FindFirstChildOfClass("UIStroke")
                        if bStroke then TweenService:Create(bStroke, rowTween, { Transparency = 0 }):Play() end
                    end
                end
            end
        end)
    end
end)

PopulateKeybindsDisplay = function()
    for _, child in ipairs(KbContainer:GetChildren()) do
        if child:IsA("Frame") then SafeDestroy(child) end
    end
    local bindsData = {
        {"Wallhack", "Wallhack", ScriptSense.Config.Keybinds.Wallhack},
        {"Aimbot", "Aimbot", ScriptSense.Config.Keybinds.Aimbot},
        {"Godmode", "Godmode", ScriptSense.Config.Keybinds.Godmode},
        {"Fly", "Fly", ScriptSense.Config.Keybinds.Fly},
        {"Skeleton esp", "Skeleton", ScriptSense.Config.Keybinds.Skeleton},
        {"Anti-Aim", "AntiAim", ScriptSense.Config.Keybinds.AntiAim},
        {"Speedhack", "Speedhack", ScriptSense.Config.Keybinds.Speedhack},
        {"TouchFling", "TouchFling", ScriptSense.Config.Keybinds.TouchFling},
        {"Menu Toggle", "MenuToggle", ScriptSense.Config.Keybinds.MenuToggle},
    }
    for _, data in ipairs(bindsData) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 35)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        row.BorderSizePixel = 0
        row.Parent = KbContainer

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(45, 45, 45)
        stroke.Thickness = 1
        stroke.Parent = row

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = row

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 12)
        padding.Parent = btn

        if activeRebindKey == data[2] then
            btn.Text = "   [ " .. data[1] .. " ] -> Press any key..."
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            btn.Text = "   " .. data[1] .. " -> [" .. string.upper(GetKeyName(data[3])) .. "]"
        end

        btn.MouseButton1Click:Connect(function()
            activeRebindKey = data[2]
            PopulateKeybindsDisplay()
        end)
    end
end

-- Keybind Input Listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if activeRebindKey then
        ScriptSense.Config.Keybinds[activeRebindKey] = input.KeyCode
        activeRebindKey = nil
        if KeybindsMenuWindow.Visible then PopulateKeybindsDisplay() end
        UpdatePanelUI()
        return
    end

    if input.KeyCode == ScriptSense.Config.Keybinds.Wallhack then
        ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Aimbot then
        if not IsRobloxMenuOpen() then ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled end
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Godmode then
        ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Fly then
        ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Skeleton then
        ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.AntiAim then
        ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Speedhack then
        ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.TouchFling then
        ScriptSense.Config.TouchFlingEnabled = not ScriptSense.Config.TouchFlingEnabled
        if ScriptSense.Config.TouchFlingEnabled then startFlingThread() end
    elseif input.KeyCode == ScriptSense.Config.Keybinds.MenuToggle then
        KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
        if KeybindsMenuWindow.Visible then PopulateKeybindsDisplay() end
    end
    UpdatePanelUI()
end)

-- 1. Wallhack Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.WallhackEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- 2. Speedhack Engine
local lastSpeedhackState = false
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if ScriptSense.Config.SpeedhackEnabled then
                humanoid.WalkSpeed = ScriptSense.Config.SpeedhackSpeed
                lastSpeedhackState = true
            else
                if lastSpeedhackState then
                    humanoid.WalkSpeed = 16
                    lastSpeedhackState = false
                end
            end
        end
    end
end)

-- 3. Fly Engine (Устойчивый полет без конфликтов)
local flyBV, flyBG
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if ScriptSense.Config.FlyEnabled then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Parent = root
        end
        if not flyBG then
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.P = 9e4
            flyBG.Parent = root
        end

        flyBG.CFrame = Camera.CFrame
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyBV.Velocity = moveDir * ScriptSense.Config.FlySpeed
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end)

-- 4. Anti-Aim & Independent Auto Jump Engine
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if character then
        if ScriptSense.Config.AntiAimEnabled then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
                rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(ScriptSense.Config.CurrentSpinAngle), 0)
                rootPart.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        
        -- Auto Jump
        if ScriptSense.Config.AutoJumpEnabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Jump = true
            end
        end
    end
end)

-- 5. Integrated White Skeleton & White Box ESP Engine
local EspCache = {}
local function ClearEspForPlayer(plr)
    if EspCache[plr] then
        for _, obj in pairs(EspCache[plr]) do
            if typeof(obj) == "table" then
                for _, subObj in ipairs(obj) do pcall(function() subObj:Remove() end) end
            else
                pcall(function() obj:Remove() end)
            end
        end
        EspCache[plr] = nil
    end
end

Players.PlayerRemoving:Connect(ClearEspForPlayer)

RunService.RenderStepped:Connect(function()
    if not ScriptSense.Config.SkeletonEspEnabled then
        for _, cache in pairs(EspCache) do
            if cache.Box then cache.Box.Visible = false end
            if cache.Lines then
                for _, line in ipairs(cache.Lines) do line.Visible = false end
            end
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not EspCache[plr] then
                local box = Drawing.new("Square")
                box.Color = Color3.fromRGB(255, 255, 255)
                box.Thickness = 1.5
                box.Filled = false
                box.Visible = false

                local lines = {}
                for i = 1, 15 do
                    local l = Drawing.new("Line")
                    l.Color = Color3.fromRGB(255, 255, 255)
                    l.Thickness = 1.5
                    l.Visible = false
                    table.insert(lines, l)
                end
                EspCache[plr] = { Box = box, Lines = lines }
            end

            local cache = EspCache[plr]
            local box = cache.Box
            local lines = cache.Lines

            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if char and hum and hum.Health > 0 and root then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local head = char:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.65

                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                    box.Visible = true

                    local isR15 = hum.RigType == Enum.HumanoidRigType.R15
                    local pairsList = isR15 and {
                        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "HumanoidRootPart"},
                        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                    } or {
                        {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
                        {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
                    }

                    local lineIdx = 1
                    for _, p in ipairs(pairsList) do
                        local partA = char:FindFirstChild(p[1])
                        local partB = char:FindFirstChild(p[2])
                        if partA and partB and lineIdx <= #lines then
                            local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                            local posB, visB = Camera:WorldToViewportPoint(partB.Position)
                            if visA or visB then
                                lines[lineIdx].From = Vector2.new(posA.X, posA.Y)
                                lines[lineIdx].To = Vector2.new(posB.X, posB.Y)
                                lines[lineIdx].Visible = true
                                lineIdx = lineIdx + 1
                            end
                        end
                    end

                    for i = lineIdx, #lines do lines[i].Visible = false end
                else
                    box.Visible = false
                    for _, l in ipairs(lines) do l.Visible = false end
                end
            else
                box.Visible = false
                for _, l in ipairs(lines) do l.Visible = false end
            end
        end
    end
end)

-- 6. Aimbot Engine (10 Blocks = 40 Studs Detection)
local FovCircle
if Drawing and Drawing.new then
    FovCircle = Drawing.new("Circle")
    FovCircle.Color = Color3.fromRGB(255, 255, 255)
    FovCircle.Thickness = 1.2
    FovCircle.Filled = false
    FovCircle.NumSides = 128
    FovCircle.Visible = false
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = ScriptSense.Config.AimbotFovRadius
    local mousePos = UserInputService:GetMouseLocation()
    local maxStudsDistance = ScriptSense.Config.AimbotMaxBlocks * 4 -- 1 блок = 4 студа

    local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and LocalPlayer.Character.HumanoidRootPart.Position or Camera.CFrame.Position

    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and playerObj.Character then
            local humanoid = playerObj.Character:FindFirstChildOfClass("Humanoid")
            local head = playerObj.Character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head then
                local distance3D = (myPos - head.Position).Magnitude
                if distance3D <= maxStudsDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distance2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance2D < shortestDistance then
                            shortestDistance = distance2D
                            closestPlayer = head
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if ScriptSense.Config.AimbotEnabled and not IsRobloxMenuOpen() then
        if FovCircle then
            FovCircle.Position = UserInputService:GetMouseLocation()
            FovCircle.Radius = ScriptSense.Config.AimbotFovRadius
            FovCircle.Visible = true
        end

        local targetHead = GetClosestPlayerToCursor()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    else
        if FovCircle then FovCircle.Visible = false end
    end
end)

-- 7. Godmode Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.GodmodeEnabled then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Health = humanoid.MaxHealth end
    end
end)

-- 8. TouchFling Thread Init
startFlingThread = function()
    task.spawn(function()
        while ScriptSense.Config.TouchFlingEnabled do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local vel = root.Velocity
                root.Velocity = Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                root.Velocity = vel
            end
            task.wait()
        end
    end)
end
