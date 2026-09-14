--[========================================================================================[
    PROJECT: SCRIPT SENSE ULTIMATE SUITE - ENTERPRISE EDITION (FIXED & ENHANCED)
    VERSION: 6.5.0 [PRODUCTION GRADE]
    DESCRIPTION: Added adjustable Spin Speed, Speedhack, and Speedhack Speed control.
--]========================================================================================]

local ScriptSense = {}
ScriptSense.Version = "6.5.0"
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

GuiService.MenuOpened:Connect(function()
    isRobloxMenuOpen = true
end)

GuiService.MenuClosed:Connect(function()
    isRobloxMenuOpen = false
end)

local function IsRobloxMenuOpen()
    if isRobloxMenuOpen then return true end
    local success, isOpen = pcall(function()
        return GuiService:IsMenuOpen()
    end)
    return success and isOpen or false
end

-- Global Configuration Registry
ScriptSense.Config = {
    AimbotEnabled = false,
    WallhackEnabled = false,
    GodmodeEnabled = false,
    FlyEnabled = false,
    SkeletonEspEnabled = false,
    AntiAimEnabled = false,
    SpeedhackEnabled = false,
    TouchFlingEnabled = false,

    FlySpeed = 50,
    SpinSpeed = 25,
    SpeedhackSpeed = 32,
    AimbotSmoothness = 4,
    AimbotFovRadius = 150,
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

-- Full Cleanup: clear from both gethui() and CoreGui to prevent caching
local successHui, huiContainer = pcall(gethui)
if successHui and huiContainer then
    for _, child in ipairs(huiContainer:GetChildren()) do
        if child.Name == "ScriptSenseEnterpriseGUI" then
            SafeDestroy(child)
        end
    end
end

for _, child in ipairs(CoreGui:GetChildren()) do
    if child.Name == "ScriptSenseEnterpriseGUI" then
        SafeDestroy(child)
    end
end

local SuccessContainer, RootGuiParent = pcall(function()
    return gethui() or CoreGui
end)
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

-- Menu Toggle Arrow Button
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
local MainControlPanel = Instance.new("Frame")
MainControlPanel.Name = "MainControlPanel"
MainControlPanel.Size = UDim2.new(0, 250, 0, 560)
MainControlPanel.Position = UDim2.new(0, 20, 0, 65)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainControlPanel.BorderSizePixel = 0
MainControlPanel.Visible = false
MainControlPanel.Parent = ScreenGui

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

-- Dedicated Interactive Keybinds Menu Window
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
KbTitle.Position = UDim2.new(0, 0, 0, 0)
KbTitle.BackgroundTransparency = 1
KbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KbTitle.TextSize = 14
KbTitle.Font = Enum.Font.GothamBold
KbTitle.Text = "   KEYBIND MANAGER (Click to rebind)"
KbTitle.TextXAlignment = Enum.TextXAlignment.Left
KbTitle.Parent = KeybindsMenuWindow

local KbContainer = Instance.new("ScrollingFrame")
KbContainer.Name = "KbContainer"
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

local PopulateKeybindsDisplay

local function ToggleKeybindsMenu()
    KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
    if KeybindsMenuWindow.Visible then
        PopulateKeybindsDisplay()
    end
end

local controlRowFrames = {}

local function CreateControlRow(parent, posY, initialText, callback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, -20, 0, 32)
    rowFrame.Position = UDim2.new(0, 10, 0, posY)
    rowFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    rowFrame.BackgroundTransparency = 1
    rowFrame.BorderSizePixel = 0
    rowFrame.Visible = false
    rowFrame.Parent = parent

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
        button.MouseButton1Click:Connect(function()
            local success, err = pcall(callback)
            if not success and err then
                warn("[ScriptSense Error]: " .. tostring(err))
            end
        end)
    end

    table.insert(controlRowFrames, rowFrame)
    return rowFrame, button
end

local startFlingThread
local activeRebindKey = nil

local function GetKeyName(keyCode)
    local name = keyCode.Name
    if name == "Backquote" then return "`" end
    return string.lower(name)
end

-- Forward declarations for dynamic UI update
local UpdatePanelUI

-- Populate Main Control Panel Rows
local verticalOffset = 12

local _, wallhackRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "wallhack: off", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local _, aimbotRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "aimbot: off", function()
    if not IsRobloxMenuOpen() then
        ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
        UpdatePanelUI()
    end
end)
verticalOffset = verticalOffset + 38

