local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local tableRaceDoor = {}
local texturePlayers = {} -- ตารางเก็บผู้เล่นที่มี Texture เป้าหมาย
local requiredCount = 2 -- จำนวนผู้เล่นที่ต้องการ
local debounceTime = 1.5 -- เวลาสำหรับการกดซ้ำ

-- ฟังก์ชันสำหรับกดปุ่ม T
local lastPressTime = 0
local function pressT()
    local success, err = pcall(function()
        if tick() - lastPressTime >= debounceTime then
            lastPressTime = tick()
            VirtualInputManager:SendKeyEvent(true, "T", false, game)
            task.wait()
            VirtualInputManager:SendKeyEvent(false, "T", false, game)
            task.wait(1.5)
            print("Pressed T because 2 players activated the Texture simultaneously.")

            -- รีเซ็ตสถานะผู้เล่นทั้งหมดหลังจากกด T
            texturePlayers = {}
        end
    end)
    if not success then
        warn("Error pressing T: " .. tostring(err))
    end
end

-- ฟังก์ชันเช็คว่าผู้เล่นอยู่หน้าประตูหรือไม่
local function isPlayerAtDoor(player)
    local success, result = pcall(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local race = player:FindFirstChild("Data") and player.Data:FindFirstChild("Race") and player.Data.Race.Value
            if race then
                local targetName = race .. "Corridor"
                local targetCFrame = tableRaceDoor[targetName]
                if targetCFrame then
                    local distance = (player.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
                    return distance < 10 -- ตรวจสอบระยะห่างจากประตู
                end
            end
        end
        return false
    end)
    if not success then
        warn("Error checking player at door: " .. tostring(result))
    end
    return result or false
end

-- ฟังก์ชันเช็ค Texture เป้าหมาย
local function isValidTexture(descendant)
    local success, result = pcall(function()
        return descendant:IsA("ParticleEmitter") and descendant.Texture == "http://www.roblox.com/asset/?id=7157487174"
    end)
    if not success then
        warn("Error checking valid texture: " .. tostring(result))
    end
    return result or false
end

-- ฟังก์ชันตรวจสอบ DescendantAdded ของผู้เล่น
local function monitorForConditions(player)
    local success = pcall(function()
        local character = player.Character or player.CharacterAdded:Wait()

        character.DescendantAdded:Connect(function(newDescendant)
            if isValidTexture(newDescendant) and isPlayerAtDoor(player) then
                -- เพิ่มผู้เล่นลงใน texturePlayers
                texturePlayers[player.Name] = true
                print(player.Name .. " activated the target Texture!")

                -- ตรวจสอบจำนวนผู้เล่นที่มี Texture
                local validCount = 0
                for _, _ in pairs(texturePlayers) do
                    validCount = validCount + 1
                end

                -- กดปุ่ม T ถ้ามีผู้เล่นครบ 2 คน
                if validCount == requiredCount then
                    pressT()
                end
            end
        end)
    end)
    if not success then
        warn("Error monitoring conditions for player: " .. player.Name)
    end
end

-- ฟังก์ชันตรวจสอบตำแหน่งผู้เล่นแบบเรียลไทม์
local function monitorPlayerPositions()
    task.spawn(function()
        while true do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if isPlayerAtDoor(player) then
                        texturePlayers[player.Name] = true
                        print(player.Name .. " is near the door.")
                    else
                        texturePlayers[player.Name] = nil
                    end
                end
            end

            -- ตรวจสอบจำนวนผู้เล่นที่มี Texture
            local validCount = 0
            for _, _ in pairs(texturePlayers) do
                validCount = validCount + 1
            end

            -- กดปุ่ม T ถ้ามีผู้เล่นครบ 2 คน
            if validCount == requiredCount then
                pressT()
            end

            task.wait(1) -- ตรวจสอบทุก ๆ 1 วินาที
        end
    end)
end

-- ฟังก์ชันสำหรับเริ่มต้นตรวจสอบผู้เล่นทั้งหมด
local function startMonitoring()
    local success = pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                monitorForConditions(player)
            end
        end

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                monitorForConditions(player)
            end)
        end)

        monitorPlayerPositions() -- เริ่มตรวจสอบตำแหน่งผู้เล่น
    end)
    if not success then
        warn("Error starting monitoring.")
    end
end

-- หาตำแหน่งของประตู
local function findDoors()
    local success = pcall(function()
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Model") and string.find(v.Name, "Corridor") and v:FindFirstChild("Door") then
                local door = v.Door:FindFirstChild("Door")
                if door and door:FindFirstChild("RightDoor") and door.RightDoor:FindFirstChild("Union") then
                    tableRaceDoor[v.Name] = door.RightDoor.Union.CFrame
                end
            end
        end
    end)
    if not success then
        warn("Error finding doors.")
    end
end

-- เริ่มต้นการตรวจสอบ
findDoors()
startMonitoring()
