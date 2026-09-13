local success, err = pcall(function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    if not player then
        repeat task.wait() player = Players.LocalPlayer until player
    end

    local camera = workspace.CurrentCamera

    local aimbotEnabled = false
    local noclipEnabled = false
    local godmodeEnabled = false
    local flyEnabled = false
    local skeletonEspEnabled = false
    local touchFlingEnabled = false
    local flySpeed = 50
    local maxStuds = 10

    local wallhackKey = Enum.KeyCode.G
    local aimbotKey = Enum.KeyCode.R
    local godmodeKey = Enum.KeyCode.C
    local flyKey = Enum.KeyCode.F
    local skeletonKey = Enum.KeyCode.X
    local touchFlingKey = Enum.KeyCode.K
    local menuKey = Enum.KeyCode.Backquote

    local listeningFor = nil
    local skeletonLines = {}
    local hasDrawing = (Drawing ~= nil and Drawing.new ~= nil)

    -- Script Sense & Multi Fling Variables
    local SelectedTargets = {}
    local PlayerCheckboxes = {}
    local FlingActive = false
    getgenv().OldPos = nil
    getgenv().FPDH = workspace.FallenPartsDestroyHeight

    -- Touch Fling Setup
    if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
        local detection = Instance.new("Decal")
        detection.Name = "juisdfj0i32i0eidsuf0iok"
        detection.Parent = ReplicatedStorage
    end
    local touchFlingThread = nil

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScriptSenseMultiFlingGUI"
    screenGui.ResetOnSpawn = false
    
    local successGui, parentGui = pcall(function()
        return gethui() or CoreGui
    end)
    if not successGui or not parentGui then
        parentGui = player:WaitForChild("PlayerGui")
    end
    screenGui.Parent = parentGui

    local isMobile = UserInputService.TouchEnabled

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(0, 260, 0, 25)
    headerLabel.Position = UDim2.new(0, 10, 0, 10)
    headerLabel.BackgroundTransparency = 1
    headerLabel.TextSize = 16
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.RichText = true
    headerLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE MULTI FLING</font>'
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.Parent = screenGui

    local function createUIElement(parent, posY, text, elementType, customWidth)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, customWidth or 215, 0, 30)
        container.Position = UDim2.new(0, 0, 0, posY)
        container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        container.Parent = container

        -- Fixing parent assignment
        container.Parent = parent

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 2
        stroke.Parent = container

        local element
        if elementType == "Button" then
            element = Instance.new("TextButton")
        elseif elementType == "Box" then
            element = Instance.new("TextBox")
            element.ClearTextOnFocus = false
        else
            element = Instance.new("TextLabel")
        end

        element.Size = UDim2.new(1, -10, 1, 0)
        element.Position = UDim2.new(0, 6, 0, 0)
        element.BackgroundTransparency = 1
        element.TextColor3 = Color3.fromRGB(255, 255, 255)
        element.TextSize = 13
        element.Font = Enum.Font.Gotham
        element.Text = text
        element.TextXAlignment = Enum.TextXAlignment.Left
        element.Parent = container

        return container, element
    end

    local pcContainer = Instance.new("Frame")
    pcContainer.Size = UDim2.new(0, 215, 0, 310)
    pcContainer.Position = UDim2.new(0, 10, 0, 40)
    pcContainer.BackgroundTransparency = 1
    pcContainer.Visible = not isMobile
    pcContainer.Parent = screenGui

    local _, wallhackLabel = createUIElement(pcContainer, 0, "wallhack: off | bind: g", "Label")
    local _, aimbotLabel = createUIElement(pcContainer, 35, "aimbot: off | bind: r", "Label")
    local _, godmodeLabel = createUIElement(pcContainer, 70, "godmode: off | bind: c", "Label")

    local flyRowContainer = Instance.new("Frame")
    flyRowContainer.Size = UDim2.new(0, 215, 0, 30)
    flyRowContainer.Position = UDim2.new(0, 0, 0, 105)
    flyRowContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    flyRowContainer.Parent = pcContainer

    local flyRowStroke = Instance.new("UIStroke")
    flyRowStroke.Color = Color3.fromRGB(255, 255, 255)
    flyRowStroke.Thickness = 2
    flyRowStroke.Parent = flyRowContainer

    local flyLabel = Instance.new("TextLabel")
    flyLabel.Size = UDim2.new(0, 150, 1, 0)
    flyLabel.Position = UDim2.new(0, 6, 0, 0)
    flyLabel.BackgroundTransparency = 1
    flyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyLabel.TextSize = 13
    flyLabel.Font = Enum.Font.Gotham
    flyLabel.Text = "fly: off | bind: f"
    flyLabel.TextXAlignment = Enum.TextXAlignment.Left
    flyLabel.Parent = flyRowContainer

    local speedTextBoxPC = Instance.new("TextBox")
    speedTextBoxPC.Size = UDim2.new(0, 45, 1, -8)
    speedTextBoxPC.Position = UDim2.new(0, 158, 0, 4)
    speedTextBoxPC.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    speedTextBoxPC.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedTextBoxPC.TextSize = 13
    speedTextBoxPC.Font = Enum.Font.Gotham
    speedTextBoxPC.Text = tostring(flySpeed)
    speedTextBoxPC.ClearTextOnFocus = false
    speedTextBoxPC.Parent = flyRowContainer

    local speedBoxStrokePC = Instance.new("UIStroke")
    speedBoxStrokePC.Color = Color3.fromRGB(255, 255, 255)
    speedBoxStrokePC.Thickness = 1
    speedBoxStrokePC.Parent = speedTextBoxPC

    local _, skeletonLabel = createUIElement(pcContainer, 140, "skeleton: off | bind: x", "Button")
    local _, touchFlingLabel = createUIElement(pcContainer, 175, "touchfling: off | bind: k", "Button")

    local menuHintLabel = Instance.new("TextLabel")
    menuHintLabel.Size = UDim2.new(0, 215, 0, 22)
    menuHintLabel.Position = UDim2.new(0, 0, 0, 215)
    menuHintLabel.BackgroundTransparency = 1
    menuHintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    menuHintLabel.TextSize = 13
    menuHintLabel.Font = Enum.Font.Gotham
    menuHintLabel.Text = "open menu - `"
    menuHintLabel.TextXAlignment = Enum.TextXAlignment.Left
    menuHintLabel.Parent = pcContainer

    local _, openFlingMenuPCBtn = createUIElement(pcContainer, 245, "open multi fling menu", "Button")

    -- Main Fling Frame (Embedded and hidden by default)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.Parent = screenGui

    local mainFrameStroke = Instance.new("UIStroke")
    mainFrameStroke.Color = Color3.fromRGB(255, 255, 255)
    mainFrameStroke.Thickness = 2
    mainFrameStroke.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleBarStroke = Instance.new("UIStroke")
    TitleBarStroke.Color = Color3.fromRGB(255, 255, 255)
    TitleBarStroke.Thickness = 1
    TitleBarStroke.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 6, 0, 0)
    Title.BackgroundTransparency = 1
    Title.RichText = true
    Title.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font>'
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = TitleBar

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Position = UDim2.new(0, 10, 0, 40)
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Select targets to multi fling"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 14
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    local SelectionFrame = Instance.new("Frame")
    SelectionFrame.Position = UDim2.new(0, 10, 0, 70)
    SelectionFrame.Size = UDim2.new(1, -20, 0, 200)
    SelectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SelectionFrame.BorderSizePixel = 0
    SelectionFrame.Parent = MainFrame

    local selStroke = Instance.new("UIStroke")
    selStroke.Color = Color3.fromRGB(255, 255, 255)
    selStroke.Thickness = 1
    selStroke.Parent = SelectionFrame

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
    StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    StartButton.BorderSizePixel = 0
    StartButton.Text = "START MULTI FLING"
    StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartButton.Font = Enum.Font.GothamBold
    StartButton.TextSize = 13
    StartButton.Parent = MainFrame

    local startStroke = Instance.new("UIStroke")
    startStroke.Color = Color3.fromRGB(255, 255, 255)
    startStroke.Thickness = 1
    startStroke.Parent = StartButton

    local StopButton = Instance.new("TextButton")
    StopButton.Position = UDim2.new(0.5, 5, 0, 280)
    StopButton.Size = UDim2.new(0.5, -15, 0, 40)
    StopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    StopButton.BorderSizePixel = 0
    StopButton.Text = "STOP FLING"
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.Font = Enum.Font.GothamBold
    StopButton.TextSize = 13
    StopButton.Parent = MainFrame

    local stopStroke = Instance.new("UIStroke")
    stopStroke.Color = Color3.fromRGB(255, 255, 255)
    stopStroke.Thickness = 1
    stopStroke.Parent = StopButton

    local SelectAllButton = Instance.new("TextButton")
    SelectAllButton.Position = UDim2.new(0, 10, 0, 330)
    SelectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
    SelectAllButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SelectAllButton.BorderSizePixel = 0
    SelectAllButton.Text = "SELECT ALL"
    SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectAllButton.Font = Enum.Font.Gotham
    SelectAllButton.TextSize = 12
    SelectAllButton.Parent = MainFrame

    local selAllStroke = Instance.new("UIStroke")
    selAllStroke.Color = Color3.fromRGB(255, 255, 255)
    selAllStroke.Thickness = 1
    selAllStroke.Parent = SelectAllButton

    local DeselectAllButton = Instance.new("TextButton")
    DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 330)
    DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
    DeselectAllButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DeselectAllButton.BorderSizePixel = 0
    DeselectAllButton.Text = "DESELECT ALL"
    DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeselectAllButton.Font = Enum.Font.Gotham
    DeselectAllButton.TextSize = 12
    DeselectAllButton.Parent = MainFrame

    local deselAllStroke = Instance.new("UIStroke")
    deselAllStroke.Color = Color3.fromRGB(255, 255, 255)
    deselAllStroke.Thickness = 1
    deselAllStroke.Parent = DeselectAllButton

    -- Keybinds Settings Menu
    local settingsMenu = Instance.new("Frame")
    settingsMenu.Size = UDim2.new(0, 240, 0, 315)
    settingsMenu.Position = UDim2.new(0.5, -120, 0.5, -155)
    settingsMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    settingsMenu.Visible = false
    settingsMenu.Parent = screenGui

    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = Color3.fromRGB(255, 255, 255)
    menuStroke.Thickness = 3
    menuStroke.Parent = settingsMenu

    local menuTitle = Instance.new("TextLabel")
    menuTitle.Size = UDim2.new(1, -12, 0, 30)
    menuTitle.Position = UDim2.new(0, 6, 0, 5)
    menuTitle.BackgroundTransparency = 1
    menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    menuTitle.TextSize = 14
    menuTitle.Font = Enum.Font.Gotham
    menuTitle.Text = "keybinds settings"
    menuTitle.TextXAlignment = Enum.TextXAlignment.Left
    menuTitle.Parent = settingsMenu

    local function createBindButton(posY, text, actionName)
        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, -12, 0, 30)
        btnContainer.Position = UDim2.new(0, 6, 0, posY)
        btnContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btnContainer.Parent = settingsMenu

        local str = Instance.new("UIStroke")
        str.Color = Color3.fromRGB(255, 255, 255)
        str.Thickness = 1
        str.Parent = btnContainer

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Text = text
        btn.Parent = btnContainer

        btn.MouseButton1Click:Connect(function()
            listeningFor = actionName
            btn.Text = "[ press key... ]"
        end)

        return btn
    end

    local btnWallhack = createBindButton(40, "wallhack: g", "wallhack")
    local btnAimbot = createBindButton(75, "aimbot: r", "aimbot")
    local btnGodmode = createBindButton(110, "godmode: c", "godmode")
    local btnFly = createBindButton(145, "fly: f", "fly")
    local btnSkeleton = createBindButton(180, "skeleton: x", "skeleton")
    local btnTouchFling = createBindButton(215, "touchfling: k", "touchfling")
    local btnMenu = createBindButton(250, "menu key: `", "menu")

    local function refreshMenuTexts()
        btnWallhack.Text = "wallhack: " .. string.lower(wallhackKey.Name)
        btnAimbot.Text = "aimbot: " .. string.lower(aimbotKey.Name)
        btnGodmode.Text = "godmode: " .. string.lower(godmodeKey.Name)
        btnFly.Text = "fly: " .. string.lower(flyKey.Name)
        btnSkeleton.Text = "skeleton: " .. string.lower(skeletonKey.Name)
        btnTouchFling.Text = "touchfling: " .. string.lower(touchFlingKey.Name)
        btnMenu.Text = "menu key: `"
    end

    -- Mobile Controls
    local toggleMenuBtnContainer, toggleMenuBtn = createUIElement(screenGui, 42, "menu", "Button", 100)
    toggleMenuBtnContainer.Visible = isMobile

    local toggleFlingMenuContainer = Instance.new("Frame")
    toggleFlingMenuContainer.Size = UDim2.new(0, 110, 0, 30)
    toggleFlingMenuContainer.Position = UDim2.new(0, 115, 0, 42)
    toggleFlingMenuContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggleFlingMenuContainer.Visible = isMobile
    toggleFlingMenuContainer.Parent = screenGui

    local tfmStroke = Instance.new("UIStroke")
    tfmStroke.Color = Color3.fromRGB(255, 255, 255)
    tfmStroke.Thickness = 2
    tfmStroke.Parent = toggleFlingMenuContainer

    local toggleFlingBtn = Instance.new("TextButton")
    toggleFlingBtn.Size = UDim2.new(1, -10, 1, 0)
    toggleFlingBtn.Position = UDim2.new(0, 6, 0, 0)
    toggleFlingBtn.BackgroundTransparency = 1
    toggleFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleFlingBtn.TextSize = 13
    toggleFlingBtn.Font = Enum.Font.Gotham
    toggleFlingBtn.Text = "multi fling"
    toggleFlingBtn.Parent = toggleFlingMenuContainer

    local mobilePanel = Instance.new("Frame")
    mobilePanel.Size = UDim2.new(0, 160, 0, 245)
    mobilePanel.Position = UDim2.new(0, 10, 0, 77)
    mobilePanel.BackgroundTransparency = 1
    mobilePanel.Visible = false
    mobilePanel.Parent = screenGui

    local _, wallhackBtnLabel = createUIElement(mobilePanel, 0, "enable wallhack", "Button", 160)
    local _, aimbotBtnLabel = createUIElement(mobilePanel, 35, "enable aimbot", "Button", 160)
    local _, godmodeBtnLabel = createUIElement(mobilePanel, 70, "enable godmode", "Button", 160)
    local _, flyBtnLabel = createUIElement(mobilePanel, 105, "enable fly", "Button", 160)
    local _, skeletonBtnLabel = createUIElement(mobilePanel, 140, "enable skeleton", "Button", 160)
    local _, touchFlingBtnLabel = createUIElement(mobilePanel, 175, "enable touchfling", "Button", 160)

    toggleMenuBtn.MouseButton1Click:Connect(function()
        mobilePanel.Visible = not mobilePanel.Visible
        toggleMenuBtn.Text = mobilePanel.Visible and "close menu" or "menu"
    end)

    local function toggleFlingMenuVisibility()
        MainFrame.Visible = not MainFrame.Visible
    end

    toggleFlingBtn.MouseButton1Click:Connect(toggleFlingMenuVisibility)
    openFlingMenuPCBtn.MouseButton1Click:Connect(toggleFlingMenuVisibility)
    CloseButton.MouseButton1Click:Connect(function()
        FlingActive = false
        MainFrame.Visible = false
    end)

    speedTextBoxPC.FocusLost:Connect(function()
        local num = tonumber(speedTextBoxPC.Text:match("%d+"))
        if num then flySpeed = num end
        speedTextBoxPC.Text = tostring(flySpeed)
    end)

    local function updateStates()
        local wName = string.lower(wallhackKey.Name)
        local aName = string.lower(aimbotKey.Name)
        local gName = string.lower(godmodeKey.Name)
        local fName = string.lower(flyKey.Name)
        local sName = string.lower(skeletonKey.Name)
        local tfName = string.lower(touchFlingKey.Name)

        wallhackLabel.Text = "wallhack: " .. (noclipEnabled and "on" or "off") .. " | bind: " .. wName
        aimbotLabel.Text = "aimbot: " .. (aimbotEnabled and "on" or "off") .. " | bind: " .. aName
        godmodeLabel.Text = "godmode: " .. (godmodeEnabled and "on" or "off") .. " | bind: " .. gName
        flyLabel.Text = "fly: " .. (flyEnabled and "on" or "off") .. " | bind: " .. fName
        skeletonLabel.Text = "skeleton: " .. (skeletonEspEnabled and "on" or "off") .. " | bind: " .. sName
        touchFlingLabel.Text = "touchfling: " .. (touchFlingEnabled and "on" or "off") .. " | bind: " .. tfName
        
        skeletonBtnLabel.Text = "skeleton: " .. (skeletonEspEnabled and "on" or "off") .. " | bind: " .. sName
        touchFlingBtnLabel.Text = "touchfling: " .. (touchFlingEnabled and "on" or "off") .. " | bind: " .. tfName
    end

    local bodyVelocity, bodyGyro

    local function toggleWallhack() noclipEnabled = not noclipEnabled updateStates() end
    local function toggleAimbot() aimbotEnabled = not aimbotEnabled updateStates() end
    local function toggleGodmode() godmodeEnabled = not godmodeEnabled updateStates() end
    local function toggleFly()
        flyEnabled = not flyEnabled
        local char = player.Character
        if char then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if flyEnabled then
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.Parent = rootPart
                    
                    bodyGyro = Instance.new("BodyGyro")
                    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bodyGyro.CFrame = rootPart.CFrame
                    bodyGyro.Parent = rootPart
                else
                    if bodyVelocity then bodyVelocity:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                end
            end
        end
        updateStates()
    end

    local function runTouchFling()
        local c, hrp, vel, movel = nil, nil, nil, 0.1
        while touchFlingEnabled do
            RunService.Heartbeat:Wait()
            c = player.Character
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
    end

    local function toggleTouchFling()
        touchFlingEnabled = not touchFlingEnabled
        updateStates()

        if touchFlingEnabled then
            touchFlingThread = coroutine.create(runTouchFling)
            coroutine.resume(touchFlingThread)
        else
            touchFlingEnabled = false
        end
    end

    local function removeSkeleton(p)
        if skeletonLines[p] then
            for _, line in pairs(skeletonLines[p]) do
                pcall(function() line:Remove() end)
            end
            skeletonLines[p] = nil
        end
    end

    local function toggleSkeleton() 
        skeletonEspEnabled = not skeletonEspEnabled 
        if not skeletonEspEnabled then
            for p, _ in pairs(skeletonLines) do
                removeSkeleton(p)
            end
        end
        updateStates() 
    end

    skeletonLabel.MouseButton1Click:Connect(toggleSkeleton)
    skeletonBtnLabel.MouseButton1Click:Connect(toggleSkeleton)
    touchFlingLabel.MouseButton1Click:Connect(toggleTouchFling)
    touchFlingBtnLabel.MouseButton1Click:Connect(toggleTouchFling)

    -- Player List Logic for Multi Fling
    local function RefreshPlayerList()
        for _, child in pairs(PlayerScrollFrame:GetChildren()) do
            child:Destroy()
        end
        PlayerCheckboxes = {}
        
        local PlayerList = Players:GetPlayers()
        table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
        
        local yPosition = 5
        for _, pTarget in ipairs(PlayerList) do
            if pTarget ~= player then
                local PlayerEntry = Instance.new("Frame")
                PlayerEntry.Size = UDim2.new(1, -10, 0, 30)
                PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
                PlayerEntry.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                PlayerEntry.BorderSizePixel = 0
                PlayerEntry.Parent = PlayerScrollFrame
                
                local Checkbox = Instance.new("TextButton")
                Checkbox.Size = UDim2.new(0, 24, 0, 24)
                Checkbox.Position = UDim2.new(0, 3, 0.5, -12)
                Checkbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Checkbox.BorderSizePixel = 0
                Checkbox.Text = ""
                Checkbox.Parent = PlayerEntry
                
                local Checkmark = Instance.new("TextLabel")
                Checkmark.Size = UDim2.new(1, 0, 1, 0)
                Checkmark.BackgroundTransparency = 1
                Checkmark.Text = "✓"
                Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
                Checkmark.TextSize = 18
                Checkmark.Font = Enum.Font.SourceSansBold
                Checkmark.Visible = SelectedTargets[pTarget.Name] ~= nil
                Checkmark.Parent = Checkbox
                
                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(1, -35, 1, 0)
                NameLabel.Position = UDim2.new(0, 30, 0, 0)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = pTarget.Name
                NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                NameLabel.TextSize = 15
                NameLabel.Font = Enum.Font.Gotham
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.Parent = PlayerEntry
                
                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1, 0, 1, 0)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.ZIndex = 2
                ClickArea.Parent = PlayerEntry
                
                ClickArea.MouseButton1Click:Connect(function()
                    if SelectedTargets[pTarget.Name] then
                        SelectedTargets[pTarget.Name] = nil
                        Checkmark.Visible = false
                    else
                        SelectedTargets[pTarget.Name] = pTarget
                        Checkmark.Visible = true
                    end
                    
                    local count = 0
                    for _ in pairs(SelectedTargets) do count = count + 1 end
                    if FlingActive then
                        StatusLabel.Text = "Multi Flinging " .. count .. " target(s)"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    else
                        StatusLabel.Text = count .. " target(s) selected" 
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end)
                
                PlayerCheckboxes[pTarget.Name] = {
                    Entry = PlayerEntry,
                    Checkmark = Checkmark
                }
                
                yPosition = yPosition + 35
            end
        end
        PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 5)
    end

    local function ToggleAllPlayers(select)
        for _, pTarget in ipairs(Players:GetPlayers()) do
            if pTarget ~= player then
                local checkboxData = PlayerCheckboxes[pTarget.Name]
                if checkboxData then
                    if select then
                        SelectedTargets[pTarget.Name] = pTarget
                        checkboxData.Checkmark.Visible = true
                    else
                        SelectedTargets[pTarget.Name] = nil
                        checkboxData.Checkmark.Visible = false
                    end
                end
            end
        end
        local count = 0
        for _ in pairs(SelectedTargets) do count = count + 1 end
        StatusLabel.Text = count .. " target(s) selected" 
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    local function SkidFling(TargetPlayer)
        local Character = player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Humanoid and Humanoid.RootPart
        local TCharacter = TargetPlayer.Character
        if not TCharacter then return end
        
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter:FindFirstChild("Head")
        local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
        local Handle = Accessory and Accessory:FindFirstChild("Handle")
        
        if Character and Humanoid and RootPart then
            if RootPart.Velocity.Magnitude < 50 then
                getgenv().OldPos = RootPart.CFrame
            end
            
            if THumanoid and THumanoid.Sit then return end
            
            if THead then
                workspace.CurrentCamera.CameraSubject = THead
            elseif Handle then
                workspace.CurrentCamera.CameraSubject = Handle
            elseif THumanoid and TRootPart then
                workspace.CurrentCamera.CameraSubject = THumanoid
            end
            
            if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
            
            local FPos = function(BasePart, Pos, Ang)
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
            
            local SFBasePart = function(BasePart)
                local TimeToWait = 2
                local Time = tick()
                local Angle = 0
                repeat
                    if RootPart and THumanoid then
                        if BasePart.Velocity.Magnitude < 50 then
                            Angle = Angle + 100
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end
                    end
                until Time + TimeToWait < tick() or not FlingActive
            end
            
            workspace.FallenPartsDestroyHeight = 0/0
            
            local BV = Instance.new("BodyVelocity")
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            
            if TRootPart then
                SFBasePart(TRootPart)
            elseif THead then
                SFBasePart(THead)
            elseif Handle then
                SFBasePart(Handle)
            end
            
            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            workspace.CurrentCamera.CameraSubject = Humanoid
            
            if getgenv().OldPos then
                repeat
                    RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                    Humanoid:ChangeState("GettingUp")
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                        end
                    end
                    task.wait()
                until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
                workspace.FallenPartsDestroyHeight = getgenv().FPDH
            end
        end
    end

    StartButton.MouseButton1Click:Connect(function()
        if FlingActive then return end
        local count = 0
        for _ in pairs(SelectedTargets) do count = count + 1 end
        if count == 0 then return end
        
        FlingActive = true
        StatusLabel.Text = "Multi Flinging " .. count .. " target(s)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        task.spawn(function()
            while FlingActive do
                local validTargets = {}
                for name, pTarget in pairs(SelectedTargets) do
                    if pTarget and pTarget.Parent then
                        validTargets[name] = pTarget
                    else
                        SelectedTargets[name] = nil
                        local checkbox = PlayerCheckboxes[name]
                        if checkbox then checkbox.Checkmark.Visible = false end
                    end
                end
                
                for _, pTarget in pairs(validTargets) do
                    if FlingActive then
                        SkidFling(pTarget)
                        task.wait(0.1)
                    else
                        break
                    end
                end
                task.wait(0.5)
            end
        end)
    end)

    StopButton.MouseButton1Click:Connect(function()
        FlingActive = false
        local count = 0
        for _ in pairs(SelectedTargets) do count = count + 1 end
        StatusLabel.Text = count .. " target(s) selected" 
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
    DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if listeningFor then
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    if listeningFor == "wallhack" then wallhackKey = input.KeyCode
                    elseif listeningFor == "aimbot" then aimbotKey = input.KeyCode
                    elseif listeningFor == "godmode" then godmodeKey = input.KeyCode
                    elseif listeningFor == "fly" then flyKey = input.KeyCode
                    elseif listeningFor == "skeleton" then skeletonKey = input.KeyCode
                    elseif listeningFor == "touchfling" then touchFlingKey = input.KeyCode
                    elseif listeningFor == "menu" then menuKey = input.KeyCode
                    end
                end
                listeningFor = nil
                refreshMenuTexts()
                updateStates()
                return
            end
        end

        if UserInputService:GetFocusedTextBox() then return end

        if input.KeyCode == menuKey then
            settingsMenu.Visible = not settingsMenu.Visible
        elseif input.KeyCode == aimbotKey then
            toggleAimbot()
        elseif input.KeyCode == wallhackKey then
            toggleWallhack()
        elseif input.KeyCode == godmodeKey then
            toggleGodmode()
        elseif input.KeyCode == flyKey then
            toggleFly()
        elseif input.KeyCode == skeletonKey then
            toggleSkeleton()
        elseif input.KeyCode == touchFlingKey then
            toggleTouchFling()
        end
    end)

    wallhackBtnLabel.MouseButton1Click:Connect(toggleWallhack)
    aimbotBtnLabel.MouseButton1Click:Connect(toggleAimbot)
    godmodeBtnLabel.MouseButton1Click:Connect(toggleGodmode)
    flyBtnLabel.MouseButton1Click:Connect(toggleFly)

    local function getNearestTarget()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
        
        local myRoot = char.HumanoidRootPart
        local nearest = nil
        local minDist = maxStuds

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local enemyRoot = p.Character:FindFirstChild("HumanoidRootPart")
                local enemyHum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if enemyHum and enemyHum.Health > 0 and enemyRoot then
                    local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                    if dist <= minDist then
                        minDist = dist
                        nearest = enemyRoot
                    end
                end
            end
        end
        return nearest
    end

    RunService.RenderStepped:Connect(function()
        if aimbotEnabled then
            local target = getNearestTarget()
            if target then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
            end
        end

        if flyEnabled and bodyVelocity and bodyGyro then
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            
            bodyVelocity.Velocity = moveDir * flySpeed
            bodyGyro.CFrame = camera.CFrame
        end

        if skeletonEspEnabled and hasDrawing then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local char = p.Character
                    
                    if not skeletonLines[p] then
                        skeletonLines[p] = {}
                        for i = 1, 14 do
                            local line = Drawing.new("Line")
                            line.Visible = false
                            line.Color = Color3.fromRGB(255, 255, 255)
                            line.Thickness = 1.5
                            table.insert(skeletonLines[p], line)
                        end
                    end

                    local lines = skeletonLines[p]
                    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                    local pairsList = {}

                    if isR15 then
                        pairsList = {
                            {"Head", "UpperTorso"},
                            {"UpperTorso", "LowerTorso"},
                            {"UpperTorso", "LeftUpperArm"},
                            {"LeftUpperArm", "LeftLowerArm"},
                            {"LeftLowerArm", "LeftHand"},
                            {"UpperTorso", "RightUpperArm"},
                            {"RightUpperArm", "RightLowerArm"},
                            {"RightLowerArm", "RightHand"},
                            {"LowerTorso", "LeftUpperLeg"},
                            {"LeftUpperLeg", "LeftLowerLeg"},
                            {"LeftLowerLeg", "LeftFoot"},
                            {"LowerTorso", "RightUpperLeg"},
                            {"RightUpperLeg", "RightLowerLeg"},
                            {"RightLowerLeg", "RightFoot"}
                        }
                    else
                        pairsList = {
                            {"Head", "Torso"},
                            {"Torso", "Left Arm"},
                            {"Torso", "Right Arm"},
                            {"Torso", "Left Leg"},
                            {"Torso", "Right Leg"}
                        }
                    end

                    for i, pair in ipairs(pairsList) do
                        local part1 = char:FindFirstChild(pair[1])
                        local part2 = char:FindFirstChild(pair[2])
                        local line = lines[i]

                        if line then
                            if part1 and part2 then
                                local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)
                                local pos2, onScreen2 = camera:WorldToViewportPoint(part2.Position)

                                if onScreen1 or onScreen2 then
                                    line.From = Vector2.new(pos1.X, pos1.Y)
                                    line.To = Vector2.new(pos2.X, pos2.Y)
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    end

                    if not isR15 then
                        for i = 6, #lines do
                            if lines[i] then lines[i].Visible = false end
                        end
                    end
                else
                    removeSkeleton(p)
                end
            end
        else
            for p, _ in pairs(skeletonLines) do
                removeSkeleton(p)
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        RefreshPlayerList()
    end)

    Players.PlayerRemoving:Connect(function(p)
        removeSkeleton(p)
        if SelectedTargets[p.Name] then
            SelectedTargets[p.Name] = nil
        end
        RefreshPlayerList()
    end)

    RunService.Stepped:Connect(function()
        if player.Character then
            if noclipEnabled then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end

            if godmodeEnabled then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanTouch = false end
                end
            end
        end
    end)

    refreshMenuTexts()
    updateStates()
    RefreshPlayerList()
    print("[Script Sense] Успешно загружен с интегрированным Touch Fling на клавишу K!")
end)

if not success then
    warn("[Script Sense Error]: " .. tostring(err))
end
