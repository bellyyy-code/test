--[========================================================================================[
    PROJECT: SCRIPT SENSE ULTIMATE SUITE - ENTERPRISE EDITION
    VERSION: 6.6.4 [SCRIPT SENSE MULTI FLING INTEGRATED]
    DESCRIPTION: Fixed Fly + ESP compatibility, white Skeleton & Box ESP integration, 
                 fixed Auto Jump, updated Aimbot block-distance detection (10 blocks = 40 studs),
                 added standalone Script Sense Multi-Target Fling GUI window.
    VERSION: 6.6.5 [FIXED FLY BIND & INTEGRATED AUTO JUMP]
--]========================================================================================]

local ScriptSense = {}
ScriptSense.Version = "6.6.4"
ScriptSense.Version = "6.6.5"
ScriptSense.Active = true

-- Services Retrieval
@@ -28,15 +25,9 @@ end

local Camera = Workspace.CurrentCamera

-- Robust Event-Driven Roblox Menu Tracking
local isRobloxMenuOpen = false
GuiService.MenuOpened:Connect(function() isRobloxMenuOpen = true end)
GuiService.MenuClosed:Connect(function() isRobloxMenuOpen = false end)

local function IsRobloxMenuOpen()
    if isRobloxMenuOpen then return true end
    local success, isOpen = pcall(function() return GuiService:IsMenuOpen() end)
    return success and isOpen or false
-- Check if player is actively typing in a chat or text box
local function IsTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

-- Global Configuration Registry
@@ -57,7 +48,7 @@ ScriptSense.Config = {

    AimbotSmoothness = 4,
    AimbotFovRadius = 150,
    AimbotMaxBlocks = 10, -- 10 блоков (40 studs)
    AimbotMaxBlocks = 10,
    CurrentSpinAngle = 0,

    Keybinds = {
@@ -381,9 +372,7 @@ local function CreateBlackIndicatorRow(labelText, callback)
    return rowFrame, indicator
end

-- =========================================================================================
-- INTEGRATED SCRIPT SENSE MULTI FLING GUI MODULE
-- =========================================================================================
-- Integrated Fling Window
local FlingGuiInstance = nil
local function BuildAndToggleFlingGUI()
    if FlingGuiInstance and FlingGuiInstance.Parent then
@@ -786,14 +775,37 @@ end
local startFlingThread
local PopulateKeybindsDisplay

-- Fixed Auto Jump Engine (Loop with interval)
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
                    task.wait(0.07)
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
    if not IsRobloxMenuOpen() then
    if not IsTyping() then
        ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
        UpdatePanelUI()
    end
@@ -829,6 +841,7 @@ end)

local autoJumpRow, autoJumpInd = CreateBlackIndicatorRow("auto jump", function()
    ScriptSense.Config.AutoJumpEnabled = not ScriptSense.Config.AutoJumpEnabled
    ToggleAutoJumpThread()
    UpdatePanelUI()
end)

@@ -883,23 +896,23 @@ UpdatePanelUI()

-- Intro Sequence
task.spawn(function()
    local fullText = "SCRIPT SENSE [v6.6.4]"
    local fullText = "SCRIPT SENSE [v6.6.5]"
    local totalChars = #fullText
    local charDelay = 2.0 / totalChars

    local function getPartialText(count)
        local scriptPart = string.sub("SCRIPT", 1, math.min(count, 6))
        local res = '<font color="#FFFFFF">' .. scriptPart .. '</font>'
        if count > 6 then res = res .. '<font color="#FF0000">' .. string.sub(" SENSE", 1, count - 6) .. '</font>' end
        if count > 12 then res = res .. '<font color="#AAAAAA">' .. string.sub(" [v6.6.4]", 1, count - 12) .. '</font>' end
        if count > 12 then res = res .. '<font color="#AAAAAA">' .. string.sub(" [v6.6.5]", 1, count - 12) .. '</font>' end
        return res
    end

    for i = 1, totalChars do
        WatermarkLabel.Text = getPartialText(i)
        task.wait(charDelay)
    end
    WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">[v6.6.4]</font>'
    WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">[v6.6.5]</font>'

    local currentAbsPos = WatermarkContainer.AbsolutePosition
    WatermarkContainer.AnchorPoint = Vector2.new(0, 0)
@@ -1010,9 +1023,9 @@ PopulateKeybindsDisplay = function()
    end
end

-- Keybind Input Listener
-- Keybind Input Listener (Ignore gameProcessed for F & other keys unless typing in Chat/TextBox)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if IsTyping() then return end

    if activeRebindKey then
        ScriptSense.Config.Keybinds[activeRebindKey] = input.KeyCode
@@ -1025,7 +1038,7 @@ UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == ScriptSense.Config.Keybinds.Wallhack then
        ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Aimbot then
        if not IsRobloxMenuOpen() then ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled end
        ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Godmode then
        ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Fly then
@@ -1078,15 +1091,17 @@ RunService.RenderStepped:Connect(function()
    end
end)

-- 3. Fly Engine
-- 3. Fixed Fly Engine (MM2 Compatible)
local flyBV, flyBG
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    if ScriptSense.Config.FlyEnabled then
        humanoid.PlatformStand = true
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
@@ -1111,27 +1126,21 @@ RunService.Heartbeat:Connect(function()
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyBV.Velocity = moveDir * ScriptSense.Config.FlySpeed
    else
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end)

-- 4. Anti-Aim & Auto Jump Engine
-- 4. Anti-Aim Engine
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
        
        if ScriptSense.Config.AutoJumpEnabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Jump = true end
    if character and ScriptSense.Config.AntiAimEnabled then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
            rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(ScriptSense.Config.CurrentSpinAngle), 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)
@@ -1289,7 +1298,7 @@ local function GetClosestPlayerToCursor()
end

RunService.RenderStepped:Connect(function()
    if ScriptSense.Config.AimbotEnabled and not IsRobloxMenuOpen() then
    if ScriptSense.Config.AimbotEnabled and not IsTyping() then
        if FovCircle then
            FovCircle.Position = UserInputService:GetMouseLocation()
            FovCircle.Radius = ScriptSense.Config.AimbotFovRadius
