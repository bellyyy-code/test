local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

local hiddenfling = false
local flingThread = nil
local toggleKey = Enum.KeyCode.T -- Можешь изменить клавишу здесь (сейчас это 'T')

local function fling()
    local c, hrp, vel, movel = nil, nil, nil, 0.1

    while hiddenfling do
        RunService.Heartbeat:Wait()
        c = lp.Character
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == toggleKey then
        hiddenfling = not hiddenfling
        print("Touch Fling:", hiddenfling and "ON" or "OFF")

        if hiddenfling then
            flingThread = coroutine.create(fling)
            coroutine.resume(flingThread)
        else
            hiddenfling = false
        end
    end
end)

print("Touch Fling забинжен на клавишу [T]. Нажимай для включения/выключения без всяких GUI.")