local _, godmodeRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "godmode: off", function()
    ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local _, flyRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "fly: off", function()
    ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local _, skeletonRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "skeleton esp: off", function()
    ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local _, antiAimRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "anti-aim (spin): off", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local spinSpeeds = {10, 25, 50, 100, 200, 400}
local spinSpeedIndex = 2
local _, spinSpeedRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "spin speed: 25", function()
    spinSpeedIndex = (spinSpeedIndex % #spinSpeeds) + 1
    ScriptSense.Config.SpinSpeed = spinSpeeds[spinSpeedIndex]
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local _, speedhackRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "speedhack: off", function()
    ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local speedhackSpeeds = {16, 24, 32, 50, 80, 120, 200}
local speedhackSpeedIndex = 3
local _, speedhackSpeedRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "speedhack speed: 32", function()
    speedhackSpeedIndex = (speedhackSpeedIndex % #speedhackSpeeds) + 1
    ScriptSense.Config.SpeedhackSpeed = speedhackSpeeds[speedhackSpeedIndex]
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

local _, touchFlingRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "touchfling: off", function()
    ScriptSense.Config.TouchFlingEnabled = not ScriptSense.Config.TouchFlingEnabled
    if ScriptSense.Config.TouchFlingEnabled then
        startFlingThread()
    end
    UpdatePanelUI()
end)
verticalOffset = verticalOffset + 38

CreateControlRow(MainControlPanel, verticalOffset, "keybinds manager", function()
    ToggleKeybindsMenu()
end)
verticalOffset = verticalOffset + 38

-- Teleport Window
local TeleportWindow = Instance.new("ScrollingFrame")
TeleportWindow.Name = "TeleportWindow"
TeleportWindow.Size = UDim2.new(0, 300, 0, 360)
TeleportWindow.Position = UDim2.new(0.5, -150, 0.5, -180)
TeleportWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TeleportWindow.BorderSizePixel = 0
TeleportWindow.ScrollBarThickness = 6
TeleportWindow.Visible = false
TeleportWindow.Parent = ScreenGui

local TpStroke = Instance.new("UIStroke")
TpStroke.Color = Color3.fromRGB(70, 70, 70)
TpStroke.Thickness = 2
TpStroke.Parent = TeleportWindow

local TpLayout = Instance.new("UIListLayout")
TpLayout.SortOrder = Enum.SortOrder.LayoutOrder
TpLayout.Parent = TeleportWindow

CreateControlRow(MainControlPanel, verticalOffset, "teleport menu", function()
    TeleportWindow.Visible = not TeleportWindow.Visible
end)

UpdatePanelUI = function()
    if wallhackRowBtn then wallhackRowBtn.Text = "wallhack: " .. (ScriptSense.Config.WallhackEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Wallhack) .. "]" end
    if aimbotRowBtn then aimbotRowBtn.Text = "aimbot: " .. (ScriptSense.Config.AimbotEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Aimbot) .. "]" end
    if godmodeRowBtn then godmodeRowBtn.Text = "godmode: " .. (ScriptSense.Config.GodmodeEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Godmode) .. "]" end
    if flyRowBtn then flyRowBtn.Text = "fly: " .. (ScriptSense.Config.FlyEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Fly) .. "]" end
    if skeletonRowBtn then skeletonRowBtn.Text = "skeleton esp: " .. (ScriptSense.Config.SkeletonEspEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Skeleton) .. "]" end
    if antiAimRowBtn then antiAimRowBtn.Text = "anti-aim (spin): " .. (ScriptSense.Config.AntiAimEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.AntiAim) .. "]" end
    if spinSpeedRowBtn then spinSpeedRowBtn.Text = "spin speed: " .. ScriptSense.Config.SpinSpeed .. " (click to cycle)" end
    if speedhackRowBtn then speedhackRowBtn.Text = "speedhack: " .. (ScriptSense.Config.SpeedhackEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.Speedhack) .. "]" end
    if speedhackSpeedRowBtn then speedhackSpeedRowBtn.Text = "speedhack speed: " .. ScriptSense.Config.SpeedhackSpeed .. " (click to cycle)" end
    if touchFlingRowBtn then touchFlingRowBtn.Text = "touchfling: " .. (ScriptSense.Config.TouchFlingEnabled and "on" or "off") .. " [" .. GetKeyName(ScriptSense.Config.Keybinds.TouchFling) .. "]" end
end

UpdatePanelUI()

-- Intro Sequence
task.spawn(function()
    local fullText = "SCRIPT SENSE [v6.5.0]"
    local totalChars = #fullText
    local totalDuration = 2.0
    local charDelay = totalDuration / totalChars

    local function getPartialText(count)
        local scriptPart = string.sub("SCRIPT", 1, math.min(count, 6))
        local res = '<font color="#FFFFFF">' .. scriptPart .. '</font>'
        
        if count > 6 then
            local spaceAndSense = string.sub(" SENSE", 1, count - 6)
            res = res .. '<font color="#FF0000">' .. spaceAndSense .. '</font>'
        end
        
        if count > 12 then
            local spaceAndVer = string.sub(" [v6.5.0]", 1, count - 12)
            res = res .. '<font color="#AAAAAA">' .. spaceAndVer .. '</font>'
        end
        
        return res
    end

    for i = 1, totalChars do
        WatermarkLabel.Text = getPartialText(i)
        task.wait(charDelay)
    end
    WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">[v6.5.0]</font>'

    local currentAbsPos = WatermarkContainer.AbsolutePosition
    WatermarkContainer.AnchorPoint = Vector2.new(0, 0)
    WatermarkContainer.Position = UDim2.new(0, currentAbsPos.X, 0, currentAbsPos.Y)

    local transitionTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local moveTween = TweenService:Create(WatermarkContainer, transitionTweenInfo, {
        Position = UDim2.new(0, 20, 0, 20)
    })
    moveTween:Play()

    local textSizeVal = Instance.new("NumberValue")
    textSizeVal.Value = 28
    textSizeVal.Changed:Connect(function(v)
        WatermarkLabel.TextSize = v
    end)
    TweenService:Create(textSizeVal, transitionTweenInfo, { Value = 16 }):Play()
    task.delay(0.45, function() SafeDestroy(textSizeVal) end)

    TweenService:Create(MenuToggleArrow, transitionTweenInfo, {
        TextTransparency = 0,
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(ArrowStroke, transitionTweenInfo, {
        Transparency = 0
    }):Play()

    moveTween.Completed:Wait()

    task.wait(0.2)

    if not IsMobileDevice then
        MainControlPanel.Visible = true
        isPanelVisible = true
    end

    TweenService:Create(PanelStroke, transitionTweenInfo, {
        Transparency = 0
    }):Play()

    for index, rowFrame in ipairs(controlRowFrames) do
        if rowFrame then
            task.delay((index - 1) * 0.03 + 0.04, function()
                rowFrame.Visible = true
                local rowTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                TweenService:Create(rowFrame, rowTweenInfo, { BackgroundTransparency = 0.2 }):Play()
                
                local stroke = rowFrame:FindFirstChildOfClass("UIStroke")
                if stroke then
                    TweenService:Create(stroke, rowTweenInfo, { Transparency = 0 }):Play()
                end

                local btn = rowFrame:FindFirstChildOfClass("TextButton")
                if btn then
                    TweenService:Create(btn, rowTweenInfo, { TextTransparency = 0 }):Play()
                end
            end)
        end
    end
end)

-- Populate Interactive Keybinds Menu Content
PopulateKeybindsDisplay = function()
    for _, child in ipairs(KbContainer:GetChildren()) do
        if child:IsA("Frame") then
            SafeDestroy(child)
        end
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
        local labelName, configKey, keyCode = data[1], data[2], data[3]

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

        if activeRebindKey == configKey then
            btn.Text = "   [ " .. labelName .. " ] -> Press any key..."
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            btn.Text = "   " .. labelName .. " -> [" .. string.upper(GetKeyName(keyCode)) .. "]"
        end

        btn.MouseButton1Click:Connect(function()
            activeRebindKey = configKey
            PopulateKeybindsDisplay()
        end)
    end

    KbContainer.CanvasSize = UDim2.new(0, 0, 0, KbListLayout.AbsoluteContentSize.Y)
end

local function RefreshPlayerTeleportList()
    for _, child in ipairs(TeleportWindow:GetChildren()) do
        if child:IsA("TextButton") then
            SafeDestroy(child)
        end
    end

    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 40)
            pBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 14
            pBtn.Font = Enum.Font.Gotham
            pBtn.Text = "   Teleport to -> " .. playerObj.Name
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.Parent = TeleportWindow

            pBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local targetChar = playerObj.Character
                    local localChar = LocalPlayer.Character
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                            localChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end)
            end)
        end
    end
    TeleportWindow.CanvasSize = UDim2.new(0, 0, 0, TpLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(RefreshPlayerTeleportList)
Players.PlayerRemoving:Connect(RefreshPlayerTeleportList)
RefreshPlayerTeleportList()

-- Input Listener for Binds & Rebinding
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if activeRebindKey then
        ScriptSense.Config.Keybinds[activeRebindKey] = input.KeyCode
        activeRebindKey = nil
        if KeybindsMenuWindow.Visible then
            PopulateKeybindsDisplay()
        end
        UpdatePanelUI()
        return
    end

    if input.KeyCode == ScriptSense.Config.Keybinds.Wallhack then
        ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Aimbot then
        if not IsRobloxMenuOpen() then
            ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
        end
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
        if ScriptSense.Config.TouchFlingEnabled then
            startFlingThread()
        end
    elseif input.KeyCode == ScriptSense.Config.Keybinds.MenuToggle then
        ToggleKeybindsMenu()
    end
    UpdatePanelUI()
end)

