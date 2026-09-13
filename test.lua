local success, err = pcall(function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")

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

    local _, tpMenuLabel = createUIElement(pcContainer, 140, "tp menu", "Button")
    local _, skeletonLabel = createUIElement(pcContainer, 175, "skeleton: off | bind: x", "Button")
    local _, touchFlingLabel = createUIElement(pcContainer, 210, "touchfling: off | bind: k", "Button")

    local menuHintLabel = Instance.new("TextLabel")
    menuHintLabel.Size = UDim2.new(0, 215, 0, 22)
    menuHintLabel.Position = UDim2.new(0, 0, 0, 245)
    menuHintLabel.BackgroundTransparency = 1
    menuHintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    menuHintLabel.TextSize = 13
    menuHintLabel.Font = Enum.Font.Gotham
    menuHintLabel.Text = "open menu - `"
    menuHintLabel.TextXAlignment = Enum.TextXAlignment.Left
    menuHintLabel.Parent = pcContainer

    local _, openFlingMenuPCBtn = createUIElement(pcContainer, 272, "open multi fling menu", "Button")

    -- Teleport Menu UI (Player List)
    local userFrame = Instance.new("ScrollingFrame")
    userFrame.Size = UDim2.new(0, 300, 0, 400)
    userFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    userFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    userFrame.BackgroundTransparency = 0.5
    userFrame.BorderSizePixel = 0
    userFrame.ScrollBarThickness = 10
    userFrame.Visible = false
    userFrame.Parent = screenGui

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = userFrame

    local function populateUsernames()
        for _, child in ipairs(userFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local playerButton = Instance.new("TextButton")
                playerButton.Size = UDim2.new(1, 0, 0, 50)
                playerButton.Text = otherPlayer.Name
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.BackgroundTransparency = 1
                playerButton.BorderSizePixel = 0
                playerButton.Parent = userFrame

                playerButton.MouseButton1Click:Connect(function()
                    if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = otherPlayer.Character.HumanoidRootPart.CFrame
                        end
                    end
                end)
            end
        end
        userFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end

    populateUsernames()

    Players.PlayerAdded:Connect(function()
        task.wait(0.1)
        populateUsernames()
    end)

    Players.PlayerRemoving:Connect(function()
        task.wait(0.1)
        populateUsernames()
    end)

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        userFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    local function toggleTpMenu()
        userFrame.Visible = not userFrame.Visible
        if userFrame.Visible then
            populateUsernames()
        end
    end

    tpMenuLabel.MouseButton1Click:Connect(toggleTpMenu)

    -- Main Fling Frame (Embedded and hidden by default)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.Parent = screenGui

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 6, 0, 0)
    Title.BackgroundTransparency = 1
    Title.RichText = true
    Title.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE MULTI FLING</font>'
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
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Position = UDim2.new(0, 10, 0, 40)
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Select targets to multi fling"
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
    StartButton.Text = "START MULTI FLING"
    StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartButton.Font = Enum.Font.SourceSansBold
    StartButton.TextSize = 16
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

    local SelectAllButton = Instance.new("TextButton")
    SelectAllButton.Position = UDim2.new(0, 10, 0, 330)
    SelectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
    SelectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SelectAllButton.BorderSizePixel = 0
    SelectAllButton.Text = "SELECT ALL"
    SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectAllButton.Font = Enum.Font.SourceSans
    SelectAllButton.TextSize = 14
    SelectAllButton.Parent = MainFrame

    local DeselectAllButton = Instance.new("TextButton")
    DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 330)
    DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
    DeselectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DeselectAllButton.BorderSizePixel = 0
    DeselectAllButton.Text = "DESELECT ALL"
    DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeselectAllButton.Font = Enum.Font.SourceSans
    DeselectAllButton.TextSize = 14
    DeselectAllButton.Parent = MainFrame

    -- Keybinds Settings Menu
    local settingsMenu = Instance.new("Frame")
    settingsMenu.Size = UDim2.new(0, 240, 0, 280)
    settingsMenu.Position = UDim2.new(0.5, -120, 0.5, -140)
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
    local btnMenu = createBindButton(215, "menu key: `", "menu")

    local function refreshMenuTexts()
        btnWallhack.Text = "wallhack: " .. string.lower(wallhackKey.Name)
        btnAimbot.Text = "aimbot: " .. string.lower(aimbotKey.Name)
        btnGodmode.Text = "godmode: " .. string.lower(godmodeKey.Name)
        btnFly.Text = "fly: " .. string.lower(flyKey.Name)
        btnSkeleton.Text = "skeleton: " .. string.lower(skeletonKey.Name)
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
    mobilePanel.Size = UDim2.new(0, 160, 0, 280)
    mobilePanel.Position = UDim2.new(0, 10, 0, 77)
    mobilePanel.BackgroundTransparency = 1
    mobilePanel.Visible = false
    mobilePanel.Parent = screenGui

    local _, wallhackBtnLabel = createUIElement(mobilePanel, 0, "enable wallhack", "Button", 160)
    local _, aimbotBtnLabel = createUIElement(mobilePanel, 35, "enable aimbot", "Button", 160)
    local _, godmodeBtnLabel = createUIElement(mobilePanel, 70, "enable godmode", "Button", 160)
    local _, flyBtnLabel = createUIElement(mobilePanel, 105, "enable fly", "Button", 160)
    local _, tpBtnMobileLabel = createUIElement(mobilePanel, 140, "tp menu", "Button", 160)
    local _, skeletonBtnLabel = createUIElement(mobilePanel, 175, "enable skeleton", "Button", 160)
    local _, touchFlingBtnLabel = createUIElement(mobilePanel, 210, "touchfling: off | bind: k", "Button", 160)

    toggleMenuBtn.MouseButton1Click:Connect(function()
        mobilePanel.Visible = not mobilePanel.Visible
        toggleMenuBtn.Text = mobilePanel.Visible and "close menu" or "menu"
    end)

    tpBtnMobileLabel.MouseButton1Click:Connect(toggleTpMenu)

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

        wallhackLabel.Text = "wallhack: " .. (noclipEnabled and "on" or "off") .. " | bind: " .. wName
        aimbotLabel.Text = "aimbot: " .. (aimbotEnabled and "on" or "off") .. " | bind: " .. aName
        godmodeLabel.Text = "godmode: " .. (godmodeEnabled and "on" or "off") .. " | bind: " .. gName
        flyLabel.Text = "fly: " .. (flyEnabled and "on" or "off") .. " | bind: " .. fName
        skeletonLabel.Text = "skeleton: " .. (skeletonEspEnabled and "on" or "off") .. " | bind: " .. sName
        skeletonBtnLabel.Text = "skeleton: " .. (skeletonEspEnabled and "on" or "off") .. " | bind: " .. sName
        touchFlingLabel.Text = "touchfling: " .. (touchFlingEnabled and "on" or "off") .. " | bind: k"
        touchFlingBtnLabel.Text = "touchfling: " .. (touchFlingEnabled and "on" or "off") .. " | bind: k"
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

    local function toggleTouchFling() touchFlingEnabled = not touchFlingEnabled updateStates() end

    skeletonLabel.MouseButton1Click:Connect(toggleSkeleton)
    skeletonBtnLabel.MouseButton1Click:Connect(toggleSkeleton)
    touchFlingLabel.MouseButton1Click:Connect(toggleTouchFling)
    touchFlingBtnLabel.MouseButton1Click:Connect(toggleTouchFling)

    -- Player List Logic for Fling
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
                PlayerEntry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                PlayerEntry.BorderSizePixel = 0
                PlayerEntry.Parent = PlayerScrollFrame
                
                local Checkbox = Instance.new("TextButton")
                Checkbox.Size = UDim2.new(0, 24, 0, 24)
                Checkbox.Position = UDim2.new(0, 3, 0.5, -12)
                Checkbox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
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
                NameLabel.TextSize = 16
                NameLabel.Font = Enum.Font.SourceSans
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

    SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
    DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)

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
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                        else
                            Angle = Angle + 100
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                            task.wait()
                        end
                    else
                        break
                    end
                until BasePart.Velocity.Magnitude > 500 or not TargetPlayer.Parent or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") or tick() > Time + TimeToWait
            end
            
            workspace.FallenPartsDestroyHeight = 0/0
            
            local BV = Instance.new("BodyVelocity")
            BV.Name = "FlingVelocity"
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
            BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            task.spawn(function()
                while FlingActive and Character and Humanoid and RootPart and RootPart.Parent do
                    local TargetPart = TRootPart or THead or Handle
                    if TargetPart then
                        SFBasePart(TargetPart)
                    end
                    task.wait()
                end
            end)
            
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
            if BV then BV:Destroy() end
            if getgenv().OldPos then
                RootPart.CFrame = getgenv().OldPos
            end
            workspace.CurrentCamera.CameraSubject = Humanoid
        end
    end

    StartButton.MouseButton1Click:Connect(function()
        if FlingActive then return end
        FlingActive = true
        local count = 0
        for _ in pairs(SelectedTargets) do count = count + 1 end
        StatusLabel.Text = "Multi Flinging " .. count .. " target(s)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        task.spawn(function()
            while FlingActive do
                for _, targetPlayer in pairs(SelectedTargets) do
                    if not FlingActive then break end
                    if targetPlayer and targetPlayer.Parent then
                        SkidFling(targetPlayer)
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

    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if MainFrame.Visible then
            RefreshPlayerList()
        end
    end)

    -- Fly Loop
    RunService.RenderStepped:Connect(function()
        if flyEnabled then
            local char = player.Character
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if rootPart and humanoid then
                    local moveDir = humanoid.MoveDirection
                    local camCFrame = camera.CFrame
                    local velocity = Vector3.new(0, 0, 0)

                    if moveDir.Magnitude > 0 then
                        velocity = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit * flySpeed
                        if moveDir.Z < 0 then
                            velocity = -velocity
                        end
                    end

                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        velocity = velocity + Vector3.new(0, flySpeed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        velocity = velocity + Vector3.new(0, -flySpeed, 0)
                    end

                    if bodyVelocity then
                        bodyVelocity.Velocity = velocity
                    end
                    if bodyGyro then
                        bodyGyro.CFrame = camCFrame
                    end
                end
            end
        end
    end)

    -- Input Binds Handler
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listeningFor then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    if listeningFor == "wallhack" then wallhackKey = input.KeyCode
                    elseif listeningFor == "aimbot" then aimbotKey = input.KeyCode
                    elseif listeningFor == "godmode" then godmodeKey = input.KeyCode
                    elseif listeningFor == "fly" then flyKey = input.KeyCode
                    elseif listeningFor == "skeleton" then skeletonKey = input.KeyCode
                    elseif listeningFor == "menu" then menuKey = input.KeyCode end
                end
                listeningFor = nil
                refreshMenuTexts()
                updateStates()
            end
            return
        end

        if gameProcessed then return end

        if input.KeyCode == wallhackKey then toggleWallhack()
        elseif input.KeyCode == aimbotKey then toggleAimbot()
        elseif input.KeyCode == godmodeKey then toggleGodmode()
        elseif input.KeyCode == flyKey then toggleFly()
        elseif input.KeyCode == skeletonKey then toggleSkeleton()
        elseif input.KeyCode == menuKey then
            settingsMenu.Visible = not settingsMenu.Visible
            if settingsMenu.Visible then refreshMenuTexts() end
        end
    end)

    updateStates()
end)

if not success then
    warn("Script Error: " .. tostring(err))
end
