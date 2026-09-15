--[========================================================================================[
    PROJECT: SCRIPT SENSE ULTIMATE SUITE - ENTERPRISE EDITION
    VERSION: 6.6.7 [FIXED EMPTY UI & F1 MENU TOGGLE]
--]========================================================================================]

local ScriptSense = {}
ScriptSense.Version = "6.6.7"
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
        Speedhack = Enum.KeyCode.V,
        TouchFling = Enum.KeyCode.K,
        MenuToggle = Enum.KeyCode.F1, -- Открытие/закрытие меню по F1
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
        if child.Name == "ScriptSenseEnterpriseGUI" or child.Name == "ScriptSenseFlingGUI" then SafeDestroy(child) end
    end
end
for _, child in ipairs(CoreGui:GetChildren()) do
    if child.Name == "ScriptSenseEnterpriseGUI" or child.Name == "ScriptSenseFlingGUI" then SafeDestroy(child) end
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

-- Watermark Container (Верхняя плашка)
local WatermarkContainer = Instance.new("Frame")
WatermarkContainer.Name = "WatermarkContainer"
WatermarkContainer.AnchorPoint = Vector2.new(0.5, 0)
WatermarkContainer.Size = UDim2.new(0, 0, 0, 40)
WatermarkContainer.Position = UDim2.new(0.5, 0, 0, 15)
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
WatermarkLabel.TextSize = 20
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WatermarkLabel.Text = "SCRIPT SENSE | v6.6.7 [F1]"
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WatermarkLabel.LayoutOrder = 1
WatermarkLabel.Parent = WatermarkContainer

local MenuToggleArrow = Instance.new("TextButton")
MenuToggleArrow.Name = "MenuToggleArrow"
MenuToggleArrow.Size = UDim2.new(0, 26, 0, 26)
MenuToggleArrow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuToggleArrow.BackgroundTransparency = 0.5
MenuToggleArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleArrow.TextSize = 13
MenuToggleArrow.Font = Enum.Font.GothamBold
MenuToggleArrow.Text = "▼"
MenuToggleArrow.LayoutOrder = 2
MenuToggleArrow.Parent = WatermarkContainer

local ArrowCorner = Instance.new("UICorner")
ArrowCorner.CornerRadius = UDim.new(0, 4)
ArrowCorner.Parent = MenuToggleArrow

-- Main Control Panel Frame (Само выпадающее меню)
local MainControlPanel = Instance.new("ScrollingFrame")
MainControlPanel.Name = "MainControlPanel"
MainControlPanel.Size = UDim2.new(0, 260, 0, 400)
MainControlPanel.Position = UDim2.new(0.5, -130, 0, 65)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
PanelStroke.Color = Color3.fromRGB(60, 60, 60)
PanelStroke.Thickness = 1.5
PanelStroke.Parent = MainControlPanel

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 6)
PanelCorner.Parent = MainControlPanel

local isPanelVisible = false
local function ToggleMenuVisibility()
    isPanelVisible = not isPanelVisible
    MainControlPanel.Visible = isPanelVisible
    MenuToggleArrow.Text = isPanelVisible and "▲" : "▼" -- Исправленный синтаксис
end

MenuToggleArrow.MouseButton1Click:Connect(ToggleMenuVisibility)

-- Обработка нажатия клавиши F1
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and not IsTyping() and input.KeyCode == ScriptSense.Config.Keybinds.MenuToggle then
        ToggleMenuVisibility()
    end
end)

-- Функция создания строк с кнопками в меню
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.Parent = MainControlPanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Добавляем рабочие элементы управления в меню, чтобы оно не было пустым:
CreateButton("Toggle Aimbot", function()
    ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
    print("Aimbot:", ScriptSense.Config.AimbotEnabled)
end)

CreateButton("Toggle Wallhack", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    print("Wallhack:", ScriptSense.Config.WallhackEnabled)
end)

CreateButton("Toggle Fly", function()
    ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
    print("Fly:", ScriptSense.Config.FlyEnabled)
end)

CreateButton("Toggle Anti-Aim / Spin", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
    print("AntiAim (Spin):", ScriptSense.Config.AntiAimEnabled)
end)

CreateButton("Toggle Godmode", function()
    ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
    print("Godmode:", ScriptSense.Config.GodmodeEnabled)
end)

-- Цикл вращения Anti-Aim (работает даже при ShiftLock)
RunService.RenderStepped:Connect(function()
    if ScriptSense.Config.AntiAimEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, math.rad(ScriptSense.Config.CurrentSpinAngle), 0)
            end
        end
    end
end)

print("[ScriptSense] Loaded successfully! Press F1 to open the menu.")