-- 1. Wallhack Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.WallhackEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 2. Flight Engine
local ActiveBodyGyro, ActiveBodyVelocity = nil, nil
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if rootPart and humanoid then
            if ScriptSense.Config.FlyEnabled then
                humanoid.PlatformStand = true
                if not ActiveBodyGyro or not ActiveBodyGyro.Parent then
                    ActiveBodyGyro = Instance.new("BodyGyro")
                    ActiveBodyGyro.P = 9e4
                    ActiveBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
                    ActiveBodyGyro.Parent = rootPart
                end
                if not ActiveBodyVelocity or not ActiveBodyVelocity.Parent then
                    ActiveBodyVelocity = Instance.new("BodyVelocity")
                    ActiveBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
                    ActiveBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    ActiveBodyVelocity.Parent = rootPart
                end

                ActiveBodyGyro.CFrame = Camera.CFrame
                local moveVector = Vector3.new(0, 0, 0)
                local speed = ScriptSense.Config.FlySpeed

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end

                if moveVector.Magnitude > 0 then
                    ActiveBodyVelocity.Velocity = moveVector.Unit * speed
                else
                    ActiveBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            else
                if ActiveBodyGyro then SafeDestroy(ActiveBodyGyro) ActiveBodyGyro = nil end
                if ActiveBodyVelocity then SafeDestroy(ActiveBodyVelocity) ActiveBodyVelocity = nil end
                if humanoid.PlatformStand and not ScriptSense.Config.AntiAimEnabled then
                    humanoid.PlatformStand = false
                end
            end
        end
    end
end)

-- 3. Speedhack Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.SpeedhackEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = ScriptSense.Config.SpeedhackSpeed
            end
        end
    end
end)

-- 4. TouchFling Engine
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

local flingThread = nil
startFlingThread = function()
    if flingThread then return end
    flingThread = coroutine.create(function()
        local c, hrp, vel, movel = nil, nil, nil, 0.1
        while ScriptSense.Config.TouchFlingEnabled do
            RunService.Heartbeat:Wait()
            c = LocalPlayer.Character
            hrp = c and c:FindFirstChild("HumanoidRootPart")

            if hrp then
                vel = hrp.Velocity
                hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                hrp.Velocity = vel
                RunService.Stepped:Wait()
                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                movel = -movel
            end
        end
        flingThread = nil
    end)
    coroutine.resume(flingThread)
end

-- 5. Skeleton & Box ESP Rendering Engine
local SkeletonCacheRegistry = {}
local function PurgeSkeletonCache(playerTarget)
    if SkeletonCacheRegistry[playerTarget] then
        for _, obj in pairs(SkeletonCacheRegistry[playerTarget]) do
            pcall(function() obj:Remove() end)
        end
        SkeletonCacheRegistry[playerTarget] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not (typeof(Drawing) == "table" and Drawing.new) then return end

    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and ScriptSense.Config.SkeletonEspEnabled then
            local character = playerObj.Character
            local head = character and character:FindFirstChild("Head")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if character and head and hrp then
                if not SkeletonCacheRegistry[playerObj] then
                    local boxObj = Drawing.new("Square")
                    boxObj.Visible = false
                    boxObj.Color = Color3.fromRGB(255, 255, 255)
                    boxObj.Thickness = 1.5
                    boxObj.Filled = false

                    SkeletonCacheRegistry[playerObj] = {
                        Box = boxObj,
                        HeadToTorso = Drawing.new("Line"),
                        TorsoToLeftArm = Drawing.new("Line"),
                        TorsoToRightArm = Drawing.new("Line"),
                        TorsoToLeftLeg = Drawing.new("Line"),
                        TorsoToRightLeg = Drawing.new("Line"),
                    }
                    for name, obj in pairs(SkeletonCacheRegistry[playerObj]) do
                        if name ~= "Box" then
                            obj.Visible = false
                            obj.Color = Color3.fromRGB(255, 255, 255)
                            obj.Thickness = 1.5
                        end
                    end
                end

                local cache = SkeletonCacheRegistry[playerObj]
                local headTop = head.Position + Vector3.new(0, 0.5, 0)
                local footBottom = hrp.Position - Vector3.new(0, 3, 0)

                local headScreen, headVis = Camera:WorldToViewportPoint(headTop)
                local footScreen, footVis = Camera:WorldToViewportPoint(footBottom)

                if headVis or footVis then
                    local height = math.abs(headScreen.Y - footScreen.Y)
                    local width = height / 2
                    cache.Box.Size = Vector2.new(width, height)
                    cache.Box.Position = Vector2.new(headScreen.X - width / 2, headScreen.Y)
                    cache.Box.Visible = true
                else
                    cache.Box.Visible = false
                end

                local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
                local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
                local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
                local leftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
                local rightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")

                if head and torso then
                    local headPos, hVis = Camera:WorldToViewportPoint(head.Position)
                    local torsoPos, tVis = Camera:WorldToViewportPoint(torso.Position)

                    if hVis and tVis then
                        cache.HeadToTorso.From = Vector2.new(headPos.X, headPos.Y)
                        cache.HeadToTorso.To = Vector2.new(torsoPos.X, torsoPos.Y)
                        cache.HeadToTorso.Visible = true
                    else
                        cache.HeadToTorso.Visible = false
                    end

                    if leftArm then
                        local laPos, laVis = Camera:WorldToViewportPoint(leftArm.Position)
                        if laVis then
                            cache.TorsoToLeftArm.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            cache.TorsoToLeftArm.To = Vector2.new(laPos.X, laPos.Y)
                            cache.TorsoToLeftArm.Visible = true
                        else cache.TorsoToLeftArm.Visible = false end
                    end

                    if rightArm then
                        local raPos, raVis = Camera:WorldToViewportPoint(rightArm.Position)
                        if raVis then
                            cache.TorsoToRightArm.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            cache.TorsoToRightArm.To = Vector2.new(raPos.X, raPos.Y)
                            cache.TorsoToRightArm.Visible = true
                        else cache.TorsoToRightArm.Visible = false end
                    end

                    if leftLeg then
                        local llPos, llVis = Camera:WorldToViewportPoint(leftLeg.Position)
                        if llVis then
                            cache.TorsoToLeftLeg.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            cache.TorsoToLeftLeg.To = Vector2.new(llPos.X, llPos.Y)
                            cache.TorsoToLeftLeg.Visible = true
                        else cache.TorsoToLeftLeg.Visible = false end
                    end

                    if rightLeg then
                        local rlPos, rlVis = Camera:WorldToViewportPoint(rightLeg.Position)
                        if rlVis then
                            cache.TorsoToRightLeg.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            cache.TorsoToRightLeg.To = Vector2.new(rlPos.X, rlPos.Y)
                            cache.TorsoToRightLeg.Visible = true
                        else cache.TorsoToRightLeg.Visible = false end
                    end
                end
            else
                PurgeSkeletonCache(playerObj)
            end
        else
            PurgeSkeletonCache(playerObj)
        end
    end
end)

-- 6. Anti-Aim (Spinbot) Engine with Adjustable Speed
RunService.Heartbeat:Connect(function()
    if ScriptSense.Config.AntiAimEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
            rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(ScriptSense.Config.CurrentSpinAngle), 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 7. Godmode Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.GodmodeEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
            end
        end
    end
end)

-- 8. Aimbot Engine
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = ScriptSense.Config.AimbotFovRadius
    local mousePos = UserInputService:GetMouseLocation()

    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and playerObj.Character then
            local humanoid = playerObj.Character:FindFirstChildOfClass("Humanoid")
            local head = playerObj.Character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = head
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if ScriptSense.Config.AimbotEnabled and not IsRobloxMenuOpen() then
        local targetHead = GetClosestPlayerToCursor()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)
